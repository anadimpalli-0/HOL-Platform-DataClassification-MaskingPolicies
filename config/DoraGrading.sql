-- =============================================================================
-- SNOWFLAKE PII HOL - DORA GRADING VALIDATION SCRIPT
-- =============================================================================
-- Purpose: Validate successful completion of the PII Data Protection HOL
-- Prerequisites: Scripts 01-06 completed, SE_GREETER.sql executed
-- Instructions: Run each validation query and verify all return ✅
-- =============================================================================

-- =============================================================================
-- SET CONTEXT
-- =============================================================================
USE DATABASE REYNHOLM_IND_DATA;
USE SCHEMA INFORMATION_SCHEMA;

-- =============================================================================
-- VALIDATION 01: DATABASE EXISTS
-- =============================================================================
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
            FROM SNOWFLAKE.INFORMATION_SCHEMA.DATABASES
            WHERE DATABASE_NAME = 'REYNHOLM_IND_DATA'
        ) AS actual,
        1 AS expected,
        'Database REYNHOLM_IND_DATA is created for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 02: SCHEMA WITH MANAGED ACCESS EXISTS
-- =============================================================================
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
            FROM SNOWFLAKE.INFORMATION_SCHEMA.SCHEMATA
            WHERE SCHEMA_NAME = 'BASEMENT'
                AND CATALOG_NAME = 'REYNHOLM_IND_DATA'
                AND IS_MANAGED_ACCESS = 'YES'
        ) AS actual,
        1 AS expected,
        'Schema BASEMENT with Managed Access is created for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 03: CUSTOMERS TABLE EXISTS WITH CORRECT ROW COUNT
-- =============================================================================
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
            FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
        ) AS actual,
        200 AS expected,
        'CUSTOMERS table with 200 rows is created for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 04: ROW ACCESS MAPPING TABLE EXISTS
-- =============================================================================
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
            FROM TABLES
            WHERE TABLE_NAME = 'ROW_ACCESS_MAPPING'
                AND TABLE_SCHEMA = 'BASEMENT'
        ) AS actual,
        1 AS expected,
        'ROW_ACCESS_MAPPING table is created for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 05: ROW ACCESS MAPPING HAS ACCESS RULES
-- =============================================================================
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
        'STEP05' AS step,
        (
            SELECT COUNT(*) 
            FROM REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING
        ) AS actual,
        6 AS expected,
        'ROW_ACCESS_MAPPING table contains 6 access rules for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 06: ROW ACCESS POLICY EXISTS
-- =============================================================================
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
        'STEP06' AS step,
        (
            SELECT COUNT(*) 
            FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
            WHERE POLICY_DB = 'REYNHOLM_IND_DATA'
                AND POLICY_SCHEMA = 'BASEMENT'
                AND POLICY_NAME = 'MAKES_NO_SENSE'
                AND POLICY_KIND = 'ROW_ACCESS_POLICY'
                AND REF_DATABASE_NAME = 'REYNHOLM_IND_DATA'
                AND REF_SCHEMA_NAME = 'BASEMENT'
                AND REF_ENTITY_NAME = 'CUSTOMERS'
                AND REF_ENTITY_DOMAIN = 'TABLE'
        ) AS actual,
        1 AS expected,
        'Row Access Policy MAKES_NO_SENSE is applied to CUSTOMERS table for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 07: MASKING POLICY EXISTS
-- =============================================================================
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
        'STEP07' AS step,
        (
            SELECT COUNT(*) 
            FROM SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES
            WHERE POLICY_DB = 'REYNHOLM_IND_DATA'
                AND POLICY_SCHEMA = 'BASEMENT'
                AND POLICY_NAME = 'HIDE_OPTOUTS'
                AND POLICY_KIND = 'MASKING_POLICY'
                AND REF_DATABASE_NAME = 'REYNHOLM_IND_DATA'
                AND REF_SCHEMA_NAME = 'BASEMENT'
                AND REF_ENTITY_NAME = 'CUSTOMERS'
                AND REF_COLUMN_NAME = 'C_EMAIL_ADDRESS'
        ) AS actual,
        1 AS expected,
        'Masking Policy HIDE_OPTOUTS is applied to C_EMAIL_ADDRESS column for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 08: CUSTOM ROLES EXIST
-- =============================================================================
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
        'STEP08' AS step,
        (
            SELECT COUNT(*) 
            FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
            WHERE NAME IN ('ITC_ADMIN', 'MARKETING', 'IT', 'INFOSEC', 'EXECUTIVE')
                AND DELETED_ON IS NULL
        ) AS actual,
        5 AS expected,
        'Five custom roles are created for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 09: USERS EXIST
