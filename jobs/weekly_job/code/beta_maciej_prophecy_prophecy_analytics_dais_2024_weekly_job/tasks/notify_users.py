from beta_maciej_prophecy_prophecy_analytics_dais_2024_weekly_job.utils import *

def notify_users():
    from airflow.operators.email import EmailOperator
    from datetime import timedelta

    return EmailOperator(
        task_id = "notify_users",
        to = "maciej@prophecy.io",
        subject = "Weekly Job complete",
        html_content = "Weekly job completed successfully on {{ds}} ",
        cc = None,
        bcc = None,
        mime_subtype = "mixed",
        mime_charset = "utf-8",
        conn_id = "email_default",
    )
