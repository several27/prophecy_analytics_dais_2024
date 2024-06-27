WITH sv_am_account_report AS (

  SELECT * 
  
  FROM {{ ref('sv_am_account_report')}}

),

cleanup_am AS (

  SELECT 
    source_relation,
    account_id,
    total_clicks AS clicks,
    total_impressions AS impressions,
    total_cost AS cost
  
  FROM sv_am_account_report

),

sv_go_account_report AS (

  SELECT * 
  
  FROM {{ ref('sv_go_account_report')}}

),

cleanup_go AS (

  {#Cleans up and organizes Google Ads account data for analysis.#}
  SELECT 
    'google' AS source_relation,
    customer_id AS account_id,
    total_clicks AS clicks,
    total_impressions AS impressions,
    total_spend AS cost
  
  FROM sv_go_account_report

),

sv_li_account_report AS (

  SELECT * 
  
  FROM {{ ref('sv_li_account_report')}}

),

cleanup_li AS (

  SELECT 
    source_relation,
    account_id,
    clicks,
    impressions,
    cost
  
  FROM sv_li_account_report

),

all_account_reports AS (

  SELECT * 
  
  FROM cleanup_li
  
  UNION ALL
  
  SELECT * 
  
  FROM cleanup_am
  
  UNION ALL
  
  SELECT * 
  
  FROM cleanup_go

)

SELECT *

FROM all_account_reports
