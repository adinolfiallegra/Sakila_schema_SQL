use sakila;

-- 1a. Display the first and last names of all actors from the table actor --
select first_name, last_name
from actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters.
-- Name the column Actor Name --
SELECT CONCAT(first_name, ' ' ,last_name) AS Actor_Name
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." --
select actor_id, first_name, last_name
from actor 
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN --
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name --
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China --
select country_id, country 
from country
where country in ('Afghanistan' , 'Bangladesh' , 'China');

-- 3a. Add a middle_name column to the table actor. 
-- Position it between first_name and last_name  --
alter table actor
add Middle_name varchar(30)
after first_name;


-- 3b Change the data type of the middle_name column to blobs --
Alter Table actor
modify Middle_name Blob;

-- 3c delete the middle_name column--
ALTER TABLE actor
 DROP COLUMN Middle_name;
 
 -- 4a List the last names of actors, as well as how many actors have that last name. --
 SELECT last_name, count(*) as NUM FROM actor
 GROUP BY last_name;
 
 -- 4b List last names of actors and the number of actors who have that last name, 
 -- but only for names that are shared by at least two actors --
SELECT DISTINCT last_name, 
COUNT(*) AS last_name_count
FROM actor
GROUP BY last_name
HAVING COUNT(*) >=2;
 
 -- 4c The actor HARPO WILLIAMS was accidentally entered in the actor table as 
 -- GROUCHO WILLIAMS, fix it--
 UPDATE actor
SET first_name = 'HARPO'
WHERE (first_name ='GROUCHO' AND last_name = 'WILLIAMS');
 
 -- 4d ?? --
 UPDATE actor
SET first_name ='MUCHO GROUCHO'
WHERE (first_name ='GROUCHO' AND last_name ='WILLIAMS');

 -- 5a You cannot locate the schema of the address table. 
 -- Which query would you use to re-create it? --
 SHOW CREATE TABLE address;


-- 6a Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address --
select first_name, last_name, address
from address a 
join staff s on 
a.address_id = s.address_id;

-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment -- 
select p.staff_id, sum(amount)
from payment p 
join staff s on 
p.staff_id = s.staff_id
where payment_date like  '2005-08%'
group by p.staff_id;

select *
from payment;

-- 6c List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join--
select title, count(actor_id)
from film f
inner join film_actor a on 
a.film_id = f.film_id
group by f.title;


-- 6d  How many copies of the film Hunchback Impossible exist in the inventory system?--
select count(i.film_id)
from film f 
join inventory i on 
f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6 Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name --
select last_name, first_name, sum(amount)
from payment p
join customer c on 
p.customer_id = c.customer_id
group by c.customer_id
order by last_name asc;

-- 7a Use subqueries to display the titles of movies starting 
-- with the letters K and Q whose language is English --
select title
from film 
where language_id in 
( select language_id 
from language
where name = 'English') AND
(title LIKE( "Q%") OR title LIKE( "K%"));

-- 7b Use subqueries to display all actors who appear in the film Alone Trip--
SELECT first_name, last_name
 FROM actor
 WHERE actor_id IN
 (
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
   (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
   )
 );
 
 -- 7c  You want to run an email marketing campaign in Canada,
 -- for which you will need the names and email addresses of all Canadian customers--
SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE address_id IN (
SELECT c.address_id
FROM customer c
WHERE c.address_id IN(
SELECT a.address_id
FROM address a
JOIN city ci
USING (city_id)
WHERE a.city_id IN(
SELECT ci.city_id
FROM city ci
JOIN country co 
USING (country_id)
WHERE ci.country_id LIKE (
SELECT co.country_id
FROM country co
WHERE co.country="CANADA"))));
 
 -- 7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
 -- Identify all movies categorized as famiy films-- 
 
 select title
 from film 
 where film_id in 
 ( select film_id 
 from film_category 
 where category_id in 
 ( select category_id
 from category 
 where name = 'Family'
 )
 );
 
 -- 7e Display the most frequently rented movies in descending order.--
-- select f.title, count(r.rental_id)
-- from rental r
-- inner join inventory i on 
-- r.inventory_id = i.inventory_id
-- inner join film f on 
-- f.film_id = i.inventory_id
-- order by count(r.rental_id)
-- desc;
SELECT f.title
FROM film f
JOIN inventory i
USING(film_id)
WHERE i.film_id IN(
SELECT i.film_id
FROM inventory i
JOIN rental r
USING(inventory_id)
WHERE i.inventory_id IN 
(SELECT r.inventory_id
FROM rental r))
GROUP BY inventory_id
ORDER BY COUNT(inventory_id) DESC;

-- 7 f  Write a query to display how much business, in dollars, each store brought in --

SELECT st.store_id, sum(p.amount)
FROM store st ,payment p, staff s
WHERE st.store_id=s.store_id
AND s.staff_id =p.staff_id
GROUP BY p.staff_id;

-- 7g Write a query to display for each store its store ID, city, and country  --
SELECT st.store_id, ci.city, co.country 
FROM store st, city ci, country co, address a 
WHERE st.address_id=a.address_id
AND a.city_id=ci.city_id
AND ci.country_id=co.country_id;

-- 7h List the top five genres in gross revenue in descending order--
SELECT  cat.name, sum(p.amount)
FROM category cat, rental r, payment p, film_category fc, inventory i
WHERE p.rental_id=r.rental_id
AND i.inventory_id=r.inventory_id
AND fc.film_id=i.film_id
AND cat.category_id=fc.category_id
GROUP BY cat.name
ORDER BY sum(p.amount) DESC LIMIT 5;


-- 8a Use the solution from the problem above to create a view.-- 
CREATE VIEW top_five_genres AS
SELECT  cat.name, sum(p.amount)
FROM category cat, rental r, payment p, film_category fc, inventory i
WHERE p.rental_id=r.rental_id
AND i.inventory_id=r.inventory_id
AND fc.film_id=i.film_id
AND cat.category_id=fc.category_id
GROUP BY cat.name
ORDER BY sum(p.amount) DESC LIMIT 5;

-- 8b How would you display the view that you created in 8a--
select * 
from top_five_genres;

-- 8c You find that you no longer need the view top_five_genres. Write a query to delete it --
DROP VIEW top_five_genres;