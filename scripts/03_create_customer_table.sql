-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 03: CREATE CUSTOMER TABLE WITH PII DATA
-- =============================================================================
-- Purpose: Create schema with managed access and populate with sample PII data
-- Prerequisites: Script 02 completed, access as user with itc_admin role
-- Estimated Time: 5 minutes
-- =============================================================================

-- =============================================================================
-- SWITCH TO ITC_ADMIN ROLE
-- =============================================================================
-- Execute as richmond@itcrowd or another user with itc_admin role
USE ROLE itc_admin;

-- =============================================================================
-- CREATE MANAGED ACCESS SCHEMA
-- =============================================================================
-- Managed Access Schemas enforce centralized privilege management
-- Only the schema owner can manage grants, preventing object owners from 
-- making arbitrary grants
CREATE SCHEMA REYNHOLM_IND_DATA.BASEMENT WITH MANAGED ACCESS;

-- =============================================================================
-- CREATE CUSTOMER TABLE WITH FAKE PII DATA
-- =============================================================================
-- This creates a table with 200 rows of realistic but fake PII
-- Data is sourced from Snowflake sample data (TPCDS dataset)
-- C_BIRTH_COUNTRY and OPTIN columns are randomly populated for demo purposes
CREATE TABLE CUSTOMERS AS (
    SELECT
        a.C_SALUTATION,
        a.C_FIRST_NAME,
        a.C_LAST_NAME,
        CASE UNIFORM(1, 3, RANDOM()) 
            WHEN 1 THEN 'UK' 
            WHEN 2 THEN 'US' 
            ELSE 'FRANCE' 
        END AS C_BIRTH_COUNTRY,
        a.C_EMAIL_ADDRESS,
        b.CD_GENDER,
        b.CD_CREDIT_RATING,
        CASE UNIFORM(1, 3, RANDOM()) 
            WHEN 1 THEN 'YES' 
            WHEN 2 THEN 'NO' 
            ELSE NULL 
        END AS OPTIN
    FROM
        SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER a,
        SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_DEMOGRAPHICS b
    WHERE
        a.C_CUSTOMER_SK = b.CD_DEMO_SK AND
        a.C_SALUTATION IS NOT NULL AND
        a.C_FIRST_NAME IS NOT NULL AND
        a.C_LAST_NAME IS NOT NULL AND
        a.C_BIRTH_COUNTRY IS NOT NULL AND
        a.C_EMAIL_ADDRESS IS NOT NULL AND 
        b.CD_GENDER IS NOT NULL AND
        b.CD_CREDIT_RATING IS NOT NULL
    LIMIT 200
);

-- =============================================================================
-- GRANT DATABASE AND SCHEMA USAGE RIGHTS
-- =============================================================================
-- Grant usage rights on database to all roles that need access
GRANT USAGE ON DATABASE REYNHOLM_IND_DATA TO ROLE itc_admin;
GRANT USAGE ON DATABASE REYNHOLM_IND_DATA TO ROLE marketing;
GRANT USAGE ON DATABASE REYNHOLM_IND_DATA TO ROLE it;
GRANT USAGE ON DATABASE REYNHOLM_IND_DATA TO ROLE executive;
GRANT USAGE ON DATABASE REYNHOLM_IND_DATA TO ROLE infosec;

-- Grant usage rights on schema to all roles
GRANT USAGE ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE itc_admin;
GRANT USAGE ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE marketing;
GRANT USAGE ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE it;
GRANT USAGE ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE executive;
GRANT USAGE ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE infosec;

-- =============================================================================
-- GRANT SELECT RIGHTS ON CUSTOMERS TABLE
-- =============================================================================
-- Grant select privileges to roles that need to query the data
-- Note: itc_admin already has ownership, so no SELECT grant needed
GRANT SELECT ON TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS TO ROLE marketing;
GRANT SELECT ON TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS TO ROLE it;
GRANT SELECT ON TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS TO ROLE executive;

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- Verify the table was created and contains data
SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS LIMIT 50;

-- Check row count
SELECT COUNT(*) AS total_rows FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;

-- Verify data distribution by birth country
SELECT 
    C_BIRTH_COUNTRY, 
    COUNT(*) AS row_count 
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
GROUP BY C_BIRTH_COUNTRY;

-- Verify OPTIN distribution
SELECT 
    OPTIN, 
    COUNT(*) AS row_count 
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
GROUP BY OPTIN;

-- Verify grants
SHOW GRANTS ON TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;

-- =============================================================================
-- TEST ACCESS FROM DIFFERENT ROLES
-- =============================================================================
-- Test as marketing role (should have access)
USE ROLE marketing;
SELECT COUNT(*) FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;
-- This should return 200 rows

-- Test as infosec role (should NOT have access yet)
USE ROLE infosec;
-- SELECT COUNT(*) FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;
-- This should fail - infosec does not have SELECT privileges

-- Return to itc_admin role
USE ROLE itc_admin;

-- =============================================================================
-- KEY CONCEPTS DEMONSTRATED
-- =============================================================================
-- 1. Managed Access Schema: Centralized privilege management
-- 2. Separation of Duties: Different roles have different access levels
-- 3. Sample Data Usage: Realistic PII without real customer data
-- 4. Random Data Generation: UNIFORM() function for randomizing values

-- =============================================================================
-- END OF SCRIPT 03
-- =============================================================================
-- Next Step: Run 04_setup_policy_framework.sql
-- =============================================================================

