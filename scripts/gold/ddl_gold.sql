
if OBJECT_ID('gold.dim_customers', 'V') is not null
	drop view gold.dim_customers;
go
create view gold.dim_customers as
select
	ROW_NUMBER() over(order by cust_id) as customer_key,  -- Create a primarykey for only dimesions views
	cc.cust_id as customer_id,
	cc.cust_key as customer_number,
	cc.cust_firstname first_name,
	cc.cust_lastname as last_name,
	el.cntry as country,
	cc.cust_material_status as marital_status,
	case when cc.cust_gndr != 'n/a' then cc.cust_gndr
		else coalesce(ec.gen,'n/a')
	end as gender,
	ec.bdate as birthdate,
	cc.cust_create_date as create_date
from silver.crm_cust_info cc
left join silver.erp_cust_az12 ec
on cc.cust_key = ec.cid
left join silver.erp_loc_a101 el
on cc.cust_key = el.cid

if OBJECT_ID('gold.dim_products', 'V') is not null
	drop view gold.dim_products;
go
create view gold.dim_products as
select 
	ROW_NUMBER() over(order by cp.prod_start_date, cp.prod_key) as product_key,
	cp.prod_id as product_id,
	cp.prod_key as product_number,
	cp.prod_nm as product_name,
	cp.cat_id category_id,
	ep.cat category,
	ep.subcat subcategory,
	ep.maintenance,
	cp.prod_cost as cost,
	cp.prod_line as product_line,
	cp.prod_start_date start_date
from silver.crm_prod_info cp
left join silver.erp_px_cat_g1v2 ep
on cp.cat_id = ep.id
where cp.prod_end_date is null    -- To filter out all historical data
-- Check the uniquiness of primary key for fyrther join

if OBJECT_ID('gold.fact_sales', 'V') is not null
	drop view gold.fact_sales;
go
create view gold.fact_sales as
select 
	cs.sal_ord_num as order_number,
	dp.product_key,    -- Use dim surrogate key instead of id's to easily 						
	dc.customer_key,     -- to easy connect facts with dimensions
	cs.sal_order_dt as order_date,
	cs.sal_ship_dt as shipping_date,
	cs.sal_due_dt as due_date,
	cs.sal_sales as sales_amount,
	cs.sal_quality as quality,
	cs.sal_price as price
from silver.crm_sal_info cs
left join gold.dim_products dp
on cs.sal_prd_key = dp.product_number
left join gold.dim_customers dc
on cs.sal_cust_id = dc.customer_id
