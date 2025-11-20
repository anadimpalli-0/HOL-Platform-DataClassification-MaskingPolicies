-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 09: CLEANUP
-- =============================================================================
-- Purpose: Remove all objects created during the lab
-- Prerequisites: All lab scripts completed
-- Estimated Time: 3 minutes
-- IMPORTANT: Run these commands in the correct order to avoid dependency errors
-- =============================================================================

-- =============================================================================
-- CLEANUP DATA SHARE (IF CREATED)
-- =============================================================================
-- If you created a data share with a second Snowflake account,
-- clean up the consumer account FIRST before running this script

-- IN THE CONSUMER ACCOUNT (the account where you ran "Get Data"):
-- USE ROLE ACCOUNTADMIN;
-- DROP DATABASE IF EXISTS REYNHOLM_IND_DATA_SHARE;

-- Then return to the provider account (this account) and continue below

-- =============================================================================
-- DROP DATA SHARE IN PROVIDER ACCOUNT
-- =============================================================================
USE ROLE ACCOUNTADMIN;

-- Drop the share (if it exists)
DROP SHARE IF EXISTS REYNHOLM_IND_DATA_SHARE;

-- Verify share is dropped
SHOW SHARES LIKE 'REYNHOLM_IND_DATA_SHARE';

-- =============================================================================
-- DROP DATABASE AND ALL CONTAINED OBJECTS
-- =============================================================================
-- Switch to ITC_ADMIN role (database owner)
USE ROLE itc_admin;

-- Drop the entire database
-- This cascades to all schemas, tables, views, policies, and tags within
DROP DATABASE IF EXISTS REYNHOLM_IND_DATA;

-- Verify database is dropped
SHOW DATABASES LIKE 'REYNHOLM_IND_DATA';

-- =============================================================================
-- CONFIRM POLICIES ARE REMOVED
-- =============================================================================
-- Dropping the database automatically removes associated policies
-- Verify by checking (should return no results)

USE ROLE SECURITYADMIN;
-- SHOW ROW ACCESS POLICIES LIKE 'makes_no_sense';
-- SHOW MASKING POLICIES LIKE 'hide_optouts';
-- SHOW TAGS LIKE 'peter';

-- =============================================================================
-- DROP USERS
-- =============================================================================
USE ROLE USERADMIN;

DROP USER IF EXISTS "roy@itcrowd";
DROP USER IF EXISTS "moss@itcrowd";
DROP USER IF EXISTS "jen@itcrowd";
DROP USER IF EXISTS "denholm@itcrowd";
DROP USER IF EXISTS "douglas@itcrowd";
DROP USER IF EXISTS "richmond@itcrowd";

-- Verify users are dropped
SHOW USERS LIKE '%itcrowd%';

-- =============================================================================
-- DROP ROLES
-- =============================================================================
USE ROLE USERADMIN;

DROP ROLE IF EXISTS itc_admin;
DROP ROLE IF EXISTS marketing;
DROP ROLE IF EXISTS it;
DROP ROLE IF EXISTS infosec;
DROP ROLE IF EXISTS executive;

-- Verify roles are dropped
SHOW ROLES LIKE 'itc_admin';
SHOW ROLES LIKE 'marketing';
SHOW ROLES LIKE 'it';
SHOW ROLES LIKE 'infosec';
SHOW ROLES LIKE 'executive';

-- =============================================================================
-- DROP UTILITY DATABASE (IF CREATED FOR GRADING)
-- =============================================================================
-- If you created the DORA grading infrastructure, clean it up
USE ROLE ACCOUNTADMIN;

-- Drop the utility database
DROP DATABASE IF EXISTS util_db;

-- Drop the API integration
DROP API INTEGRATION IF EXISTS dora_api_integration;

-- Verify cleanup
SHOW DATABASES LIKE 'util_db';
SHOW INTEGRATIONS LIKE 'dora_api_integration';

-- =============================================================================
-- WAREHOUSE MANAGEMENT
-- =============================================================================
-- Suspend the warehouse to stop compute costs
-- Replace <WAREHOUSE_YOU_WILL_USE> with your warehouse name
USE ROLE SYSADMIN;  -- Or the role that owns your warehouse

-- Suspend warehouse
ALTER WAREHOUSE <WAREHOUSE_YOU_WILL_USE> SUSPEND;

