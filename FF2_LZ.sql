-- set environment
create schema challenge_2;
use schema challenge_2;

-- create a table to load one column with variant type
CREATE TABLE "FROSTYFRIDAY"."CHALLENGE_2"."FF2" ("C1" VARIANT);

-- create file format for loading parquet type
CREATE FILE FORMAT "FROSTYFRIDAY"."CHALLENGE_2".Parquet_load TYPE = 'PARQUET' COMPRESSION = 'AUTO' BINARY_AS_TEXT = FALSE;

-- used Classical console for loading file from local drive
PUT file :// < file_path > / employees.parquet @FF2/ui1658850446235 COPY INTO "FROSTYFRIDAY"."CHALLENGE_2"."FF2"
FROM
    @/ui1658850446235 FILE_FORMAT = '"FROSTYFRIDAY"."CHALLENGE_2"."PARQUET_LOAD"' ON_ERROR = 'ABORT_STATEMENT' PURGE = TRUE;

-- parse information out into new table
create
    or replace table ff2_2 as
select
    t.$1:city::varchar as city,
    t.$1:country::varchar as country,
    t.$1:country_code::varchar as country_code,
    t.$1:dept::varchar as dept,
    t.$1:education::varchar as education,
    t.$1:email::varchar as email,
    t.$1:employee_id::varchar as employee_id,
    t.$1:first_name::varchar as first_name,
    t.$1:job_title::varchar as job_title,
    t.$1:last_name::varchar as last_name,
    t.$1:payroll_iban::varchar as payroll_iban,
    t.$1:postcode::varchar as postcode,
    t.$1:street_name::varchar as street_name,
    t.$1:street_num::varchar as street_num,
    t.$1:time_zone::varchar as time_zone,
    t.$1:title::varchar as title
from
    ff2 t;

-- since only need to keep track of limited column, so create a view
create
    or replace view ff2_view as
select
    employee_id,
    dept,
    job_title
from
    ff2_2;

-- create stream to track change
create
    or replace stream ff2_stream on view ff2_view;

-- apply required changes
UPDATE ff2_2 SET COUNTRY = 'Japan' WHERE EMPLOYEE_ID = 8;
UPDATE ff2_2 SET LAST_NAME = 'Forester' WHERE EMPLOYEE_ID = 22;
UPDATE ff2_2 SET DEPT = 'Marketing' WHERE EMPLOYEE_ID = 25;
UPDATE ff2_2 SET TITLE = 'Ms' WHERE EMPLOYEE_ID = 32;
UPDATE ff2_2 SET JOB_TITLE = 'Senior Financial Analyst' WHERE EMPLOYEE_ID = 68;

-- check result
select
    *
from
    ff2_stream;