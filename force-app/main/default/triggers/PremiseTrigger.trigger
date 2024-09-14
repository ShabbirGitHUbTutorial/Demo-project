/*-----------------------------------------------------------------------------
DESCRIPTION	:	APEX Trigger for SPEN_Premise__c custom object.
AUTHOR		:	Macjules Sevilla
TEST		:	?
LIBRARY		:	SPEN

HISTORY		:
Date			Author				Comment
FEB-12-2023		Macjules Sevilla	Added bypass logic check
-----------------------------------------------------------------------------*/
trigger PremiseTrigger on SPEN_Premise__c (before insert, before update, after update) 
{
    if(trigger.isUpdate && trigger.isAfter)
    {
        // RULE
        // Bypass the business logic inside this section if the running user
        // is either the Data Migration or Data Sync Batch user.
        if(!FeatureManagement.checkPermission('SPEN_BypassTriggerPermise'))
        {
            Premises.afterPremiseUpdate(trigger.newmap, trigger.oldmap);
        }
        
    }
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('Before Insert');
        Premises.beforeInsert(Trigger.new);
        Premises.beforePremiseInsert(trigger.new);//9191
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('Before Update');
        Premises.beforeUpdate(Trigger.new);
        Premises.beforePremiseUpdate(trigger.newmap, trigger.oldmap);//9191
    }
    
}