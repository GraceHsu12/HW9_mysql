-- Open sakila database
USE sakila;

-- 1a) display first and last name of each actor in the table actor
SELECT first_name, last_name FROM actor;

-- 1b) display first and last name of each actor in a single column in upper case letters.
-- name the column Actor Name
SELECT CONCAT(first_name, ' ', last_name) AS `Actor Name`
FROM actor;

-- 2a) You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name From actor
WHERE first_name = "Joe";

-- 2b) Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c) Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name DESC;

-- 2d) Using IN, display the country_id and country columns 
-- of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a) You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and 
-- use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b) Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;


-- 4a) List the last names of actors, 
-- as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS actor_count
FROM actor
GROUP BY last_name;


-- 4b) List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, 
COUNT(*) AS actor_count
FROM actor
GROUP BY last_name
HAVING COUNT(*)>1;


-- 4c) The actor HARPO WILLIAMS was accidentally entered 
-- in the actor table as GROUCHO WILLIAMS. Write a query 
-- to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d) Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently 
-- HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a) You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- CREATE TABLE IF NOT EXISTS address(
-- `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
--  `address` varchar(50) NOT NULL,
--  `address2` varchar(50) DEFAULT NULL,
--  `district` varchar(20) NOT NULL,
--  `city_id` smallint(5) unsigned NOT NULL,
--  `postal_code` varchar(10) DEFAULT NULL,
--  `phone` varchar(20) NOT NULL,
--  `location` geometry NOT NULL,
--  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--  PRIMARY KEY (`address_id`),
--  KEY `idx_fk_city_id` (`city_id`),
--  SPATIAL KEY `idx_location` (`location`),
--  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
-- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;


-- 6a) Use JOIN to display the first and last names, as well as the address, 
-- of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-- 6b) Use JOIN to display the total amount rung up by each staff member 
-- in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, sum(payment.amount)
FROM staff
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;


-- 6c) List each film and the number of actors who are listed for that film.
-- Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id)
FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film_actor.film_id;

-- 6d) How many copies of the film Hunchback Impossible 
-- exist in the inventory system?

-- find the film id for "Hunchback Impossible"
SELECT film_id FROM film
WHERE title = "Hunchback Impossible";

-- Perform query with the film id
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id = 439;


-- 6e) Using the tables payment and customer and the JOIN command,
-- list the total paid by each customer. List the customers 
-- alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS `Total Amount Paid`
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;


-- 7a)  The music of Queen and Kris Kristofferson have seen an unlikely
-- resurgence. As an unintended consequence, films starting with the 
-- letters K and Q have also soared in popularity. Use subqueries to
-- display the titles of movies starting with the letters K and Q whose
-- language is English.
SELECT title FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%'
AND language_id = (SELECT language_id FROM language WHERE name = "English");


-- 7b) Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
		SELECT film_id
        FROM film
        WHERE title ="Alone Trip"
    )
);	


-- 7c) You want to run an email marketing campaign in Canada, for which you 
-- will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

-- MAP OUT TABLES FOR JOINS -- 
-- names and email addresses
-- customer(customer_id, store_id, address_id, email, first_name, last_name),
-- store(store_id, address_id)
-- country(country_id), city(country_id, city_id)
-- address(city_id, address_id)

SELECT first_name, last_name, email
FROM country co
JOIN city ci 
ON co.country_id = ci.country_id
JOIN address a
ON ci.city_id = a.city_id
JOIN store s
ON a.address_id = s.address_id
JOIN customer cu
ON s.store_id = cu.store_id
WHERE co.country = "Canada";




-- 7d)  Sales have been lagging among young families, and you wish to
-- target all family movies for a promotion. Identify all movies
-- categorized as family films.

SELECT title AS 'Family Film Movies'
FROM film
WHERE film_id IN (
	SELECT film_id FROM film_category
	WHERE category_id IN (
		SELECT category_id FROM category
		WHERE name = 'Family'
	)
);




-- 7e) Display the most frequently rented movies in descending order.

SELECT rental_duration AS 'Most frequently rented', title AS 'Movies'
FROM film
ORDER BY rental_duration DESC;



-- 7f) Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) AS 'Earnings($)'
FROM store
JOIN customer
ON store.store_id = customer.store_id
JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY store.store_id;



-- 7g) Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store s
JOIN address a 
ON s.address_id = a.address_id
JOIN city c 
ON a.city_id = c.city_id
JOIN country co 
ON c.country_id = co.country_id;


-- 7h) List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category,
-- inventory, payment, and rental.)
SELECT ca.name AS 'Top 5 Genres', SUM(amount) AS 'Gross Revenue'
FROM category ca 
JOIN film_category fc
ON ca.category_id = fc.category_id
JOIN inventory i 
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY ca.name 
ORDER BY SUM(amount) DESC LIMIT 5;




-- 8a) In your new role as an executive, you would like to have an easy
-- way of viewing the Top five genres by gross revenue. Use the solution
-- from the problem above to create a view. If you haven't solved 7h,
-- you can substitute another query to create a view.
CREATE VIEW top_gross_revenue AS 
SELECT ca.name AS 'Top 5 Genres', SUM(amount) AS 'Gross Revenue'
FROM category ca 
JOIN film_category fc
ON ca.category_id = fc.category_id
JOIN inventory i 
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY ca.name 
ORDER BY SUM(amount) DESC LIMIT 5;



-- 8b) How would you display the view that you created in 8a?
SELECT * FROM top_gross_revenue;



-- 8c) You find that you no longer need the view top_five_genres.
-- Write a query to delete it.
DROP VIEW top_gross_revenue;




