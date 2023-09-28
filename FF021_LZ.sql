-- Supplied code
create
or replace table FF21_hero_powers (
    hero_name VARCHAR(50),
    flight VARCHAR(50),
    laser_eyes VARCHAR(50),
    invisibility VARCHAR(50),
    invincibility VARCHAR(50),
    psychic VARCHAR(50),
    magic VARCHAR(50),
    super_speed VARCHAR(50),
    super_strength VARCHAR(50)
);

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'The Impossible Guard',
        '++',
        '-',
        '-',
        '-',
        '-',
        '-',
        '-',
        '+'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'The Clever Daggers',
        '-',
        '+',
        '-',
        '-',
        '-',
        '-',
        '-',
        '++'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'The Quick Jackal',
        '+',
        '-',
        '++',
        '-',
        '-',
        '-',
        '-',
        '-'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'The Steel Spy',
        '-',
        '++',
        '-',
        '-',
        '+',
        '-',
        '-',
        '-'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'Agent Thundering Sage',
        '++',
        '+',
        '-',
        '-',
        '-',
        '-',
        '-',
        '-'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'Mister Unarmed Genius',
        '-',
        '-',
        '-',
        '-',
        '-',
        '-',
        '-',
        '-'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'Doctor Galactic Spectacle',
        '-',
        '-',
        '-',
        '++',
        '-',
        '-',
        '-',
        '+'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'Master Rapid Illusionist',
        '-',
        '-',
        '-',
        '-',
        '++',
        '-',
        '+',
        '-'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'Galactic Gargoyle',
        '+',
        '-',
        '-',
        '-',
        '-',
        '-',
        '++',
        '-'
    );

insert into
    FF21_hero_powers (
        hero_name,
        flight,
        laser_eyes,
        invisibility,
        invincibility,
        psychic,
        magic,
        super_speed,
        super_strength
    )
values
    (
        'Alley Cat',
        '-',
        '++',
        '-',
        '-',
        '-',
        '-',
        '-',
        '+'
    );

-- Create table 1 for pivot long the input table
create
or replace temp table ff21_t1 as
select
    hero_name,
    power,
    strength
from
    ff21_hero_powers unpivot(
        strength for power in (
            FLIGHT,
            LASER_EYES,
            INVISIBILITY,
            INVINCIBILITY,
            PSYCHIC,
            MAGIC,
            SUPER_SPEED,
            SUPER_STRENGTH
        )
    )
where
    strength != '-';

-- Pivot wide again with the filter results and change column names
create
or replace temp table ff21_t2 as
select
    *
from
    ff21_t1 pivot(max(power) for strength in ('++', '+')) as t (hero_name, main_power, secondary_power);