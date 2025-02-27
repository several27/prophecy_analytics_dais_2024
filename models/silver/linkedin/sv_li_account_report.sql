WITH br_li_campaign_history AS (

  SELECT * 
  
  FROM {{ ref('br_li_campaign_history')}}

),

br_li_account_history AS (

  SELECT * 
  
  FROM {{ ref('br_li_account_history')}}

),

br_li_ad_analytics_by_campaign AS (

  SELECT * 
  
  FROM {{ ref('br_li_ad_analytics_by_campaign')}}

),

campaign_analytics_history_join AS (

  {#Combines campaign analytics, campaign history, and account history to provide a comprehensive view of campaign performance.#}
  SELECT 
    in1.campaign_id AS campaign_id,
    in1.source_relation AS source_relation,
    in0.date_day AS date_day,
    in2.account_id AS account_id,
    in2.account_name AS account_name,
    in2.version_tag AS version_tag,
    in2.currency AS currency,
    in2.status AS status,
    in2.type AS type,
    in2.last_modified_time AS last_modified_time,
    in2.created_time AS created_time,
    in0.clicks AS clicks,
    in0.impressions AS impressions,
    in0.cost AS cost
  
  FROM br_li_ad_analytics_by_campaign AS in0
  LEFT JOIN br_li_campaign_history AS in1
     ON in1.campaign_id = in0.campaign_id
  LEFT JOIN br_li_account_history AS in2
     ON in2.account_id = in1.account_id

),

campaign_analytics_summary AS (

  {#Summarizes campaign analytics by account, aggregating clicks, impressions, and cost. The summary includes the most recent record for each account.#}
  SELECT 
    any_value(source_relation) AS source_relation,
    any_value(date_day) AS date_day,
    any_value(account_id) AS account_id_2,
    any_value(account_name) AS account_name,
    any_value(version_tag) AS version_tag,
    any_value(currency) AS currency,
    any_value(status) AS status,
    any_value(type) AS type,
    any_value(last_modified_time) AS last_modified_time,
    any_value(created_time) AS created_time,
    sum(clicks) AS clicks,
    sum(impressions) AS impressions,
    sum(cost) AS cost,
    true AS is_most_recent_record
  
  FROM campaign_analytics_history_join AS in0
  
  GROUP BY account_id

)

SELECT *

FROM campaign_analytics_summary
