trigger SPEN_ContactTrigger on Contact (before insert, after insert, before update, after update) 
{
	/*if(Trigger.isBefore && Trigger.isInsert)
	{
		// RULE
		// Bypass the business logic inside this section if the running user
		// is either the Data Migration user or ADQM Sync.
		if(!FeatureManagement.checkPermission('SPEN_BypassTriggerContact'))
		{
			SPEN_ContactTriggerHandler.SPEN_ContactUpdateSyncADQMValueinsert(trigger.new);
		}
	}*/
	
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		// RULE
		// Bypass the business logic inside this section if the running user
		// is either the Data Migration user or ADQM Sync.
		if(!FeatureManagement.checkPermission('SPEN_BypassTriggerContact'))
		{
			SPEN_ContactTriggerHandler.SPEN_ContactUpdateSyncADQMValueUpdate(trigger.oldmap,trigger.new);
		}
	}

	if(Trigger.isAfter && Trigger.isUpdate)
	{
		// DO NOT BYPASS
		// This is important for auditing purposes
		SPEN_ContactTriggerHandler.SPEN_ContactPreviousValue(trigger.new,trigger.oldmap);
	}
}