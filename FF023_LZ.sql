-- Setup the environment
create schema challenge_23;
use schema challenge_23;

-- SnowSQL part
-- Login
snowsql -a cd35415.eu-west-1 -u ff23 

-- Set context
use role SYSADMIN;
use SCHEMA FROSTYFRIDAY.challenge_23;

-- Create stage for load
create
or replace stage ff23_csv_stage;

-- Loading from local path
put 'file://C:/Users/Liu Zhang/Downloads/ff23/data_batch_*.csv' @ff23_csv_stage auto_compress = true;

-- Create file format 
create
or replace file format ff23_csv_format type = 'CSV' field_delimiter = ',' field_optionally_enclosed_by = '"' skip_header = 1;

-- Create table for loading
create
or replace table ff23 (
    id varchar(100),
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100),
    gender varchar(100),
    ip_address varchar(100)
);

-- Loading into the table
COPY INTO ff23
from
    @ff23_csv_stage FILE_FORMAT = (format_name = 'ff23_csv_format') PATTERN = '.*data_batch_.*1[.]csv[.]gz' ON_ERROR = SKIP_FILE;

-- Final check
select
    *
from
    ff23;