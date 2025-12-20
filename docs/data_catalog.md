Table Name: gold.dim_customers
Description: Stores customer master data used for analytics and reporting.

| Column Name     | Data Type     | Description                                                |
| --------------- | ------------- | ---------------------------------------------------------- |
| customer_key    | INT           | Surrogate primary key generated for the customer dimension |
| customer_id     | VARCHAR / INT | Business customer ID from CRM system                       |
| customer_number | VARCHAR / INT | Unique customer key used across CRM and ERP systems        |
| first_name      | VARCHAR       | Customer first name                                        |
| last_name       | VARCHAR       | Customer last name                                         |
| country         | VARCHAR       | Customer country information                               |
| marital_status  | VARCHAR       | Customer marital status                                    |
| gender          | VARCHAR       | Customer gender resolved from CRM or ERP                   |
| birthdate       | DATE          | Customer date of birth                                     |
| create_date     | DATE          | Customer record creation date                              |


Table Name: gold.dim_products
Description: Contains product master data with category and pricing information.

| Column Name    | Data Type     | Description                                               |
| -------------- | ------------- | --------------------------------------------------------- |
| product_key    | INT           | Surrogate primary key generated for the product dimension |
| product_id     | VARCHAR / INT | Business product ID from CRM                              |
| product_number | VARCHAR / INT | Unique product identifier used in sales                   |
| product_name   | VARCHAR       | Name of the product                                       |
| category_id    | VARCHAR / INT | Product category identifier                               |
| category       | VARCHAR       | Product category name                                     |
| subcategory    | VARCHAR       | Product subcategory name                                  |
| maintenance    | VARCHAR       | Maintenance details                                       |
| cost           | DECIMAL       | Cost of the product                                       |
| product_line   | VARCHAR       | Product line classification                               |
| start_date     | DATE          | Product effective start date                              |


Table Name: gold.fact_sales
Description: Stores transactional sales data used for reporting and analysis.

| Column Name   | Data Type     | Description                                               |
| ------------- | ------------- | --------------------------------------------------------- |
| order_number  | VARCHAR / INT | Sales order business key                                  |
| product_key   | INT           | Foreign key referencing `gold.dim_products.product_key`   |
| customer_key  | INT           | Foreign key referencing `gold.dim_customers.customer_key` |
| order_date    | DATE          | Date when the order was placed                            |
| shipping_date | DATE          | Date when the order was shipped                           |
| due_date      | DATE          | Payment due date                                          |
| sales_amount  | DECIMAL       | Total sales amount                                        |
| quality       | INT           | Quantity of products sold                                 |
| price         | DECIMAL       | Unit price of the product                                 |
