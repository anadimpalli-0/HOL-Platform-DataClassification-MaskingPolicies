# How to Complete Lab Grading

Congrats\! You have completed the lab. Please run the following commands in Snowsight to confirm your completion.

Remember to edit your contact information in the SQL Statement for the [SE_GREETER.sql](/config/SE_GREETER.sql)

* [Greeter Script for DORA](/config/SE_GREETER.sql)
* [Grading Script for DORA](/config/DoraGrading.sql)

If all validations return ✅, you have successfully completed the HOL

----
## Next Steps

### CleanUp

Clean up all the Objects created during the lab

Ensure that all the validations return ✅ before you cleanup the Objects.

[Cleanup Script to Execute](/scripts/09_cleanup.sql)

**Role Required:** ACCOUNTADMIN, itc_admin, USERADMIN  
**Description:** Removes all lab objects and stops costs

**What it does:**
- Drops data share (if created)
- Drops `REYNHOLM_IND_DATA` database (cascades to all objects)
- Drops all six demo users
- Drops all five custom roles
- Drops utility database and API integration (if created for grading)
- Suspends warehouse to stop compute costs

**Important Notes:**
- ⚠️ Run in the correct order to avoid dependency errors
- If data sharing was used, clean up consumer account FIRST
- Replace `<WAREHOUSE_YOU_WILL_USE>` with your warehouse name
- Verify all objects are removed before completing

**Expected Result:** All lab objects removed, warehouse suspended, no ongoing costs
