WITH br_go_account_history AS (

  SELECT * 
  
  FROM {{ ref('br_go_account_history')}}

),

br_go_account_stats AS (

  SELECT * 
  
  FROM {{ ref('br_go_account_stats')}}

),

by_account_id_source_relation AS (

  SELECT 
    br_go_account_stats.date_day AS date_day,
    br_go_account_stats.ad_network_type AS ad_network_type,
    br_go_account_stats.device AS device,
    br_go_account_stats.clicks AS clicks,
    br_go_account_stats.spend AS spend,
    br_go_account_stats.impressions AS impressions,
    br_go_account_history.currency_code AS currency_code,
    br_go_account_history.updated_at AS updated_at,
    br_go_account_history.account_id AS account_id,
    br_go_account_history.source_relation AS source_relation,
    br_go_account_history.account_name AS account_name,
    br_go_account_history.auto_tagging_enabled AS auto_tagging_enabled,
    br_go_account_history.time_zone AS time_zone,
    br_go_account_history.is_most_recent_record AS is_most_recent_record
  
  FROM br_go_account_history
  INNER JOIN br_go_account_stats
     ON br_go_account_stats.account_id = br_go_account_history.account_id
    AND br_go_account_stats.source_relation = br_go_account_history.source_relation

),

account_performance_summary AS (

  {#Summarizes account performance metrics, including total spend, impressions, and clicks for better campaign analysis.#}
  SELECT 
    account_id,
    SUM(spend) AS TOTAL_SPENT,
    SUM(impressions) AS TOTAL_IMPRESSIONS,
    SUM(clicks) AS TOTAL_CLICKS,
    any_value(date_day) AS date_day,
    any_value(ad_network_type) AS ad_network_type,
    any_value(device) AS device,
    any_value(currency_code) AS currency_code,
    any_value(updated_at) AS updated_at,
    any_value(account_name) AS account_name,
    any_value(auto_tagging_enabled) AS auto_tagging_enabled
  
  FROM by_account_id_source_relation
  
  GROUP BY account_id

),

account_performance_summary_1 AS (

  {#Summarizes account performance metrics, including spending, impressions, and clicks, while providing a formatted view for better financial analysis.#}
  SELECT 
    account_id AS account_id,
    TOTAL_SPENT AS TOTAL_SPENT,
    TOTAL_IMPRESSIONS AS TOTAL_IMPRESSIONS,
    TOTAL_CLICKS AS TOTAL_CLICKS,
    date_day AS date_day,
    ad_network_type AS ad_network_type,
    device AS device,
    currency_code AS currency_code,
    updated_at AS updated_at,
    account_name AS account_name,
    auto_tagging_enabled AS auto_tagging_enabled,
    CONCAT(currency_code, ' ', TOTAL_SPENT) AS formatted_spend
  
  FROM account_performance_summary

),

LIMIT_100 AS (

  SELECT * 
  
  FROM account_performance_summary_1
  
  LIMIT 100

)

SELECT *

FROM LIMIT_100
