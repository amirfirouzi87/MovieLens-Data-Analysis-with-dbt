{{
    config(
        materialized='incremental',
        unique_key = ['user_id' , 'movie_id'],
        on_schema_change = 'fail',
        incremental_strategy = 'merge'
    )
}}

WITH src_ratings AS (
SELECT * FROM {{ ref('src_ratings')}}
)
SELECT 
    user_id,
    movie_id,
    rating,
    rating_timestamp
FROM src_ratings
WHERE rating IS NOT null

{% if is_incremental() %}
    AND rating_timestamp > (SELECT MAX(rating_timestamp) FROM {{ this }})
{% endif %}