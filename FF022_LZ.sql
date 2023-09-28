-- Setup the environment
create schema challenge_22;

use schema challenge_22;

-- File format to read the CSV
create
or replace file format ff22_frosty_csv type = csv field_delimiter = ',' field_optionally_enclosed_by = '"' skip_header = 1;

-- Creates stage to read the CSV
create
or replace stage ff22_frosty_stage url = 's3://frostyfridaychallenges/challenge_22/' file_format = ff22_frosty_csv;

-- Change role to create
use role accountadmin;

-- Roles needed for challenge
create role ff22_rep1;

create role ff22_rep2;

-- Grant roles to self for testing
grant role ff22_rep1 to role accountadmin;

grant role ff22_rep2 to role accountadmin;

-- Enable warehouse usage. Assumes that `public` has access to the warehouse
grant role public to role ff22_rep1;

grant role public to role ff22_rep2;

-- Create the table from the CSV in S3
create table FROSTYFRIDAY.CHALLENGE_22.ff22 as
select
    t.$ 1 :: int id,
    t.$ 2 :: varchar(50) city,
    t.$ 3 :: int district
from
    @ff22_frosty_stage (pattern = > '.*sales_areas.*') t;

-- Quick check on mod function to filter
use role accountadmin;

select
    *
from
    ff22
where
    mod(id, 2) = 0;

-- Create RLS policy
create
or replace row access policy ff22_rls_policy as (id int) returns boolean -> (
    (
        is_role_in_session('ff22_rep1')
        and id % 2 = 1
    )
    or (
        is_role_in_session('ff22_rep2')
        and id % 2 = 0
    )
    or (is_role_in_session('accountadmin'))
);

-- Create secure view
create
or replace secure view ff22_sec_view as
select
    uuid_string() as id,
    city,
    district
from
    ff22;

-- Apply RLS policy to the secure view
alter table
    ff22
add
    row access policy ff22_rls_policy on (id);

-- Roles need DB access
grant usage on database frostyfriday to role ff22_rep1;

grant usage on database frostyfriday to role ff22_rep2;

-- And schema access
grant usage on schema FROSTYFRIDAY.CHALLENGE_22 to role ff22_rep1;

grant usage on schema FROSTYFRIDAY.CHALLENGE_22 to role ff22_rep2;

-- And usage of view
grant
select
    on view FROSTYFRIDAY.CHALLENGE_22.FF22_SEC_VIEW to role ff22_rep1;

grant
select
    on view FROSTYFRIDAY.CHALLENGE_22.FF22_SEC_VIEW to role ff22_rep2;

-- Test on the view to see 500 rows each
use role ff22_rep1;

select
    *
from
    ff22_sec_view;