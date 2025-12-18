
create or alter procedure silver.load_silver as
begin
	Declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime
	begin try
		set @batch_start_time = GETDATE()
		set @start_time = GETDATE()
		print '>> Truncatng the Table'
		Truncate table silver.crm_cust_info
		print '>> Inserting into the Table'
		-- Inserting the cleaned data into table : silver.crm_cust_info
		insert into silver.crm_cust_info(
			cust_id,
			cust_key,
			cust_firstname,
			cust_lastname,
			cust_material_status,
			cust_gndr,
			cust_create_date
			)
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
			)t 
		where row_numbers=1
		set @end_time = GETDATE()
		print '-------------------------------'
		print 'Load Duration :'+cast(datediff(second, @start_time, @end_time) as nvarchar)+'seconds'
		print '-------------------------------'

		set @start_time = GETDATE()
		print '>> Truncatng the Table'
		Truncate table silver.crm_cust_info
		print '>> Inserting into the Table'
		-- Inserting the cleaned data into table : silver.crm_prod_info
		insert into silver.crm_prod_info(
			prod_id,
			cat_id,
			prod_key,
			prod_nm,
			prod_cost,
			prod_line,
			prod_start_date,
			prod_end_date
		)
		select 
			prod_id,
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
		set @end_time = GETDATE()
		print '-------------------------------'
		print 'Load Duration :'+cast(datediff(second, @start_time, @end_time) as nvarchar)+'seconds' 
		print '-------------------------------'

		set @start_time = GETDATE()
		print '>> Truncatng the Table'
		Truncate table silver.crm_cust_info
		print '>> Inserting into the Table'
		-- Inserting the cleaned data into : silver.crm_sal_info
		insert into silver.crm_sal_info(
			sal_ord_num,
			sal_prd_key,
			sal_cust_id,
			sal_order_dt,
			sal_ship_dt,
			sal_due_dt,
			sal_sales,
			sal_quality,
			sal_price
		)
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
		set @end_time = GETDATE()
		print '-------------------------------'
		print 'Load Duration :'+cast(datediff(second, @start_time, @end_time) as nvarchar)+'seconds' 
		print '-------------------------------'

		set @start_time = GETDATE()
		print '>> Truncatng the Table'
		Truncate table silver.crm_cust_info
		print '>> Inserting into the Table'
		-- Inserting into table : silver.crm_cust_az12
		insert into silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
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
		set @end_time = GETDATE()
		print '-------------------------------'
		print 'Load Duration :'+cast(datediff(second, @start_time, @end_time) as nvarchar)+'seconds' 
		print '-------------------------------'

		set @start_time = GETDATE()
		print '>> Truncatng the Table'
		Truncate table silver.crm_cust_info
		print '>> Inserting into the Table'
		-- Inserting into the table : silver.erp_loc_a101
		insert into silver.erp_loc_a101(
			cid,
			cntry
		)
		select
			replace(cid,'-','') as cid,
			case when trim(cntry) = 'DE' then 'Germany'
				when trim(cntry) in ('USA','US') then 'United States'
				when cntry = '' or cntry is null then 'n/a'
				else trim(cntry)
			end cntry
		from bronze.erp_loc_a101
		set @end_time = GETDATE()
		print '-------------------------------'
		print 'Load Duration :'+cast(datediff(second, @start_time, @end_time) as nvarchar)+'seconds' 
		print '-------------------------------'

		set @start_time = GETDATE()
		print '>> Truncatng the Table'
		Truncate table silver.crm_cust_info
		print '>> Inserting into the Table'
		-- Inserting into Table : silver.erp_px_cat_g1v2 
		insert into silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		select
			id,
			cat,
			subcat,
			maintenance
		from bronze.erp_px_cat_g1v2
		set @end_time = GETDATE()
		print '-------------------------------'
		print 'Load Duration :'+cast(datediff(second, @start_time, @end_time) as nvarchar)+'seconds' 
		print '-------------------------------'

		set @batch_end_time = GETDATE()
		print '-------------------------------'
		print 'Toatl Load Duration :'+cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar)+'seconds' 
		print '-------------------------------'

	end try
	begin catch
		print '===================================='
		print 'ERROR OCCCURED DURING THE LOADING THE BRONZE LAYER'
		Print 'Error message'+Error_message();
		print 'Error message'+cast(Error_number() as nvarchar);
		print 'Error message'+cast(error_state() as nvarchar);
		print '===================================='
	end catch
end

-- For executing the code use
--exec silver.load_silver
