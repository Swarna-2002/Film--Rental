use film_rental;

/*Film - Rental*/

--- Questions:
 
/*1.What is the total revenue generated from all rentals in the database? */
select * from payment;
select sum(amount) as TotalRevenue from payment;
 

/*2.How many rentals were made in each month_name?*/
select * from rental;
select monthname(rental_date) as month,count(*) as number_month from rental group by monthname (rental_date);


/*3.What is the rental rate of the film with the longest title in the database?*/
select * from film;
select title,rental_rate from film where length(title)=(select max(length(title)) from film);


/*4.What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? */
select * from film;
select * from inventory;
select * from rental;
select avg(rental_rate) from film f 
inner join inventory i on i.film_id=f.film_id
inner join rental r on i.inventory_id=r.inventory_id
where datediff(rental_rate,"2005-05-05 22:04:30") <=30;


 

/*5.What is the most popular category of films in terms of the number of rentals?*/
select * from film;
select * from inventory;
select * from rental;
select * from film_category;
select * from category;
select name,count(*) as number_of_rentals from film f
inner join inventory i on i.film_id=f.film_id
inner join rental r on i.inventory_id=r.inventory_id
inner join film_category fc on f.film_id=fc.film_id
inner join category c on fc.category_id=c.category_id
group by name order by number_of_rentals desc limit 1;



/*6.Find the longest movie duration from the list of films that have not been rented by any customer. */
select * from film;
select title,length from film where film_id in (select distinct film_id from film where film_id not in (select distinct film_id from inventory)) order by length desc limit 1;

select * from film where film_id in (select film_id from inventory where inventory_id not in(select inventory_id from rental)) order by length desc limit 1;



/*7.What is the average rental rate for films, broken down by category?*/
select * from rental;
select * from film;
select * from film_category;
select name,avg(rental_rate) from rental join inventory using (inventory_id) join film f using(film_id) join film_category fc on f.film_id=fc.film_id join category c using(category_id) group by name;



/*8.What is the total revenue generated from rentals for each actor in the database?*/
select * from rental;
select * from inventory;
select * from film;
select * from payment;
select * from film_actor;
select * from actor;
select a.actor_id,a.first_name,a.last_name,sum(amount)as total_revenue from rental r
inner join inventory i on i.inventory_id=r.inventory_id
inner join film f on f.film_id=i.film_id
inner join payment p on p.customer_id=r.customer_id
inner join film_actor fa on f.film_id=fa.film_id
inner join actor a on fa.actor_id=a.actor_id
group by a.actor_id order by total_revenue desc;


/*9.Show all the actresses who worked in a film having a "Wrestler" in the description.*/
select * from actor;
select * from film;
select * from film_actor;
select distinct a.* from film f
inner join film_actor fa on f.film_id=fa.film_id
inner join actor a on fa.actor_id=a.actor_id
where description like '%wrestler%'; 


/*10.Which customers have rented the same film more than once? */
select c.customer_id,f.film_id,f.title,count(c.customer_id) as cust_id_count
from customer c join rental r on c.customer_id=r.customer_id
join inventory i on r.inventory_id=i.inventory_id
join film f on i.film_id=f.film_id
group by c.customer_id,f.film_id
having cust_id_count>1;

/*11.How many films in the comedy category have a rental rate higher than the average rental rate?*/
select * from film;
select * from film_category;
select * from category;
select title,rental_rate from film join film_category using(film_id) join category using(category_id)
where name in ('comedy') and rental_rate >(select avg(rental_rate) from film);

select count(*) from film join film_category using(film_id) join category
using(category_id) where name='comedy' and rental_rate>(select avg(rental_rate) from film);


/*12.Which films have been rented the most by customers living in each city? */
select * from customer;
select * from rental;
select * from inventory;
select * from address;
select * from city;
with cte as(select city,title,i.film_id,count(r.rental_id) as rental_num from rental r
inner join inventory i on i.inventory_id=r.inventory_id
inner join film f on f.film_id=i.film_id
inner join customer c on i.store_id=c.store_id
inner join address a on c.address_id=a.address_id
inner join city ci on ci.city_id=a.city_id
group by a.city_id,i.film_id order by count(r.rental_id)desc)
select * from (select city,title,rental_num,rank()over (partition by city order by rental_num desc) as ranking from cte) as cte2 where ranking =1
order by rental_num desc;

select city,title,count(*),rank() over(partition by city order by count(*))from film join inventory using(film_id) join rental using(inventory_id) join customer using(customer_id)
join address using(address_id) join city using(city_id) group by 1,2;



/*13.What is the total amount spent by customers whose rental payments exceed $200? */
select * from payment;
with cte as (select customer_id,sum(amount) as rental_payment from payment
group by customer_id having rental_payment>200)
select sum(rental_payment) as total_amount from cte;


/*14.Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] */
use information_schema;
select table_name,column_name,constraint_name,referenced_table_name,referenced_column_name from key_column_usage
where table_schema='film_rental' and table_name='rental' and referenced_column_name is not null;


/*15.Create a View for the total revenue generated by each staff member, broken down by store city with the country name*/
select distinct staff_id,first_name,last_name,sum(amount)over(partition by staff_id),city,country from payment join staff using(staff_id)join 
address using(address_id) join city using(city_id) join country using(country_id);


/*16.Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,  no_of_rental_days, the amount paid by the customer along with the percentage of customer spending*/
select sum(amount) from rental join inventory using (inventory_id) join film using(film_id)
join customer using (customer_id) join payment using (rental_id);
select sum(amount) from payment;
select c.customer_id,rental_date as visiting_date,first_name as customer_name,title,rental_duration,
amount as paid_amount, amount*100/(select sum(amount) from payment) as pct
from rental join inventory using (inventory_id) join film using(film_id)
join customer c using(customer_id) join payment using(rental_id)
group by c.customer_id;


/*17.Display the customers who paid 50% of their total rental costs within one day.*/
select r.customer_id,concat(c.first_name," ",c.last_name) as customer_name,date(payment_date),
sum(amount)/(select sum(amount) from payment where payment.customer_id=r.customer_id)*100 as percent_spent_singleday from payment p
inner join rental r on r.rental_id=p.rental_id
inner join customer c on c.customer_id=p.customer_id
group by 1,2,3 having percent_spent_singleday >50
order by percent_spent_singleday desc;



