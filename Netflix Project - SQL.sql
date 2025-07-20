-- 15 Business Problems --

#1. Count the number of TV Shows and Movies
SELECT 
   type,
   COUNT(*) AS total_content
FROM netflix
GROUP BY type;

#2. Find the most common rating for Movies and TV shows
SELECT
   type,
   rating
FROM 
(
SELECT 
   type,
   rating,
   COUNT(*),
   RANK() OVER( PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1,2 
) 
AS t1

WHERE 
   ranking = 1;
   
#3. List all Movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

#4. Find the top 5 countries with the most content on Netflix
SELECT
   UNNEST(STRING_TO_ARRAY(country, ',')) AS separated_countries; ## Separate columns have various countries; UNNEST: tách array strings kia thành từng rows
   COUNT(show_id) AS total_content
FROM netflix
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

#5. Identify the longest movie
SELECT * FROM netflix
WHERE 
   type = 'Movie'
   AND
   duration = (SELECT MAX(duration) FROM netflix);

#6. Find content added in the last 5 years
SELECT 
   *,
   STR_TO_DATE(date_added, '%M %d, %Y') AS formatted_date   
FROM netflix
WHERE 
   STR_TO_DATE(date_added, '%M %d, %Y')  >= CURRENT_DATE - INTERVAL 5 YEAR;
   
#7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

#8. List all TV shows with more than 5 seasons
SELECT 
   *
   ##SUBSTRING_INDEX(duration, ' ', 1) AS duration_number,
   ##SUBSTRING_INDEX(duration, ' ', -1) AS duration_unit
FROM netflix
WHERE 
   type = 'TV Show'
   AND
   SUBSTRING_INDEX(duration, ' ', 1) >= 6;
   
#9. Count the number of content items in each genre
SELECT
   UNNEST(STRING_TO_ARRAY(listed_in, ',') AS genre,
   COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;

#10. Find each year and the average numbers of content release by United States on netflix. Return top 5 year with highest avg content release !
SELECT
   EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
   COUNT(*) AS yearly_content,
   COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'United States') * 100 AS avg_content_per_year
FROM netflix
WHERE country = 'United States'
GROUP BY year;
   
#11. List all movies that are documentaries
SELECT * FROM netflix
WHERE 
   type = 'Movie'
   AND
   listed_in LIKE '%Documentaries%';
   
#12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

#13. Find how many movies actor 'Salman Khan' appeared in last 11 years
SELECT * FROM netflix
WHERE 
   type = 'Movie'
   AND
   casts LIKE '%Salman Khan%'
   AND 
   release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 11;
   
#14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.
SELECT 
   *,
   UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
   COUNT(*) AS total_content
FROM netflix
WHERE country LIKE '%United States%'
GROUP BY 2
ORDER BY 3 DESC
LIMIT 10;

#15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT 
   *,
   CASE
   WHEN 
      description LIKE '%kill%'
      OR
      description LIKE 'violence%'
   THEN 'Bad_content'
   ELSE 'Good_content'
   END category
FROM netflix
)

SELECT 
   category,
   COUNT(*) AS total_content
FROM new_table
GROUP BY 1;








   






