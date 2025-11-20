-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 05: ROW ACCESS POLICY
-- =============================================================================
-- Purpose: Create and apply row access policies for data filtering
-- Prerequisites: Script 04 completed, access as infosec, securityadmin, itc_admin
-- Estimated Time: 10 minutes
-- =============================================================================

-- =============================================================================
-- POPULATE ROW ACCESS MAPPING TABLE
-- =============================================================================
-- Execute as moss@itcrowd or another user with infosec role
USE ROLE infosec;

-- Insert access rules defining which roles can see which country data
-- Column definitions:
--   role_name: The Snowflake role
--   national_letter: Country code pattern (used with LIKE operator)
--   allowed: 'TRUE' or 'FALSE' indicating if access is granted
INSERT INTO REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING
VALUES
    ('ACCOUNTADMIN', '', 'FALSE'),         -- No data access for ACCOUNTADMIN
    ('ITC_ADMIN', '', 'FALSE'),            -- No data access for ITC_ADMIN
    ('MARKETING', 'UK', 'TRUE'),           -- Marketing sees UK customers only
    ('IT', 'US', 'TRUE'),                  -- IT sees US customers only
    ('INFOSEC', '', 'FALSE'),              -- No data access for INFOSEC
    ('EXECUTIVE', 'FRANCE', 'TRUE');       -- Executive sees France customers only

-- Verify the mapping data
SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING ORDER BY role_name;

-- =============================================================================
-- CREATE ROW ACCESS POLICY
-- =============================================================================
-- This policy filters rows based on role and country
-- Policy logic:
--   1. Check if current role has access to the requested country
--   2. Special case for data shares (REYNHOLM_IND_DATA_SHARE)
--   3. Default deny if no rules match
CREATE OR REPLACE ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense 
AS (C_BIRTH_COUNTRY VARCHAR) RETURNS BOOLEAN ->
    CASE
        -- Check for role-based access using the mapping table
        WHEN EXISTS ( 
            SELECT 1 FROM REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING
            WHERE role_name = CURRENT_ROLE()
                AND C_BIRTH_COUNTRY LIKE national_letter
                AND allowed = 'TRUE'
        ) THEN TRUE
        
        -- Special control for secure data sharing
        -- Allows UK data to be visible through the share
        WHEN (
            INVOKER_SHARE() IN ('REYNHOLM_IND_DATA_SHARE')
            AND C_BIRTH_COUNTRY = 'UK'
        ) THEN TRUE
        
        -- Default deny - security best practice
        ELSE FALSE
    END
;

-- =============================================================================
-- GRANT POLICY APPLICATION RIGHTS
-- =============================================================================
-- The security admin grants the right to apply policies
-- This separates policy creation (INFOSEC) from policy application (ITC_ADMIN)
USE ROLE SECURITYADMIN;

GRANT APPLY ON ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense TO ROLE itc_admin;

-- Note: The following grant won't work in managed access schema
-- GRANT APPLY ON ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense TO ROLE itc_admin;

-- =============================================================================
-- APPLY ROW ACCESS POLICY TO TABLE
-- =============================================================================
-- Execute as richmond@itcrowd or another user with itc_admin role
-- The data owner applies the policy to the table
USE ROLE itc_admin;

ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
    ADD ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense ON (C_BIRTH_COUNTRY);

-- =============================================================================
-- TEST ROW ACCESS POLICY
-- =============================================================================

-- Test 1: ITC_ADMIN should see no rows (per mapping table)
USE ROLE itc_admin;
SELECT 
    COUNT(*) AS rows_visible,
    'ITC_ADMIN should see 0 rows' AS expected_result
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;

-- Test 2: Marketing should see only UK customers
USE ROLE marketing;
SELECT 
    C_BIRTH_COUNTRY,
    COUNT(*) AS row_count
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
GROUP BY C_BIRTH_COUNTRY;
-- Expected: Only 'UK' rows visible

-- Show sample marketing data
SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS LIMIT 10;

-- Test 3: IT should see only US customers
USE ROLE it;
SELECT 
    C_BIRTH_COUNTRY,
    COUNT(*) AS row_count
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
GROUP BY C_BIRTH_COUNTRY;
-- Expected: Only 'US' rows visible

-- Test 4: Executive should see only France customers
USE ROLE executive;
SELECT 
    C_BIRTH_COUNTRY,
    COUNT(*) AS row_count
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
GROUP BY C_BIRTH_COUNTRY;
-- Expected: Only 'FRANCE' rows visible

-- Test 5: INFOSEC should see no rows
USE ROLE infosec;
SELECT 
    COUNT(*) AS rows_visible,
    'INFOSEC should see 0 rows' AS expected_result
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;

-- =============================================================================
-- VERIFICATION AND METADATA QUERIES
-- =============================================================================
USE ROLE itc_admin;

-- Show all row access policies in the schema
SHOW ROW ACCESS POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;

-- View policy definition
DESC ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense;

-- Show which tables have this policy applied
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.POLICY_REFERENCES(
        POLICY_NAME => 'REYNHOLM_IND_DATA.BASEMENT.makes_no_sense'
    )
);

-- =============================================================================
-- TO REMOVE POLICY (FOR TROUBLESHOOTING)
-- =============================================================================
-- Uncomment this line if you need to remove and reapply the policy
-- ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
--     DROP ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense;

-- =============================================================================
-- KEY CONCEPTS DEMONSTRATED
-- =============================================================================
-- 1. Mapping Table Pattern: Externalized policy logic for easy maintenance
-- 2. Role-Based Filtering: Different roles see different subsets of data
-- 3. Data Share Support: Policies can include special logic for shares
-- 4. Default Deny: Security best practice - explicitly allow, implicitly deny
-- 5. Separation of Duties: Policy creation vs. policy application
-- 6. Dynamic Evaluation: Policy is evaluated at query time using CURRENT_ROLE()

-- =============================================================================
-- ROW ACCESS POLICY BENEFITS
-- =============================================================================
-- Row Access Policies provide:
--   - Transparent data filtering (no view management needed)
--   - Automatic enforcement across all query types
--   - Policy inheritance through cloning and sharing
--   - Centralized security logic
--   - Minimal performance overhead

-- =============================================================================
-- END OF SCRIPT 05
-- =============================================================================
-- Next Step: Run 06_column_masking_policy.sql
-- =============================================================================

