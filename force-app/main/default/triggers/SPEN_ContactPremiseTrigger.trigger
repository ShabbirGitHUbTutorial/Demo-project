/*-----------------------------------------------------------------------------
DESCRIPTION :   APEX Trigger for SPEN_ContactPremise__c custom object.
AUTHOR      :   Macjules Sevilla
TEST        :   ?
LIBRARY     :   SPEN

HISTORY     :
Date            Author              Comment
FEB-15-2023     Macjules Sevilla    Added bypass logic check
-----------------------------------------------------------------------------*/
trigger SPEN_ContactPremiseTrigger on SPEN_ContactPremise__c (before insert, before update, after insert, after update, before delete,after delete,after undelete) 
{

    SPEN_ContactPremise_TriggerHandler ct=new SPEN_ContactPremise_TriggerHandler();
    TriggerDispatcher.run(ct);
    /*if(Trigger.isInsert && Trigger.isBefore)
    {
        // RULE
        // Bypass the business logic inside this section if the running user
        // is the Data Migration user.
        if(!FeatureManagement.checkPermission('SPEN_BypassTriggerContactPremise'))
        {
            new SPEN_ContactPremiseTriggerHandler().validateBeforeInsert(Trigger.new);
        }
    }
    
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        // RULE
        // Bypass the business logic inside this section if the running user
        // is the Data Migration user.
        if(!FeatureManagement.checkPermission('SPEN_BypassTriggerContactPremise'))
        {
            new SPEN_ContactPremiseTriggerHandler().validateBeforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }
    if(Trigger.isInsert && Trigger.isAfter)
    {
        // RULE
        // Bypass the business logic inside this section if the running user
        // is the Data Migration user.
        if(!FeatureManagement.checkPermission('SPEN_BypassTriggerContactPremise'))
        {
            new SPEN_ContactPremiseTriggerHandler().updateContactAfterInsert(Trigger.newMap);
        }
    }
    // 5199 Related changes
    if(Trigger.isUpdate && Trigger.isAfter){
        if(!FeatureManagement.checkPermission('SPEN_BypassTriggerContactPremise')){
            new SPEN_ContactPremiseTriggerHandler().updateContactAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }*/
}