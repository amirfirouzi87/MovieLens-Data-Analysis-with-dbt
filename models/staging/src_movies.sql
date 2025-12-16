WITH raw_movies AS (
SELECT * FROM {{ source('MOVIELENS', 'RAW_MOVIES') }}
)
SELECT 
    movieId AS movie_id,
    title,
    genres
FROM raw_movies