# 🎬 Netflix Movies and TV Shows Data Analysis Project
![Language](https://img.shields.io/badge/Language-SQL-blue)
![Power BI](https://img.shields.io/badge/Visualization-PowerBI-yellow)
![Status](https://img.shields.io/badge/Project-Completed-brightgreen)
![Data](https://img.shields.io/badge/Data-Netflix-red)

> A SQL and Power BI analysis of Netflix content, highlighting genre distributions, audience rating patterns, and global content trends.

---

## 1. Overview

This project analyzes Netflix’s global content catalog using SQL and Power BI to extract key patterns in content types, genres, and geographic distribution. It focuses on understanding production trends, audience targeting strategies, and platform diversity.

The data was cleaned and explored using SQL with advanced queries, covering release timelines, content duration, rating frequency, and keyword indicators. Final results were visualized in Power BI to support content strategy and global market expansion.

---

## 2. Business Objectives

### 2.1. Business Problem

As Netflix scales globally, it faces challenges in balancing content variety, regional demand, and viewer preferences. This analysis turns content metadata into actionable insights that guide platform strategy and market positioning.

> **Key questions** addressed in this analysis:
> - What is the distribution of Movies vs. TV Shows?
> - Which ratings are most common across content types?
> - Which countries contribute the most content to Netflix?
> - How has content changed over the last 5 years?
> - What themes, actors, or directors dominate the catalog?

### 2.2. Business Impact & Insights

- TV Shows are less frequent than Movies, but show increasing additions in recent years. 
- The most common ratings differ between Movies and TV Shows, guiding audience segmentation.  
- The United States contributes the highest volume of content, followed by India and the UK.  
- "Documentaries" and "Comedies" are dominant genres, especially among Movies.  
- Content containing sensitive keywords like “kill” and “violence” was flagged, aiding content moderation. 

---

## 3. Data Sources & Schema

The dataset was downloaded from Kaggle and imported into MySQL for SQL querying. It includes over 8,800 content records, including metadata such as type, genre, director, actors, country, rating, and duration.

### 🔗 Dataset Links

- **Kaggle Source:**  
  [🌐 View on Kaggle](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

- **Google Drive Download:**  
  [📁 View Dataset (Google Drive)](https://drive.google.com/file/d/1_mxh7A1TyIHZ6YOCD4Y5BYAPnjx7ilCL/view?usp=sharing)

### 📝 Table Schema

```sql
CREATE TABLE netflix (
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
````

---
## 4. Methodology & SQL Analysis

This section outlines the complete end-to-end process of cleaning, transforming, and analyzing Netflix metadata using MySQL. Each query block directly addresses a specific business question to uncover actionable content insights.

### 4.1. Data Cleaning

* **Convert string-based `date_added` to DATE format** → Ensures consistency for time-based filtering.

```sql
SELECT *, STR_TO_DATE(date_added, '%M %d, %Y') AS formatted_date
FROM netflix;
```

* **Extract year from `date_added` using `EXTRACT()`** → Enables analysis of content trends over time.

```sql
SELECT EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%M %d, %Y')) AS year
FROM netflix;
```

* **Handle missing directors** → Flags entries missing critical metadata for optional exclusion or separate handling.

```sql
SELECT * FROM netflix
WHERE director IS NULL;
```

* **Standardize `country`, `listed_in`, and `casts` fields** → Converts multi-value string fields into row-wise arrays to support aggregation.

```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS separated_countries
FROM netflix;
```

```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
FROM netflix;
```

```sql
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors
FROM netflix;
```

* **Extract number of seasons from string `duration` using `SUBSTRING_INDEX()`** → Parses numerical duration data for conditional logic (e.g., more than 5 seasons).

```sql
SELECT SUBSTRING_INDEX(duration, ' ', 1) AS seasons
FROM netflix
WHERE type = 'TV Show';
```

> These steps ensured the dataset was structured, clean, and compatible with advanced SQL queries and dashboard visualization.

### 4.2. Exploratory Data Analysis (EDA)

* **Content Distribution by Type** → Counts how many entries are Movies vs. TV Shows.

```sql
SELECT type, COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

* **Most Common Rating per Type** → Identifies the most popular content ratings for each type.

```sql
SELECT type, rating
FROM (
  SELECT type, rating, COUNT(*),
         RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
  FROM netflix
  GROUP BY type, rating
) AS t1
WHERE ranking = 1;
```

* **Movies Released in 2020** → Filters for all movies released in a specified year.

```sql
SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

* **Top 5 Countries by Content Volume** → Identifies where most of Netflix’s content originates.

```sql
SELECT
   UNNEST(STRING_TO_ARRAY(country, ',')) AS separated_countries,
   COUNT(show_id) AS total_content
FROM netflix
GROUP BY separated_countries
ORDER BY total_content DESC
LIMIT 5;
```

* **Longest Movie on the Platform** → Finds the movie with the maximum duration.

```sql
SELECT * FROM netflix
WHERE 
   type = 'Movie'
   AND
   duration = (SELECT MAX(duration) FROM netflix);
```

* **Content Added in the Last 5 Years** → Filters for recently added content.

```sql
SELECT *, STR_TO_DATE(date_added, '%M %d, %Y') AS formatted_date
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURRENT_DATE - INTERVAL 5 YEAR;
```

* **Content by Specific Director ('Rajiv Chilaka')** → Retrieves shows or movies directed by a given name.

```sql
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```

* **TV Shows with More Than 5 Seasons** → Identifies long-running shows.

```sql
SELECT * FROM netflix
WHERE type = 'TV Show' AND SUBSTRING_INDEX(duration, ' ', 1) >= 6;
```

* **Content Count by Genre** → Explores genre popularity.

```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre;
```

* **Average Annual Content from United States** → Evaluates U.S. content contribution over time.

```sql
SELECT
   EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
   COUNT(*) AS yearly_content,
   COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'United States') * 100 AS avg_content_per_year
FROM netflix
WHERE country = 'United States'
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5;
```

* **All Movies Tagged as Documentaries** → Filters movies by theme.

```sql
SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%';
```

* **Content Without a Director** → Surfaces records with missing director data.

```sql
SELECT * FROM netflix
WHERE director IS NULL;
```

* **Salman Khan's Appearances (Past 11 Years)** → Tracks actor-specific content.

```sql
SELECT * FROM netflix
WHERE type = 'Movie'
  AND casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 11;
```

* **Top 10 U.S. Actors by Appearance Count** → Reveals the most-featured U.S.-based actors.

```sql
SELECT 
   UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
   COUNT(*) AS total_content
FROM netflix
WHERE country LIKE '%United States%'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10;
```

* **Flagging Harmful vs. Safe Content** → Categorizes content for ethical tagging and moderation.

```sql
WITH new_table AS (
  SELECT *,
         CASE
         WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad_content'
         ELSE 'Good_content'
         END AS category
  FROM netflix
)
SELECT category, COUNT(*) AS total_content
FROM new_table
GROUP BY category;
```

> Together, these queries supported a comprehensive analysis of Netflix’s catalog and powered the Power BI dashboard for stakeholder reporting.


### 4.3.  Power BI Dashboard Design

- This Power BI dashboard helps uncover global content trends, genre distributions, and audience targeting patterns through interactive filtering and drill-down visualizations.

🔗 [View Full Dashboard on Power BI](https://project.novypro.com/JbmD6y)

### Dashboard Snapshot

![Netflix Power BI Dashboard](https://github.com/annievu22/Netflix_Project/blob/main/Netflix%20Project%20-%20PowerBI%20Snapshot.png)

### Walkthrough of Key Visuals:

* **Content Type Distribution (Pie Chart):**
  Shows the split between Movies and TV Shows.

* **Ratings by Type (Stacked Bar Chart):**
  Illustrates the most common ratings for both Movies and TV Shows.

* **Top 10 Countries (Bar Chart):**
  Highlights countries contributing the most content.

* **Genre Distribution (Multi-Row Card):**
  Summarizes the most popular genres on Netflix.

* **Content Added Over Time (Line Chart):**
  Displays yearly additions, helping track growth trends.

* **Keyword Categorization (Donut Chart):**
  Visualizes how many titles are flagged as “Good” vs “Bad” based on sensitive keywords.

These visuals support strategic decision-making for content sourcing, regional targeting, and catalog health monitoring.

---

## 5. Final Conclusion

This project demonstrates the power of structured SQL analysis and Power BI storytelling in understanding a massive digital content platform like Netflix. By dissecting ratings, genres, countries, and time trends, we generated insights relevant to content curation, platform strategy, and audience engagement.

**Key business insights:**

* Content distribution leans heavily toward Movies, but TV Shows are rising
* Rating trends inform which demographics are being served
* The U.S. dominates content creation, but there's a need for localized variety
* Description-based tagging offers opportunities for smarter filtering and safety monitoring

**Future enhancement:**

* Integrate watch-time or engagement metrics for deeper audience insights
* Add NLP sentiment analysis on description text
* Use clustering to identify under-served niche genres or content gaps

Overall, this project highlights strong SQL capabilities and effective data storytelling using Power BI in a real-world content analytics setting.
