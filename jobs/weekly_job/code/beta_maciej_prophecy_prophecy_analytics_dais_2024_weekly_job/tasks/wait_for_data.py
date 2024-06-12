from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils import *

def wait_for_data():
    from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
    from datetime import timedelta

    return S3KeySensor(
        task_id = "wait_for_data",
        bucket_key = [s.strip() for s in "s3://airflow-guide/configs.csv".split(",") if s.strip()],
        bucket_name = None,
        check_fn = None,
        aws_conn_id = "aws_default",
        wildcard_match = False,
        verify = True,
        timeout = 600,
    )
