-- Start-up code
CREATE
OR REPLACE TABLE ff58_measurements (
    height INT,
    weight INT,
    age INT,
    gender VARCHAR(),
    id INT
);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (188, 145, 87, 'other', 2);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (215, 725, 30, 'male', 3);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (159, 48, 116, 'female', 4);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (243, 204, 6, 'other', 5);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (232, 306, 30, 'male', 6);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (261, 602, 62, 'other', 7);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (143, 829, 113, 'female', 8);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (62, 190, 86, 'male', 9);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (41, 178, 74, 'other', 1);

insert into
    ff58_measurements (height, weight, age, gender, id)
values
    (249, 15, 73, 'male', 10);

-- basic way
select
    height,
    weight * 1.1 as weight,
    age -1 as age,
    id,
    iff(gender = 'other', 'unknown', gender) as gender
from
    ff58_measurements
order by
    id;

-- with replace
select
    * replace (
        weight * 1.1 as weight,
        age -1 as age,
        iff(gender = 'other', 'unknown', gender) as gender
    )
from
    ff58_measurements
order by
    id;