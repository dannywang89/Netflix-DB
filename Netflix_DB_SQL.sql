-- Netflix Project

select * 
from netflix_titles;

select count(*)
from netflix_titles;

select distinct(type)
from netflix_titles;

-- 15 Business Problems

-- 1. Count number of movies vs TV shows
Select type, count(*) as total_content
from netflix_titles
group by type;

--2. Most common rating for movies and TV shows
with rank_table as(
Select type, rating, count(*) as total_content, rank()over(partition by type order by count(*) desc) as ranking
from netflix_titles
group by type, rating)
select type, rating
from rank_table
where ranking = 1;

--3. List movie count from specific year (e.g. 2020)
select release_year as year, count(*) as movie_count
from netflix_titles
where type = 'Movie' and release_year = 2020
group by release_year;

--4. Find the top 5 countries with the most content on Netflix
--Use trim(value) instead of trim(country) because trim(country) trims entire cell, 
--but we want it to trim the individual content in each cell after it splits
Select top 5 trim(value) as new_country, count(*) as total_content
from netflix_titles
-- need this line to split the content in the cell by using a comma as the delimiter
cross apply string_split(country, ',')
where country is not null
group by trim(value)
order by count(*) desc;

--5. Identify the longest movie
select top 1 type, title, duration
from netflix_titles
where type = 'Movie'
--use this line so SQL changes duration to just the # w/out the 'min' and then changes that '#' str into an int 
-- w/out casting to an int, SQL will read the '#' as a string and stop at first value
--Ex: '90', '120', '150' , as str SQL will see 9 > 1 and stop there and order it as 90, 150, 120 
order by cast(replace(duration, ' min', '') as int) desc;

-- 6. Find content added in the last 5 years
Select * 
from netflix_titles
-- in postgreSQL it would be : where to_date(date_added, 'DD-Month-Year') >= CURRENT_DATE - interval '5 years'
where try_convert(date, date_added) >= DATEADD(year,-5,GETDATE())

-- 7. Find all movies and TV shows directed by 'Rajiv Chilaka'
Select * 
from netflix_titles
where director like '%Rajiv Chilaka%';

-- 8.List all TV shows with more than 5 seasons
Select *
from netflix_titles
where type = 'TV Show' and cast(replace(replace(duration, ' Seasons', ''), ' Season', '') as int) > 5;

-- 9. Count the number of content items in each genre
Select trim(value) as genre, count(*) as genre_count
from netflix_titles
-- need this line to split the content in the cell by using a comma as the delimiter
cross apply string_split(listed_in, ',')
where country is not null
group by trim(value)
order by count(*) desc;
-- 9.5 Now also seperate based on Movie and TV Show
Select type, trim(value) as genre, count(*) as genre_count
from netflix_titles
cross apply string_split(listed_in, ',')
where country is not null
group by type, trim(value)
order by genre, count(*) desc;

-- 10. Find each year and the number of content released by India on Netflix,
Select year(date_added) as Year, count(*)
from netflix_titles
cross apply string_split(country, ',')
where trim(value) = 'India'
group by year(date_added)
order by year(date_added);

-- 11. List all movies that are documentaries 
Select *
from netflix_titles
where type = 'Movie' and listed_in like '%Documentaries%';

-- 12. Find all content without a director
Select *
from netflix_titles
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years
Select *
from netflix_titles
where cast like '%Salman Khan%' and (year(getdate()) - release_year) <= 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India 
Select top 10 trim(value) as cast_member, count(*) movie_appearance
from netflix_titles
cross apply string_split(cast, ',')
where type = 'Movie' and country like '%India%'
group by trim(value)
order by count(*) desc;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
--	   Label content containing these keywords as 'Bad' and all other content as 'Good'..
--     Count how many items fall into each category 
with new_table as (
Select *, 
	case 
	when description like '%kill%' or description like 'violence' then 'Bad Content'
	else 'Good Content'
	end category
from netflix_titles)
Select category, count(*) as number_of_content
from new_table
group by category;