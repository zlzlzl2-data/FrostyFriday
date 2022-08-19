-- Set environment
create schema challenge_3;
use schema challenge_3;

-- Create loading stage
create or replace stage challenge_3_AWS_stage url = 's3://frostyfridaychallenges/challenge_3/';

-- Check what files are in the location
list @challenge_3_AWS_stage;

-- Check the keyword table mentioned in the challenge guide
select
    metadata$filename,
    metadata$file_row_number,
    $1,
    $2,
    $3,
    $4
from
    @challenge_3_AWS_stage
where
    contains(metadata$filename, 'keyword');

-- Create a table to load the keywords
create
    or replace table ff3_keyword
(
        keyword varchar
(1000),
        added_by varchar
(1000),
        nonsense varchar
(1000)
    );

-- Load keywords data into the table
copy into ff3_keyword
from
    @challenge_3_AWS_stage/keywords.csv;

-- For rest of the data, load into the data table    
-- Create table
create
    or replace table ff3_all_data
(
        file_name varchar
(100),
        file_row_number int,
        id varchar
(100) not null,
        first_name varchar
(100),
        last_name varchar
(100),
        catch_phrase varchar
(1000)
    );

-- Add values to the created data table
insert into
    ff3_all_data (
select
    metadata$filename,
    metadata$file_row_number,
    $1,
    $2,
    $3,
    $4
from
    @challenge_3_AWS_stage
where
            not contains(METADATA$FILENAME, 'keyword') -- don't load the keyword
    and METADATA$file_row_number != 1
-- skip the header row
);

-- Get the result
select
    file_name as FILENAME,
    count(1) as NUMBER_OF_ROWS
from
    ff3_all_data
where
-- use keyword column to filter out special file
    file_name like any
(
        select
    '%' || keyword || '%'
from
    ff3_keyword
    )
group by
    file_name;