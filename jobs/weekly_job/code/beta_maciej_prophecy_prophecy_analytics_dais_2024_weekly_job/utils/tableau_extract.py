from dataclasses import dataclass
from typing import List, Optional
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.providers.databricks.hooks.databricks import DatabricksHook
from databricks import sql
from airflow.hooks.base import BaseHook
import pandas as pd
import pantab
import tableauserverclient as TSC
import yaml
from dataclasses import dataclass
from typing import Optional, List, Dict


def get_table_name(catalog, database, table):
    if database and catalog:
        return f"{catalog}.{database}.{table}"
    elif database:
        return f"{database}.{table}"
    else:
        return table

def get_info(_source_type, warehouse_conn_id, table_name, database_name, catalog_name):
    table = table_name if _source_type == "SNOWFLAKE" else get_table_name(catalog_name, database_name, table_name)
    hook = SnowflakeHook(warehouse_conn_id) if _source_type == "SNOWFLAKE" else DatabricksHook(warehouse_conn_id)

    return hook, table

def get_databricks_sql_conn(profile_dir, dbt_profile):

    def read_yaml_content():
        file_path = f"{profile_dir}/profiles.yml"

        with open(file_path, 'r') as file:
            data = yaml.safe_load(file)
            target = data[dbt_profile]['target']
            db_creds = data[dbt_profile]['outputs'][target]

            return (db_creds['host'], db_creds['http_path'], db_creds['token'])

    db_creds = read_yaml_content()

    return sql.connect(server_hostname = db_creds[0], http_path = db_creds[1], access_token = db_creds[2])

def export_tableau_hyperfile(
        source_type,
        hyper_path,
        hyper_name,
        tableau_conn_id,
        project_name,
        warehouse_conn_id,
        table_name,
        database_name,
        catalog_name,
        profile_dir,
        dbt_profile
):
    hook, table = get_info(source_type, warehouse_conn_id, table_name, database_name, catalog_name)
    sql_query = f"SELECT * FROM {table}"
    # Fetch data from Snowflake into a pandas DataFrame
    # tableau
    connection = hook.get_conn() if source_type == "SNOWFLAKE" else get_databricks_sql_conn(profile_dir, dbt_profile)
    cursor = connection.cursor()

    try:
        # Execute the query
        cursor.execute(sql_query)
        results = cursor.fetchall()

        if results:
            df = pd.DataFrame(results, columns = [col[0] for col in cursor.description])
            print(f"Data fetched successfully from {source_type}.")
            # Specify the path for the Hyper file
            pantab.frame_to_hyper(df, hyper_path, table = hyper_name)
            print(f"Data written to Hyper file successfully at {hyper_path}.")
        else:
            print("Query returned no data.")
    except Exception as e:
        print(f"An error occurred while fetching data: {e}")
        raise 

    # Get Tableau details from Airflow connection
    tableau_conn = BaseHook.get_connection(tableau_conn_id)
    # Tableau authentication ( using Username/Password )
    # tableau_auth = TSC.TableauAuth(tableau_conn.login, tableau_conn.password,
    #                                site_id=tableau_conn.extra_dejson.get('site_id'))
    # Using Personal Access Token
    tableau_auth = TSC.PersonalAccessTokenAuth(
        tableau_conn.extra_dejson.get('token_name'),
        tableau_conn.extra_dejson.get('personal_access_token'),
        site_id = tableau_conn.extra_dejson.get('site_id')
    )
    server = TSC.Server(tableau_conn.host, use_server_version = True)

    with server.auth.sign_in(tableau_auth):
        all_projects = TSC.Pager(server.projects.get)
        project = [project for project in all_projects if project.name == project_name][0]
        print("Writing into project: " + str(project.name))
        # Publish Hyper file to Tableau Server
        new_datasource_item = TSC.DatasourceItem(project.id)
        datasource = server.datasources.publish(new_datasource_item, hyper_path, 'Overwrite')
        print("Datasource published. ID: ", datasource.id)
