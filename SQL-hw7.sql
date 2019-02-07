USE sakila;

DESCRIBE actor;


-- Display first and last names of actors
SELECT first_name, last_name FROM actor;

-- Display first and last name of each actor in a single column in upper-case letters, column name is "Actor Name"
SELECT concat(first_name, ' ', last_name) AS "Actor Name" FROM actor;

-- Find ID number and name of actor with first name "Joe"
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "JOE";

-- Find all actors whose last name contains letters "GEN"
SELECT * FROM actor WHERE last_name LIKE '%gen%';

-- Find all actors last names contains "LI". Order the rows by last name and first name
SELECT last_name, first_name FROM actor WHERE last_name LIKE '%li%';

-- Using IN display the country_id and country columns of Afghanistan, Bangladesh, and China
DESCRIBE country;
SELECT country_id, country FROM country WHERE (country) IN ('Afghanistan', 'Bangladesh', 'China');

-- Create a column in the table actor named description and use the data type BLOB
-- BLOB is stored off the table with a pointer to it placed in the table itself
-- VARCHAR is stored within the table itself
ALTER TABLE actor ADD COLUMN Description BLOB;
SELECT * FROM actor;

-- Delete description column
ALTER TABLE actor DROP COLUMN Description;

-- List names of actors, and how many actors share the last name
SELECT last_name, count(*) FROM actor GROUP BY last_name;

-- Do same thing, but limit to only instances where the count is at least 2
SELECT last_name, count(*) FROM actor GROUP BY last_name HAVING count(last_name)>1;

-- Write query to fix GROUCHO WILLIAMS to HARPO WILLIAMS
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "GROUCHO";
-- Groucho Williams is id 172
UPDATE actor SET first_name="HARPO" WHERE actor_id = 172;

-- In one query, revert actor name Harpo to Groucho
UPDATE actor SET first_name="GROUCHO" WHERE actor_id = 172; 

-- Which query used to re-create the schema of the address table?
SHOW CREATE TABLE address;
describe address;
explain address;

SELECT 'table_schema' FROM 'information_schema'.'tables' WHERE 'table_name'='address';

-- Use JOIN to display first and last names and address of each staff member. Use the tables staff and address
SELECT address FROM address INNER JOIN staff ON address.address_id = staff.address_id;

SELECT * FROM address;
SELECT * FROM staff;

DROP TABLE staff_address_table;
CREATE TABLE staff_address_table AS SELECT first_name, last_name, address FROM staff INNER JOIN address ON staff.address_id = address.address_id;
SELECT * FROM staff_address_table;

-- Use JOIN to display total amount rung up by each staff member in August 2005. Use tables staff and payment
USE sakila;

SELECT * FROM staff;
SELECT * FROM payment;
-- sum by staff_id between payment dates of 2005-08-01 and 2005-08-31
SELECT first_name, last_name, sum(amount) AS total_amount FROM staff s LEFT JOIN payment p ON p.staff_id = s.staff_id
WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59' GROUP BY p.staff_id;

-- List each film and number of actors listed for that film. Use tables film_actor and film. Use inner join
SELECT * FROM  film_actor;
SELECT * FROM film;

SELECT title, count(actor_id) as actor_count FROM film f INNER JOIN film_actor fa ON fa.film_id = f.film_id GROUP BY fa.film_id;

-- Find number of copies of Hunchback Impossible in the inventory system
SELECT title, count(*) AS count FROM film WHERE title = "Hunchback Impossible";

-- Use tables payment and customer and the JOIN command, list total paid by each customer. List customers alphabetically by last name
SELECT * FROM payment;
SELECT * FROM customer;

SELECT sum(amount) as total_paid, first_name, last_name FROM customer c INNER JOIN payment p ON c.customer_id = p.customer_id GROUP BY c.customer_id ORDER BY last_name ASC;

-- Use subqueries to display the titles of movies starting with letters K and Q, language is English
SELECT * FROM language; -- language id 1 for English
SELECT * FROM film;

USE sakila;

SELECT *, name FROM film f INNER JOIN language l ON f.language_id = l.language_id WHERE (title LIKE 'K%' or title LIKE 'Q%') AND l.language_id = 1;

-- Use subqueries to display all actors in the film Alone Trip
SELECT * FROM actor;
SELECT * FROM film_actor;
SELECT * FROM film; -- film_id for Alone Trip is 17

SELECT a.first_name, a.last_name, fm.title FROM actor a, film fm, film_actor fa WHERE a.actor_id = fa.actor_id AND fa.film_id = fm.film_id AND fm.title LIKE "Alone Trip";

