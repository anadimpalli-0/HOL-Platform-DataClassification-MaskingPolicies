-- =============================================================================
-- SNOWFLAKE PII HOL - SCRIPT 08: DATA CLASSIFICATION
-- =============================================================================
-- Purpose: Use Snowflake's built-in classification to identify PII automatically
-- Prerequisites: Script 07 completed, access as IT role
-- Estimated Time: 5 minutes
-- Note: Classification was a preview feature at original publication
-- =============================================================================

-- =============================================================================
-- EXTRACT SEMANTIC CATEGORIES
-- =============================================================================
-- Execute as jen@itcrowd or another user with IT role
USE ROLE it;

-- Run classification on the CUSTOMERS table
-- This function analyzes column contents and returns semantic categories
SELECT EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS');

-- The output is a JSON object containing classification results for each column
-- It includes:
--   - semantic_category: Type of data (e.g., EMAIL, NAME, GENDER)
--   - privacy_category: Privacy classification (e.g., IDENTIFIER, QUASI_IDENTIFIER, SENSITIVE)
--   - probability: Confidence score for the classification

-- =============================================================================
-- PARSE CLASSIFICATION RESULTS FOR A SPECIFIC COLUMN
-- =============================================================================
-- Use FLATTEN to parse the JSON results for the CD_GENDER column
SELECT 
    VALUE 
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT:CD_GENDER
    )
) AS f;

-- =============================================================================
-- CREATE READABLE CLASSIFICATION REPORT
-- =============================================================================
-- Parse the JSON into a tabular format for easier analysis
SELECT 
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT
    )
) AS f 
WHERE f.key = 'CD_GENDER';

-- =============================================================================
-- COMPREHENSIVE CLASSIFICATION REPORT FOR ALL COLUMNS
-- =============================================================================
-- Generate a full report showing classification results for all columns
SELECT 
    f.key AS column_name,
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability,
    f.value:"extra_info":"alternates" AS alternate_categories
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT
    )
) AS f
ORDER BY 
    CASE privacy_category
        WHEN 'IDENTIFIER' THEN 1
        WHEN 'QUASI_IDENTIFIER' THEN 2
        WHEN 'SENSITIVE' THEN 3
        ELSE 4
    END,
    column_name;

-- =============================================================================
-- FILTER FOR HIGH-PROBABILITY PII COLUMNS
-- =============================================================================
-- Identify columns with high confidence PII classification
SELECT 
    f.key AS column_name,
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT
    )
) AS f
WHERE f.value:"extra_info":"probability"::NUMBER(10,2) > 0.70
ORDER BY probability DESC;

-- =============================================================================
-- CLASSIFY SPECIFIC COLUMNS
-- =============================================================================
-- You can also classify specific columns instead of the entire table

-- Classify just the email column
SELECT 
    'C_EMAIL_ADDRESS' AS column_name,
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT:C_EMAIL_ADDRESS
    )
) AS f;

-- Classify the name columns
SELECT 
    'C_FIRST_NAME' AS column_name,
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT:C_FIRST_NAME
    )
) AS f
UNION ALL
SELECT 
    'C_LAST_NAME' AS column_name,
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT:C_LAST_NAME
    )
) AS f;

-- =============================================================================
-- UNDERSTANDING PRIVACY CATEGORIES
-- =============================================================================
/*
Privacy Category Definitions:
- IDENTIFIER: Can uniquely identify an individual (e.g., email, SSN, phone)
- QUASI_IDENTIFIER: Can identify when combined (e.g., zip code, birth date, gender)
- SENSITIVE: Sensitive personal information (e.g., health data, financial info)
- null: Not classified as PII

Semantic Category Examples:
- EMAIL: Email addresses
- NAME: Person names
- GENDER: Gender information
- AGE: Age or age-related data
- PHONE_NUMBER: Phone numbers
- DATE_OF_BIRTH: Birth dates
- And many more...
*/

