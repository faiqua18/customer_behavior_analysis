
--select * from customer limit 20;
-- q1 comparing total revenue male vs female
--ALTER TABLE customer 
--RENAME COLUMN purcahse_amount TO purchase_amount;
select gender, SUM(purchase_amount) as revenue
from customer
group by gender;
--q2 which customers used discount but still spent more than average amount?
select customer_id, purchase_amount from customer
where discount_applied = 'Yes' and purchase_amount>= (Select AVG(purchase_amount)from customer);
--q3 which are top 5 products with highest review rating?
select item_purchased, ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

--q4 compare the average purchase amounts between standard and express shipping
select shipping_type, 
ROUND(AVG(purchase_amount),2) from customer
where shipping_type in ('Standard','Express') group by shipping_type;

--q5 do subscribed customers spend more? compare average spend and total revenue
select subscription_status, 
COUNT(customer_id) as total_customers,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM( purchase_amount),2) as total_revnue
from customer
group by subscription_status
order by total_revnue, avg_spend desc;

--q6 which 5 products have the highest percentage of purchases with discounts applied?
select item_purchased, 
ROUND(
100.0 * SUM(CASE WHEN discount_applied= 'Yes' THEN 1 ELSE 0 END)/ COUNT(*)
,2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

--q7 segment customers into new, returning and loyal
--based on their total numbers of previous purchases,
-- and show the count of each segment
with customer_type as ( -- CTE COMMON TABLE EXP- TEMPORARY TABLE
select customer_id, previous_purchases,
CASE 
WHEN previous_purchases = 1 THEN 'NEW'
WHEN previous_purchases BETWEEN 2 AND 10 THEN 'RETURNING'
ELSE 'LOYAL'
END AS customer_segment
from customer
)

select customer_segment, count(*) as "Number of customers"
from customer_type 
group by customer_segment;

-- What are the 3 top most purchased products within each category?
with item_counts as (
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) DESC) as item_rank
-- window function 
from customer 
group by category, item_purchased
)
select item_rank,category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

--q9 Are customers who are repeat buyerss (more than 5 previous purchases) also likely to subscribe?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

--q10 What is the revenue contribution of each age group?
select age_group ,
SUM(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;