-- =============================================================================
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
        'STEP09' AS step,
        (
            SELECT COUNT(*) 
            FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
            WHERE NAME LIKE '%@itcrowd'
                AND DELETED_ON IS NULL
        ) AS actual,
        6 AS expected,
        'Six demo users are created for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION 10: ROLE GRANTS TO USERS
-- =============================================================================
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
        'STEP10' AS step,
        (
            SELECT COUNT(DISTINCT GRANTEE_NAME) 
            FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
            WHERE ROLE IN ('ITC_ADMIN', 'MARKETING', 'IT', 'INFOSEC', 'EXECUTIVE')
                AND DELETED_ON IS NULL
        ) AS actual,
        6 AS expected,
        'Roles are granted to users for Platform College PII HOL' AS description
);

-- =============================================================================
-- VALIDATION SUMMARY
-- =============================================================================
-- If all validations above return ✅, you have successfully completed the 
-- Snowflake PII Data Protection HOL! 🎉
--
-- Validation Checklist:
-- ✅ STEP01: Database created
-- ✅ STEP02: Managed Access Schema created
-- ✅ STEP03: Customer table with 200 rows
-- ✅ STEP04: Row access mapping table created
-- ✅ STEP05: Access rules populated
-- ✅ STEP06: Row access policy applied
-- ✅ STEP07: Masking policy applied
-- ✅ STEP08: Custom roles created
-- ✅ STEP09: Demo users created
-- ✅ STEP10: Roles granted to users

-- =============================================================================
-- TROUBLESHOOTING GRADING ISSUES
-- =============================================================================
/*
If a validation fails (returns ❌):

STEP01-02 Failure: Database or schema not created
- Solution: Re-run scripts 02 and 03

STEP03 Failure: Wrong row count or table missing
- Solution: Re-run script 03, verify sample data access

STEP04-05 Failure: Mapping table issues
- Solution: Re-run script 04 and verify script 05 insert statement

STEP06 Failure: Row access policy not applied
- Solution: Re-run script 05, check SHOW ROW ACCESS POLICIES

STEP07 Failure: Masking policy not applied
- Solution: Re-run script 06, check SHOW MASKING POLICIES

STEP08-10 Failure: Roles or users missing
- Solution: Re-run scripts 01 and 02

Account Usage Latency:
- STEP06, STEP07, STEP08, STEP09, STEP10 use ACCOUNT_USAGE views
- These views have latency (up to 2 hours for some views)
- If you just completed the lab, wait 5-10 minutes and retry
- Alternatively, check using SHOW commands instead:
  - SHOW ROW ACCESS POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;
  - SHOW MASKING POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;
  - SHOW ROLES LIKE 'ITC_ADMIN';
  - SHOW USERS LIKE '%itcrowd%';
*/

-- =============================================================================
-- ALTERNATIVE VALIDATION (If Account Usage has latency)
-- =============================================================================
-- Use these immediate validation queries if ACCOUNT_USAGE is delayed

-- Check Row Access Policy (immediate)
-- SHOW ROW ACCESS POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;

-- Check Masking Policy (immediate)
-- SHOW MASKING POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;

-- Check Policy References (immediate)
-- SELECT * FROM TABLE(
--     INFORMATION_SCHEMA.POLICY_REFERENCES(
--         REF_ENTITY_NAME => 'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS',
--         REF_ENTITY_DOMAIN => 'TABLE'
--     )
-- );

-- Check Roles (immediate)
-- SHOW ROLES LIKE 'ITC_ADMIN';

-- Check Users (immediate)
-- SHOW USERS LIKE '%itcrowd%';

-- =============================================================================
-- NEXT STEPS AFTER SUCCESSFUL GRADING
-- =============================================================================
/*
After completing all validations:

1. ✅ Review the lab experience and key learnings
2. 📸 Take screenshots of successful validation results
3. 📝 Document any challenges or questions
4. 🧹 Run the cleanup script: scripts/09_cleanup.sql
5. 💰 Verify warehouse is suspended to avoid costs
6. 📊 Review Account Usage for queries and access patterns
7. 🎓 Share feedback to improve the lab experience

Optional Advanced Steps:
- Try the data sharing demonstration with a second account
- Explore object tagging (script 07) if not already completed
- Run data classification (script 08) if not already completed
- Experiment with different policy configurations
- Test cross-database policy enforcement

Thank you for completing the Snowflake PII Data Protection HOL!
*/

-- =============================================================================
-- END OF GRADING SCRIPT
-- =============================================================================

