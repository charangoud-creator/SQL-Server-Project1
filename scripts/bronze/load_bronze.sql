
create or alter procedure bronze.load_bronze as
begin
	Declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime 
	begin try
		set @batch_start_time = GETDATE();
		print '=========================================';
		print 'Loading Bronze Layer';
		print '=========================================';

		print '-----------------------------------------';
		print 'Loading CRM Table';
		print '-----------------------------------------';

		set @start_time = GETDATE();
		print '>> Truncating Table : bronze.crm_cust_info';
		truncate table bronze.crm_cust_info;

		print '>> Inserting Data into : bronze.crm_cust_info';
		Bulk insert bronze.crm_cust_info
		from 'C:\Users\User\OneDrive\Desktop\SQL Server\SQL_Project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'Load Duration:'+cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
		print '>>----------------'

		set @start_time=GETDATE();
		print '>> Truncating Table : bronze.crm_prod_info';
		truncate table bronze.crm_prod_info;

		print '>> INserting Data into : bronze.crm_prod_info';
		bulk insert bronze.crm_prod_info
		from 'C:\Users\User\OneDrive\Desktop\SQL Server\SQL_Project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'Load Duration:'+cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
		print '>>----------------'

		set @start_time = GETDATE();
		print 'Truncating Table : bronze.crm_sal_info';
		truncate table bronze.crm_sal_info;

		print 'Inserting into : bronze.crm_sal_info';
		bulk insert bronze.crm_sal_info
		from 'C:\Users\User\OneDrive\Desktop\SQL Server\SQL_Project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'Load Duration:'+cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
		print '>>----------------'

		print '-----------------------------------------';
		print 'Loading ERP Table';
		print '-----------------------------------------';

		set @start_time = GETDATE();
		print 'Truncating Table : bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12;

		print 'Inserting into : bronze.erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\User\OneDrive\Desktop\SQL Server\SQL_Project\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'Load Duration:'+cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
		print '>>----------------'

		set @start_time = GETDATE();
		print 'Truncating Table : bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101;

		print 'Inserting into : bronze.erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\User\OneDrive\Desktop\SQL Server\SQL_Project\datasets\source_erp\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'Load Duration:'+cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
		print '>>----------------'

		set @start_time = GETDATE();
		print 'Truncating Table : bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2;

		print 'Insering into : bronze.erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\User\OneDrive\Desktop\SQL Server\SQL_Project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = GETDATE();
		print 'Load Duration:'+cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds'
		print '>>----------------'

		set @batch_end_time = GETDATE();
		print 'Loading Bronze Layer is Completed';
		print '=======================================';
		print 'Batch Duration:'+cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds'
		print '=======================================';

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

-- Use this for execution of above code
-- exec bronze.load_bronze;
