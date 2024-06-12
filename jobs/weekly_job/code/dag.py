import os
import sys
import pendulum
from datetime import timedelta
import airflow
from airflow import DAG
from airflow.models.param import Param
from airflow.decorators import task
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.tasks import (
    analytics,
    extract_to_tab,
    notify_users,
    wait_for_data
)
PROPHECY_RELEASE_TAG = "__PROJECT_ID_PLACEHOLDER__/__PROJECT_RELEASE_VERSION_PLACEHOLDER__"

with DAG(
    dag_id = "beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job", 
    schedule_interval = None, 
    default_args = {"owner" : "Prophecy", "ignore_first_depends_on_past" : True, "do_xcom_push" : True}, 
    start_date = pendulum.today('UTC'), 
    catchup = False, 
    max_active_runs = 1, 
    tags = []
) as dag:
    wait_for_data_op = wait_for_data()
    analytics_op = analytics()
    extract_to_tab_op = extract_to_tab()
    notify_users_op = notify_users()
    wait_for_data_op >> analytics_op
    analytics_op >> extract_to_tab_op
    extract_to_tab_op >> notify_users_op
