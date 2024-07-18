WITH campaign_history AS (

  SELECT * 
  
  FROM {{ ref('br_am_campaign_history')}}

),

profile AS (

  SELECT * 
  
  FROM {{ ref('br_am_profile')}}

),

report AS (

  SELECT * 
  
  FROM {{ ref('br_am_campaign_level_report')}}

),

report_history_profile AS (

  {#Combines report data with profile information for historical campaign analysis.#}
  SELECT 
    report.source_relation AS source_relation,
    report.date_day AS date_day,
    profile.account_name AS account_name,
    profile.account_id AS account_id,
    profile.currency_code AS currency_code,
    campaign_history.profile_id AS profile_id,
    report.cost AS cost,
    report.impressions AS impressions,
    report.clicks AS clicks
  
  FROM report
  LEFT JOIN campaign_history
     ON report.campaign_id = campaign_history.campaign_id
  LEFT JOIN profile
     ON campaign_history.profile_id = profile.profile_id

),

sum_cost_clicks_impressions AS (

  SELECT 
    profile_id,
    any_value(source_relation) AS source_relation,
    any_value(account_name) AS account_name,
    any_value(account_id) AS account_id,
    any_value(currency_code) AS currency_code,
    any_value(date_day) AS date_day,
    SUM(cost) AS total_cost,
    SUM(CAST(impressions AS BIGINT)) AS total_impressions,
    SUM(clicks) AS total_clicks
  
  FROM report_history_profile
  
  GROUP BY profile_id

)

SELECT *

FROM sum_cost_clicks_impressions
