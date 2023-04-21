-- Setup the environment
-- Create schema
use database frostyfriday;

create schema challenge_18;

use schema challenge_18;

-- Base input data
create table challenge_18_input as (
    SELECT
        "Date",
        "Value"
    FROM
        ECONOMY_DATA_ATLAS.ECONOMY.BEANIPA
    WHERE
        "Table Name" = 'Price Indexes For Personal Consumption Expenditures By Major Type Of Product'
        AND "Indicator Name" = 'Personal consumption expenditures (PCE)'
        AND "Frequency" = 'A'
        AND "Date" >= '1972-01-01'
    ORDER BY
        "Date"
);

-- Rather than run the model everytime the function is called, we run it independently
-- Can schedule as replace of table or materialised view
create
or replace view challenge_18_coefficient as
select
    regr_intercept("Value", year("Date")) as intercept,
    regr_slope("Value", year("Date")) as slope,
    regr_r2("Value", year("Date")) as r2
from
    challenge_18_input;

-- Check coefficients are created
select
    *
from
    challenge_18_coefficient;

-- Create UDF, used table in this case. Can use scalar function
create function predict_pce_udf(year int) returns table (year int, predict_pce float, r2 float) as $ $
select
    year,
    intercept + slope * year as predict_pce,
    r2
from
    challenge_18_coefficient $ $;

-- Run predication for 2021
select
    *
from
    table(predict_pce_udf(2021));