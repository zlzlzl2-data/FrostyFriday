-- set environment
create schema challenge_5;
use schema challenge_5;

-- Create a dummy table
create or replace table data 
    (number int);
-- Add a dummy value
insert into data 
    (number)
values
    (1);
    
-- Create simple function
create or replace function timesthree
    (start_int int) 
    returns int 
    language python 
    runtime_version = '3.8' 
    handler = 'timesthree_py' 
    
    -- define the actual function
    as $$
    def timesthree_py(i):
    return i*3
    $$;
    
-- Test the function
select timesthree(
    select * from data
    );