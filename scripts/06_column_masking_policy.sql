-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 06: COLUMN MASKING POLICY
-- =============================================================================
-- Purpose: Create and apply dynamic data masking policies to protect PII columns
-- Prerequisites: Script 05 completed, access as infosec, securityadmin, itc_admin
-- Estimated Time: 10 minutes
-- =============================================================================

-- =============================================================================
-- CREATE CONDITIONAL MASKING POLICY
-- =============================================================================
-- Execute as moss@itcrowd or another user with infosec role
USE ROLE infosec;

-- Conditional masking policy based on OPTIN column
-- This policy demonstrates context-aware masking:
--   - If customer opted in ('YES'), show actual email
--   - Otherwise, mask the email address
-- 
-- Note: Conditional masking may require preview feature enablement
CREATE MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_optouts AS
(col_value VARCHAR, optin STRING) RETURNS VARCHAR ->
    CASE
        WHEN optin = 'YES' THEN col_value
        ELSE '***MASKED***'
    END;

-- =============================================================================
-- CREATE FULL COLUMN MASKING POLICY (ALTERNATIVE)
-- =============================================================================
-- Alternative policy that always masks, regardless of conditions
-- Use this if conditional masking is not available in your account
CREATE MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_column_values AS
(col_value VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN 1 = 1 THEN '***MASKED***'
        ELSE '***MASKED***'
    END;

-- =============================================================================
-- GRANT POLICY APPLICATION RIGHTS
-- =============================================================================
-- Security admin grants the right to apply masking policies
USE ROLE SECURITYADMIN;

GRANT APPLY ON MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_optouts TO ROLE itc_admin;

-- If using the alternative full masking policy, grant this instead:
-- GRANT APPLY ON MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_column_values TO ROLE itc_admin;

-- =============================================================================
-- APPLY MASKING POLICY TO EMAIL COLUMN
-- =============================================================================
-- Execute as richmond@itcrowd or another user with itc_admin role
USE ROLE itc_admin;

-- Apply conditional masking policy to C_EMAIL_ADDRESS column
-- The policy uses both C_EMAIL_ADDRESS and OPTIN columns
ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
    MODIFY COLUMN C_EMAIL_ADDRESS
    SET MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_optouts 
    USING (C_EMAIL_ADDRESS, OPTIN);

-- Alternative: Apply full masking policy (if conditional masking not available)
-- ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
--     MODIFY COLUMN C_EMAIL_ADDRESS
--     SET MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_column_values 
--     USING (C_EMAIL_ADDRESS);

-- =============================================================================
-- TEST MASKING POLICY
-- =============================================================================

-- Test 1: Marketing role sees masked/unmasked emails based on OPTIN
USE ROLE marketing;

-- View all columns including masked emails
SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS LIMIT 50;

-- Count how many emails are visible vs masked
SELECT 
    OPTIN,
    COUNT(*) AS customer_count,
    CASE 
        WHEN OPTIN = 'YES' THEN 'Email Visible'
        ELSE 'Email Masked'
    END AS masking_status
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
GROUP BY OPTIN
ORDER BY OPTIN;

-- Show examples of masked vs unmasked
SELECT 
    C_FIRST_NAME,
    C_LAST_NAME,
    C_EMAIL_ADDRESS,
    OPTIN,
    CASE 
        WHEN C_EMAIL_ADDRESS = '***MASKED***' THEN 'Masked'
        ELSE 'Visible'
    END AS email_status
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
LIMIT 20;

-- Test 2: IT role also sees conditional masking
USE ROLE it;
SELECT 
    C_FIRST_NAME,
    C_LAST_NAME,
    C_EMAIL_ADDRESS,
    OPTIN
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
LIMIT 20;

-- Test 3: Executive role also sees conditional masking
USE ROLE executive;
SELECT 
    C_FIRST_NAME,
    C_LAST_NAME,
    C_EMAIL_ADDRESS,
    OPTIN
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
LIMIT 20;

-- =============================================================================
-- COMBINED POLICY TEST: ROW ACCESS + COLUMN MASKING
-- =============================================================================
-- These queries demonstrate both policies working together
-- Row Access Policy: Filters which rows you see based on country
-- Masking Policy: Masks email addresses based on opt-in status

USE ROLE marketing;
SELECT 
    C_BIRTH_COUNTRY,
    C_FIRST_NAME,
    C_LAST_NAME,
    C_EMAIL_ADDRESS,
    OPTIN,
    'Marketing sees UK only + conditional masking' AS policy_effect
FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS
LIMIT 20;

-- =============================================================================
-- VERIFICATION AND METADATA QUERIES
-- =============================================================================
USE ROLE itc_admin;

-- Show all masking policies in the schema
SHOW MASKING POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;

-- View policy definition
DESC MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_optouts;

-- Show which columns have masking policies applied
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.POLICY_REFERENCES(
        REF_ENTITY_NAME => 'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS',
        REF_ENTITY_DOMAIN => 'TABLE'
    )
);

-- =============================================================================
-- TO REMOVE MASKING POLICY (FOR TROUBLESHOOTING)
-- =============================================================================
-- Uncomment this line if you need to remove and reapply the policy
-- USE ROLE itc_admin;
-- ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
--     MODIFY COLUMN C_EMAIL_ADDRESS
--     UNSET MASKING POLICY;

-- =============================================================================
-- KEY CONCEPTS DEMONSTRATED
-- =============================================================================
-- 1. Conditional Masking: Masking based on data context (OPTIN column)
-- 2. Dynamic Data Masking: Applied at query time, no data duplication
-- 3. Transparent to Users: Users query normally, masking happens automatically
-- 4. Policy Composition: Row access and masking policies work together
-- 5. Separation of Duties: INFOSEC creates policies, ITC_ADMIN applies them

-- =============================================================================
-- DYNAMIC DATA MASKING BENEFITS
-- =============================================================================
-- Column-level security with masking provides:
--   - Protection of sensitive data without creating multiple views
--   - Context-aware masking (conditional policies)
--   - Automatic enforcement across all query types
--   - Policy inheritance through cloning and sharing
--   - No performance overhead (evaluated at query time)
--   - Compliance support (GDPR, CCPA, HIPAA)

-- =============================================================================
-- MASKING POLICY PATTERNS
-- =============================================================================
-- Common masking patterns:
--   - Full masking: Replace with '***MASKED***' or NULL
--   - Partial masking: Show first/last N characters
--   - Format-preserving: Mask but maintain data format
--   - Conditional masking: Mask based on other column values or user context
--   - Hash masking: Use HASH() for anonymization
--   - Tokenization: Replace with tokens for referential integrity

-- Example: Partial email masking
-- LEFT(col_value, 3) || '***@***' || SPLIT_PART(col_value, '@', -1)

-- =============================================================================
-- END OF SCRIPT 06
-- =============================================================================
-- Next Step: Run 07_object_tagging.sql
-- =============================================================================

