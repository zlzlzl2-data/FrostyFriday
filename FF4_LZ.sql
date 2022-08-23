-- set environment
create schema challenge_4;
use schema challenge_4;

-- create the stage for loading
create
    or replace stage challenge_4_AWS_stage url = 's3://frostyfridaychallenges/challenge_4/';
-- check the files in the staging location
list @challenge_4_AWS_stage;

-- create the initial table to load json file in as variant
-- create table
create
    or replace table ff4_raw_json (file variant);
-- load the data
copy into ff4_raw_json
    from @challenge_4_AWS_stage FILE_FORMAT = (TYPE = JSON);

-- check the loaded file
select * from ff4_raw_json;
    
-- 1st level of parsing
-- save to a level 1 table
create
    or replace table ff4_level1 as (
        -- select the key value pair, if value is not nested then cast to string, else keep for next level parsing
        select
            t1.value:Era::string as Era,
            t1.value:Houses as Houses_l1
        from
            ff4_raw_json,
            lateral flatten(file) as t1
    );

-- 2nd level of parsing
-- save to a level 2 table
create
    or replace table ff4_level2 as (
        select
            era,
            t2.value:House::string as House,
            t2.value:Monarchs as Monarchs_l2
        from
            ff4_level1,
            lateral flatten(houses_l1) as t2
    );
    
select * from ff4_level2;

-- 3nd level of parsing
-- save to a level 3 table
create
    or replace table ff4_level3 as (
        select
            t3.index+1::int Inter_House_ID, // use index from lateral flatten
            era,
            house,
            split(t3.value:"Age at Time of Death",' ' )[0]::int as Age_at_Time_of_Death,
            t3.value:"Birth"::date as Birth,
            t3.value:"Burial Place" ::string as Burial_Place,
            t3.value:"Consort\/Queen Consort" [0] ::string as Consort_or_Queen_Consort_1,
            t3.value:"Consort\/Queen Consort" [1] ::string as Consort_or_Queen_Consort_2,
            t3.value:"Consort\/Queen Consort" [2] ::string as Consort_or_Queen_Consort_3,
            t3.value:"Death"::date as Death,
            t3.value:"Duration"::string as Duration,
            t3.value: "End of Reign" ::date as End_of_Reign,
            t3.value:"Name"::string as Name,
            t3.value:"Nickname"[0]::string as Nickname_1,
            t3.value:"Nickname"[1]::string as Nickname_2,
            t3.value:"Nickname"[2]::string as Nickname_3,
            t3.value:"Place of Birth" ::string Place_of_Birth,
            t3.value:"Place of Death" ::string Place_of_Death,
            t3.value: "Start of Reign" ::date Start_of_Reign
        from
            ff4_level2,
            lateral flatten(monarchs_l2) as t3
    );

-- Produce the result table
select
    ROW_NUMBER() OVER (ORDER BY BIRTH) as ID,
    *
    from
        ff4_level3 as t;