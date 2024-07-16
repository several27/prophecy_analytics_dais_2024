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
     ON br_go_account_history.account_id = br_go_account_stats.account_id
    AND br_go_account_history.source_relation = br_go_account_stats.source_relation

),

total_spent_impressions_by_account_id AS (

  SELECT 
    account_id,
    SUM(spend) AS TOTAL_SPENT,
    SUM(impressions) AS TOTAL_IMPRESSIONS
  
  FROM by_account_id_source_relation
  
  GROUP BY account_id

),

limit_100 AS (

  SELECT * 
  
  FROM total_spent_impressions_by_account_id
  
  LIMIT 100

)

SELECT *

FROM limit_100
