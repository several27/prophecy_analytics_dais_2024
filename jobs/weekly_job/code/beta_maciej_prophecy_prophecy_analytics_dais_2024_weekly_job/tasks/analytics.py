from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils import *

def analytics():
    from airflow.operators.bash import BashOperator
    import os
    import zipfile
    import tempfile
    envs = {"DBT_DATABRICKS_INVOCATION_ENV" : "prophecy"}
    dbt_props_cmd = ""

    if "/home/airflow/gcs/data":
        envs = {"DBT_DATABRICKS_INVOCATION_ENV" : "prophecy", "DBT_PROFILES_DIR" : "/home/airflow/gcs/data"}

    if "run_profile_admin":
        dbt_props_cmd = " --profile run_profile_admin"

    return BashOperator(
        task_id = "analytics",
        bash_command = " && ".join(
          ["{} && cd $tmpDir/{}".format(
             (
               "set -euxo pipefail && tmpDir=`mktemp -d` && git clone "
               + "--depth 1 {} --branch {} $tmpDir".format(
                 "https://github.com/several27/prophecy_analytics_dais_2024",
                 "__PROJECT_FULL_RELEASE_TAG_PLACEHOLDER__"
               )
             ),
             ""
           ),            "dbt seed" + dbt_props_cmd,  "dbt run" + dbt_props_cmd,  "dbt test" + dbt_props_cmd]
        ),
        env = envs,
        append_env = True,
    )
