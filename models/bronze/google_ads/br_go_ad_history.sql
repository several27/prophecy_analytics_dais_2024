WITH dt_go_ad_history AS (

  SELECT * 
  
  FROM {{ ref('dt_go_ad_history')}}

),

Reformat_1 AS (

  {#Reformats ad data to extract and organize various URL components and ad attributes for better analysis.#}
  SELECT 
    CASE
      WHEN NOT type IS NULL
        THEN type
      ELSE ''
    END AS source_relation,
    ad_group_id AS ad_group_id,
    CAST(id AS STRING) AS ad_id,
    updated_at AS updated_at,
    display_url AS display_url,
    type AS ad_type,
    status AS ad_status,
    CAST(final_urls AS STRING) AS source_final_urls,
    SPLIT(final_urls, ',')[0] AS final_url,
    SUBSTRING_INDEX(final_urls, ',', 1) AS base_url,
    REGEXP_EXTRACT(final_urls, '^(https?://)?([^/]+)', 2) AS url_host,
    final_urls AS url_path,
    SPLIT(final_urls, '?')[1] AS utm_source,
    SUBSTRING_INDEX(final_urls, 'utm_medium=', -1) AS utm_medium,
    REGEXP_EXTRACT(final_urls, 'utm_campaign=([^&]+)', 1) AS utm_campaign,
    SUBSTRING_INDEX(final_urls, 'utm_content=', -1) AS utm_content,
    SUBSTRING_INDEX(final_urls, 'utm_term=', -1) AS utm_term
  
  FROM dt_go_ad_history AS in0

)

SELECT *

FROM Reformat_1
