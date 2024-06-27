WITH dt_go_account_history AS (

  SELECT * 
  
  FROM {{ ref('dt_go_account_history')}}

),

dt_go_account_stats AS (

  SELECT * 
  
  FROM {{ ref('dt_go_account_stats')}}

),

by__fivetran_synced AS (

  SELECT 
    dt_go_account_stats._fivetran_id AS _fivetran_id,
    dt_go_account_stats.customer_id AS customer_id,
    dt_go_account_stats.date AS date,
    dt_go_account_stats.active_view_impressions AS active_view_impressions,
    dt_go_account_stats.active_view_measurability AS active_view_measurability,
    dt_go_account_stats.active_view_measurable_cost_micros AS active_view_measurable_cost_micros,
    dt_go_account_stats.active_view_measurable_impressions AS active_view_measurable_impressions,
    dt_go_account_stats.active_view_viewability AS active_view_viewability,
    dt_go_account_stats.ad_network_type AS ad_network_type,
    dt_go_account_stats.clicks AS clicks,
    dt_go_account_stats.conversions AS conversions,
    dt_go_account_stats.conversions_value AS conversions_value,
    dt_go_account_stats.cost_micros AS cost_micros,
    dt_go_account_stats.device AS device,
    dt_go_account_stats.impressions AS impressions,
    dt_go_account_stats.interaction_event_types AS interaction_event_types,
    dt_go_account_stats.interactions AS interactions,
    dt_go_account_stats.view_through_conversions AS view_through_conversions,
    dt_go_account_history.currency_code AS currency_code,
    dt_go_account_history.auto_tagging_enabled AS auto_tagging_enabled,
    dt_go_account_history.manager_customer_id AS manager_customer_id,
    dt_go_account_history.final_url_suffix AS final_url_suffix,
    dt_go_account_history.test_account AS test_account,
    dt_go_account_history.manager AS manager,
    dt_go_account_history._fivetran_synced AS _fivetran_synced,
    dt_go_account_history.tracking_url_template AS tracking_url_template,
    dt_go_account_history.optimization_score AS optimization_score,
    dt_go_account_history.updated_at AS updated_at,
    dt_go_account_history.id AS id,
    dt_go_account_history.pay_per_conversion_eligibility_failure_reasons AS pay_per_conversion_eligibility_failure_reasons,
    dt_go_account_history.descriptive_name AS descriptive_name,
    dt_go_account_history.time_zone AS time_zone,
    dt_go_account_history.hidden AS hidden
  
  FROM dt_go_account_history
  INNER JOIN dt_go_account_stats
     ON dt_go_account_stats.customer_id = dt_go_account_history.id

),

aggregated_data AS (

  {#Aggregates data by customer, calculating total spend, impressions, clicks, and interactions.#}
  SELECT 
    customer_id,
    SUM(cost_micros) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    any_value(DATE) AS date,
    any_value(device) AS device,
    any_value(interactions) AS interactions
  
  FROM by__fivetran_synced
  
  GROUP BY customer_id

),

Reformat_1 AS (

  {#Formats aggregated data for better readability, including customer ID, total spend, total impressions, total clicks, date, device, interactions, and formatted spend.#}
  SELECT 
    customer_id AS customer_id,
    total_spend AS total_spend,
    total_impressions AS total_impressions,
    total_clicks AS total_clicks,
    DATE AS date,
    device AS device,
    interactions AS interactions,
    CONCAT('$', FORMAT_NUMBER(total_spend, 2)) AS formatted_spend
  
  FROM aggregated_data AS in0

)

SELECT *

FROM Reformat_1
