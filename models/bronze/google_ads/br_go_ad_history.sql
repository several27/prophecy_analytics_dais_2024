WITH dt_go_ad_history AS (

  SELECT * 
  
  FROM {{ ref('dt_go_ad_history')}}

),

Reformat_1 AS (

  {#Extracts various components from ad URLs in the dt_go_ad_history table, including source relation, ad group ID, ad ID, updated timestamp, display URL, ad type, ad status, whether it is the most recent record, source final URLs, base URL, URL host, URL path, and UTM parameters.#}
  SELECT 
    CASE
      WHEN type = 'union'
        THEN 'unioning functionality'
      ELSE ''
    END AS source_relation,
    ad_group_id AS ad_group_id,
    id AS ad_id,
    updated_at AS updated_at,
    display_url AS display_url,
    type AS ad_type,
    status AS ad_status,
    CASE
      WHEN updated_at = (
        SELECT MAX(updated_at)
        
        FROM dt_go_ad_history
       )
        THEN TRUE
      ELSE FALSE
    END AS is_most_recent_record,
    SPLIT(final_urls, ',')[0] AS source_final_urls,
    SUBSTRING_INDEX(SUBSTRING_INDEX(final_urls, ',', 1), ' ', -1) AS final_url,
    SUBSTRING_INDEX(SUBSTRING_INDEX(final_urls, '/', 3), '://', -1) AS base_url,
    PARSE_URL(final_urls, 'HOST') AS url_host,
    SUBSTRING_INDEX(SUBSTRING_INDEX(final_urls, '/', -1), '?', 1) AS url_path,
    'source' AS utm_source,
    'source' AS utm_medium,
    REGEXP_EXTRACT(final_urls, '\\?utm_campaign=([^&]+)') AS utm_campaign,
    SUBSTRING(final_urls, INSTR(final_urls, 'utm_content=') + LENGTH('utm_content=')) AS utm_content,
    REGEXP_EXTRACT(final_urls, '\\butm_term=([^&]*)', 1) AS utm_term
  
  FROM dt_go_ad_history

)

SELECT *

FROM Reformat_1
