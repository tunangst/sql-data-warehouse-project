-- change over time
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date) ASC

--accumulative analysis, running total
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_date ASC) AS running_total_sales
FROM (
SELECT
    DATETRUNC(month,order_date) AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
) AS t

-- moving average
SELECT
    order_date,
    avg_price,
    AVG(avg_price) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ASC) AS moving_avg_price
FROM (
SELECT
    DATETRUNC(month,order_date) AS order_date,
    AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
) AS t

-- performance analysis, current vs target
-- analyze the yearly performance of products by comparing their sales to both the average of sales performance of the product and the previous year's sales
WITH yearly_product_sales AS (
SELECT
    YEAR(f.order_date) AS order_year,
    p.product_name,
    SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
    YEAR(f.order_date),
    p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0
        THEN 'Above AVG'
        WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0
        THEN 'Below AVG'
        ELSE 'AVG'
    END AS avg_flag,
    LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS prev_year_sales,
    current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS diff_prev_year,
    CASE
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0
        THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0
        THEN 'Decrease'
        ELSE 'No Change'
    END AS avg_flag
FROM yearly_product_sales
ORDER BY product_name, order_year

-- part to whole analysis
-- which category contribute most to the total sales
WITH category_sales AS (
SELECT
    category,
    SUM(sales_amount) AS partitioned_sales
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
GROUP BY category
)
SELECT
    category,
    partitioned_sales,
    SUM(partitioned_sales) OVER() AS total_sales,
    CONCAT(
        ROUND(
            (CAST(partitioned_sales AS FLOAT) / SUM(partitioned_sales) OVER()
            ) * 100, 2
        ), '%'
    ) AS percentage_of_total
FROM category_sales
ORDER BY partitioned_sales DESC

-- data segmentation
-- segment products into cost ranges and count how many fall into that bucket
WITH product_segments AS (
SELECT
    product_key,
    product_name,
    cost,
    CASE
        WHEN cost < 100
        THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500
        THEN '100-500'
        WHEN cost BETWEEN 500 AND 1000
        THEN '500-1000'
        ELSE 'Above 1000'
    END AS cost_range
FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

-- group customers into 3 segments based on spending behaviour
-- vip: 12+ months of history and spending more than 5,000
-- regular: 12+ months of history and spending less than 5,000
-- new: 12- months
WITH customer_spending AS (
SELECT
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_spent,
    MIN(f.order_date) AS first_order,
    MAX(f.order_date) AS last_order,
    DATEDIFF(MONTH,MIN(f.order_date),MAX(f.order_date)) AS order_span
FROM gold.fact_sales AS f
JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY customer_id, c.first_name, c.last_name
),
rated_customers AS (
SELECT
    first_name,
    last_name,
    CASE
        WHEN total_spent > 5000 AND order_span >= 12
        THEN 'VIP'
        WHEN total_spent <= 5000 AND order_span >= 12
        THEN 'Regular'
        WHEN order_span < 12
        THEN 'New'
        ELSE 'n/a'
    END AS customer_status
FROM customer_spending
)
SELECT
    customer_status,
    COUNT(customer_status) AS count_of_status
FROM rated_customers
GROUP BY customer_status
ORDER BY COUNT(customer_status) DESC
