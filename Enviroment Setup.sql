-- File format for csv
CREATE FILE FORMAT ff_csv_header TYPE = csv SKIP_HEADER = 0 SKIP_BLANK_LINES = TRUE TRIM_SPACE = TRUE COMMENT = 'Used for Frosty Friday csv without header file load';

CREATE FILE FORMAT ff_csv_skip_header TYPE = csv SKIP_HEADER = 1 SKIP_BLANK_LINES = TRUE TRIM_SPACE = TRUE COMMENT = 'Used for Frosty Friday csv with header file load';

-- File format for json
CREATE FILE FORMAT ff_json TYPE = json strip_outer_array = True COMMENT = 'Used for Frosty Friday json without outer array file load';