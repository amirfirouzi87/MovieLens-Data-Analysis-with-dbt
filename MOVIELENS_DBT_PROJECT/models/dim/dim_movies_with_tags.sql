WITH movies AS (
SELECT * FROM {{ ref('dim_movies') }}
),
tags AS (
SELECT * FROM {{ ref('dim_genome_tags') }}
),
scores AS (
SELECT * FROM {{    ref('fct_genome_scores') }}
)
SELECT
    m.movie_id,
    m.movie_title,
    m.release_year,
    m.genre_array,
    s.relevance_score,
    t.tag_name
FROM movies m
left join scores s
on m.movie_id = s.movie_id
left join tags t
on s.tag_id = t.tag_id