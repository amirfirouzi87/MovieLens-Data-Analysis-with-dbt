# MovieLens Analytics: dbt & Snowflake Project

## 📊 Project Overview
This project transforms the **MovieLens dataset** into an analytics-ready schema using **dbt (data build tool)** and **Snowflake**. The pipeline cleans raw data, models dimensions and facts, and produces aggregated marts for visualization in **Power BI**.
For this project I used "dbt Projects on Snowflake" feature in Snowflake. I wrote about it, you can read it **[here](https://medium.com/@amirfirouzi87/dbt-core-vs-cloud-vs-native-the-new-snowflake-integration-explained-89660669fb69)** .

## 🏗 Data Architecture & Lineage
The project follows a standard layered architecture:

### 1. Staging Layer (`src_*.sql`)
* **Purpose:** Raw data ingestion and cleaning.
* **Sources:** `RAW_MOVIES`, `RAW_TAGS`, `RAW_GENOME_TAGS`, `RAW_LINKS`, `RAW_RATINGS`, `RAW_GENOME_SCORES`.

### 2. Core Layer (Dimensions & Facts)
This layer handles the heavy lifting of business logic and normalization.

* **`dim_movies`**:
    * **Transformation:** Parses the raw title string (e.g., "Toy Story (1995)") to extract the clean `movie_title` and `release_year` separately.
    * **Arrays:** Converts pipe-separated genres (e.g., "Adventure|Animation") into a Snowflake `ARRAY` type (`genre_array`) for flexible querying.
* **`dim_genome_tags`**:
    * **Standardization:** Standardizes tag names using `INITCAP` and `TRIM` for consistent presentation.
* **`fct_ratings` (Incremental)**:
    * **Optimization:** Configured as an incremental model using the `merge` strategy.
    * **Logic:** Only processes new records where `rating_timestamp` is greater than the last run's maximum timestamp, significantly reducing processing costs on large datasets.
* **`fct_genome_scores`**:
    * **Filters:** Filters out irrelevant tags (`relevance > 0`) and rounds scores to 4 decimal places for efficiency.

### 3. Marts & Reporting Layer
These models are denormalized and ready for BI tools.

* **`dim_movies_with_tags`**:
    * **Wide Table:** Joins `dim_movies`, `fct_genome_scores`, and `dim_genome_tags` into a single view. This allows analysts to filter movies by `relevance_score` and specific `tag_name` without writing complex joins.
* **`movie_analysis` & `movie_analysis_by_year`**:
    * Aggregated metrics (Average Rating, Total Ratings) grouped by movie or release year.
    * Includes filters (e.g., movies with >100 ratings) to ensure statistical relevance.

### 4. Snapshots
* **`tags_snapshots`**: Captures historical changes in user tags (**SCD Type 2**) using `timestamp` strategy, allowing for time-travel analysis of how user sentiment (tags) evolves.

## ⚙️ Key Technical Features

| Feature | Implementation Details |
| :--- | :--- |
| **Incremental Loading** | Implemented in `fct_ratings` to handle high-volume transaction data efficiently. |
| **String Parsing** | `SUBSTR` and `LENGTH` logic in `dim_movies` to separate titles from years. |
| **Semi-Structured Data** | Usage of `SPLIT()` to create arrays for movie genres. |
| **Materialization** | Configured in `dbt_project.yml`: `dim`, `fct`, and `marts` are materialized as tables for query performance. |

## 📈 Power BI Integration
The Marts (specifically movie_analysis and dim_movies_with_tags) are imported into Power BI.

<img width="2800" height="1569" alt="image" src="https://github.com/user-attachments/assets/53bf20f6-e41d-45ea-a07a-2c738af5cd11" />


## 🚀 What I Learned

In this project, I deepened my understanding of **Incremental Strategies** (specifically `append` vs. `merge`) and the critical role of the `unique_key`:

* **Merge + Unique Key:** This is equivalent to **SCD Type 1** (updates existing records, inserts new ones).
* **Append Strategy:** This is used when there is no `unique_key` (or when history preservation isn't needed), effectively acting as a "log" of events.
* **SCD Type 2:** I learned that standard incremental models cannot easily handle history tracking; for this, **dbt Snapshots** are the correct tool.
* **Modern Configuration:** I learned to define snapshots using the modern YAML approach (tags_snapshots.yml) rather than the legacy {% snapshot %} SQL blocks.
