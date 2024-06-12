from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils import *

def extract_to_tab():
    from typing import Optional, List, Dict
    from dataclasses import dataclass, field
    from abc import ABC


    @dataclass(frozen = True)
    class TableauExtractProperties():
        taskId: Optional[str] = None
        source_type: str = "SNOWFLAKE"
        warehouse_conn_id: Optional[str] = None
        databricks_conn_id: Optional[str] = None
        table_name: Optional[str] = None
        database_name: Optional[str] = None
        catalog_name: Optional[str] = None
        use_catalog: bool = False
        tableau_conn_id: Optional[str] = None
        tableau_project_name: Optional[str] = None
        tableau_extract_name: Optional[str] = None

    props = TableauExtractProperties(  #skiptraversal
        taskId = "extract_to_tab", 
        source_type = "DATABRICKS", 
        warehouse_conn_id = "dev_databricks_admin", 
        databricks_conn_id = None, 
        table_name = "some_table", 
        database_name = "main", 
        catalog_name = "hive_metastore", 
        use_catalog = True, 
        tableau_conn_id = "tableau_pooja", 
        tableau_project_name = "CustomersOrders", 
        tableau_extract_name = "some_extract_name"
    )
    settings = {}
    from airflow.operators.python import PythonOperator
    from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
    from airflow.providers.databricks.hooks.databricks import DatabricksHook
    from airflow.hooks.base import BaseHook
    import pandas as pd
    import pantab
    import tableauserverclient as TSC
    tableau_conn_id = props.tableau_conn_id
    project_name = props.tableau_project_name
    hyper_path = f"{props.tableau_extract_name}.hyper"
    hyper_name = 'Extract' # this can be handled internally
    source_type = props.source_type
    # snowflake
    warehouse_conn_id = props.warehouse_conn_id
    table_name = props.table_name
    database_name = props.database_name
    catalog_name = props.catalog_name

    def get_table_name(catalog, database, table):
        if database and catalog:
            return f"{catalog}.{database}.{table}"
        elif database:
            return f"{database}.{table}"
        else:
            return table

    def get_info(_source_type):
        table = table_name if _source_type == "SNOWFLAKE" else get_table_name(catalog_name, database_name, table_name)
        hook = SnowflakeHook(warehouse_conn_id) if _source_type == "SNOWFLAKE" else DatabricksHook(warehouse_conn_id)

        return hook, table

    def get_databricks_sql_conn(_hook):
        _conn = _hook.get_conn()
        from databricks import sql

        return sql.connect(
            server_hostname = _conn.host,
            http_path = _conn.extra_dejson.get('http_path'),
            access_token = _conn.extra_dejson.get('token')
        )

    def export_tableau_hyperfile():
        hook, table = get_info(source_type)
        sql_query = f"SELECT * FROM {table}"
        # Fetch data from Snowflake into a pandas DataFrame
        # tableau
        connection = hook.get_conn() if source_type == "SNOWFLAKE" else get_databricks_sql_conn(hook)
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

    return PythonOperator(task_id = props.taskId, python_callable = export_tableau_hyperfile, **settings)
