CREATE FILE FORMAT ff_csv_header TYPE = csv SKIP_HEADER = 0 SKIP_BLANK_LINES = TRUE TRIM_SPACE = TRUE COMMENT = 'Used for Frosty Friday csv without header file load';

CREATE FILE FORMAT ff_csv_skip_header TYPE = csv SKIP_HEADER = 1 SKIP_BLANK_LINES = TRUE TRIM_SPACE = TRUE COMMENT = 'Used for Frosty Friday csv with header file load';