-- Optional: Drop the warehouse if it was created specifically for this lab
-- ONLY run this if you created demo_wh specifically for this lab
-- DROP WAREHOUSE IF EXISTS demo_wh;

-- Verify warehouse is suspended (not dropped)
SHOW WAREHOUSES LIKE '<WAREHOUSE_YOU_WILL_USE>';

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================
-- Run these queries to confirm all lab objects are removed

USE ROLE ACCOUNTADMIN;

-- Check for any remaining databases
SHOW DATABASES LIKE 'REYNHOLM%';
SHOW DATABASES LIKE 'util_db';

-- Check for any remaining shares
SHOW SHARES LIKE 'REYNHOLM%';

-- Check for remaining users
SHOW USERS LIKE '%itcrowd%';

-- Check for remaining roles
SHOW ROLES LIKE '%itc%';
SHOW ROLES LIKE 'marketing';
SHOW ROLES LIKE 'infosec';
SHOW ROLES LIKE 'executive';

-- =============================================================================
-- CLEANUP SUMMARY
-- =============================================================================
/*
Objects Cleaned Up:
✅ Data Share: REYNHOLM_IND_DATA_SHARE
✅ Database: REYNHOLM_IND_DATA
    ✅ Schema: BASEMENT
        ✅ Tables: CUSTOMERS, ROW_ACCESS_MAPPING, CLASSIFICATION_HISTORY
        ✅ View: CUSTOMERS_VIEW
        ✅ Row Access Policy: makes_no_sense
        ✅ Masking Policies: hide_optouts, hide_column_values
        ✅ Tags: peter, calendar
✅ Users: roy@itcrowd, moss@itcrowd, jen@itcrowd, denholm@itcrowd, 
          douglas@itcrowd, richmond@itcrowd
✅ Roles: itc_admin, marketing, it, infosec, executive
✅ Utility Database: util_db (if created)
✅ API Integration: dora_api_integration (if created)
✅ Warehouse: Suspended (not dropped)
*/

-- =============================================================================
-- COST STEWARDSHIP NOTES
-- =============================================================================
/*
By completing this cleanup:
- Storage costs eliminated: All tables and data dropped
- Compute costs stopped: Warehouse suspended
- API integration removed: No external function costs
- No ongoing charges: All billable resources removed or suspended

Best Practices:
1. Always clean up demo/test environments immediately after use
2. Use auto-suspend on warehouses (5-10 minutes recommended)
3. Set up resource monitors for cost control
4. Review warehouse usage regularly in Admin > Usage
5. Drop unused databases promptly
*/

-- =============================================================================
-- TROUBLESHOOTING CLEANUP ISSUES
-- =============================================================================
/*
If you encounter errors during cleanup:

Error: "Cannot drop database because it is in use"
Solution: Close all worksheets using the database, switch to a different 
          database context, then retry

Error: "Insufficient privileges to drop..."
Solution: Ensure you're using the correct role (ACCOUNTADMIN has all privileges)

Error: "Cannot drop user because it owns objects"
Solution: Transfer ownership or drop the owned objects first, or drop the 
          database before dropping users

Error: "Cannot drop role because it is granted to users"
Solution: This shouldn't happen if users were dropped first. If it does,
          revoke the role from users before dropping the role
*/

-- =============================================================================
-- OPTIONAL: REVIEW ACCOUNT USAGE BEFORE COMPLETE CLEANUP
-- =============================================================================
-- Before final cleanup, you may want to review what was created/accessed
USE ROLE ACCOUNTADMIN;

-- Review query history from this lab session
-- SELECT 
--     query_text,
--     user_name,
--     role_name,
--     execution_status,
--     start_time
-- FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
-- WHERE start_time > DATEADD(hour, -4, CURRENT_TIMESTAMP())
--     AND (user_name LIKE '%itcrowd%' 
--          OR query_text ILIKE '%REYNHOLM%')
-- ORDER BY start_time DESC
-- LIMIT 100;

-- =============================================================================
-- END OF SCRIPT 09 - CLEANUP COMPLETE
-- =============================================================================
-- Thank you for completing the Snowflake PII HOL!
-- For feedback or questions, see the main README.md
-- =============================================================================

