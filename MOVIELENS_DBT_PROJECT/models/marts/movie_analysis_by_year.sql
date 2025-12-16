WITH ratings_summary AS (
    -- 1. Calculate the ratings first
    SELECT
        movie_id,
        AVG(rating) AS average_rating,
        COUNT(*) AS total_ratings
    FROM {{ ref('fct_ratings') }}
    GROUP BY movie_id
    HAVING COUNT(*) > 100
),

movies_with_ratings AS (
    -- 2. Join to movies (Chain this CTE after the first one)
    SELECT
        m.movie_title,
        m.release_year,
        rs.average_rating
    FROM {{ ref('dim_movies') }} m
    JOIN ratings_summary rs
    ON m.movie_id = rs.movie_id
)

-- 3. Final aggregation
SELECT
    release_year,
    AVG(average_rating) AS average_rating_by_year,
    COUNT(*) AS number_of_movies
FROM movies_with_ratings
GROUP BY release_year
HAVING COUNT(*) > 20
ORDER BY average_rating_by_year DESC