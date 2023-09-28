-- set environment
use database FROSTYFRIDAY;

create schema challenge_11;

use schema challenge_11;

-- Create the stage that points at the data.
create
or replace stage challenge_11_AWS_stage url = 's3://frostyfridaychallenges/challenge_11/' file_format = FROSTYFRIDAY.PUBLIC.FF_CSV_SKIP_HEADER;

-- Create the table as a CTAS statement.
create
or replace table challenge_11 as
select
    m.$ 1 as milking_datetime,
    m.$ 2 as cow_number,
    m.$ 3 as fat_percentage,
    m.$ 4 as farm_code,
    m.$ 5 as centrifuge_start_time,
    m.$ 6 as centrifuge_end_time,
    m.$ 7 as centrifuge_kwph,
    m.$ 8 as centrifuge_electricity_used,
    m.$ 9 as centrifuge_processing_time,
    m.$ 10 as task_used
from
    @challenge_11_AWS_stage (pattern = > '.*milk_data.*[.]csv') m;

-- Check data loaded
select
    *
from
    challenge_11;

-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create
or replace task FF11_whole_milk_updates warehouse = compute_wh schedule = '1400 minutes' as
update
    challenge_11
set
    centrifuge_start_time = null,
    centrifuge_end_time = null,
    centrifuge_kwph = null,
    task_used = system $ current_user_task_name() || ' at ' || current_timestamp
where
    fat_percentage = 3;

-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create
or replace task FF11_skim_milk_updates warehouse = compute_wh
after
    FROSTYFRIDAY.CHALLENGE_11.FF11_WHOLE_MILK_UPDATES as
update
    challenge_11
set
    centrifuge_electricity_used = round(
        centrifuge_kwph * datediff(
            "minute",
            centrifuge_start_time,
            centrifuge_end_time
        ) / 60,
        2
    ),
    centrifuge_processing_time = datediff(
        "minute",
        centrifuge_start_time,
        centrifuge_end_time
    ),
    task_used = system $ current_user_task_name() || ' at ' || current_timestamp
where
    fat_percentage != 3;

-- Enable child task
alter task FROSTYFRIDAY.CHALLENGE_11.FF11_SKIM_MILK_UPDATES resume;

-- Manually execute the task.
execute task FF11_whole_milk_updates;

-- Check that the data looks as it should.
select
    *
from
    challenge_11;

-- Check that the numbers are correct.
select
    task_used,
    count(*) as row_count
from
    challenge_11
group by
    task_used;

-- Check task run history
select
    *
from
    table(information_schema.task_history())
order by
    scheduled_time desc;