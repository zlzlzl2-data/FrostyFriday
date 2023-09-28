-- Layer 1: Landing zone for external stage
create
or replace stage challenge_25_aws_stage url = 's3://frostyfridaychallenges/challenge_25/' file_format = ff_json;

-- Check data in external stage
select
    $ 1 :: variant as json_input
from
    @challenge_25_aws_stage;

-- Create table for loading raw data
create
or replace table ff25_raw (json_input variant);

-- Loading data into raw table
copy into ff25_raw
from
    @challenge_25_aws_stage;

--
-- Layer 2: Curated zone with data parsed
create
or replace table ff25_weather_parse as
select
    t1.value :timestamp :: datetime as date,
    t1.value :icon :: string as icon,
    t1.value :temperature :: number as temperature,
    t1.value :precipitation :: number as precipitation,
    t1.value :wind_speed :: number as wind,
    t1.value :relative_humidity :: number as humidity
from
    ff25_raw,
    lateral flatten (json_input :weather) t1;

--
-- Layer 3: Consumption zone with data aggregated
create
or replace table ff25_weather_agg as
select
    date_trunc('day', date) as date_at_daily,
    array_agg(distinct icon) as icon_array,
    avg(temperature) as avg_temperature,
    sum(precipitation) as total_precipitation,
    avg(wind) as avg_wind,
    avg(humidity) as avg_humidity
from
    ff25_weather_parse
group by
    1
order by
    1 desc;

-- Check results
select
    *
from
    ff25_weather_agg;