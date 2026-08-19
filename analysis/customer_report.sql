/*
============================================================================
Customer Report
============================================================================
Purpose:
    Consolidate key customer metrics and behaviors

Highlights:
    1. Gather essential fields such as names, ages, transactions details
    2. Segment customers into categories ('VIP','Regular','New') and age groups
    3. Aggregate customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculate valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
============================================================================
*/
CREATE OR ALTER VIEW gold.view_customer_report AS
WITH base_query AS (
    -- Base Query: retrieves core columns from tables
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate,GETDATE()) AS age
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
), customer_aggregation AS (
-- aggregate data
        SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age < 20
        THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29
        THEN '20-29'
        WHEN age BETWEEN 30 AND 39
        THEN '30-39'
        WHEN age BETWEEN 40 AND 49
        THEN '40-49'
        ELSE '50+'
    END AS age_group,
    CASE
        WHEN total_sales > 5000 AND lifespan >= 12
        THEN 'VIP'
        WHEN total_sales <= 5000 AND lifespan >= 12
        THEN 'Regular'
        WHEN lifespan < 12
        THEN 'New'
        ELSE 'n/a'
    END AS customer_status,
    last_order_date,
    DATEDIFF(MONTH,last_order_date,GETDATE()) AS months_since_last_order,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- average order value
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales/total_orders
    END AS avg_order_value,
    -- average monthly spend
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales/lifespan
    END AS avg_monthly_spend
FROM customer_aggregation
