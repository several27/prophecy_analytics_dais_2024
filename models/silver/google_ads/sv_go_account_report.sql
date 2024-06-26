WITH google_account_stats_data AS (

  SELECT * 
  
  FROM {{ source('google', 'google_account_stats_data') }}

),

google_account_history_data AS (

  SELECT * 
  
  FROM {{ source('google', 'google_account_history_data') }}

),

by__fivetran_synced AS (

  SELECT 
    google_account_stats_data._fivetran_id AS _fivetran_id,
    google_account_stats_data.customer_id AS customer_id,
    google_account_stats_data.date AS date,
    google_account_stats_data.active_view_impressions AS active_view_impressions,
    google_account_stats_data.active_view_measurability AS active_view_measurability,
    google_account_stats_data.active_view_measurable_cost_micros AS active_view_measurable_cost_micros,
    google_account_stats_data.active_view_measurable_impressions AS active_view_measurable_impressions,
    google_account_stats_data.active_view_viewability AS active_view_viewability,
    google_account_stats_data.ad_network_type AS ad_network_type,
    google_account_stats_data.clicks AS clicks,
    google_account_stats_data.conversions AS conversions,
    google_account_stats_data.conversions_value AS conversions_value,
    google_account_stats_data.cost_micros AS cost_micros,
    google_account_stats_data.device AS device,
    google_account_stats_data.impressions AS impressions,
    google_account_stats_data.interaction_event_types AS interaction_event_types,
    google_account_stats_data.interactions AS interactions,
    google_account_stats_data.view_through_conversions AS view_through_conversions,
    google_account_history_data.final_url_suffix AS final_url_suffix,
    google_account_history_data.manager AS manager,
    google_account_history_data.descriptive_name AS descriptive_name,
    google_account_history_data.test_account AS test_account,
    google_account_history_data.tracking_url_template AS tracking_url_template,
    google_account_history_data.time_zone AS time_zone,
    google_account_history_data.manager_customer_id AS manager_customer_id,
    google_account_history_data.currency_code AS currency_code,
    google_account_history_data.optimization_score AS optimization_score,
    google_account_history_data._fivetran_synced AS _fivetran_synced,
    google_account_history_data.auto_tagging_enabled AS auto_tagging_enabled,
    google_account_history_data.updated_at AS updated_at,
    google_account_history_data.pay_per_conversion_eligibility_failure_reasons AS pay_per_conversion_eligibility_failure_reasons,
    google_account_history_data.hidden AS hidden,
    google_account_history_data.id AS id
  
  FROM google_account_history_data
  INNER JOIN google_account_stats_data
     ON google_account_history_data._fivetran_synced = google_account_stats_data._fivetran_synced

),

cost_impressions_ratio AS (

  {#Calculates the cost-to-impressions ratio and formats the spend in dollars for each customer.#}
  SELECT 
    customer_id AS CUSTOMER_ID,
    cost_micros,
    impressions,
    CAST(cost_micros AS FLOAT) / 1000000 AS FEXPR3,
    CONCAT('$', FORMAT_NUMBER(CAST(cost_micros AS FLOAT) / 1000000, 2)) AS formatted_spend
  
  FROM by__fivetran_synced

),

total_cost_impressions_spend_by_customer AS (

  SELECT 
    CUSTOMER_ID,
    SUM(cost_micros) AS TOTAL_COST_MICROS,
    SUM(impressions) AS TOTAL_IMPRESSIONS,
    SUM(FEXPR3) AS TOTAL_SPEND
  
  FROM cost_impressions_ratio
  
  GROUP BY CUSTOMER_ID

)

SELECT *

FROM total_cost_impressions_spend_by_customer
