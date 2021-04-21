/*1.	Create a new column called “status” in the rental table 
that uses a case statement to indicate if a film was returned late, 
early, or on time. */

SELECT *, 
	CASE 
		WHEN (DATE_PART('day', r.return_date)-(DATE_PART('day', r.rental_date))) > f.rental_duration THEN 'late'
		WHEN (DATE_PART('day', r.return_date)-(DATE_PART('day', r.rental_date))) < f.rental_duration THEN 'early'
		WHEN (DATE_PART('day', r.return_date)-(DATE_PART('day', r.rental_date))) = f.rental_duration THEN 'on time' 
	END status
FROM rental AS r
INNER JOIN film as f
ON r.inventory_id = f.film_id ;

/* 2.	Show the total payment amounts for people who live in 
Kansas City or Saint Louis. */

SELECT c.first_name, c.last_name, city.city as city_name, SUM(p.amount) as total_payments
FROM payment AS p
LEFT JOIN customer AS c
ON p.customer_id = c.customer_id
LEFT JOIN address AS a
ON c.address_id = a.address_id
LEFT JOIN city 
ON a.city_id = city.city_id
WHERE city = 'Kansas City' OR city = 'Saint Louis'
GROUP BY c.last_name, c.first_name, city ;

/*3. How many film categories are in each category? 
Why do you think there is a table for category and 
a table for film category?*/

SELECT c.name, COUNT (DISTINCT fc.category_id)
FROM film_category as fc
LEFT JOIN category as c
ON fc.category_id = c.category_id
GROUP BY c.name;

/* There is one film category in each category.  But we can also count how 
many films there are per category using the query below. */

SELECT c.name, COUNT (DISTINCT fc.film_id) AS films_per_category
FROM film_category as fc
LEFT JOIN category as c
ON fc.category_id = c.category_id
GROUP BY c.name ;

/* The table for category is specifically for giving a name to each category id.
The table for film_category is to specify the category for each film. There is 
likely two separate tables so that if you add a film, you can give it a category id
and you don't have to type out the whole category name. */

/* 4.	Show a roster for the staff that includes their email, address, 
city, and country (not ids) */

SELECT s.last_name, s.first_name, s.email, a.address, a.address2, c.city, country.country
FROM staff AS s
LEFT JOIN address AS a
ON s.address_id = a.address_id
LEFT JOIN city as c
ON a.city_id = c.city_id
LEFT JOIN country 
ON c.country_id = country.country_id 
ORDER BY s.last_name ;

/*5.	Show the film_id, title, and length for the movies
that were returned from May 15 to 31, 2005 */

SELECT f.film_id, f.title, f.length, return_date
FROM rental as r
LEFT JOIN inventory as i
ON r.inventory_id = i.inventory_id
LEFT JOIN film as f
ON i.film_id = f.film_id
WHERE return_date between '2005-05-15' AND '2005-06-01';

/*6.	Write a subquery to show which movies are rented 
below the average price for all movies. */

SELECT f.film_id, f.title, f.rental_rate
FROM film as f
WHERE
	f.rental_rate < 
	(SELECT AVG(rental_rate) as avg_rental_rate
	FROM film) ;

/* 7.	Write a join statement to show which moves are rented 
below the average price for all movies. */

SELECT f.film_id, f.title, f.rental_rate
FROM film as f
JOIN 
 (SELECT AVG(rental_rate) AS average_rental_rate FROM film) AS avg_rate 
ON f.rental_rate < avg_rate.average_rental_rate
ORDER BY rental_rate DESC

/*8.	Perform an explain plan on 6 and 7, and describe 
what you’re seeing and important ways they differ. 

For question 6, you are using an aggregate function to average
over the rental_column of the film table.  That returns one value
for the average rental rate of all films.  Next, you are comparing 
every films rental rate the to average and only returning those values
that are less than the average rental rate.

For question 7, you are first selecting the average of all the rental
rate values and essentially saving that in memory and then you are joining 
the result of that subquery to your original table but only keeping those
values that have a rental rate less than the average rental rate.*/

/*9.	With a window function, write a query that shows the film, its duration, 
and what percentile the duration fits into. This may help 
https://mode.com/sql-tutorial/sql-window-functions/#rank-and-dense_rank */

SELECT f.title, f.length,
	NTILE(100) OVER
         (ORDER BY f.length)
         AS percentile
FROM film AS f


/* 10.	In under 100 words, explain what the difference is between set-based and procedural programming. 
Be sure to specify which sql and python are.

Procedural programming is done with languages that use a sequence of operations or procedures
to produce the desired results, however, set-based programming processes entire tables or result sets
together instead of doing row by row.  It is therefore more efficient. SQL is typically set-based
because you are performing functions on the entire database, while python is procedural based and 
uses loops and conditional statements to perform tasks. 
*/




