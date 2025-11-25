# College of Platform HOL: Process PII Data with Snowflake Security Features
**Master data governance, security, and compliance using Snowflake's RBAC, DAC, Row Access Policies, and Dynamic Data Masking.**

![Lab Architecture](images/Architecture.png)

---

## 🛠️ Hands-On Lab Overview

In this hands-on lab, you'll step into the shoes of a **Data Security Engineer** tasked with **implementing comprehensive data protection for PII (Personally Identifiable Information) while maintaining data accessibility for authorized users**.

### 📋 What You'll Do:
Learn how to protect sensitive data using Snowflake's enterprise security features while enabling authorized access.

- **Task 1:** Create users, roles, and establish **Role-Based Access Control (RBAC)** foundations for a fictional organization
- **Task 2:** Build a customer table with realistic PII data and implement **Managed Access Schema** for controlled permissions
- **Task 3:** Apply **Row Access Policies** to filter data based on user roles and geographical requirements
- **Task 4:** Implement **Dynamic Data Masking** using conditional masking policies to protect sensitive columns
- **Task 5:** Create **Object Tags** and use **Classification** to identify and categorize PII data automatically
- **Task 6 (Optional):** Test policy enforcement through **Secure Data Sharing** across Snowflake accounts


Detailed instruction on executing the Lab can be found [HERE](lab_instructions/README.md) 

### ⏲️ Estimated Lab Timeline

This lab is designed to be completed in approximately 60-90 minutes:

- **Phase 1 (Setup & RBAC):** ~20 min
- **Phase 2 (Row & Column Security):** ~30 min
- **Phase 3 (Tagging, Classification & Sharing):** ~25 min
- **Phase 4 (Cleanup):** ~5 min
  
---

## 📖 Table of Contents

