# Data Dictionary for Gold Layer

## Overview
The Gold layer is the business level data representation. The purpose is to support analytics and reporting. It consists of dimension and fact tables.

### 1. gold.dim_customers
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name | Data Type |Description |
|---|---|---|
| customer_key | INT | Unique surrogate key identifying each customer record in the dimension table |
| customer_id | INT | Unique numerical identifier assigned to each customer from the data source |
| customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| first_name | NVARCHAR(50) | The customer's first name |
| last_name | NVARCHAR(50) | The customer's last name |
| country | NVARCHAR(50) | The customer's country of residence |
| marital_status | NVARCHAR(50) | The customer's marital status ('Married','Single') etc. |
| gender | NVARCHAR(50) | The customer's gender |
| birthdate | DATE | The customer's date of birth (formatted as YYYY-MM-DD) |
| create_date | DATE | The date when the customer record was created in the database |

### 2. gold.dim_products
- **Purpose:** Provides information about products and their attributes.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| product_key | INT | Unique surrogate key to identify product records in the product dimension table |
| product_id | INT | Unique identifier for internal tracking and referencing |
| product_number | NVARCHAR(20) | Alphanumeric code representing the product, used for categorization and inventory |
| category_id | NVARCHAR(20) | The product category's unique identifier |
| category | NVARCHAR(50) | The product's classification (ex 'Bike','Shoe') |
| subcategory | NVARCHAR(50) | A lower level classification of the product (ex. 'Mountain Bike','Sneaker') |
| maintenance_required | NVARCHAR(5) | Indicator if product requires maintenance (ex. 'Yes', 'No") |
| cost | INT | The product's base price (not in decimal) |
| product_line | NVARCHAR(20) | The product's specific product line (ex. 'Road','Mountain') |
| start_date | DATE | The product's availability date for sale or use |

### 3. gold.fact_sales
- **Purpose:** Stores the transactional sales data for analytics.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR(10) | Unique alphanumeric identifier for each sales order |
| product_key | INT | Surrogate key, Foreign key to the gold.dim_products table |
| customer_key | INT | Surrogate key, Foreign key to the gold.dim_customers table |
| order_date | DATE | The order's date placed |
| shipping_date | DATE | The order's shipped date |
| due_date | DATE | The order's payment due date |
| sales_amount | INT | The order's whole monetary value (not in decimal) |
| quantity | INT | The amount of the product ordered |
| price | INT | The item's price per item (not in decimal) |
