-- Supplied code
create
or replace file format FF16_json_ff type = json strip_outer_array = TRUE;

create
or replace stage challenge_16_aws_stage url = 's3://frostyfridaychallenges/challenge_16/' file_format = FF16_json_ff;

select
    *
from
    @challenge_16_aws_stage;

create
or replace table FF16 as
select
    t.$ 1 :word :: text word,
    t.$ 1 :url :: text url,
    t.$ 1 :definition :: variant definition
from
    @challenge_16_aws_stage (
        file_format = > 'FF16_json_ff',
        pattern = > '.*week16.*'
    ) t;

-- Create temp table
create temp table ff16 as
select
    word,
    url,
    t0.value :partOfSpeech :: string as part_of_speech,
    t0.value :synonyms :: string as general_synonyms,
    t0.value :antonyms :: string as general_antonyms,
    t1.value :definition :: string as definition,
    t1.value :example :: string as example_if_applicable,
    t1.value :synonyms :: string as definitional_synonyms,
    t1.value :antonyms :: string as definitional_antonyms
from
    ff16,
    lateral flatten (definition [0] :meanings) as t0,
    lateral flatten (t0.value :definitions) as t1;

-- Query to check Count
select
    count(word),
    count(distinct(word))
from
    ff16;