-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 01: SETUP USERS AND ROLES
-- =============================================================================
-- Purpose: Create users and roles for the PII data governance demonstration
-- Prerequisites: USERADMIN role privileges
-- Estimated Time: 5 minutes
-- =============================================================================

-- Switch to USERADMIN role to create users and roles
USE ROLE USERADMIN;

-- =============================================================================
-- CREATE ROLES
-- =============================================================================
-- Create custom roles for the fictional Reynholm Industries organization
CREATE ROLE itc_admin;    -- IT Company Administrator
CREATE ROLE marketing;    -- Marketing team
CREATE ROLE it;           -- IT operations team
CREATE ROLE infosec;      -- Information security team
CREATE ROLE executive;    -- Executive leadership

-- =============================================================================
-- CREATE USERS
-- =============================================================================
-- Create demo users based on characters from 'The IT Crowd' TV show
-- IMPORTANT: Change the passwords before running in a real environment!
-- Alternative: Remove password parameters and use key pair authentication

CREATE USER 'roy@itcrowd'      
    DEFAULT_WAREHOUSE = demo_wh 
    DEFAULT_ROLE = it        
    PASSWORD = 'usesomethinggoodthiswontwork' 
    MUST_CHANGE_PASSWORD = true;

CREATE USER 'moss@itcrowd'     
    DEFAULT_WAREHOUSE = demo_wh 
    DEFAULT_ROLE = infosec   
    PASSWORD = 'usesomethinggoodthiswontwork' 
    MUST_CHANGE_PASSWORD = true;

CREATE USER 'jen@itcrowd'      
    DEFAULT_WAREHOUSE = demo_wh 
    DEFAULT_ROLE = it        
    PASSWORD = 'usesomethinggoodthiswontwork' 
    MUST_CHANGE_PASSWORD = true;

CREATE USER 'denholm@itcrowd'  
    DEFAULT_WAREHOUSE = demo_wh 
    DEFAULT_ROLE = executive 
    PASSWORD = 'usesomethinggoodthiswontwork' 
    MUST_CHANGE_PASSWORD = true;

CREATE USER 'douglas@itcrowd'  
    DEFAULT_WAREHOUSE = demo_wh 
    DEFAULT_ROLE = marketing 
    PASSWORD = 'usesomethinggoodthiswontwork' 
    MUST_CHANGE_PASSWORD = true;

CREATE USER 'richmond@itcrowd' 
    DEFAULT_WAREHOUSE = demo_wh 
    DEFAULT_ROLE = itc_admin 
    PASSWORD = 'usesomethinggoodthiswontwork' 
    MUST_CHANGE_PASSWORD = true;

-- NOTE: Only using passwords for demo purposes. In production, use:
--   1. Key pair authentication (recommended)
--   2. SSO/SAML integration
--   3. OAuth authentication

-- =============================================================================
-- OPTIONAL: KEY PAIR AUTHENTICATION SETUP
-- =============================================================================
-- If you prefer key pair authentication, follow these steps:
--   1. Generate RSA key pairs for each user following Snowflake documentation
--   2. Uncomment and run the ALTER USER statements below
--   3. Replace 'MIIB...' with actual public key values
--
-- Documentation: https://docs.snowflake.com/en/user-guide/key-pair-auth.html

-- ALTER USER 'roy@itcrowd' SET rsa_public_key='MIIB...';
-- ALTER USER 'moss@itcrowd' SET rsa_public_key='MIIB...';
-- ALTER USER 'jen@itcrowd' SET rsa_public_key='MIIB...';
-- ALTER USER 'denholm@itcrowd' SET rsa_public_key='MIIB...';
-- ALTER USER 'douglas@itcrowd' SET rsa_public_key='MIIB...';
-- ALTER USER 'richmond@itcrowd' SET rsa_public_key='MIIB...';

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- Verify users and roles were created successfully
SHOW USERS LIKE '%itcrowd%';
SHOW ROLES LIKE 'itc_admin';
SHOW ROLES LIKE 'marketing';
SHOW ROLES LIKE 'it';
SHOW ROLES LIKE 'infosec';
SHOW ROLES LIKE 'executive';

-- =============================================================================
-- END OF SCRIPT 01
-- =============================================================================
-- Next Step: Run 02_grant_roles_create_database.sql
-- =============================================================================

