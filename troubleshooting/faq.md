# Troubleshooting & FAQ

This document provides solutions to common issues encountered during the Snowflake PII Data Protection Hands-on Lab.

---

## 📋 Table of Contents

- [Environment Setup Issues](#environment-setup-issues)
- [User and Role Issues](#user-and-role-issues)
- [Database and Schema Issues](#database-and-schema-issues)
- [Policy Issues](#policy-issues)
- [Data Sharing Issues](#data-sharing-issues)
- [Grading Issues](#grading-issues)
- [Performance and Timeout Issues](#performance-and-timeout-issues)
- [General Questions](#general-questions)

---

## Environment Setup Issues

### Q: I don't have access to SNOWFLAKE_SAMPLE_DATA

**Error:** `Object 'SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER' does not exist`

**Solution:**
1. Contact your Snowflake account administrator
2. Request access to the sample data database
3. Alternatively, ask admin to run: `GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE PUBLIC;`

**Workaround:** If sample data is unavailable, you can create synthetic test data using a different approach (contact lab support).

---

### Q: I don't have the required administrative roles

**Error:** `Insufficient privileges to operate on database/user/role`

**Solution:**
- You need ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, or USERADMIN roles
- Contact your account administrator to grant these roles temporarily
- For learning environments, ACCOUNTADMIN can complete all steps

**Alternative:** If you cannot get admin roles, ask your admin to execute the setup scripts on your behalf.

---

### Q: I don't have a warehouse or don't know which one to use

**Error:** `No active warehouse selected`

**Solution:**
1. Check existing warehouses: `SHOW WAREHOUSES;`
2. Create a new warehouse:
   ```sql
   USE ROLE SYSADMIN;
   CREATE WAREHOUSE demo_wh 
       WITH WAREHOUSE_SIZE = 'X-SMALL' 
       AUTO_SUSPEND = 300 
       AUTO_RESUME = TRUE;
   ```
3. Replace `<WAREHOUSE_YOU_WILL_USE>` with `demo_wh` in scripts

---

## User and Role Issues

### Q: Password requirements error when creating users

**Error:** `Password does not meet requirements`

**Solution:**
- Snowflake requires strong passwords with minimum complexity
- Use passwords with at least 8 characters, uppercase, lowercase, and numbers
- Example: `SecurePass123!`
- Alternatively, use key pair authentication instead (see script 01)

---

### Q: Can I complete the lab without creating separate users?

**Answer:** Yes!

**Solution:**
1. Grant all five roles to your own user account
2. When instructions say "login as user X", instead run: `USE ROLE <role_name>;`
3. Example: Instead of logging in as `moss@itcrowd`, run `USE ROLE infosec;`

This approach still demonstrates the RBAC concepts without requiring multiple user accounts.

---

### Q: Key pair authentication setup is unclear

**Resources:**
- [Snowflake Key Pair Authentication Guide](https://docs.snowflake.com/en/user-guide/key-pair-auth.html)
- [Key Pair Generation Tutorial](https://docs.snowflake.com/en/user-guide/key-pair-auth.html#configuring-key-pair-authentication)

**Quick Steps:**
1. Generate private key: `openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt`
2. Generate public key: `openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub`
3. Copy public key content (without headers) and assign to user

---

### Q: I accidentally deleted a user that owns objects

**Error:** `Cannot drop user because it owns objects`

**Solution:**
1. Transfer object ownership to another user/role first
2. Or drop the objects before dropping the user
3. Or drop the entire database (if in demo environment)
4. Use cleanup script which handles dependencies correctly

---

## Database and Schema Issues

### Q: Managed Access Schema prevents me from granting privileges

**Error:** `Cannot grant ownership in managed access schema`

**Answer:** This is expected behavior!

**Explanation:**
- Managed Access Schemas enforce centralized privilege management
- Only the schema owner can grant privileges
- This prevents privilege escalation

**Solution:**
- Grant specific privileges (SELECT, INSERT) instead of OWNERSHIP
- Use SECURITYADMIN or schema owner role to make grants
- See script 04 for examples

---

### Q: Table already exists error

**Error:** `Object 'CUSTOMERS' already exists`

**Solution:**
1. Drop the existing table: `DROP TABLE IF EXISTS REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS;`
2. Or use `CREATE OR REPLACE TABLE` instead of `CREATE TABLE`
3. Or skip to the next script if table is already correctly created

---

### Q: Wrong number of rows in CUSTOMERS table

**Issue:** Table has more or fewer than 200 rows

**Solution:**
- Drop and recreate the table using script 03
- Verify the LIMIT 200 clause is present in the CREATE TABLE statement
- Check if table was modified after creation

---

## Policy Issues

### Q: Row Access Policy doesn't seem to work

**Symptoms:** All roles see the same data

**Troubleshooting:**
1. Verify policy is applied:
   ```sql
   SHOW ROW ACCESS POLICIES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;
   SELECT * FROM TABLE(
       INFORMATION_SCHEMA.POLICY_REFERENCES(
           REF_ENTITY_NAME => 'REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS',
           REF_ENTITY_DOMAIN => 'TABLE'
       )
   );
   ```

2. Verify mapping table has correct data:
   ```sql
   SELECT * FROM REYNHOLM_IND_DATA.BASEMENT.ROW_ACCESS_MAPPING;
   ```

3. Verify you're using the correct role:
   ```sql
   SELECT CURRENT_ROLE();
   ```

**Solution:**
- If policy not applied, re-run script 05
- If mapping table empty, re-run the INSERT statement in script 05
- Switch roles to test: `USE ROLE marketing;`

---

### Q: Masking Policy shows ***MASKED*** for all rows

**Symptoms:** All emails are masked, even when OPTIN = 'YES'

**Troubleshooting:**
1. Verify policy definition:
   ```sql
   DESC MASKING POLICY REYNHOLM_IND_DATA.BASEMENT.hide_optouts;
   ```

2. Check if conditional masking is enabled in your account

3. Verify OPTIN column has 'YES' values:
   ```sql
   SELECT OPTIN, COUNT(*) 
   FROM REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
   GROUP BY OPTIN;
   ```

**Solution:**
- If conditional masking not available, use the alternative full masking policy
- If OPTIN column is all NULL, recreate table (script 03)

---

### Q: How do I remove a policy to reapply it?

**Row Access Policy:**
```sql
USE ROLE itc_admin;
ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
    DROP ROW ACCESS POLICY REYNHOLM_IND_DATA.BASEMENT.makes_no_sense;
```

**Masking Policy:**
```sql
USE ROLE itc_admin;
ALTER TABLE REYNHOLM_IND_DATA.BASEMENT.CUSTOMERS 
    MODIFY COLUMN C_EMAIL_ADDRESS UNSET MASKING POLICY;
```

---

### Q: Policy creation fails with privilege error

**Error:** `Insufficient privileges to create policy`

**Solution:**
1. Verify you have CREATE MASKING POLICY or CREATE ROW ACCESS POLICY privilege
2. Use the INFOSEC role (which was granted these privileges in script 04)
3. Or re-run script 04 to grant privileges

---

## Data Sharing Issues

### Q: I don't have a second Snowflake account for sharing

**Answer:** Data sharing is optional for this lab.

**Solution:**
- Skip the data sharing section
- The lab can be completed without it
- All other learning objectives are achieved through scripts 01-08

**Alternative:** Request a trial account from Snowflake for testing data sharing.

---

### Q: Share creation fails

**Error:** Various errors during share creation

**Troubleshooting:**
1. Verify you're using ACCOUNTADMIN role
2. Ensure the share name matches exactly: `REYNHOLM_IND_DATA_SHARE`
3. Verify both accounts are in the same region
4. Check that policies are applied before sharing

**Solution:**
- Use the Snowsight UI for share creation (more intuitive than SQL)
- Follow the screenshots in the main README.md
- Verify second account locator is correct

---

### Q: Shared data doesn't show policy enforcement

**Issue:** Consumer sees all data without policy restrictions

**Troubleshooting:**
1. Verify share name matches policy: `REYNHOLM_IND_DATA_SHARE`
2. Check policy includes INVOKER_SHARE() logic
3. Verify policy was applied BEFORE creating share

**Solution:**
- Drop and recreate share if policy was applied after sharing
- Ensure share name matches exactly in both policy and UI

---

## Grading Issues

### Q: Grading script fails with API integration error

**Error:** `External function not found` or `API integration error`

**Solution:**
1. Verify you ran SE_GREETER.sql first
2. Check API integration exists: `SHOW INTEGRATIONS;`
3. Verify you have ACCOUNTADMIN privileges
4. Ensure util_db database exists: `SHOW DATABASES LIKE 'util_db';`

---

### Q: All grading validations fail

**Cause:** Usually Account Usage view latency

**Solution:**
1. Wait 5-10 minutes after completing lab
2. Retry grading script
3. Use alternative immediate validation:
   ```sql
   -- Check objects directly
   SHOW DATABASES;
   SHOW TABLES IN SCHEMA REYNHOLM_IND_DATA.BASEMENT;
   SHOW ROW ACCESS POLICIES;
   SHOW MASKING POLICIES;
   ```

---

### Q: Specific validation step fails

**Approach:**
1. Note which STEP## failed
2. Review the actual vs expected values
3. Check the description to identify the issue
4. Re-run the corresponding script:
   - STEP01-03: Scripts 02-03
   - STEP04-05: Scripts 04-05
   - STEP06: Script 05
   - STEP07: Script 06
   - STEP08-10: Scripts 01-02
5. Wait 5-10 minutes for Account Usage to update
6. Retry grading

---

## Performance and Timeout Issues

### Q: Queries are timing out

**Causes:**
- Warehouse is too small
- Warehouse is suspended
- Network issues

**Solution:**
1. Resume warehouse: `ALTER WAREHOUSE <name> RESUME;`
2. Increase warehouse size:
   ```sql
   ALTER WAREHOUSE <name> SET WAREHOUSE_SIZE = 'SMALL';
   ```
3. Check warehouse status: `SHOW WAREHOUSES;`

---

### Q: Warehouse auto-suspend is too aggressive

**Issue:** Warehouse keeps suspending during lab

**Solution:**
1. Increase auto-suspend timeout:
   ```sql
   ALTER WAREHOUSE <name> SET AUTO_SUSPEND = 600;  -- 10 minutes
   ```
2. Or disable auto-suspend temporarily:
   ```sql
   ALTER WAREHOUSE <name> SET AUTO_SUSPEND = NULL;
   ```
3. Remember to re-enable after lab!

---

## General Questions

### Q: How long does the lab take?

**Answer:** Approximately 80 minutes
- Setup: 20 minutes
- Policies: 30 minutes
- Advanced features: 25 minutes
- Cleanup: 5 minutes

Times vary based on familiarity with Snowflake and environment setup complexity.

---

### Q: Which scripts are required vs. optional?

**Required (for grading):**
- Scripts 01-06: Setup, policies, and core features

**Optional:**
- Script 07: Object tagging (preview feature)
- Script 08: Data classification (preview feature)
- Script 09: Cleanup (recommended but optional)
- Data Sharing: Via UI (optional, requires second account)

---

### Q: Can I run multiple scripts at once?

**Answer:** Not recommended

**Best Practice:**
- Run one script at a time
- Execute scripts in sections, not all at once
- Verify results after each section
- Read comments to understand what's happening

**Why:** Scripts have dependencies, and troubleshooting is easier when done incrementally.

---

### Q: I made a mistake. How do I start over?

**Solution:**
1. Run the cleanup script: `scripts/09_cleanup.sql`
2. Wait for cleanup to complete
3. Start from script 01 again
4. Review instructions more carefully this time

---

### Q: Are there any costs for running this lab?

**Answer:** Minimal costs

**Cost Factors:**
- Compute: Small warehouse for ~80 minutes (pennies to few dollars)
- Storage: ~200 rows of data (negligible)
- API calls: DORA grading (free for education)

**Cost Control:**
- Use X-SMALL warehouse
- Run cleanup immediately after completion
- Suspend warehouse when not in use

---

### Q: Can I use this lab in production?

**Answer:** No, this is for learning only.

**Production Considerations:**
- Change all passwords and use proper authentication
- Don't use demo user names
- Adapt policies to your actual data and requirements
- Implement proper governance and change management
- Test thoroughly in non-production environment first
- Follow your organization's security standards

**What to Adopt:**
- Policy patterns and approaches
- Separation of duties model
- Managed access schema practices
- Documentation standards

---

## 📞 Getting Additional Help

If you've reviewed this FAQ and still need assistance:

1. **Review Main Documentation:**
   - [Main README.md](../README.md)
   - [Lab Instructions](../lab_instructions/README.md)
   - Script comments in each SQL file

2. **Snowflake Documentation:**
   - [Row Access Policies](https://docs.snowflake.com/en/user-guide/security-row.html)
   - [Dynamic Data Masking](https://docs.snowflake.com/en/user-guide/security-column-ddm.html)
   - [Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-overview.html)

3. **Submit Feedback:**
   - GitHub Issues: [Snowflake Labs](https://github.com/Snowflake-Labs/sfguides/issues)
   - Include: Error message, script number, Snowflake edition, what you tried

4. **Internal Support:**
   - Contact your Platform College team
   - Reach out to your Snowflake account team
   - Check internal documentation and resources

---

## 💡 Pro Tips

1. **Read Comments:** Every script has detailed comments explaining each step
2. **Use Snowsight:** Better UI experience than classic console
3. **Test as You Go:** Verify results after each script section
4. **Document Issues:** Note any problems for feedback
5. **Take Screenshots:** Capture successful results for records
6. **Don't Rush:** Understanding concepts is more important than speed
7. **Experiment:** Try variations after completing the lab
8. **Clean Up:** Always run cleanup to avoid costs

---

**Still stuck?** Review the specific script file - it contains detailed comments and troubleshooting notes for that step.

