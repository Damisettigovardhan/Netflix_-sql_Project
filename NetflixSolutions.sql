CREATE TABLE netflix
(
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

select *from netflix;

-- Netflix Data Analysis using SQL
-- 1. Count the number of Movies vs TV Shows

select type, count(*) from netflix
group by 1;


--2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


--3. List all movies released in a specific year (e.g., 2020)

select *from netflix
where type = 'Movie'
and release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

select 
UNNEST(String_to_Array (country, ',')),
count(show_id)
from netflix
group by 1
order by 2 Desc
limit 5;


-- 5. Identify the longest movie

select *from netflix
where type = 'Movie' and 
duration = (select Max(duration) from netflix);



-- 6. Find content added in the last 5 years
select *from netflix 
where TO_Date(date_added, 'Month DD,YYYY') 
>= Current_Date - Interval '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select *from netflix
where director ILIKE '%Rajiv Chilaka%';



-- 8. List all TV shows with more than 5 seasons

select *from netflix 
where type = 'TV Show' and
SPLIT_PART(duration, ' ', 1)::INT > 5;


-- 9. Count the number of content items in each genre

select 
UNNEST(String_to_Array(listed_in, ',')),
count(show_id)
from netflix
group by 1;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;


-- 11. List all movies that are documentaries

select *from netflix
where listed_in ILIKE '%Documentaries%';


-- 12. Find all content without a director

select *from netflix
where director is NULL;



-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *from netflix
where casts ILIKE '%Salman Khan%' and 
release_year > Extract(Year from Current_Date) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
UNNEST(String_to_Array(casts, ',')),
count(*) 
from netflix where Country = 'India'
group by 1
order by 2 Desc
limit 10;



/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'RATED A' and all other 
content as 'RATED U'. Count how many items fall into each category.
*/


SELECT 
category,
TYPE,
 COUNT(*) AS content_count
FROM (
SELECT 
*,
CASE 
WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'RATED A'
ELSE 'RATED U'
END AS category
FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2


