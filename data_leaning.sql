-- 1. PostgreSQL CREATE TABLE query


CREATE TABLE messy_customers (
    customer_id   INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    email         VARCHAR(180),
    phone         VARCHAR(50),
    city          VARCHAR(100),
    age           VARCHAR(30),
    signup_date   VARCHAR(30),
    country       VARCHAR(50)
);

-- 2. Load Data

copy messy_customers
FROM '/path/to/messy_customers_1580_rows.csv'
WITH (FORMAT CSV, HEADER TRUE);


-- 3. Inspect your data

SELECT COUNT(*) AS total_rows
FROM messy_customers;


-- 4. Check missing values

select 

	count(*) filter(
		where customer_name is null
	) as missing_names,

	count(*) filter(
		where email is null
	) as missing_emails,

	count(*) filter(
		where phone is null
	) as missing_phone,

	count(*) filter(
		where city is null
	) as missing_city,

	count(*) filter(
		where age is null
	) as missing_age,

	count(*) filter(
		where signup_date is null
	) as missing_date,

	count(*) filter(
		where country is null
	) as missing_country
	
from messy_customers



-- - IS NULL finds actual missing database values.
-- - TRIM(customer_name) removes spaces around the name.
-- - If the result is an empty string, the name is effectively missing.


--  6. Count all missing values

SELECT
    COUNT(*) FILTER (
        WHERE customer_name IS NULL
           OR TRIM(customer_name) = ''
    ) AS missing_names,

    COUNT(*) FILTER (
        WHERE email IS NULL
           OR TRIM(email) = ''
    ) AS missing_emails,

    COUNT(*) FILTER (
        WHERE phone IS NULL
           OR TRIM(phone) = ''
    ) AS missing_phones,

    COUNT(*) FILTER (
        WHERE city IS NULL
           OR TRIM(city) = ''
    ) AS missing_cities,

    COUNT(*) FILTER (
        WHERE age IS NULL
           OR TRIM(age) = ''
    ) AS missing_ages,

    COUNT(*) FILTER (
        WHERE signup_date IS NULL
           OR TRIM(signup_date) = ''
    ) AS missing_dates,

    COUNT(*) FILTER (
        WHERE country IS NULL
           OR TRIM(country) = ''
    ) AS missing_countries

FROM messy_customers;


--7. Lets clean data permanently

-- create a duplicate table for security

create table messy_customers_backup
as
select *
from messy_customers

-- check whether rows are matching

select
	(select count(*) from
	messy_customers) as original_rows,
	(select count(*) from
	messy_customers_backup) as backup_rows



-- lets clean extra spaces and emails, cities, phone numbers and countries

-- preview what will change

select
	customer_id,
	customer_name as old_name,
	trim(customer_name)as new_name,
	email as old_email,
	lower(trim(email)) as new_email
from messy_customers
where customer_name is distinct from trim(customer_name)
or email is distinct from lower(trim(email))
limit 20;

-- Find duplicate emails


select
	lower(trim(email))as cleaned_email,
	count (*) as total_records
from messy_customers
where email is not null and  trim(email) <> ''
group by lower(trim(email))
having count (*) > 1
order by total_records desc;


-- This removes extra spaces and converts empty strings into NULL:

UPDATE messy_customers
SET
    customer_name = NULLIF(TRIM(customer_name), ''),
    email         = NULLIF(LOWER(TRIM(email)), ''),
    phone         = NULLIF(TRIM(phone), ''),
    city          = NULLIF(INITCAP(TRIM(city)), ''),
    country       = NULLIF(UPPER(TRIM(country)), ''),
    signup_date   = NULLIF(TRIM(signup_date), ''),
    age           = NULLIF(TRIM(age), '');



-- This changes negative, zero, non-numeric, and unrealistic ages into NULL:

UPDATE messy_customers
SET age = NULL
WHERE age IS NOT NULL
AND (
    TRIM(age) !~ '^[0-9]+$'
    OR TRIM(age)::NUMERIC NOT BETWEEN 1 AND 120
);


-- Delete confirmed duplicates only

-- If you've inspected the records and confirmed that they are duplicate copies, 
-- this PostgreSQL query keeps the lowest customer_id and deletes the others:

BEGIN;

WITH ranked AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY LOWER(TRIM(email))
            ORDER BY customer_id
        ) AS rn
    FROM messy_customers
    WHERE email IS NOT NULL
      AND TRIM(email) <> ''
)
DELETE FROM messy_customers
WHERE customer_id IN (
    SELECT customer_id
    FROM ranked
    WHERE rn > 1
);

-- Check the result before deciding:
SELECT * FROM messy_customers;

-- COMMIT;   -- Keep the changes
-- ROLLBACK; -- Undo the changes



-- you can remove unrealistic values in contacts

update messy_customers

set
	phone = nullif(trim(phone), '12345')


update messy_customers

set
	phone = nullif(trim(phone), 'not mentioned')

-- or any other values

-- NOTE

-- you can check  that whether the duplicates
-- are eliminated or not by rinnig the query 
-- you have used to find diplicates , 
-- and if you find no column there 
-- then your duplicates are removed 
-- succesfully removed


-- checking for null values in each column

SELECT
    COUNT(*) FILTER (WHERE customer_name IS NULL) AS missing_names,
    COUNT(*) FILTER (WHERE email IS NULL) AS missing_emails,
    COUNT(*) FILTER (WHERE phone IS NULL) AS missing_phones,
    COUNT(*) FILTER (WHERE city IS NULL) AS missing_cities,
    COUNT(*) FILTER (WHERE age IS NULL) AS missing_ages,
    COUNT(*) FILTER (WHERE signup_date IS NULL) AS missing_dates,
    COUNT(*) FILTER (WHERE country IS NULL) AS missing_countries
FROM messy_customers;


-- Check duplicate emails

SELECT LOWER(TRIM(email)), COUNT(*)
FROM messy_customers
WHERE email IS NOT NULL
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;
-- Expected: no confirmed duplicate customer records.


-- Check invalid ages

SELECT *
FROM messy_customers
WHERE age IS NOT NULL
AND (age < 1 OR age > 120);
-- Expected: zero rows.


-- Check duplicate customer IDs

SELECT customer_id, COUNT(*)
FROM messy_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Expected: zero rows.


-- Check date data type

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'messy_customers'
AND column_name = 'signup_date';
-- Expected: date.


-- Check invalid or short phone numbers

SELECT customer_id, phone
FROM messy_customers
WHERE phone IS NOT NULL
AND LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '', 'g')) < 10;
-- Expected: zero rows, assuming your dataset requires at least 10 digits.



-- Getting zero values after running these commands make sure that data has been cleaned