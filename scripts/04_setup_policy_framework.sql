-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 04: SETUP POLICY FRAMEWORK
-- =============================================================================
-- Purpose: Set up infrastructure for row access and masking policies
-- Prerequisites: Script 03 completed, access as itc_admin and securityadmin
-- Estimated Time: 5 minutes
-- =============================================================================

-- =============================================================================
-- GRANT POLICY CREATION RIGHTS TO INFOSEC ROLE
-- =============================================================================
-- Execute as richmond@itcrowd or another user with itc_admin role
-- The data owner grants policy creation rights to the security team
USE ROLE itc_admin;

-- Grant right to create row access policies
GRANT CREATE ROW ACCESS POLICY ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE infosec;

-- Grant right to create masking policies
GRANT CREATE MASKING POLICY ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE infosec;

-- =============================================================================
-- CREATE ROW ACCESS MAPPING TABLE
-- =============================================================================
-- This table will store the rules for row-level access control
-- It defines which roles can see which data based on country codes
CREATE TABLE REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING (
    role_name VARCHAR,
    national_letter VARCHAR,
    allowed VARCHAR
);

-- Attempt to grant ownership (this demonstrates managed access schema behavior)
-- In a managed access schema, this will fail, demonstrating the security control
-- GRANT OWNERSHIP ON TABLE REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING TO ROLE infosec;
-- Expected: This statement will be blocked by the Managed Access Schema

-- =============================================================================
-- GRANT SPECIFIC PRIVILEGES USING SECURITYADMIN
-- =============================================================================
-- Switch to SECURITYADMIN to grant privileges on the mapping table
-- In managed access schemas, we grant specific privileges instead of ownership
USE ROLE SECURITYADMIN;

-- The following OWNERSHIP grant will fail due to Managed Access Schema restrictions
-- GRANT OWNERSHIP ON TABLE REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING TO ROLE infosec;
-- This demonstrates that managed access schemas prevent ownership transfers

-- Instead, grant only the specific privileges needed
GRANT SELECT ON TABLE REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING TO ROLE infosec;
GRANT INSERT ON TABLE REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING TO ROLE infosec;

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- Verify the mapping table was created
USE ROLE itc_admin;
SHOW TABLES LIKE 'ROW_ACCESS_MAPPING' IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;

-- Verify grants on the mapping table
SHOW GRANTS ON TABLE REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING;

-- Verify infosec can access the table
USE ROLE infosec;
SELECT COUNT(*) FROM REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING;
-- Should return 0 (table is empty at this point)

-- =============================================================================
-- KEY CONCEPTS DEMONSTRATED
-- =============================================================================
-- 1. Separation of Duties: Data owners (ITC_ADMIN) grant policy creation rights
--    to security team (INFOSEC)
-- 2. Managed Access Schema Enforcement: Ownership grants are blocked, forcing
--    specific privilege grants
-- 3. Principle of Least Privilege: Grant only SELECT and INSERT, not full ownership
-- 4. Policy Framework Setup: Creating infrastructure before defining policy logic

-- =============================================================================
-- MANAGED ACCESS SCHEMA BENEFITS
-- =============================================================================
-- Managed Access Schemas provide:
--   - Centralized privilege management
--   - Prevention of privilege escalation
--   - Auditability of all access grants
--   - Consistent access control patterns
--
-- In this lab, it ensures that even the INFOSEC role cannot make arbitrary
-- grants on the mapping table, maintaining security governance

-- =============================================================================
-- END OF SCRIPT 04
-- =============================================================================
-- Next Step: Run 05_row_access_policy.sql
-- =============================================================================

