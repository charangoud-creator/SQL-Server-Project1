-----------------------------------------------------
-- First Table
-- Checking for null & duplicates in Primary key in bronze.crm_cust_info
select
	cust_id,
	count(*) as counts 
from bronze.crm_cust_info
group by cust_id
Having count(*)>1 or cust_id is null

-- Filtering All duplicate values 
select
*
from
(select
	*,
	ROW_NUMBER() over(partition by cust_id order by cust_create_date desc) as row_numbers
from bronze.crm_cust_info
)t where row_numbers=1

-- check for unwanted spaces
select
	cust_firstname
from bronze.crm_cust_info
where cust_firstname!=TRIM(cust_firstname)

select
	cust_lastname
from bronze.crm_cust_info
where cust_lastname!=TRIM(cust_lastname)

-- Removing unwanted spces
select
	cust_id,
	cust_key,
	trim(cust_firstname) as cust_firstname,
	trim(cust_lastname) as cust_lastname,
	case when upper(trim(cust_material_status))='S' then 'Single'
		when upper(trim(cust_material_status))='M' then 'Married'
		else 'n/a'
	end cust_material_status,
	case when upper(trim(cust_gndr))='M' then 'Male'
		when upper(trim(cust_gndr))='F' then 'Female'
		else 'n/a'
	end cust_gndr,
	cust_create_date
from
(select
	*,
	ROW_NUMBER() over(partition by cust_id order by cust_create_date desc) as row_numbers
from bronze.crm_cust_info
where cust_id is not null
)t where row_numbers=1

-- after inserting the cleaned data into silver layer the check
select
	cust_id,
	count(*) as counts 
from silver.crm_cust_info
group by cust_id
Having count(*)>1

select
	cust_firstname
from silver.crm_cust_info
where cust_firstname!=TRIM(cust_firstname)

select
	cust_lastname
from silver.crm_cust_info
where cust_lastname!=TRIM(cust_lastname)
-----------------------------------------------------

-----------------------------------------------------
-- Second Table
-- Checking for null & duplicates in Primary key in bronze.crm_prod_info
select
	prod_id,
	count(*) 
from bronze.crm_prod_info
group by prod_id
having count(*) > 1 or prod_id is null

-- check for unwanted spaces
select
	prod_nm
from bronze.crm_prod_info
where prod_nm!=TRIM(prod_nm)

-- Check for null or negative numbers
select
	prod_cost
from bronze.crm_prod_info
where prod_cost<0 or prod_cost is null

-- Check Distinct values 
select 
	DISTINCT prod_line
from bronze.crm_prod_info

-- Checking for valid date
select
	*
from bronze.crm_prod_info
where prod_end_date<prod_start_date

select
	prod_key,
	prod_start_date,
	prod_end_date,
	LEAD(prod_start_date) over(partition by prod_key order by prod_start_date)-1 as prod_end_date
from bronze.crm_prod_info

-- Cleaning the bronze.crm_prod_info
select 
	prod_id,
	prod_key,
	REPLACE(SUBSTRING(prod_key,1,5),'-','_') as cat_id,
	SUBSTRING(prod_key,7,LEN(prod_key)) as prod_key,
	prod_nm,
	ISNULL(prod_cost,0) as prod_cost,
	case UPPER(prod_line)
		when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other Sales'
		when 'T' then 'Touring'
		else 'n/a'
	end prod_line,
	cast(prod_start_date as date) as prod_start_date,
	cast(LEAD(prod_start_date) over(partition by prod_key order by prod_start_date)-1 as date) as prod_end_date
from bronze.crm_prod_info

-- After cleaning 
-- Checking for null & duplicates in Primary key in bronze.crm_prod_info
select
	prod_id,
	count(*) 
from silver.crm_prod_info
group by prod_id
having count(*) > 1 or prod_id is null

-- check for unwanted spaces
select
	prod_nm
from silver.crm_prod_info
where prod_nm!=TRIM(prod_nm)

-- Check for null or negative numbers
select
	prod_cost
from silver.crm_prod_info
where prod_cost<0 or prod_cost is null

-- Check Distinct values 
select 
	DISTINCT prod_line
from silver.crm_prod_info

-- Checking for valid date
select
	*
from silver.crm_prod_info
where prod_end_date<prod_start_date
-----------------------------------------------------

-----------------------------------------------------
-- Third Table
-- Checking for unwanted spaces
select
	sal_ord_num
from bronze.crm_sal_info
where sal_ord_num != TRIM(sal_ord_num)

-- check data integrity
select
	sal_prd_key
from bronze.crm_sal_info
where sal_prd_key not in (select prod_key from silver.crm_prod_info)

select
	sal_cust_id
from bronze.crm_sal_info
where sal_cust_id not in (select cust_id from silver.crm_cust_info)

-- check for valid dates
select
	sal_order_dt
