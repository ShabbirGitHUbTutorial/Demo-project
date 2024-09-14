/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler class of the SPEN_FinancialInformation__c Object Trigger.
LIBRARY     :   Salesforce Enterprise Library - Handler class of the SPEN_FinancialInformation__c Object Trigger
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
22-Sep-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/

public with sharing class SPEN_FinancialInformationTriggerHandler {
    
    
    public static void calculateFixedCumulativeApplicationFee(List<SPEN_FinancialInformation__c> newFinancialList)
    {
        List<Id> financialIds = new List<Id>();
        List<String> cseName = new List<String>();
        Map<String,Id> finacialCaseMap =  new Map<String,Id>();
        
        for(SPEN_FinancialInformation__c financialInfo: newFinancialList)
        {
            financialIds.add(financialInfo.Id);
            String strCaseNumber = financialInfo.Name.SUBSTRINGBEFORE('-');
            csename.add(strCaseNumber);
            finacialCaseMap.put(strCaseNumber,financialInfo.Id);
        }
        
        List<Case> caseList = [Select Id,CaseNumber, Application_fee_Type__c, Application_Stage__c,SPEN_ApplicationType__c,SPEN_SizeMWsExportCEC__c,
                               SPEN_ContractArea__c, SPEN_LocationType__c, SPEN_PrimaryTransmissionTechnologyType__c,SPEN_DemandCapacityMWs__c,SPEN_FinancialInformation__c,
                               SPEN_SecondaryTransmissionTechnologyType__c,SPEN_TertiaryTransmissionTechnologyType__c 
                               From Case where CaseNumber  =: csename];
        
        Cases.calculateFixedCumulativeApplicationFee(caseList,finacialCaseMap);
        
        
    }
    
}