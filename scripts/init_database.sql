
-- Drop and recreate database
if exists (select 1 from sys.databases where name='DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end;
go

-- creating database
create database DataWarehouse;

-- Using database
use DataWarehouse;
go

-- creating schemas
create schema bronze;
go

create schema silver;
go

create schema gold;
