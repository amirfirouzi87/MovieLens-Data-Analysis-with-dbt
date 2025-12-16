WITH src_movies AS (
SELECT * FROM {{ ref('src_movies') }}
)
SELECT
    movie_id,
    TRIM(SUBSTR(title, 1, LENGTH(title) - 7)) AS movie_title,
    TRY_TO_NUMBER(SUBSTR(title, LENGTH(title) - 4, 4)) AS release_year,
    SPLIT(genres,'|') AS genre_array,
    genres
FROM {{ ref('src_movies') }}