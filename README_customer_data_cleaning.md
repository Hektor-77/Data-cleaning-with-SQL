# Customer Data Cleaning Project (PostgreSQL)

## Project Overview

This project focuses on cleaning a deliberately messy customer dataset
using **PostgreSQL**. The goal was to identify and correct common
data-quality problems so the data could be used more reliably for
reporting and analysis.

The dataset contains customer information such as names, email
addresses, phone numbers, cities, ages, signup dates, and countries.

> **Dataset note:** The working dataset contains 1,580 records and was
> created for data-cleaning practice. Replace this note if your final
> dataset has a different row count.

## Project Objectives

-   Identify missing, blank, and whitespace-only values.
-   Standardize inconsistent text formats.
-   Validate ages and handle invalid values.
-   Clean and validate email addresses.
-   Identify invalid or incomplete phone numbers.
-   Standardize signup dates and use an appropriate date data type.
-   Detect duplicate records and investigate possible duplicate
    customers.
-   Preserve a backup of the original data.
-   Prepare a cleaner dataset for further analysis.

## Tools and Technologies

-   **PostgreSQL** --- database and SQL data-cleaning operations.
-   **pgAdmin / psql** --- database management and query execution (keep
    the one you actually used).
-   **CSV** --- source data format.

## Dataset Structure

The dataset includes these fields:

  Column            Description
  ----------------- ------------------------
  `customer_id`     Customer identifier
  `customer_name`   Customer name
  `email`           Customer email address
  `phone`           Customer phone number
  `city`            Customer city
  `age`             Customer age
  `signup_date`     Customer signup date
  `country`         Customer country

## Before Cleaning: Raw Data

The original dataset contained data-quality issues, including missing
values, inconsistent capitalization and spacing, malformed contact
details, mixed date formats, invalid ages, and duplicate-like records.

```{=html}
<!-- Add your raw-data screenshot in the space below. -->
```
![Raw / messy dataset screenshot](images/messy-data.png)

*Figure 1. Screenshot of the dataset before cleaning. Replace
`images/messy-data.png` with your image path or filename.*

## Cleaning Process

### 1. Handling Missing Values

-   Identified SQL `NULL` values.
-   Checked for empty strings and values containing only spaces.
-   Used trimming and null-handling logic to treat blank values
    consistently.
-   Kept genuinely unknown values as `NULL` rather than inventing
    information.

**SQL functions / concepts:** `IS NULL`, `TRIM()`, `BTRIM()`,
`NULLIF()`.

### 2. Text Standardization

Standardized text fields to remove unwanted spaces and make formatting
consistent.

Examples of the transformations used:

-   Email addresses: trimmed and converted to lowercase.
-   Names and city names: trimmed and formatted consistently.
-   Country names: trimmed and standardized in capitalization.

**SQL functions:** `TRIM()`, `LOWER()`, `UPPER()`, `INITCAP()`.

### 3. Age Validation

-   Identified missing and blank age values.
-   Detected non-numeric values, such as ages entered as words.
-   Flagged values outside the chosen validation range of 1--120.
-   Treated invalid or unknown ages as `NULL` rather than guessing.

**SQL concepts / functions:** `CASE`, regular-expression matching (`~`
and `!~`), `BTRIM()`, `NULLIF()`, numeric conversion.

### 4. Email Cleaning and Validation

-   Removed leading and trailing spaces.
-   Converted email addresses to lowercase.
-   Identified missing and malformed email values.
-   Compared normalized email addresses when looking for possible
    duplicates.

**SQL functions / concepts:** `LOWER()`, `TRIM()`, regular expressions,
`GROUP BY`, `HAVING COUNT(*)`.

### 5. Phone Number Cleaning

-   Identified missing phone values.
-   Checked the number of digits after ignoring separators and other
    non-digit characters.
-   Flagged short or clearly invalid values (for example, a five-digit
    placeholder).
-   Kept phone numbers as text so leading zeros and country-code
    prefixes would not be lost.

**SQL functions:** `REGEXP_REPLACE()`, `LENGTH()`, `TRIM()`.

*The minimum valid length should be based on the countries and
phone-number rules relevant to the dataset.*

### 6. Signup Date Standardization

-   Identified mixed date representations, including day-month-year
    values separated by hyphens or slashes.
-   Used explicit date-format masks when parsing supported formats.
-   Checked for missing or unconverted dates.
-   Used PostgreSQL's `DATE` data type for the cleaned date field.

**SQL functions / concepts:** `TO_DATE()`, `TRIM()`, regular
expressions, `CASE`, `ALTER TABLE`, `DATE`.

