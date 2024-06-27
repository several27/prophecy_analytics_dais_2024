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

joined_data AS (

  {#Combines campaign history, profile, and report data to provide a comprehensive view of account performance.#}
  SELECT 
    profile.account_name,
    report.clicks,
    report.impressions,
    report.cost,
    campaign_history.source_relation AS source_relation,
    report.date_day AS date_day,
    profile.account_id AS account_id,
    profile.currency_code AS currency_code
  
  FROM campaign_history
  JOIN profile
     ON campaign_history.profile_id = profile.profile_id
  JOIN report
     ON campaign_history.campaign_id = report.campaign_id

),

sum_cost_clicks_impressions AS (

  SELECT 
    account_id,
    any_value(source_relation) AS source_relation,
    any_value(account_name) AS account_name,
    any_value(currency_code) AS currency_code,
    any_value(date_day) AS date_day,
    SUM(clicks) AS total_clicks,
    SUM(impressions) AS total_impressions,
    SUM(cost) AS total_cost
  
  FROM joined_data
  
  GROUP BY account_id

)

SELECT *

FROM sum_cost_clicks_impressions
