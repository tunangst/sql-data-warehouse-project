/*
This script will truncate all of the tables then take the files in the locations listed and load them into the respective tables.
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		PRINT '======================================================================';
		PRINT 'loading the bronze layer';
		PRINT '======================================================================';

		PRINT '----------------------------------------------------------------------';
		PRINT 'loading crm tables';
		PRINT '----------------------------------------------------------------------';
		
		DECLARE @start_time DATE = GETDATE();

		TRUNCATE TABLE bronze.crm_cust_info;
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\snype\Documents\SQL Server Management Studio\Data Warehouse Project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\snype\Documents\SQL Server Management Studio\Data Warehouse Project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.crm_sales_details;
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\snype\Documents\SQL Server Management Studio\Data Warehouse Project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		PRINT '----------------------------------------------------------------------';
		PRINT 'loading erp tables';
		PRINT '----------------------------------------------------------------------';

		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\snype\Documents\SQL Server Management Studio\Data Warehouse Project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\snype\Documents\SQL Server Management Studio\Data Warehouse Project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\snype\Documents\SQL Server Management Studio\Data Warehouse Project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		DECLARE @end_time DATE = GETDATE();

		PRINT ' -= load time; ' + CAST(DATEDIFF(Nanosecond,@start_time,@end_time) AS NVARCHAR) + ' nanoseconds =-';
		PRINT '----------------------------------------------------------------------';
		PRINT 'finished loading bronze tables';
		PRINT '----------------------------------------------------------------------';
	END TRY
	BEGIN CATCH
		PRINT 'ERROR WHEN LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
	END CATCH
END;
GO
EXEC bronze.load_bronze;
