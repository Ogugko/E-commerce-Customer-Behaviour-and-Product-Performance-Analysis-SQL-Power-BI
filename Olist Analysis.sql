/****************
DATA EXPLORATION 
*****************/

-- 1. Total Number of Orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- 2. Total Number of Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers; 

-- 3. Customer Deomgraphics: Who are our customers?
-- Where are they located?
SELECT customer_state, COUNT(customer_id) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC
LIMIT 7;

-- 4. Most Popular Product Categories: What are the top product categories with the most orders? 
SELECT DISTINCT(p.product_category_name_english), COUNT(*) AS total_orders
FROM products p
JOIN items i ON p.product_id = i.product_id
GROUP BY p.product_category_name_english
ORDER BY total_orders DESC;
 
-- 5. Average Order Value: What is the average order value by product category?
SELECT p.product_category_name_english, ROUND(AVG(i.price), 2) AS aov_per_category
FROM products p
JOIN items i
ON p.product_id = i.product_id
GROUP BY p.product_category_name_english
ORDER BY aov_per_category DESC;

-- 6. Delivery Times Analysis: 
-- a. What is the average delivery time? 
SELECT ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 0) AS avg_delivery_time
FROM orders 
ORDER BY avg_delivery_time;

-- b. Are there delays in certain regions? 
SELECT customer_city, ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 0) AS avg_delivery_time
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY customer_city
ORDER BY avg_delivery_time DESC;

-- 7. Customer Rentention Analysis: What is the rate of repeat customers?
SELECT COUNT(*) AS total_repeat_customers
FROM
(
SELECT customer_unique_id, COUNT(customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(customer_unique_id) > 1
ORDER BY total_customers
)total_repeat_customers;

-- How does it vary by product category? 
SELECT product_category_name_english, COUNT(DISTINCT customer_id) AS repeat_customers
FROM orders o 
JOIN items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
WHERE order_approved_at IS NOT NULL
GROUP BY product_category_name_english
ORDER BY repeat_customers DESC;

-- 8. Customer Lifetime Value (CLV): What is the average CLV? 
SELECT ROUND(AVG(price), 2) AS avg_total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN items i ON o.order_id = i.order_id
ORDER BY total_spend DESC;

-- 9. Customer Segmentation: Can we segment our customers based on their purchase frequency?
SELECT customer_unique_id AS 'customer id' , COUNT(order_id) AS frequency
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
ORDER BY frequency DESC
LIMIT 20;

-- 10. Customer Order Timing: What times of the day do customers place the most orders?
SELECT 
	CASE 
		WHEN DAYOFWEEK(order_purchase_timestamp) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
	END AS day_type,
    CASE
		WHEN HOUR(order_purchase_timestamp) BETWEEN 0 AND 5 THEN '00:00-05:59'
        WHEN HOUR(order_purchase_timestamp) BETWEEN 6 AND 11 THEN '06:00-11:59'
        WHEN HOUR(order_purchase_timestamp) BETWEEN 12 AND 17 THEN '12:00-17:59'
        WHEN HOUR(order_purchase_timestamp) BETWEEN 18 AND 23 THEN '18:00-23:59'
	END AS hour_range,
    COUNT(*) AS order_count
FROM orders
GROUP BY day_type, hour_range
ORDER BY day_type, hour_range;

-- 11. Seasonal Trends: Are there any seasonal trends or patterns throughout the year?
SELECT MONTH(order_purchase_timestamp) AS month, MONTHNAME(order_purchase_timestamp) AS monthname, ROUND(SUM(price), 2) AS monthly_sales
FROM orders o
JOIN items i ON o.order_id = i.order_id
GROUP BY month, monthname
ORDER BY month, monthname;

-- 12. Total Revenue: What is the total sales revenue?
SELECT ROUND(SUM(i.price), 2) AS _total_revenue
FROM items i
JOIN orders o ON i.order_id = o.order_id
WHERE o.order_approved_at IS NOT NULL;

-- 13. Market Basket Analysis: What products are often bought together? 
SELECT i1.product_id AS product1, i2.product_id AS product2, COUNT(*) AS frequency 
FROM items i1
JOIN items i2 ON i1.order_id = i2.order_id AND i1.order_item_id < i2.order_item_id 
GROUP BY product1, product2
HAVING i1.product_id != i2.product_id 
ORDER BY frequency DESC;





