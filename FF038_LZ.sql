-- Supplied Code
-- Create first table
CREATE TABLE FF38_employees (
    id INT,
    name VARCHAR(50),
    department VARCHAR(50)
);

-- Insert example data into first table
INSERT INTO
    FF38_employees (id, name, department)
VALUES
    (1, 'lice', 'Sales'),
    (2, 'Bob', 'Marketing');

-- Create second table
CREATE TABLE FF38_sales (
    id INT,
    employee_id INT,
    sale_amount DECIMAL(10, 2)
);

-- Insert example data into second table
INSERT INTO
    FF38_sales (id, employee_id, sale_amount)
VALUES
    (1, 1, 100.00),
    (2, 1, 200.00),
    (3, 2, 150.00);

-- Create view that combines both tables
CREATE VIEW FF38_employee_sales AS
SELECT
    e.id,
    e.name,
    e.department,
    s.sale_amount
FROM
    FF38_employees e
    JOIN FF38_sales s ON e.id = s.employee_id;

--
-- Create stream to track change
create
or replace stream ff38_stream on view FF38_employee_sales;

-- Delete 1 sales from the underlaying table for the view
delete from
    FF38_sales
where
    id = 3;

-- For checks if needed
-- Check the view, one row is removed
--     SELECT * FROM FF38_employee_sales;
-- Check the stream, one row is added
--     select * from ff38_stream;
--
-- Create table for tracking deleted row from stream
create
or replace table ff38_deleted_sales (
    ID int,
    NAME string,
    DEPARTMENT string,
    SALE_AMOUNT number,
    METADATA $ ROW_ID string,
    METADATA $ ACTION string,
    METADATA $ ISUPDATE boolean
);

-- Add values to deleted sales table
insert into
    ff38_deleted_sales
select
    *
from
    ff38_stream;

-- For check if needed
-- Compare row count as they move between different stage when delete happens
select
    count(*) as row_count,
    'base table' as source
from
    FF38_sales
union
select
    count(*) as row_count,
    'view' as source
from
    FF38_employee_sales
union
select
    count(*) as row_count,
    'stream' as source
from
    ff38_stream
union
select
    count(*) as row_count,
    'deleted table' as source
from
    ff38_deleted_sales;