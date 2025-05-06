-- The Netflix Project--
DROP TABLE IF EXISTS Netflix;
CREATE TABLE Netflix(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR (208),
casts VARCHAR(100000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

select * from Netflix;

-- 15 business problems--
--1. Count the number of Movies vs TV Shows--

SELECT type, count(*) from Netflix
group by type;

-- 2. Find the most common rating for movies and TV shows--
select type, rating from 
	(select type, rating, count(*)
	,rank() over(partition by type order by count(*) DESC) as ranking
	
	from Netflix
	group by 1, 2
	)
where ranking =1;
--3. List all movies released in a specific year (e.g., 2020)--
SELECT * from Netflix 
where type = 'Movie'
AND
release_year = 2020;
--4. Find the top 5 countries with the most content on Netflix--
select  Unnest(string_to_array(country, ',')) as new_country
,count(show_id) as total_content
from Netflix
group by country
order by 2 desc
LIMIT 5;

select Unnest(string_to_array(country, ',')) as new_country
from netflix
-- 5. Identify the longest movie--

SELECT * from Netflix
	where type = 'Movie'
	AND duration = (select max(duration) from netflix)

--6. Find content added in the last 5 years--

select *, TO_DATE(date_added, 'Month DD, YYYY')  from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!--
SELECT * from netflix
where director LIKE '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons--	
select * from netflix 
where type = 'TV Show' and 
SPLIT_PART(duration, ' ', 1)::numeric > 5 ;

--9. Count the number of content items in each genre--
select Unnest(STRING_TO_ARRAY(listed_in, ',')) as genre, count(show_id) as total_content
from netflix
group by 1;

--10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!--
select EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as date, count(*) AS yearly_content_india,
ROUND(COUNT(*)::numeric/(select count(*) from netflix where country='India')::numeric*100, 2) as avg_yearly_content_india
FROM netflix
where country = 'India'
GROUP BY 1
LIMIT 5;
--11. List all movies that are documentaries--
SELECT * from netflix
where type='Movie'
AND listed_in ILIKE '%Documentaries%'
--12. Find all content without a director--
SELECT * FROM Netflix
where director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!--
select * from netflix
where casts ILIKE '%Salman Khan%' 
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.--
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.content as 'Good'. Count how many items fall into each category.--

SELECT count(*),
	CASE
	WHEN description ILIKE '%kill%'
	OR
	description ILIKE '%violence%' THEN 'bad_content'
	ELSE 'good_content'
	END Category, 
COUNT(2)
FROM Netflix
group by 2


