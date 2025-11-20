-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 07: OBJECT TAGGING
-- =============================================================================
-- Purpose: Create and apply object tags for metadata and governance
-- Prerequisites: Script 06 completed, access as securityadmin, accountadmin, infosec, itc_admin
-- Estimated Time: 5 minutes
-- Note: Object Tagging was a preview feature at original publication
-- =============================================================================

-- =============================================================================
-- GRANT TAG CREATION AND APPLICATION RIGHTS
-- =============================================================================

-- Grant the right to create tags to INFOSEC role
USE ROLE SECURITYADMIN;
GRANT CREATE TAG ON SCHEMA REYNHOLM_IND_DATA.BASEMENT TO ROLE infosec;

-- Grant the right to apply tags at account level to ITC_ADMIN role
USE ROLE ACCOUNTADMIN;
GRANT APPLY TAG ON ACCOUNT TO ROLE itc_admin;

-- =============================================================================
-- CREATE TAGS
-- =============================================================================
-- Execute as moss@itcrowd or another user with infosec role
-- Tags are created centrally by the security team to avoid namespace explosion
USE ROLE infosec;

-- Create tags with descriptive names
-- These tag names are from the original IT Crowd themed demo
CREATE TAG REYNHOLM_IND_DATA.BASEMENT.peter;
CREATE TAG REYNHOLM_IND_DATA.BASEMENT.calendar;

-- In production, use meaningful tag names like:
-- CREATE TAG REYNHOLM_IND_DATA.BASEMENT.data_classification;
-- CREATE TAG REYNHOLM_IND_DATA.BASEMENT.pii_category;
-- CREATE TAG REYNHOLM_IND_DATA.BASEMENT.retention_period;
-- CREATE TAG REYNHOLM_IND_DATA.BASEMENT.business_owner;

-- =============================================================================
-- APPLY TAGS TO OBJECTS
-- =============================================================================
-- Execute as richmond@itcrowd or another user with itc_admin role
-- Data owners apply tags to their objects with appropriate values
USE ROLE itc_admin;

-- Apply tags to the CUSTOMERS table
ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS SET TAG 
    REYNHOLM_IND_DATA.BASEMENT.PETER = 'file', 
    REYNHOLM_IND_DATA.BASEMENT.CALENDAR = 'geeks';

-- In production, apply meaningful tag values like:
-- ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS SET TAG 
--     REYNHOLM_IND_DATA.BASEMENT.data_classification = 'PII',
--     REYNHOLM_IND_DATA.BASEMENT.pii_category = 'customer_data',
--     REYNHOLM_IND_DATA.BASEMENT.retention_period = '7_years',
--     REYNHOLM_IND_DATA.BASEMENT.business_owner = 'marketing_dept';

-- =============================================================================
-- RETRIEVE TAG VALUES
-- =============================================================================
-- Query tag values using the system function
SELECT 
    SYSTEM$GET_TAG('REYNHOLM_IND_DATA.BASEMENT.calendar', 
                   'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS', 
                   'table') AS calendar_tag_value;

SELECT 
    SYSTEM$GET_TAG('REYNHOLM_IND_DATA.BASEMENT.peter', 
                   'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS', 
                   'table') AS peter_tag_value;

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- Show all tags in the schema
SHOW TAGS IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;

-- View tag references for the CUSTOMERS table
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.TAG_REFERENCES(
        'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS', 
        'TABLE'
    )
);

-- Query Account Usage to see all tagged objects (requires ACCOUNTADMIN)
-- Note: Account Usage views have latency (up to 2 hours)
-- USE ROLE ACCOUNTADMIN;
-- SELECT 
--     tag_database,
--     tag_schema,
--     tag_name,
--     tag_value,
--     object_database,
--     object_schema,
--     object_name,
--     domain
-- FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
-- WHERE tag_name IN ('PETER', 'CALENDAR')
--     AND object_name = 'CUSTOMERS';

-- =============================================================================
-- TAG LINEAGE AND INHERITANCE
-- =============================================================================
-- Tags are inherited by child objects created from tagged objects
-- Demonstrate this by creating a view from the tagged table

USE ROLE itc_admin;

CREATE OR REPLACE VIEW REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS_VIEW AS
SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;

-- Check if tags are inherited by the view
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.TAG_REFERENCES(
        'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS_VIEW', 
        'VIEW'
    )
);

-- Tags on tables propagate through:
--   - Views created from the table
--   - Cloned tables
--   - Tables in cloned databases/schemas
--   - Materialized views

-- =============================================================================
-- APPLY TAGS TO COLUMNS
-- =============================================================================
-- Tags can also be applied at the column level for fine-grained governance
ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
    MODIFY COLUMN C_EMAIL_ADDRESS 
    SET TAG REYNHOLM_IND_DATA.BASEMENT.peter = 'email_pii';

-- Verify column-level tags
SELECT 
    SYSTEM$GET_TAG('REYNHOLM_IND_DATA.BASEMENT.peter', 
                   'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS.C_EMAIL_ADDRESS', 
                   'COLUMN') AS email_column_tag;

-- =============================================================================
-- REMOVE TAGS (FOR CLEANUP OR UPDATES)
-- =============================================================================
-- To remove a tag from an object:
-- ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS UNSET TAG REYNHOLM_IND_DATA.BASEMENT.peter;

-- To drop a tag entirely (must remove all references first):
-- DROP TAG REYNHOLM_IND_DATA.BASEMENT.peter;

-- =============================================================================
-- KEY CONCEPTS DEMONSTRATED
-- =============================================================================
-- 1. Tag Creation: Central management by security/governance team
-- 2. Tag Application: Data owners apply tags to their objects
-- 3. Tag Retrieval: Query tag values using SYSTEM$GET_TAG
-- 4. Tag Lineage: Tags inherit through views, clones, and derived objects
-- 5. Column-Level Tagging: Fine-grained metadata at column level
-- 6. Tag Governance: Centralized tag namespace prevents sprawl

-- =============================================================================
-- OBJECT TAGGING BENEFITS
-- =============================================================================
-- Object Tagging provides:
--   - Metadata at the object level (tables, columns, views, etc.)
--   - Support for data classification and compliance
--   - Tag-based search and discovery
--   - Integration with governance tools
--   - Tag-driven policy automation (future capability)
--   - Audit trail for data lineage
--   - Business context for technical objects

-- =============================================================================
-- PRODUCTION USE CASES FOR TAGS
-- =============================================================================
-- Common tag categories:
--   - Data Classification: PII, PHI, PCI, Public, Internal, Confidential
--   - Business Owner: Department, team, or individual responsible
--   - Data Quality: Certified, verified, raw, experimental
--   - Retention Policy: 1_year, 7_years, indefinite
--   - Compliance: GDPR, CCPA, HIPAA, SOX
--   - Cost Center: For chargeback and cost allocation
--   - Environment: Production, staging, development
--   - Project: Project name or initiative

-- =============================================================================
-- TAG-DRIVEN GOVERNANCE WORKFLOW
-- =============================================================================
-- 1. Governance team defines tag taxonomy
-- 2. Create tags in a central schema
-- 3. Grant APPLY TAG privilege to data stewards
-- 4. Data stewards tag objects as they create them
-- 5. Use tags for:
--    - Discovery (find all PII tables)
--    - Automated policy application
--    - Compliance reporting
--    - Access governance
--    - Cost allocation

-- =============================================================================
-- END OF SCRIPT 07
-- =============================================================================
-- Next Step: Run 08_data_classification.sql
-- =============================================================================

