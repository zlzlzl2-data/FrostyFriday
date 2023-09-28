-- Create the dimension table
create
or replace table FF19_date_dimension as with date_pad as (
    -- Generate dummy table with generator
    select
        seq4() as row_number,
        dateadd('day', row_number, '2000-01-01') :: date as generated_dates
    from
        table(generator(rowcount = > 366 * 100))
) -- From the generated table, calculate all the required columns
select
    generated_dates,
    year(generated_dates) as extr_year,
    monthname(generated_dates) as extr_month_name_abb,
    -- 3 letters abbreviation
    to_varchar(generated_dates, 'MMMM') as extr_month_name_full,
    month(generated_dates) as extr_month,
    dayofweekiso(generated_dates) as extr_number_day_in_week,
    -- use iso so 7 is Sunday
    dayofmonth(generated_dates) as extr_number_day_in_month,
    dayofyear(generated_dates) as extr_number_day_in_year,
    weekofyear(generated_dates) as extr_number_week_in_year
from
    date_pad;

-- Check the table is created        
select
    *
from
    ff19_date_dimension;

-- Create UDF for date calculation
create
or replace function calculate_businss_days(
    start_date date,
    end_date date,
    inc boolean
) returns int as -- Used a basic datediff calculation
$ $ datediff('day', start_date, end_date) + inc :: number - 1 $ $;

-- Supplied dummy data
create table FF19_testing_data (id INT, start_date DATE, end_date DATE);

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (1, '11/11/2020', '9/3/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (2, '12/8/2020', '1/19/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (3, '12/24/2020', '1/15/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (4, '12/5/2020', '3/3/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (5, '12/24/2020', '6/20/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (6, '12/24/2020', '5/19/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (7, '12/31/2020', '5/6/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (8, '12/4/2020', '9/16/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (9, '11/27/2020', '4/14/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (10, '11/20/2020', '1/18/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (11, '12/1/2020', '3/31/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (12, '11/30/2020', '7/5/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (13, '11/28/2020', '6/19/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (14, '12/21/2020', '9/7/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (15, '12/13/2020', '8/15/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (16, '11/4/2020', '3/22/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (17, '12/24/2020', '8/29/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (18, '11/29/2020', '10/13/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (19, '12/10/2020', '7/31/2022');

insert into
    FF19_testing_data (id, start_date, end_date)
values
    (20, '11/1/2020', '10/23/2021');

-- Apply the UDF
select
    id,
    calculate_businss_days(start_date, end_date, TRUE) as include,
    calculate_businss_days(start_date, end_date, FALSE) as exclude
from
    ff19_testing_data;