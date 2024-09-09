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

total_spend_by_account AS (

  {#Calculates total spending per account while capturing the most recent record details.#}
  SELECT 
    account_id,
    SUM(spend) AS TOTAL_SPEND,
    any_value(is_most_recent_record) AS is_most_recent_record,
    any_value(currency_code) AS currency_code,
    any_value(updated_at) AS updated_at
  
  FROM by_account_id_source_relation
  
  GROUP BY account_id

),

total_spend_details AS (

  {#Summarizes total spending details for accounts, including formatted currency representation.#}
  SELECT 
    account_id AS account_id,
    TOTAL_SPEND AS TOTAL_SPEND,
    is_most_recent_record AS is_most_recent_record,
    currency_code AS currency_code,
    updated_at AS updated_at,
    CONCAT(TOTAL_SPEND, ' ', currency_code) AS pretty_spend
  
  FROM total_spend_by_account

),

limit_100 AS (

  SELECT * 
  
  FROM total_spend_details
  
  LIMIT 100

)

SELECT *

FROM limit_100
