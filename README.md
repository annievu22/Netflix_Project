# 🎬 Netflix Movies and TV Shows Data Analysis Project
![Language](https://img.shields.io/badge/Language-SQL-blue)
![Power BI](https://img.shields.io/badge/Visualization-PowerBI-yellow)
![Status](https://img.shields.io/badge/Project-Completed-brightgreen)
![Data](https://img.shields.io/badge/Data-Netflix-red)

> A Python and Power BI analysis of Netflix content, highlighting genre distributions, audience rating patterns, and global content trends.

---

## 1. Overview

This project explores Netflix's global content library using SQL and Power BI to reveal insights about content types, genres, countries, and production trends. The analysis supports data-driven recommendations for content curation, audience engagement, and catalog expansion.

The dataset was cleaned and analyzed using SQL, covering release years, ratings, directors, durations, and keyword patterns in descriptions. The results were then visualized in Power BI for easier stakeholder interpretation.

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

### 2.2. Goal of the Dashboard

To create a platform-level dashboard that:
- Visualizes content trends across types, genres, and countries
- Tracks new content additions by year
- Helps identify viewer-friendly genres and underrepresented areas
- Flags problematic content through description-based keyword tagging

### 2.3. Business Impact & Insights

- TV Shows are less frequent than Movies but show increasing additions in recent years  
- The most common ratings differ between Movies and TV Shows, guiding audience segmentation  
- The United States contributes the highest volume of content, followed by India and the UK  
- "Documentaries" and "Comedies" are dominant genres, especially among Movies  
- Content containing sensitive keywords like “kill” and “violence” were flagged, aiding content moderation  

---

## 3. Data Sources & Schema

The dataset was downloaded from Kaggle and imported into MySQL for SQL querying. It includes over 8,800 content records, including metadata such as type, genre, director, actors, country, rating, and duration.

### 🔗 Dataset Links

- **Kaggle Source:**  
  Open Netflix title metadata (movies & shows) curated by Shivam Bansal  
  [🌐 View on Kaggle](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

- **Google Drive Download:**  
  [📁 View Dataset (Google Drive)](https://drive.google.com/file/d/1_mxh7A1TyIHZ6YOCD4Y5BYAPnjx7ilCL/view?usp=sharing)

### 3.1. Table Schema

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

## 4. Tech Stack & Methodology

### 4.1. Tech Stack

* **SQL (MySQL Workbench):** Main tool for data wrangling and business question answering using window functions, CTEs, and string manipulation
* **Power BI:** Used to design interactive visuals for content trends, actor frequency, and genre insights

### 4.2. Methodology

**a. Data Cleaning & Preparation:**

* Converted `date_added` to SQL `DATE` format using `STR_TO_DATE()`
* Used `UNNEST(STRING_TO_ARRAY(...))` to split genres and country columns for frequency analysis
* Handled NULL values in directors and descriptions

**b. SQL Query Design:**

* Applied aggregation functions to calculate content counts by type, rating, and year
* Used `RANK()` to find top-rated and most frequent attributes
* Extracted durations for TV Shows and flagged those with more than 5 seasons
* Used `LIKE` and `CASE WHEN` logic to categorize content based on keywords like "kill" or "violence"

**c. Keyword-Based Content Tagging:**

* Built logic to categorize content as “Good” or “Bad” based on presence of harmful descriptors
* Applied `CASE` statements inside `WITH` CTE to flag and count such content

**d. Visualization Design:**

* Developed a Power BI dashboard that includes:

  * Pie charts for content type breakdown
  * Bar charts for country and rating distributions
  * Line charts for yearly growth
  * Donut charts for keyword-based content flagging

---

## 5. SQL Data Preparation & Analysis

Here are some of the key queries used in analysis, with explanations:

* **Content Type Distribution:**

```sql
SELECT 
   type,
   COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

→ Shows how many Movies vs. TV Shows are in the catalog.

* **Most Common Rating by Type:**

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

→ Identifies the most frequently used content rating for each content type.

* **Top Countries by Content Volume:**

```sql
SELECT
   UNNEST(STRING_TO_ARRAY(country, ',')) AS separated_countries,
   COUNT(show_id) AS total_content
FROM netflix
GROUP BY separated_countries
ORDER BY total_content DESC
LIMIT 5;
```

→ Explores where most of Netflix’s content originates.

* **Shows with More Than 5 Seasons:**

```sql
SELECT *
FROM netflix
WHERE 
   type = 'TV Show'
   AND
   SUBSTRING_INDEX(duration, ' ', 1) >= 6;
```

→ Filters out long-format shows.

* **Categorizing Content by Keywords:**

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

→ Helps moderation teams identify potentially sensitive or violent content.

---

## 6. Power BI Dashboard

🔗 [View Full Dashboard on GitHub](https://github.com/annievu22/Netflix_Project/blob/main/Netflix%20Project%20-%20PowerBI%20Snapshot.png)

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

## 7. Final Conclusion

This project demonstrates the power of structured SQL analysis and Power BI storytelling in understanding a massive digital content platform like Netflix. By dissecting ratings, genres, countries, and time trends, we generated insights relevant to content curation, platform strategy, and audience engagement.

From a business and policy perspective, the project offers actionable insights such as:

* Content distribution leans heavily toward Movies, but TV Shows are rising
* Rating trends inform which demographics are being served
* The U.S. dominates content creation, but there's a need for localized variety
* Description-based tagging offers opportunities for smarter filtering and safety monitoring

In future iterations, this project could be enhanced by:

* Integrate watch-time or engagement metrics for deeper audience insights
* Add NLP sentiment analysis on description text
* Use clustering to identify under-served niche genres or content gaps

Overall, this project highlights strong SQL capabilities and effective data storytelling using Power BI in a real-world content analytics setting.
