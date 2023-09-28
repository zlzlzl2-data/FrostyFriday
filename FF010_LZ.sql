-- Setup the enviroment, if needed
-- use database frostyfriday;
-- create schema challenge_10;
-- Supplied Code
-- Create the warehouses
create warehouse if not exists ff10_xsmall_wh with warehouse_size = XSMALL auto_suspend = 120;

--    
create warehouse if not exists ff10_small_wh with warehouse_size = SMALL auto_suspend = 120;

-- Create the table
create
or replace table ff10 (
    date_time datetime,
    trans_amount double
);

-- Create the stage
create
or replace stage challenge_10_AWS_stage url = 's3://frostyfridaychallenges/challenge_10/' file_format = ff_csv_skip_header;

-- Create the stored procedure
create
or replace procedure ff10_dynamic_warehouse_data_load(stage_name string, table_name string) RETURNS VARCHAR LANGUAGE SQL EXECUTE AS caller as declare row_counts int := 0;

begin -- Query the staging files then create a resultset and cursor on the result table
execute immediate 'ls @' || stage_name;

let stg_res resultset := (
    select
        "name",
        "size"
    from
        table(result_scan(last_query_id()))
);

let cur cursor for stg_res;

-- Iterate through with condition on size
for i in cur do if (i."size" < 1024 * 10) then execute immediate 'use warehouse ff10_xsmall_wh';

else execute immediate 'use warehouse ff10_small_wh';

end if;

execute immediate 'copy into ' || table_name || ' from @' || stage_name || ' files = (''' || split_part(i."name", '/', -1) || ''')';

end for;

-- Aggregate from the iteration steps about rows loadd
select
    count(*) into :row_counts
from
    identifier(:table_name);

return row_counts;

end;

--
-- Call the stored procedure.
call ff10_dynamic_warehouse_data_load('challenge_10_AWS_stage', 'ff10');

--
-- Check number of iterations loaded
select
    count(*)
from
    ff10;