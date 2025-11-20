-- =============================================================================
-- VALIDATION QUERIES FOR SNOWFLAKE DATA QUALITY HOL
-- =============================================================================

USE DATABASE dq_tutorial_db;
USE SCHEMA information_schema;

SELECT
    util_db.public.se_grader(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
   SELECT
        'STEP01' AS step,
        (
            SELECT COUNT(*) 
            FROM tables
            where table_name='CUSTOMER'
        ) AS actual,
        1 AS expected,
        'Customer Table is created for Platform College Data Quality HOL' AS description
);

SELECT
    util_db.public.se_grader(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
   SELECT
        'STEP02' AS step,
        (
            SELECT COUNT(*) 
            FROM tables
            where table_name='CUSTOMER_ORDERS'
        ) AS actual,
        1 AS expected,
        'Customer Orders Table is created for Platform College Data Quality HOL' AS description
);

SELECT
    util_db.public.se_grader(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
   SELECT
        'STEP03' AS step,
        (
            SELECT COUNT(*) 
            FROM functions
            where function_name='REFERENTIAL_CHECK'
        ) AS actual,
        1 AS expected,
        'Custom DMF REFERENTIAL_CHECK is created for Platform College Data Quality HOL' AS description
);

SELECT
    util_db.public.se_grader(
        step,
        (actual = expected),
        actual,
        expected,
        description
    ) AS graded_results
FROM (
   SELECT
        'STEP04' AS step,
        (
            SELECT COUNT(*) 
            FROM functions
            where function_name='VOLUME_CHECK'
        ) AS actual,
        1 AS expected,
        'Custom DMF VOLUME_CHECK is created for Platform College Data Quality HOL' AS description
);
 

--If all validations return ✅, you have completed the Snowflake Data Quality HOL 🎉
