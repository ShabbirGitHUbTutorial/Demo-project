/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the Plot Queries.
LIBRARY     :   Salesforce Enterprise Library - Plot Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
25-Jul-2023     Akshay Pandit        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_PhysicalInformationSelector {
    /**************************************************
    @Author: Akshay Pandit
    @Date: 25-Jul-2023 
    @purpose: Method to get Physical Information details from case.
    ***************************************************/
    public static List<SPEN_PhysicalInformation__c> getPhysicalInfoFromCase(Id caseId){
        List<SPEN_PhysicalInformation__c>	physicalInfoList = new List<SPEN_PhysicalInformation__c>();
        if(caseId != null)
        {
            physicalInfoList = 	[Select Id,SPEN_ItemID__c,SPEN_Case__c,SPEN_ItemClass__c,SPEN_ItemProfile__c,SPEN_ItemRequestedDate__c,SPEN_ItemRequestRemark__c,SPEN_ItemReceivedOn__c,SPEN_ItemReceivedRemark__c FROM SPEN_PhysicalInformation__c where SPEN_Case__c=: caseId WITH SECURITY_ENFORCED];
        }  	                       
        return physicalInfoList;     
    }

    public static SPEN_PhysicalInformation__c getPhysicalInfoFromPhyInfoIds(List<Id> phyInfoIds){
        SPEN_PhysicalInformation__c	physicalInfoRec;
        if(!phyInfoIds.isEmpty())
        {
            physicalInfoRec = [select id,SPEN_Case__c from SPEN_PhysicalInformation__c where id in : phyInfoIds WITH SECURITY_ENFORCED limit 1 ];
        }  	                       
        return physicalInfoRec;     
    }

    public static SPEN_PhysicalInformation__c getPhysicalInfoFromPhyInfoStrId(String phyInfoRef){
        SPEN_PhysicalInformation__c	physicalInfoRec;
        if(phyInfoRef != null)
        {
            physicalInfoRec = [Select Id,SPEN_ItemID__c,SPEN_Case__c,SPEN_ItemClass__c,SPEN_ItemProfile__c,SPEN_ItemRequestedDate__c,SPEN_ItemRequestRemark__c,SPEN_ItemReceivedOn__c,SPEN_ItemReceivedRemark__c,SPEN_Case__r.SPEN_SAPReference__c FROM SPEN_PhysicalInformation__c where id =: phyInfoRef WITH SECURITY_ENFORCED limit 1];
        }  	                       
        return physicalInfoRec;     
    }
}