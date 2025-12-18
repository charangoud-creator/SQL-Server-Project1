
if OBJECT_ID('silver.crm_cust_info', 'U') is not null
	drop table silver.crm_cust_info;
create table silver.crm_cust_info(
	cust_id int,
	cust_key nvarchar(50),
	cust_firstname nvarchar(50),
	cust_lastname varchar(50),
	cust_material_status nvarchar(50),
	cust_gndr nvarchar(50),
	cust_create_date date,
	dwh_create_date datetime2 default getdate()
);

if OBJECT_ID('silver.crm_prod_info', 'U') is not null
	drop table silver.crm_prod_info;
create table silver.crm_prod_info(
	prod_id int,
	cat_id nvarchar(50),
	prod_key nvarchar(50),
	prod_nm nvarchar(50),
	prod_cost int,
	prod_line nvarchar(50),
	prod_start_date date,
	prod_end_date date,
	dwh_create_date datetime2 default getdate()
);

if OBJECT_ID('silver.crm_sal_info', 'U') is not null
	drop table silver.crm_sal_info;
create table silver.crm_sal_info(
	sal_ord_num nvarchar(50),
	sal_prd_key nvarchar(50),
	sal_cust_id int,
	sal_order_dt date,
	sal_ship_dt date,
	sal_due_dt date,
	sal_sales int,
	sal_quality int,
	sal_price int,
	dwh_create_date datetime2 default getdate()
);

if OBJECT_ID('silver.erp_cust_az12', 'U') is not null
	drop table silver.erp_cust_az12;
create table silver.erp_cust_az12(
	cid nvarchar(50),
	bdate date,
	gen nvarchar(50),
	dwh_create_date datetime2 default getdate()
);

if OBJECT_ID('silver.erp_loc_a101', 'U') is not null
	drop table silver.erp_loc_a101;
create table silver.erp_loc_a101(
	cid nvarchar(50),
	cntry varchar(50),
	dwh_create_date datetime2 default getdate()
);

if OBJECT_ID('silver.erp_px_cat_g1v2', 'U') is not null
	drop table silver.erp_px_cat_g1v2;
create table silver.erp_px_cat_g1v2(
	id nvarchar(50),
	cat nvarchar(50),
	subcat nvarchar(50),
	maintenance nvarchar(50),
	dwh_create_date datetime2 default getdate()
);
