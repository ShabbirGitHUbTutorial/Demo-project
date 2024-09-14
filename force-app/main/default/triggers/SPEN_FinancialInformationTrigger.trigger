/*-----------------------------------------------------------------------------
DESCRIPTION :   Trigger of the SPEN_FinancialInformation__c Object 
LIBRARY     :   Salesforce Enterprise Library - Trigger of the SPEN_FinancialInformation__c Object
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
22-Sep-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
trigger SPEN_FinancialInformationTrigger on SPEN_FinancialInformation__c (after insert) {
    
	if(trigger.isInsert && trigger.isAfter && !FeatureManagement.checkPermission('SPEN_BypassTriggerFinancialInformation'))
	{
       SPEN_FinancialInformationTriggerHandler.calculateFixedCumulativeApplicationFee(trigger.new);
    }
}