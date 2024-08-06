from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils import *

def analytics():
    from airflow.operators.bash import BashOperator
    from datetime import timedelta
    import os
    import zipfile
    import tempfile

    return BashOperator(
        task_id = "analytics",
        bash_command = " && ".join(
          ["{} && cd $tmpDir/{}".format(
             (
               "set -euxo pipefail && tmpDir=`mktemp -d` && git clone "
               + "{} --branch {} --single-branch $tmpDir".format("", None)
             ),
             ""
           ),            "dbt seed",  "dbt run",  "dbt test"]
        ),
        env = {"DBT_DATABRICKS_INVOCATION_ENV" : "prophecy"},
        append_env = True,
    )
