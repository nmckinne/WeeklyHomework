--1.	Show all customers whose last names start with T. Order them by first name from A-Z.
SELECT customer_id, first_name, last_name
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name ; 
--This query select the columns showing the customer id, first and last name of each customer from the customer table and then puts them in alpahbetical order by first name. 

--2. Show all rentals returned from 5/28/2005 to 6/1/2005
SELECT *
FROM rental
WHERE rental_date BETWEEN '2005-05-28' AND '2005-06-01'
--This query selects all fields from the rental table and then only selects the information for those films that were rented between May 28 2005 and June 1st 2005.

--3. How would you determine which movies are rented the most?
SELECT rental.inventory_id, COUNT(rental.rental_id) AS rental_count, film.title
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film
ON inventory.film_id = film.film_id
GROUP BY rental.inventory_id, film.title
ORDER BY COUNT(rental.inventory_id) DESC
--This query selects inventory_id and counts the number of rentals for each inventory id. The result is stored in a new column titled rental count. In order to do this, the data must be grouped by inventory id. 
--Finally, the data is ordered by the rental_count in descending order.  This way, you can easily see which movies are rented the most. 


--4. Show how how much each customer spent on movies (for all time) . Order them from least to most.
SELECT customer_id, SUM(amount) as total_spent 
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount)
--This query selects customer_id and sums up the amount spent by each customer based on the customer id.  
--This information is from the payment table.  The data needs to be grouped by customer_id in order to find out the total spent by each customer. 
--The data is then sorted by the total spent from the least to the most using the ORDER BY function. 

--5. Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.
SELECT film_actor.actor_id, COUNT(film_actor.film_id) as number_of_films, actor.last_name as actor_name 
FROM film_actor
JOIN actor
ON film_actor.actor_id = actor.actor_id
GROUP BY film_actor.actor_id, actor.last_name
ORDER BY COUNT(film_actor.film_id) DESC
--This query select the actor id from the films table and joins it to the actor table using the actor_id as the joining column.
--The data is then grouped by actor id and then number of films for each actor is counted using COUNT of the film ids.  The result is stored as number of films.
--The data is then sorted by the number of films per actor in descending order. 

--6. Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. 
--For question 4: Sort (cost=362.06... rows=599 width=34)
                    --Sort Key: (sum(amount))
                         --HashAggregate(cost=326.94... rows=599, width=34)
                            --Group Key: customer_id
                                --Seq Scan on payment (cost=0.00...253.96 rows=14596 width=8)
--For question 4: You do a scan on the payment table, you sort the data based on customer id, and then you aggregate the amount for each grouped data. 

--For question 5: Sort (cost=540.40...554.06 rows=5462 width=17)
                    --Sort Key: (count(film_actor.film_id)) DESC
                        --HashAggregate (cost=146.72...201.34 rows=5462 width=17)
                            --Group Key: film_actor.actor_is, actor.last_name)
                                --Hash Join (cost=6.50...105.76 rows=5462 width=11)
                                     --Hash Cond: (film_actor.actor_id = actor_id)
                                         --Seq Scan on film_actor (cost=0.00...84.62 rows=5462 width=4)
                                             --Hash (cost=4.00...4.00 rows=200 width=11)
                                                 --Seq Scan on actor (cost=0.00...4.00 rows=200 width=11)

--7. What is the average rental rate per genre?
SELECT film_category.category_id, category.name, AVG(film.rental_rate) as avg_rental_rate
FROM film_category
JOIN film ON film_category.film_id = film.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY film_category.category_id, category.name
--This query joins the tables film and category to the table film_category. It then groups the data by category id and category name and finds
--the average of the film rental rate for each category.  

--8. How many films were returned late? Early? On time?
SELECT COUNT(CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date)>film.rental_duration then 1 else null end) as late_return,
       COUNT(CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date)<film.rental_duration then 1 else null end) as early_return,
	   COUNT(CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date)=film.rental_duration then 1 else null end) as on_time_return
FROM film
JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
--This query selects the film table and joins the inventory table to it based on the film id.  It counts the days between the rental date and the return
--date and compares the difference to the rental_duration.  Counts are performed for all films returned late, on time and early. 


--9. What categories are the most rented and what are their total sales?
SELECT film_category.category_id, category.name, SUM(rental.inventory_id) as total_rentals, SUM(payment.amount) AS total_sales 
FROM film_category
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY film_category.category_id, category.name
ORDER BY SUM(rental.inventory_id) DESC
--This query selects the film_category table and joins the inventory, category, rental and payment tables. Data is grouped by category. 
--Total rentals is counted by summing the rental_id for each category group.  Total sales are calculated by summing the payment amount for 
--each category group. 


--10. Create a view for 8 and a view for 9. Be sure to name them appropriately. 
CREATE VIEW return_status AS 
SELECT COUNT(CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date)>film.rental_duration then 1 else null end) as late_return,
       COUNT(CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date)<film.rental_duration then 1 else null end) as early_return,
	   COUNT(CASE WHEN DATE_PART('day',rental.return_date-rental.rental_date)=film.rental_duration then 1 else null end) as on_time_return
FROM film
JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id

CREATE VIEW sales_by_category AS 
SELECT film_category.category_id, category.name, SUM(rental.inventory_id) as total_rentals, SUM(payment.amount) AS total_sales 
FROM film_category
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY film_category.category_id, category.name
ORDER BY SUM(rental.inventory_id) DESC


--Write a query that shows how many films were rented each month. Group them by category and month. 
SELECT category.name, COUNT(CASE WHEN EXTRACT(MONTH from rental_date)=5 then 1 else null end) as rental_month_may,
       COUNT(CASE WHEN EXTRACT(MONTH from rental_date)=6 then 1 else null end) as rental_month_june,
	   COUNT(CASE WHEN EXTRACT(MONTH from rental_date)=7 then 1 else null end) as rental_month_july,
	   COUNT(CASE WHEN EXTRACT(MONTH from rental_date)=8 then 1 else null end) as rental_month_august
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON film_category.film_id = inventory.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY category.category_id