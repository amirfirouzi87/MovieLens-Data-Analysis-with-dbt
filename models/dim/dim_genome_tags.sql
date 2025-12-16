WITH src_genome_tags AS (
SELECT * FROM {{ ref('src_genome_tags') }}
)
select
    tag_id,
    INITCAP(TRIM(tag)) AS tag_name
from src_genome_tags