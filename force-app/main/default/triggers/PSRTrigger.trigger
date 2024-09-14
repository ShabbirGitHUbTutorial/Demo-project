/*-----------------------------------------------------------------------------
DESCRIPTION	:	APEX Trigger for SPEN_PSR__c custom object.
AUTHOR		:	Macjules Sevilla
TEST		:	?
LIBRARY		:	SPEN

HISTORY		:
Date			Author				Comment
FEB-15-2023		Macjules Sevilla	Added bypass logic check
-----------------------------------------------------------------------------*/
trigger PSRTrigger on SPEN_PSR__c (after insert, after update, after delete, before insert) 
{	
   //SFAMS-778: Bypass the business logic inside this section if the running user has SPEN: ADQM Data Migration Bypass permission set
   if( !FeatureManagement.checkPermission('SPEN_BypassTriggerPSR') ){
	 SPEN_PSRTriggerHandler psrth = new SPEN_PSRTriggerHandler();
	 TriggerDispatcher.run(psrth);
    }
	/*if(trigger.isInsert && trigger.isAfter)
	{
		// RULE
		// Bypass the business logic inside this section if the running user
		// is the Data Migration user.
		if(!FeatureManagement.checkPermission('SPEN_BypassTriggerPSR'))
		{
			PSRs.afterPSRInsert(trigger.new);
			PSRs.PSRUpdateSyncADQMValue(trigger.new);
		}
	}
	if(trigger.isInsert && trigger.isBefore)
	{
        PSRs.beforePSRInsert(trigger.new);
    }
	if(trigger.isUpdate && trigger.isAfter)
	{
		// RULE
		// Bypass the business logic inside this section if the running user
		// is the Data Migration user.
		if(!FeatureManagement.checkPermission('SPEN_BypassTriggerPSR'))
		{
			PSRs.afterPSRUpdate(trigger.newmap, trigger.oldmap);
			PSRs.PSRUpdateSyncADQMValue(trigger.new);
		}
	}
	
	// Delete event considered for ADQM Sync process
	if(trigger.isDelete && trigger.isAfter)
	{
		// RULE
		// Bypass the business logic inside this section if the running user
		// is the Data Migration user.
		if(!FeatureManagement.checkPermission('SPEN_BypassTriggerPSR'))
		{
			PSRs.PSRUpdateSyncADQMValue(trigger.old);
		}
	}*/
}