-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 02: GRANT ROLES AND CREATE DATABASE
-- =============================================================================
-- Purpose: Assign roles to users, grant warehouse access, and create database
-- Prerequisites: Script 01 completed, USERADMIN and SYSADMIN role privileges
-- Estimated Time: 5 minutes
-- =============================================================================

-- =============================================================================
-- GRANT ROLES TO USERS
-- =============================================================================
-- Assign the appropriate roles to each user
USE ROLE USERADMIN;

GRANT ROLE itc_admin TO USER 'richmond@itcrowd';
GRANT ROLE marketing TO USER 'douglas@itcrowd';
GRANT ROLE it TO USER 'roy@itcrowd';
GRANT ROLE it TO USER 'moss@itcrowd';
GRANT ROLE infosec TO USER 'moss@itcrowd';  -- Moss has both IT and INFOSEC roles
GRANT ROLE it TO USER 'jen@itcrowd';
GRANT ROLE executive TO USER 'denholm@itcrowd';

-- =============================================================================
-- GRANT WAREHOUSE ACCESS TO ROLES
-- =============================================================================
-- IMPORTANT: Replace <ROLE_THAT_OWNS_THE_WAREHOUSE> with the role that owns your warehouse
-- IMPORTANT: Replace <WAREHOUSE_YOU_WILL_USE> with your actual warehouse name
-- Common warehouse owner roles: SYSADMIN, ACCOUNTADMIN
-- If you need to create a warehouse, uncomment the CREATE WAREHOUSE statement below

-- USE ROLE SYSADMIN;
-- CREATE WAREHOUSE IF NOT EXISTS demo_wh 
--     WITH WAREHOUSE_SIZE = 'X-SMALL' 
--     AUTO_SUSPEND = 300 
--     AUTO_RESUME = TRUE
--     INITIALLY_SUSPENDED = TRUE;

USE ROLE <ROLE_THAT_OWNS_THE_WAREHOUSE>;

GRANT USAGE ON WAREHOUSE <WAREHOUSE_YOU_WILL_USE> TO ROLE itc_admin;
GRANT USAGE ON WAREHOUSE <WAREHOUSE_YOU_WILL_USE> TO ROLE marketing;
GRANT USAGE ON WAREHOUSE <WAREHOUSE_YOU_WILL_USE> TO ROLE it;
GRANT USAGE ON WAREHOUSE <WAREHOUSE_YOU_WILL_USE> TO ROLE executive;
GRANT USAGE ON WAREHOUSE <WAREHOUSE_YOU_WILL_USE> TO ROLE infosec;

-- =============================================================================
-- CREATE DATABASE AND TRANSFER OWNERSHIP
-- =============================================================================
-- Create the main database for the demo and hand ownership to ITC_ADMIN
USE ROLE SYSADMIN;

CREATE DATABASE REYNHOLM_IND_DATA;

-- Transfer ownership to the ITC_ADMIN role (representing the data owner)
GRANT OWNERSHIP ON DATABASE REYNHOLM_IND_DATA TO ROLE itc_admin;

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- Verify role assignments
SHOW GRANTS TO USER 'richmond@itcrowd';
SHOW GRANTS TO USER 'moss@itcrowd';
SHOW GRANTS TO USER 'douglas@itcrowd';

-- Verify warehouse grants
SHOW GRANTS ON WAREHOUSE <WAREHOUSE_YOU_WILL_USE>;

-- Verify database creation
SHOW DATABASES LIKE 'REYNHOLM_IND_DATA';

-- =============================================================================
-- IMPORTANT NOTES
-- =============================================================================
-- If you cannot create users in your environment:
--   - Grant these roles to your own user account instead
--   - When the lab instructions say to switch users, use 'USE ROLE <role_name>;'
--   - This allows you to complete the lab using role switching instead of user switching
--
-- Example: Instead of logging in as 'moss@itcrowd', run: USE ROLE infosec;

-- =============================================================================
-- END OF SCRIPT 02
-- =============================================================================
-- Next Step: Run 03_create_customer_table.sql
-- =============================================================================

