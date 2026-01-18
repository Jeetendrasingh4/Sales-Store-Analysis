use project ;
select * from sales ;

-- DATA CLEANING 
-- step 1 : Checking dublicate values
select transaction_id from sales
group by transaction_id having count(transaction_id)>1;
with cte as 
(select transaction_id , row_number() over(partition by transaction_id order by transaction_id) 
as rn from sales )
select * from cte where rn >1;

-- step 2 : Deleting dublicate values
delete from sales where transaction_id = 'TXN240646';
delete from sales where transaction_id ='TXN342128';
delete from sales where transaction_id ='TXN855235';
delete from sales where transaction_id ='TXN981773';
select * from sales ;

-- step 3 : Updating columns
alter table sales
rename column quantiy to Quantity;
alter table sales
rename column prce to price ;

-- step 4 : To check the data type
describe sales;

-- step 5 : To check null values
select count(*) from sales where 
transaction_id is null ;

-- step 6 : Data cleaning for gender and payment mode
select distinct gender
from sales ;
SET SQL_SAFE_UPDATES = 0;
update sales set gender="Female" where gender = 'F';
update sales set gender="Male" where gender = "M";

select distinct payment_mode
from sales ;
update sales set payment_mode='Credit card' where payment_mode='CC';

-- DATA ANALYSIS
-- 1. What are the top 5 most selling product by quantity
SELECT 
    product_name, SUM(quantity) AS Quantity
FROM
    sales
WHERE
    status = 'delivered'
GROUP BY product_name
ORDER BY Quantity DESC
LIMIT 5;

-- 2. Which products are most frequently cancelled ?
SELECT 
    product_name, COUNT(status) AS total_cancelled
FROM
    sales
WHERE
    status = 'cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC
LIMIT 5;

-- 3.What time of the day has the heighest number of purchase ?
SELECT 
    CASE
        WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time_of_purchase) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(time_of_purchase) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'night'
    END AS time_of_day,
    COUNT(*) AS total_purchase
FROM
    sales
GROUP BY time_of_day
ORDER BY total_purchase DESC;
    
-- 4. Who are the top 5 heighest spending customers ?
SELECT 
    customer_name, FORMAT(sum(price * Quantity),'C0') AS total_purchase
FROM
    sales
GROUP BY customer_name
ORDER BY sum(price * Quantity) DESC
LIMIT 5;
    
-- 5. Which product category generate heighest revenue 
SELECT 
    product_category,
    FORMAT(SUM(quantity * price), 'C0') AS Total_revenue
FROM
    sales
GROUP BY product_category
ORDER BY SUM(price * Quantity) DESC;

-- 6. What is the return/cancellation rate per product category ?
SELECT 
    product_category ,
    format(count(case 
          when status in ('cancelled','returned')
          then 1
          end )*100/count(*),2)as return_cancelled_rate
from sales
group by product_category
order by return_cancelled_rate desc;

-- 7. What is the most preferred payment mode ?
select payment_mode,count(payment_mode)as quantity from sales
group by payment_mode
order by quantity desc;

-- 8. How does age group affect purchasing behavior ?
select min(customer_age),max(customer_age) from sales ;

select 
   case
   when customer_age between 18 and 25 then '18-25'
   when customer_age between 26 and 35 then '26-35'
   when customer_age between 36 and 50 then '36-50'
   else '50+'
   end as customer_age ,
   sum(price * quantity) as total_purchase
   from sales
   group by case
   when customer_age between 18 and 25 then '18-25'
   when customer_age between 26 and 35 then '26-35'
   when customer_age between 36 and 50 then '36-50'
   else '50+'
   end
   order by total_purchase desc ;
   
-- 9.what is the monthly sales trend ?
SELECT 
   YEAR(STR_TO_DATE(purchase_date,'%d/%m/%y')) as Years,
   MONTHNAME(STR_TO_DATE(purchase_date, '%d/%m/%Y')) AS months,
   format(SUM(quantity * price),'C0','en-IN') AS total_sales,
   sum(quantity) as total_quantity
FROM sales
GROUP BY MONTHNAME(STR_TO_DATE(purchase_date, '%d/%m/%Y')) 
, YEAR(STR_TO_DATE(purchase_date,'%d/%m/%y')) ;

-- 10. Are certain genders buying more specific product categories .
select gender,product_category,count(product_category) as total_purchase from sales
group by gender ,product_category
order by total_purchase desc;