*Date parsing requires confirming the source convention (for example,
`DD/MM/YYYY`). Unrecognized or ambiguous dates should be investigated
rather than silently assumed.*

### 7. Duplicate Investigation

-   Grouped normalized email addresses to find repeated values.
-   Inspected matching customer records before deciding whether they
    represented duplicate customers.
-   Used window functions such as `ROW_NUMBER()` to rank records when
    reviewing duplicates.
-   Avoided treating a shared email address alone as proof that two
    records were the same customer.

**SQL concepts / functions:** `LOWER()`, `TRIM()`, `GROUP BY`, `HAVING`,
`ROW_NUMBER()`, `PARTITION BY`.

### 8. Backup and Data Integrity

-   Preserved a backup table before making permanent changes.
-   Used `UPDATE` statements for data corrections.
-   Checked results after changes.
-   Used transactions (`BEGIN`, `COMMIT`, `ROLLBACK`) where appropriate
    to control changes.

**SQL concepts:** `CREATE TABLE AS`, `UPDATE`, `BEGIN`, `COMMIT`,
`ROLLBACK`, primary keys.

## After Cleaning: Cleaned Data

The cleaned dataset is intended to have consistent text formatting,
appropriately handled missing values, validated ages and contact fields,
standardized signup dates, and investigated duplicate records.

```{=html}
<!-- Add your cleaned-data screenshot in the space below. -->
```
![Cleaned dataset screenshot](images/cleaned-data.png)

*Figure 2. Screenshot of the dataset after cleaning. Replace
`images/cleaned-data.png` with your image path or filename.*

## Validation and Quality Checks

The following checks should be run against the final table before
describing the dataset as fully validated:

-   [ ] Confirm missing-value counts are understood and appropriate.
-   [ ] Confirm text fields have no unintended leading or trailing
    spaces.
-   [ ] Confirm ages are numeric and within the selected validation
    range, where present.
-   [ ] Review invalid or missing email addresses.
-   [ ] Review phone numbers against the relevant country-specific
    rules.
-   [ ] Confirm `signup_date` has the `DATE` data type and review
    unparsed values.
-   [ ] Confirm duplicate customer records were investigated and only
    true duplicates were removed.
-   [ ] Confirm `customer_id` is unique and the primary key is intact.
-   [ ] Compare the cleaned table with the backup to ensure no
    unintended data loss occurred.

## Key SQL Functions and Concepts Practiced

  Function / concept                Purpose in this project
  --------------------------------- -------------------------------------------------
  `TRIM()` / `BTRIM()`              Remove leading and trailing whitespace
  `LOWER()`                         Standardize email capitalization
  `UPPER()`                         Standardize country capitalization
  `INITCAP()`                       Apply title-style capitalization
  `NULLIF()`                        Convert empty strings to `NULL`
  `CASE`                            Apply conditional cleaning and validation rules
  `REGEXP_REPLACE()`                Remove non-digit characters for phone checks
  `LENGTH()`                        Check the number of digits in a phone value
  `TO_DATE()`                       Parse text dates using an explicit format
  `GROUP BY` / `HAVING`             Identify repeated normalized values
  `ROW_NUMBER()`                    Rank records within duplicate groups
  `COUNT(*) FILTER (WHERE ...)`     Count records meeting a condition
  `UPDATE`                          Apply corrections to existing rows
  `ALTER TABLE`                     Change a column's data type
  `CREATE TABLE AS`                 Create a backup copy of table data
  `BEGIN` / `COMMIT` / `ROLLBACK`   Manage database transactions

## Project Outcome

This project provided practical experience in profiling, cleaning,
standardizing, validating, and checking relational data using
PostgreSQL. It also demonstrated why data-cleaning decisions should be
based on the meaning of each field: unknown values should not be
fabricated, and possible duplicates should be reviewed before deletion.

**Final status:** Complete the validation checklist above and update
this section with the results from your final SQL checks. Do not claim
that every quality check passed until you have verified it.

## Possible Next Steps

-   Perform exploratory data analysis (EDA).
-   Calculate customer counts by country and city.
-   Analyze age distributions.
-   Examine customer signup trends over time.
-   Build visualizations or a dashboard using the cleaned data.

## Repository Contents

Add or update this list to match the files you publish:

-   `README.md` --- project documentation.
-   `messy_customers_1580_rows.csv` --- original source dataset, if you
    choose to publish it.
-   `messy_customers_1580_rows.sql` --- SQL dataset script, if you
    choose to publish it.
-   `images/messy-data.png` --- screenshot of the raw data.
-   `images/cleaned-data.png` --- screenshot of the cleaned data.

------------------------------------------------------------------------

*Prepared as a SQL data-cleaning portfolio project using PostgreSQL.*
