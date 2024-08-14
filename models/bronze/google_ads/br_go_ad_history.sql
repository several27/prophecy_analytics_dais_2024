WITH dt_go_ad_history AS (

  SELECT * 
  
  FROM {{ ref('dt_go_ad_history')}}

),

Reformat_1 AS (

  {#Reformats ad history data to extract key attributes and marketing parameters for performance analysis.#}
  SELECT 
    CASE
      WHEN NOT type IS NULL
        THEN type
      ELSE ''
    END AS source_relation,
    CAST(ad_group_id AS STRING) AS ad_group_id,
    CAST(id AS STRING) AS ad_id,
    updated_at AS updated_at,
    display_url AS display_url,
    type AS ad_type,
    status AS ad_status,
    updated_at = (
      SELECT MAX(updated_at)
      
      FROM in0
     ) AS is_most_recent_record,
    ARRAY(final_urls) AS source_final_urls,
    SPLIT(final_urls, ',')[0] AS final_url,
    SUBSTRING_INDEX(final_urls, ',', 1) AS base_url,
    REGEXP_EXTRACT(final_urls, '^(https?://)?([^/]+)', 2) AS url_host,
    SUBSTRING_INDEX(final_urls, '/', -1) AS url_path,
    REGEXP_EXTRACT(final_urls, 'utm_source=([^&]+)', 1) AS utm_source,
    REGEXP_EXTRACT(final_urls, 'utm_medium=([^&]+)', 1) AS utm_medium,
    REGEXP_EXTRACT(final_urls, 'utm_campaign=([^&]+)', 1) AS utm_campaign,
    REGEXP_EXTRACT(final_urls, 'utm_content=([^&]+)', 1) AS utm_content,
    REGEXP_EXTRACT(final_urls, 'utm_term=([^&]+)', 1) AS utm_term
  
  FROM dt_go_ad_history AS in0

)

SELECT *

FROM Reformat_1