from bronze.crm_sal_info
where sal_order_dt <=0 or LEN(sal_order_dt) != 8 

-- Check date integrity
select 
	*
from bronze.crm_sal_info
where sal_order_dt > sal_ship_dt or sal_order_dt > sal_due_dt

-- check data consistency between sales, quality, price
-- sales = qulity * price
-- values must not negative, null, zero
select
	sal_sales,
	sal_quality,
	sal_price
from bronze.crm_sal_info
where sal_sales != sal_quality * sal_price
or sal_sales <=0 or sal_price <=0 or sal_quality <= 0
or sal_sales is null or sal_price is null or sal_quality is null
order by sal_sales,sal_quality,sal_price

-- Cleaning the table : bronze.sal_ord_num
select
	sal_ord_num,
	sal_prd_key,
	sal_cust_id,
	case when sal_order_dt <= 0 or LEN(sal_order_dt) != 8 then null
		else cast(cast(sal_order_dt as varchar) as date)
	end sal_order_dt,
	case when sal_ship_dt <= 0 or LEN(sal_ship_dt) != 8 then null
		else cast(cast(sal_ship_dt as varchar) as date)
	end sal_ship_dt,
	case when sal_due_dt <= 0 or LEN(sal_due_dt) != 8 then null
		else cast(cast(sal_due_dt as varchar) as date)
	end sal_due_dt,
	case when sal_sales <= 0 or sal_sales is null or sal_sales != sal_quality * sal_price
		then sal_quality * abs(sal_price)
		else sal_sales
	end sal_sales,
	sal_quality,
	case when sal_price <= 0 or sal_price is null then sal_sales/nullif(sal_quality,0)
		else sal_price
	end sal_price
from bronze.crm_sal_info

-- After cleaning check
select 
	*
from silver.crm_sal_info
where sal_order_dt > sal_ship_dt or sal_order_dt > sal_due_dt

select
	sal_sales,
	sal_quality,
	sal_price
from silver.crm_sal_info
where sal_sales != sal_quality * sal_price
or sal_sales <=0 or sal_price <=0 or sal_quality <= 0
or sal_sales is null or sal_price is null or sal_quality is null
order by sal_sales,sal_quality,sal_price
-----------------------------------------------------

-----------------------------------------------------
-- Fourth Table

-- Checking cid with other table
-- In table silver.crm_cust_info don't have NAS in starting of cust_key 
select
	cid
from bronze.erp_cust_az12
where cid not in (select cust_key from silver.crm_cust_info)

-- validate the bdate
select
	bdate
from bronze.erp_cust_az12
where bdate<'1924-01-01' or bdate>GETDATE()

-- check distinct of gen
select 
	distinct gen
from bronze.erp_cust_az12

-- Cleaning the table : bronze.erp_cust_az12
select
	case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
		else cid
	end cid,
	case when bdate > GETDATE() then null
		else bdate
	end bdate,
	case when upper(trim(gen)) in ('F','FEMALE') then 'Female'
		when upper(trim(gen)) in ('M','MALE') then 'Male'
		else 'n/a'
	end gen
from bronze.erp_cust_az12

-- After cleaning check
select
	bdate
from silver.erp_cust_az12
where bdate<'1924-01-01' or bdate>GETDATE()

select
	cid
from silver.erp_cust_az12
where cid not in (select cust_key from silver.crm_cust_info)

select 
	distinct gen
from silver.erp_cust_az12
-----------------------------------------------------

-----------------------------------------------------
-- Fifth Table 

-- checking with the another table
-- there is no "-" symbol
select cust_key from silver.crm_cust_info

-- checking distinct of cntry
select
	distinct cntry
from bronze.erp_loc_a101

-- Cleaning the table : bronze.erp_loc_a101
select
	replace(cid,'-','') as cid,
	case when trim(cntry) = 'DE' then 'Germany'
		when trim(cntry) in ('USA','US') then 'United States'
		when cntry = '' or cntry is null then 'n/a'
		else trim(cntry)
	end cntry
from bronze.erp_loc_a101

-- After cleaning check
select
	distinct cntry
from silver.erp_loc_a101
-----------------------------------------------------

-----------------------------------------------------
-- Sixth Table

-- checking with other table 
-- nothing issue
select cat_id from silver.crm_prod_info

-- checking for unwanted issues
select
	*
from bronze.erp_px_cat_g1v2
where cat != trim(cat) 
or subcat != trim(subcat)
or maintenance != trim(maintenance)

-- checking distinct values
select
	distinct cat
from bronze.erp_px_cat_g1v2

select
	distinct subcat
from bronze.erp_px_cat_g1v2

select
	distinct maintenance
from bronze.erp_px_cat_g1v2

-- Cleaning the table : 
select
	id,
	cat,
	subcat,
	maintenance
from bronze.erp_px_cat_g1v2
