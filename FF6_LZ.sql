-- set environment
create schema challenge_6;
use schema challenge_6;
-- Due to colume in csv contains ', need to create a separete file format to load
create
or replace file format ff6_csv type = csv,
skip_header = 0,
field_optionally_enclosed_by = '"';
-- Create loading stage
create
or replace stage challenge_6_AWS_stage url = 's3://frostyfridaychallenges/challenge_6/' file_format = ff6_csv;
-- Not required: Check the files in the staging location
list @challenge_6_AWS_stage;
-- Not required: Checking out the data in the file
select
    metadata$filename,
    metadata$file_row_number,
    $1,
    $2,
    $3,
    $4,
    $5,
    $6,
    $7,
    $8
from
    @challenge_6_AWS_stage
where
    metadata$filename = 'challenge_6/westminster_constituency_points.csv';
    -- Create table for loading data
    create
    or replace table ff6_westminster_constituency_points (
        constituency string(100),
        sequence_num int,
        longitude double,
        latitude double,
        part int
    );
-- Add values into the table
insert into
    ff6_westminster_constituency_points (
        select
            $1,
            $2,
            $3,
            $4,
            $5
        from
            @challenge_6_AWS_stage
        where
            metadata$filename = 'challenge_6/westminster_constituency_points.csv'
            and METADATA$file_row_number != 1-- skip the header row
    );
-- The approach that I used is to create string that list the coordinates, then cast it as a line, then polygon
create
or replace temp table westminster_point as (
    select
        constituency,
        part,
        sequence_num,
        listagg(longitude || ' ' || latitude) as str_point //create string that concat coordinates
    from
        ff6_westminster_constituency_points
    group by
        constituency,
        part,
        sequence_num
    );
-- From above, create line from the points created, then polygon
create
or replace table westminster_polygon as (
    select
        constituency,
        part,
        listagg(str_point, ', ') within group (
            order by
                sequence_num
        ) as str_line //create line that concat all points
        ,
        'LINESTRING(' || str_line || ')' as str_line_2 //attach LINESTRING as keyword for spatial function
        ,
        st_makepolygon (to_geography (str_line_2)) as polygon //create polygon
    from
        westminster_point
    group by
        constituency,
        part
);
-- The field Part is used to make creating polygon easier, now remove it to aggragte the polygons
create
or replace table westminster_combined as (
    select
        constituency as constituency,
        st_collect(polygon) as polygon //aggragte the polygon field
    from
        westminster_polygon
    group by
        constituency
);
-- Repeat as above for nations and regions data
-- Not required: used for checking
select
    metadata$filename,
    metadata$file_row_number,
    $1,
    $2,
    $3,
    $4,
    $5,
    $6,
    $7,
    $8
from
    @challenge_6_AWS_stage
where
    metadata$filename = 'challenge_6/nations_and_regions.csv';
-- create table
create
or replace table ff6_nations_and_regions_points (
    nation_or_region_name string,
    type string,
    sequence_num int,
    longitude double,
    latitude double,
    part int
);
-- load table
insert into
    ff6_nations_and_regions_points (
        select
            $1,
            $2,
            $3,
            $4,
            $5,
            $6
        from
            @challenge_6_AWS_stage
        where
            metadata$filename = 'challenge_6/nations_and_regions.csv'
            and METADATA$file_row_number != 1 -- skip the header row
    );
-- create points
create
or replace temp table nations_and_regions_point as (
    select
        nation_or_region_name,
        type,
        part,
        sequence_num,
        listagg(longitude || ' ' || latitude) as str_point
    from
        ff6_nations_and_regions_points
    group by
        nation_or_region_name,
        type,
        part,
        sequence_num
);
-- create polygon
create
or replace table nations_and_regions_polygon as (
    select
        nation_or_region_name,
        type,
        part,
        listagg(str_point, ', ') within group (
            order by
                sequence_num
        ) as str_line,
        'LINESTRING(' || str_line || ')' as str_line_2,
        st_makepolygon(to_geography(str_line_2)) as polygon
    from
        nations_and_regions_point
    group by
        nation_or_region_name,
        type,
        part
);
-- aggregate
create
or replace table nations_and_regions_combined as (
    select
        nation_or_region_name as name,
        st_collect(polygon) as polygon
    from
        nations_and_regions_polygon
    group by
        nation_or_region_name,
        type
);
-- Use cross join to append all combinations from two tables, then use spatial intersection to filter out not needed.
select
    n.name as NATION_OR_REGION,
    count(1) as INTERSECTING_CONSITUENCIES
from
    WESTMINSTER_COMBINED w
    cross join nations_and_regions_combined n
where
    st_intersects(w.polygon, n.polygon)
group by
    n.name
order by
    INTERSECTING_CONSITUENCIES desc;