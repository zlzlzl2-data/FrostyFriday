-- set environment
create schema challenge_1;
use schema challenge_1;

-- create external stage
create 
    or replace stage challenge_1_AWS_stage url = 's3: //frostyfridaychallenges/challenge_1/';

-- check for file in the external stage, notice there are 3 csv
list @challenge_1_AWS_stage;

-- check for header and data in the file
select
    t.$1,
    t.$2,
    t.$3
from
    @challenge_1_AWS_stage t;
-- files agree in format, with 1 column. 'result' maybe the header

-- create table for loading
create
    or replace table ff1
(result varchar);
    
-- Load
copy into ff1
    from @challenge_1_AWS_stage;

-- View data
select *
from ff1;