-- =============================================================================
-- USING CLASSIFICATION RESULTS
-- =============================================================================
-- Classification results can be used to:
--   1. Automatically identify PII columns requiring protection
--   2. Drive policy application (which columns need masking)
--   3. Generate compliance reports (GDPR, CCPA data inventory)
--   4. Audit data access patterns for sensitive data
--   5. Tag objects based on classification results
--   6. Inform data retention policies

-- Example: Create a view of only non-PII columns for unrestricted access
-- (This would be implemented based on classification results)

-- =============================================================================
-- JSON PARSING TECHNIQUES DEMONSTRATED
-- =============================================================================
-- This script demonstrates several Snowflake JSON capabilities:
--   1. FLATTEN: Unnest JSON arrays and objects into rows
--   2. :: VARIANT: Cast to variant type for JSON processing
--   3. : notation: Access JSON object properties
--   4. :: VARCHAR/NUMBER: Cast JSON values to specific types
--   5. Nested JSON navigation: Access nested properties

-- =============================================================================
-- SAVE CLASSIFICATION RESULTS
-- =============================================================================
-- For production use, save classification results to a table for tracking
USE ROLE itc_admin;

CREATE TABLE IF NOT EXISTS REYNHOLM_IND_DATA.BASEMENT.CLASSIFICATION_HISTORY (
    classification_date TIMESTAMP_LTZ,
    table_name VARCHAR,
    column_name VARCHAR,
    privacy_category VARCHAR,
    semantic_category VARCHAR,
    probability NUMBER(10,2)
);

-- Insert current classification results
INSERT INTO REYNHOLM_IND_DATA.BASEMENT.CLASSIFICATION_HISTORY
SELECT 
    CURRENT_TIMESTAMP() AS classification_date,
    'CUSTOMERS' AS table_name,
    f.key AS column_name,
    f.value:"privacy_category"::VARCHAR AS privacy_category,  
    f.value:"semantic_category"::VARCHAR AS semantic_category,
    f.value:"extra_info":"probability"::NUMBER(10,2) AS probability
FROM TABLE(
    FLATTEN(
        EXTRACT_SEMANTIC_CATEGORIES('REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS')::VARIANT
    )
) AS f;

-- Query the history
SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.CLASSIFICATION_HISTORY
ORDER BY privacy_category, column_name;

-- =============================================================================
-- KEY CONCEPTS DEMONSTRATED
-- =============================================================================
-- 1. Automated Classification: Built-in intelligence to identify PII
-- 2. JSON Processing: Parse complex JSON results using FLATTEN and variant types
-- 3. Confidence Scoring: Probability values indicate classification confidence
-- 4. Privacy Categories: Standardized categories for regulatory compliance
-- 5. Semantic Categories: Specific data types identified in columns

-- =============================================================================
-- CLASSIFICATION BENEFITS
-- =============================================================================
-- Data Classification provides:
--   - Automated PII discovery across your data estate
--   - Reduced manual effort in identifying sensitive data
--   - Consistent classification taxonomy
--   - Support for compliance requirements (GDPR, CCPA)
--   - Foundation for automated policy application
--   - Data cataloging and discovery
--   - Risk assessment and data inventory

-- =============================================================================
-- PRODUCTION RECOMMENDATIONS
-- =============================================================================
-- 1. Run classification regularly (e.g., weekly) to detect new PII
-- 2. Store results in a metadata table for historical tracking
-- 3. Use classification results to trigger policy application
-- 4. Review low-confidence classifications manually
-- 5. Integrate with data governance platforms
-- 6. Create alerts for newly discovered PII columns
-- 7. Document classification decisions and exceptions

-- =============================================================================
-- END OF SCRIPT 08
-- =============================================================================
-- Next Step: Run 09_cleanup.sql (or proceed to data sharing if desired)
-- Optional: Follow lab instructions to test policy enforcement through data sharing
-- =============================================================================