- [Why this Matters](#-why-this-matters)
- [Suggested Discovery Questions](#-suggested-discovery-questions)
- [Repository Structure](#-repository-structure)
- [Prerequisites & Setup Details](#-prerequisites--setup-details)
- [Estimated Lab Timeline](#️-estimated-lab-timeline)
- [Troubleshooting & FAQ](#️-troubleshooting--faq)
- [Cleanup & Cost-Stewardship Procedures](#-cleanup--cost-stewardship-procedures)
- [Grading Instructions](#-grading-instructions)
- [Advanced Concepts (Salted in Training)](#-advanced-concepts-salted-in-training)
- [Links to Internal Resources & Helpful Documents](#-links-to-internal-resources--helpful-documents)

---

## 📌 Why this Matters

- **Business value:** Organizations processing PII face complex regulatory requirements (GDPR, CCPA, HIPAA). This lab demonstrates how Snowflake enables compliance without sacrificing data accessibility, accelerating time-to-insight by enabling self-service analytics on protected data while maintaining audit trails.

- **Pricing impact:** Security features like Row Access Policies and Dynamic Data Masking are included in Enterprise Edition at no additional cost. The compute costs are minimal as policies are evaluated at query time with negligible overhead. Enable virtual warehouses only when needed to optimize costs.

---

## ❓ Suggested Discovery Questions

Provide **5 to 6 open-ended questions** for customer conversations related to this HOL.

- "How are you currently handling PII data protection and what compliance requirements do you need to meet?"
- "What challenges do you face in balancing data security with data accessibility for analytics teams?"
- "How do you currently manage access control policies across different user groups and data domains?"
- "What metrics matter most when evaluating data governance solutions in your organization?"
- "Have you faced any security or compliance roadblocks when sharing data with partners or across business units?"
- "How would you customize these security patterns for multi-tenant environments or cross-border data transfers?"

---

## 📂 Repository Structure

```bash
├── README.md              # Main entry point with lab overview
├── config/                # Configuration and grading scripts
│   ├── SE_GREETER.sql     # DORA greeting script
│   ├── DoraGrading.sql    # Automated grading validation
│   └── README.md          # Grading instructions
├── scripts/               # SQL scripts organized by phase
│   ├── 01_setup_users_roles.sql
│   ├── 02_grant_roles_create_database.sql
│   ├── 03_create_customer_table.sql
│   ├── 04_setup_policy_framework.sql
│   ├── 05_row_access_policy.sql
│   ├── 06_column_masking_policy.sql
│   ├── 07_object_tagging.sql
│   ├── 08_data_classification.sql
│   └── 09_cleanup.sql
├── images/                # Diagrams and visual assets
├── lab_instructions/      # Step-by-step detailed instructions
│   └── README.md          # Script execution order and descriptions
└── troubleshooting/       # Common issues and resolutions
    └── faq.md
```
---
## ✅ Prerequisites & Setup Details

Internally helpful setup requirements:

- **Knowledge prerequisites:** 
  - Basic SQL knowledge
  - Understanding of role-based access control concepts
  - Familiarity with data privacy regulations (helpful but not required)

- **Account and entitlement checks:** 
  - Snowflake Account with **Enterprise Edition** or higher
  - ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, and USERADMIN roles
  - Access to Snowflake sample data (`SNOWFLAKE_SAMPLE_DATA` database)
  - *Optional:* Second Enterprise Edition Snowflake Account for data sharing demonstration

- **Hardware/software:** 
  - Supported web browser for Snowsight
  - A warehouse to use for compute (or create a `DEMO_WH`)
  - *Optional:* SnowSQL CLI for key pair authentication demonstration

---
### 🛠️ Lab Instructions

Detailed instruction on executing the scripts can be found [HERE](/lab_instructions/README.md)

## 📊 Grading Instructions

### How to Complete Lab Grading

Congratulations! After completing the lab, validate your work using the automated grading system (DORA).

**Prerequisites for Grading:**
1. Complete all lab steps through Section 6 (Column Masking Policy)
2. Ensure all database objects are created as specified
3. Have ACCOUNTADMIN privileges to create API integrations

**Grading Steps:**

1. **Set up the Grading Environment:**
   - Run the [SE_GREETER.sql](config/SE_GREETER.sql) script first
   - **IMPORTANT:** Edit your contact information in the greeting query (replace `<snowflake email>`, `<First Name>`, `<Last Name>`)

2. **Execute the Grading Script:**
   - Run the [DoraGrading.sql](config/DoraGrading.sql) script
   - Each validation query will return a result indicating pass/fail status

3. **Interpret Results:**
   - ✅ = Step completed successfully
   - ❌ = Step needs attention - review the description for details
   - The `actual` vs `expected` columns show what was found vs what should exist

**Validation Checks:**
- ✅ Database `REYNHOLM_IND_DATA` exists
- ✅ Schema `BASEMENT` exists with Managed Access
- ✅ Table `CUSTOMERS` contains 200 rows
- ✅ Row Access Mapping table exists and contains policy rules
- ✅ Row Access Policy `makes_no_sense` is created and applied
- ✅ Masking Policy `hide_optouts` is created and applied to `C_EMAIL_ADDRESS` column
- ✅ All roles have appropriate grants

**If all validations return ✅, you have successfully completed the HOL! 🎉**

For detailed grading instructions, see [config/README.md](config/README.md)

---
## 🧹 Cleanup & Cost-Stewardship Procedures

### 🗑 Cleanup Instructions:

**IMPORTANT:** Complete cleanup in the correct order to avoid dependency issues.

#### Step 1: Clean up Data Share (if created)
If you created a data share with a second Snowflake account, clean up the consumer account first:

**In the Consumer Account:**
```sql
-- Drop the shared database
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS REYNHOLM_IND_DATA_SHARE;
```

**In the Provider Account (your main account):**
```sql
-- Drop the share
USE ROLE ACCOUNTADMIN;
DROP SHARE IF EXISTS REYNHOLM_IND_DATA_SHARE;
```

#### Step 2: Clean up Database and Schema Objects
Run the comprehensive cleanup script:

```sql
-- Drop the database (this cascades to all schemas, tables, and policies)
USE ROLE ITC_ADMIN;
DROP DATABASE IF EXISTS REYNHOLM_IND_DATA;
```

#### Step 3: Clean up Users and Roles
```sql
-- Drop users
USE ROLE USERADMIN;
DROP USER IF EXISTS "roy@itcrowd";
DROP USER IF EXISTS "moss@itcrowd";
DROP USER IF EXISTS "jen@itcrowd";
DROP USER IF EXISTS "denholm@itcrowd";
DROP USER IF EXISTS "douglas@itcrowd";
DROP USER IF EXISTS "richmond@itcrowd";

-- Drop roles
DROP ROLE IF EXISTS itc_admin;
DROP ROLE IF EXISTS marketing;
DROP ROLE IF EXISTS it;
DROP ROLE IF EXISTS infosec;
DROP ROLE IF EXISTS executive;
```

#### Step 4: Clean up Utility Database (if created for grading)
```sql
-- Drop utility database used for DORA grading
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS util_db;
DROP API INTEGRATION IF EXISTS dora_api_integration;
```

#### Step 5: Suspend or Drop Warehouse (Cost Optimization)
```sql
-- Suspend the warehouse to stop compute costs
USE ROLE SYSADMIN; -- or the role that owns your warehouse
ALTER WAREHOUSE <WAREHOUSE_YOU_WILL_USE> SUSPEND;

-- Optional: Drop the warehouse if it was created specifically for this lab
-- DROP WAREHOUSE IF EXISTS DEMO_WH;
```

### 💰 Cost-Stewardship Best Practices:
- **Immediate cleanup:** Run cleanup scripts immediately after lab completion to minimize storage and compute costs
- **Warehouse management:** Always suspend warehouses when not in use
- **Monitor usage:** Check warehouse and storage usage in Snowsight under Admin > Usage
- **Set timeouts:** Configure auto-suspend on warehouses (recommended: 5-10 minutes)

You can run the complete cleanup script available at: [scripts/09_cleanup.sql](scripts/09_cleanup.sql)

---

## ⚠️ Troubleshooting & FAQ

Common errors and resolutions:

**Issue:** "Object does not exist" error when accessing `SNOWFLAKE_SAMPLE_DATA`  
**Cause:** Sample data not available in the account  
**Solution:** Contact your account administrator to ensure `SNOWFLAKE_SAMPLE_DATA` is accessible, or request it through Snowflake support.

**Issue:** "Insufficient privileges" when creating users or roles  
**Cause:** Not using appropriate administrative role  
**Solution:** Ensure you're using `USERADMIN` for user/role creation, `SECURITYADMIN` for grants, and `SYSADMIN` for database objects.

**Issue:** Cannot grant ownership in Managed Access Schema  
**Cause:** This is expected behavior - Managed Access Schemas prevent direct ownership grants  
**Solution:** Use specific grants (SELECT, INSERT, etc.) instead of OWNERSHIP as demonstrated in the lab.

**Issue:** Row Access Policy or Masking Policy not applying  
**Cause:** Policy may not be attached to the table or column correctly  
**Solution:** Verify policy attachment using `SHOW ROW ACCESS POLICIES` and `SHOW MASKING POLICIES`.

**Issue:** Classification or Tagging features not available  
**Cause:** Preview features may not be enabled in your account  
**Solution:** Contact your account team to enable preview features, or skip those optional sections.

Provide internal Slack channels or support queue links for additional assistance.

---
## 📘 Advanced Concepts (Salted in Training)

Brief callouts to deeper internal learning topics:

- **Separation of Duties:** This lab demonstrates how policy creation (INFOSEC role) can be separated from policy application (ITC_ADMIN role), enabling governance teams to maintain control while empowering data teams.

- **Managed Access Schemas:** By using managed access schemas, you prevent object owners from making arbitrary grants, ensuring all access must flow through schema-level privileges for better auditability.

- **Policy Inheritance through Sharing:** Row Access Policies and Masking Policies automatically apply to shared data, ensuring consistent protection regardless of how data is accessed.

- **Conditional vs. Full Masking:** Conditional masking (based on the OPTIN column) demonstrates context-aware security where data visibility depends on business rules, not just user identity.

- **Tag-Based Policies:** While this lab shows manual tagging, tags can drive automated policy application in production environments, reducing administrative overhead.

- **JSON Processing:** The classification section showcases Snowflake's semi-structured data handling with `FLATTEN()` and variant parsing for analyzing metadata.

- **Cost Optimization:** Security policies add negligible compute overhead as they're evaluated at query time without materializing separate secured views.

---

## 🔗 Links to Internal Resources & Helpful Documents

### Snowflake Documentation
- [Access Control Overview (RBAC & DAC)](https://docs.snowflake.com/en/user-guide/security-access-control-overview.html)
- [Column Level Security](https://docs.snowflake.com/en/user-guide/security-column.html)
- [Dynamic Data Masking](https://docs.snowflake.com/en/user-guide/security-column-ddm.html)
- [Row Access Policies](https://docs.snowflake.com/en/user-guide/security-row.html)
- [Secure Data Sharing](https://docs.snowflake.com/en/user-guide/data-sharing-intro.html)
- [Object Tagging](https://docs.snowflake.com/en/user-guide/object-tagging.html)
- [JSON Processing Basics](https://docs.snowflake.com/en/user-guide/json-basics-tutorial.html)
- [Snowflake Quickstarts](https://www.snowflake.com/en/developers/guides/getting-started-with-pii/)


---

## 👤 Author & Support
**Lab created by:** Aparna Nadimpalli – SE Enablement Senior Manager  
**Created on:** October 29, 2025 | **Last updated:** November 17, 2025 

💬 **Need Help or Have Feedback?**  
- Slack Channel: [#College-of-Platform](#)  
- Slack DM: [@aparna.nadimpalli](https://snowflake.enterprise.slack.com/team/U03RQG03MJR)  
- Email: [aparna.nadimpalli@snowflake.com](mailto:aparna.nadimpalli@snowflake.com)

🌟 *We greatly value your feedback to continuously improve our HOL experiences!*
