# Lab Instructions: Script Execution Guide

This document provides detailed step-by-step instructions for executing the PII Data Protection Hands-on Lab scripts in Snowsight.

- [Phase 1:  Environment Setup](README.md#phase-1-environment-setup-20-minutes)
- [Phase 2: Policy Implementation](README.md#phase-2-policy-implementation-30-minutes)
- [Phase 3: Advanced Features ](README.md#phase-3-advanced-features-25-minutes)


---

## 📋 Prerequisites

Before starting the lab, ensure you have:

1. **Snowflake Account:** Enterprise Edition or higher
2. **Required Roles:** Access to ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, and USERADMIN
3. **Sample Data:** Access to `SNOWFLAKE_SAMPLE_DATA` database
4. **Warehouse:** A warehouse available for compute (or permissions to create one)
---

## 🚀 Script Execution Order

Execute the scripts in the following order. **Do not skip scripts** as each builds upon the previous one.

### Phase 1: Environment Setup (20 minutes)

#### Script 1: Setup Users and Roles

Script file to Execute [01_setup_users_roles.sql](/scripts/01_setup_users_roles.sql)

**Role Required:** USERADMIN  
**Description:** Creates six demo users and five custom roles for the lab

**What it does:**
- Creates custom roles: `itc_admin`, `marketing`, `it`, `infosec`, `executive`
- Creates six users based on "The IT Crowd" TV show characters
- Sets default warehouses and roles for each user

**Important Notes:**
- ⚠️ **MUST change passwords** from the sample values before running
- Alternative: Remove password parameters and configure key pair authentication
- Verify users and roles are created successfully before proceeding

**Expected Result:** Six users and five roles created

---

#### Script 2: Grant Roles and Create Database
Script file to Execute [02_grant_roles_create_database.sql](/scripts/02_grant_roles_create_database.sql)

**Role Required:** USERADMIN, then role that owns warehouse, then SYSADMIN  
**Description:** Assigns roles to users, grants warehouse access, creates database

**What it does:**
- Grants appropriate roles to each user (some users have multiple roles)
- Grants warehouse USAGE privileges to all roles
- Creates `REYNHOLM_IND_DATA` database
- Transfers database ownership to `itc_admin` role

**Important Notes:**
- ⚠️ **MUST replace placeholders:**
  - `<ROLE_THAT_OWNS_THE_WAREHOUSE>` with your warehouse owner role
  - `<WAREHOUSE_YOU_WILL_USE>` with your warehouse name (e.g., `DEMO_WH`)
- If you don't have a warehouse, uncomment the CREATE WAREHOUSE statement
- If you cannot create users, grant these roles to your own account instead

**Expected Result:** Roles granted, warehouse accessible, database created

---

#### Script 3: Create Customer Table with PII Data
Script file to Execute [03_create_customer_table.sql](/scripts/03_create_customer_table.sql)

**Role Required:** itc_admin  
**Description:** Creates managed access schema and populates with sample PII data

**What it does:**
- Creates `BASEMENT` schema with managed access enabled
- Creates `CUSTOMERS` table with 200 rows of fake but realistic PII
- Sources data from Snowflake sample TPCDS dataset
- Grants database, schema, and table access to appropriate roles
- Randomly populates `C_BIRTH_COUNTRY` (UK/US/FRANCE) and `OPTIN` (YES/NO/NULL)

**Important Notes:**
- Uses `UNIFORM()` function to randomly distribute country and opt-in values
- Managed Access Schema enforces centralized privilege management
- Data is fake but realistic for demonstration purposes
- Verify 200 rows are created

**Expected Result:** Schema and table created with 200 rows of sample PII data

---

### Phase 2: Policy Implementation (30 minutes)

#### Script 4: Setup Policy Framework

Script file to Execute [04_setup_policy_framework.sql](/scripts/04_setup_policy_framework.sql)


**Role Required:** itc_admin, then SECURITYADMIN  
**Description:** Sets up infrastructure for row access and masking policies

**What it does:**
- Grants policy creation privileges to `infosec` role
- Creates `ROW_ACCESS_MAPPING` table to store access rules
- Demonstrates Managed Access Schema behavior (ownership grants blocked)
- Grants SELECT and INSERT privileges on mapping table

**Important Notes:**
- Demonstrates separation of duties (data owner grants policy rights to security team)
- Shows that Managed Access Schemas prevent ownership grants
- Only specific privileges (SELECT, INSERT) are granted instead

**Expected Result:** Mapping table created, policy privileges granted to infosec role

---

#### Script 5: Row Access Policy

Script file to Execute [05_row_access_policy.sql](/scripts/05_row_access_policy.sql)


**Role Required:** infosec, then SECURITYADMIN, then itc_admin, then marketing  
**Description:** Creates and applies row-level access controls

**What it does:**
- Populates mapping table with access rules (which roles see which countries)
- Creates row access policy `makes_no_sense` with logic:
  - Marketing sees UK customers only
  - IT sees US customers only
  - Executive sees France customers only
  - Admin and INFOSEC see no rows
- Grants APPLY privilege to `itc_admin`
- Applies policy to `CUSTOMERS` table
- Tests policy with different roles

**Important Notes:**
- Policy uses mapping table for flexible rule management
- Includes special logic for data sharing (`INVOKER_SHARE()`)
- Default deny approach (security best practice)
- Different roles will see different row counts

**Expected Result:** Row access policy applied; different roles see different data subsets

---

#### Script 6: Column Masking Policy

Script file to Execute [06_column_masking_policy.sql](/scripts/06_column_masking_policy.sql)

**File:** `scripts/06_column_masking_policy.sql`  
**Role Required:** infosec, then SECURITYADMIN, then itc_admin, then marketing  
**Description:** Implements dynamic data masking on email column

**What it does:**
- Creates conditional masking policy `hide_optouts`
  - Shows email if `OPTIN = 'YES'`
  - Masks email with `***MASKED***` otherwise
- Creates alternative full masking policy (if conditional not available)
- Grants APPLY privilege to `itc_admin`
- Applies masking policy to `C_EMAIL_ADDRESS` column
- Tests combined effect of row access + masking policies

**Important Notes:**
- Conditional masking was a preview feature at original publication
- If conditional masking not available, use the full masking alternative
- Masking is evaluated at query time (no data duplication)
- Works in conjunction with row access policies

**Expected Result:** Email addresses masked based on opt-in status; both policies working together

---

### Phase 3: Advanced Features (25 minutes)

#### Script 7: Object Tagging

Script file to Execute [07_object_tagging.sql](/scripts/07_object_tagging.sql)

**File:** `scripts/07_object_tagging.sql`  
**Role Required:** SECURITYADMIN, ACCOUNTADMIN, infosec, itc_admin  
**Description:** Applies metadata tags for governance and classification

**What it does:**
- Grants tag creation rights to `infosec` role
- Grants tag application rights to `itc_admin` role
- Creates tags: `peter` and `calendar` (demo tags)
- Applies tags to `CUSTOMERS` table and `C_EMAIL_ADDRESS` column
- Demonstrates tag retrieval using `SYSTEM$GET_TAG`
- Shows tag inheritance through views

**Important Notes:**
- Object Tagging was a preview feature at original publication
- Tags are created centrally to avoid namespace sprawl
- Tags inherit through clones, views, and derived objects
- In production, use meaningful tag names (data_classification, pii_category, etc.)

**Expected Result:** Tags created and applied to table and columns

---

#### Script 8: Data Classification
    
Script file to Execute [08_data_classification.sql](/scripts/08_data_classification.sql)

**Role Required:** it, then itc_admin  
**Description:** Uses Snowflake's automated classification to identify PII

**What it does:**
- Runs `EXTRACT_SEMANTIC_CATEGORIES()` on `CUSTOMERS` table
- Parses JSON results using `FLATTEN()` and variant types
- Creates readable classification report showing:
  - Privacy categories (IDENTIFIER, QUASI_IDENTIFIER, SENSITIVE)
  - Semantic categories (EMAIL, NAME, GENDER, etc.)
  - Confidence probability scores
- Saves classification history to a table
- Demonstrates JSON processing techniques

**Important Notes:**
- Classification was a preview feature at original publication
- Returns JSON that requires parsing for readability
- Confidence scores indicate classification accuracy
- Results can drive automated policy application
- Demonstrates Snowflake's semi-structured data capabilities

**Expected Result:** Classification report showing PII columns with confidence scores

---

## Next Steps

### Grading

Complete grading before cleanup of objects created in this Lab
Detailed grading instructions can be found [HERE](/config/README.md)

---

## 🔧 Troubleshooting Tips

### Common Issues

**Issue:** "Object does not exist" errors  
**Solution:** Verify previous scripts completed successfully; check object names for typos

**Issue:** "Insufficient privileges" errors  
**Solution:** Verify you're using the correct role; check `USE ROLE` statements

**Issue:** Policies not applying as expected  
**Solution:** Verify policy is attached using `SHOW ROW ACCESS POLICIES` or `SHOW MASKING POLICIES`

**Issue:** Warehouse timeout errors  
**Solution:** Resume warehouse or increase auto-suspend timeout

**Issue:** Sample data not accessible  
**Solution:** Contact account admin to enable `SNOWFLAKE_SAMPLE_DATA`

### Getting Help

- Review the main `README.md` for detailed troubleshooting section
- Check script comments for context-specific notes
- Verify prerequisites are met before starting
- Ensure all placeholders are replaced with actual values

---

## 🎓 Learning Checkpoints

After completing each phase, you should understand:

**After Phase 1:**
- How to create users and roles in Snowflake
- Role-based access control (RBAC) fundamentals
- Database and schema creation
- Managed Access Schema concept

**After Phase 2:**
- Row Access Policies for data filtering
- Dynamic Data Masking for column protection
- Separation of duties (policy creation vs application)
- Policy evaluation and testing

**After Phase 3:**
- Object tagging for metadata management
- Automated data classification
- JSON processing in Snowflake
- Governance and compliance support

**After Phase 4:**
- Proper cleanup procedures
- Cost stewardship best practices
- Dependency management in Snowflake

---

