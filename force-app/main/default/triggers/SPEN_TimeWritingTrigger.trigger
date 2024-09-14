/*-----------------------------------------------------------------------------
DESCRIPTION :   Trigger of the SPEN_TimeWriting__c Object 
LIBRARY     :   Salesforce Enterprise Library - Trigger of the SPEN_TimeWriting__c Object
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
22-Sep-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
trigger SPEN_TimeWritingTrigger on SPEN_TimeWriting__c (before insert, before update) {

    if(trigger.isInsert && trigger.isBefore)
	{
        SPEN_TimeWritingTriggerHandler.calculateTimeWritingFee(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore)
	{
        SPEN_TimeWritingTriggerHandler.calculateTimeWritingFee(trigger.new);
    }
    
}