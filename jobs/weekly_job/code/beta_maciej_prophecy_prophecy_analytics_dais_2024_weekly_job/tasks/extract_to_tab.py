from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils import *
from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils.tableau_extract import *

def extract_to_tab():
    from airflow.operators.python import PythonOperator
    from datetime import timedelta

    return PythonOperator(
        task_id = "extract_to_tab",
        python_callable = export_tableau_hyperfile,
        op_kwargs = {
          "source_type": "DATABRICKS",
          "hyper_path": "some_extract_name.hyper",
          "hyper_name": 'Extract',
          "tableau_conn_id": "tableau_pooja",
          "project_name": "CustomersOrders",
          "warehouse_conn_id": "dev_databricks_admin",
          "table_name": "some_table",
          "database_name": "main",
          "catalog_name": "hive_metastore",
          "profile_dir": None,
          "dbt_profile": None
        },
    )
