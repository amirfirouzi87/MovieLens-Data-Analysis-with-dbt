{{ config(
    materialized = 'table'

)}}
WITH raw_ratings AS (
SELECT * FROM {{ source('MOVIELENS', 'RAW_RATINGS') }}
)
SELECT 
    userId AS user_id,
    movieId AS movie_id,
    rating,
    TO_TIMESTAMP(timestamp) AS rating_timestamp
FROM raw_ratings