-- Get names and email addresses of all Canadian customers. Use joins to retrieve info
SELECT * FROM customer; -- email, first_name, last_name, customer_id, store_id
SELECT * FROM country; -- country_id for country Canada is 20
SELECT * FROM store; -- store_id, address_id
SELECT * FROM address; -- address_id, city_id, postal_code
SELECT * FROM city; -- city_id, city, country_id
-- store ID from customer to store ID from store
-- address ID from store to address ID from address
-- city ID from address to city ID from city
-- country ID from city to country ID from country
SELECT cu.first_name, cu.last_name, cu.email, co.country
	FROM customer cu
		INNER JOIN store s
			ON cu.store_id = s.store_id
		INNER JOIN address a
			ON a.address_id = s.address_id
		INNER JOIN city cy
			ON cy.city_id = a.city_id
		INNER JOIN country co
			ON cy.country_id = co.country_id
            WHERE co.country LIKE "Canada";

-- Identify all movies categorized as family films
SELECT * FROM film; -- film_id
SELECT * FROM film_category; -- film_id, category_id
SELECT * FROM category; -- category_id=8 for Family

SELECT f.title, c.name FROM film f INNER JOIN film_category fc ON f.film_id = fc.film_id INNER JOIN category c ON c.category_id = fc.category_id WHERE c.name LIKE "Family";

-- Display most frequently rented movies in descending order
SELECT * FROM film; -- film_id, title
SELECT * FROM rental; -- rental_id, rental_date, inventory_id, customer_id, staff_id
SELECT * FROM payment; -- payment_id, customer_id, staff_id, rental_id, amount, payment_date
SELECT * FROM inventory; -- inventory_id, film_id, store_id
-- join from film to inventory on film_id
-- join from inventory to rental on inventory_id
-- join from rental to payment on rental_id
SELECT count(r.customer_id) AS frequency, f.title
FROM film f
	INNER JOIN inventory i
		ON f.film_id = i.film_id
	INNER JOIN rental r
		ON i.inventory_id = r.inventory_id
	INNER JOIN payment p
		ON r.rental_id = p.rental_id
        GROUP BY f.title HAVING frequency > 29
        ORDER BY frequency DESC;

-- Write query to display how much business in dollars each store earned
SELECT * FROM store; -- store_id, address_id, manager_staff_id
SELECT * FROM payment; -- payment_id, customer_id, staff_id, rental_id, amount, payment_date
SELECT * FROM staff; -- staff_id, store_id

SELECT concat('$', format(sum(payment.amount), 2)) AS total_value, store.store_id
FROM store INNER JOIN staff ON store.store_id = staff.store_id
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY store.store_id;	

-- Write query to display each store its store ID, city, and country
SELECT * FROM customer; -- customer_id, store_id, first_name, last_name, email, address_id
SELECT * FROM country; -- country_id, country
SELECT * FROM store; -- store_id, address_id
SELECT * FROM address; -- address_id, address, city_id, postal_code
SELECT * FROM city; -- city_id, city, country_id
-- store to address (address_id), address to city (city_id), city to country (country_id)
SELECT s.store_id, ct.city, co.country
FROM store s
	INNER JOIN address a 
		ON s.address_id = a.address_id
	INNER JOIN city ct
		ON a.city_id = ct.city_id
	INNER JOIN country co
		ON ct.country_id = co.country_id;

-- List top five genres in gross revenue in descending order (use category, film_category, inventory, payment, rental)
SELECT * FROM category; -- category_id, name(Genre)
SELECT * FROM film_category; -- film_id, category_id
SELECT * FROM inventory; -- inventory_id, film_id, store_id
SELECT * FROM payment; -- payment_id, customer_id, staff_id, rental_id, amount
SELECT * FROM rental; -- rental_id, inventory_id, customer_id, staff_id
-- sum amount in payment by category.name in category
-- category to film_category (category_id), film_category to inventory (film_id), inventory to rental (inventory_id), rental to payment (rental_id)
SELECT c.name, concat('$', format(sum(amount),2)) as gross_revenue FROM category c
	INNER JOIN film_category fc
		ON c.category_id = fc.category_id
	INNER JOIN inventory i
		ON fc.film_id = i.film_id
	INNER JOIN rental r
		ON i.inventory_id = r.inventory_id
	INNER JOIN payment p
		ON r.rental_id = p.rental_id
	GROUP BY name ORDER BY gross_revenue DESC LIMIT 5;

-- find easier way to view previous exercise (top five genre revenue)
Create View "Top 5 Gross Revenue Genres" AS
SELECT c.name, concat('$', format(sum(amount),2)) as gross_revenue FROM category c
	INNER JOIN film_category fc
		ON c.category_id = fc.category_id
	INNER JOIN inventory i
		ON fc.film_id = i.film_id
	INNER JOIN rental r
		ON i.inventory_id = r.inventory_id
	INNER JOIN payment p
		ON r.rental_id = p.rental_id
	GROUP BY name ORDER BY gross_revenue DESC LIMIT 5;

-- How would you display the view created above?
SELECT * FROM "Top 5 Gross Revenue Genres";

-- Write query to delete above
DROP VIEW "Top 5 Gross Revenue Genres";