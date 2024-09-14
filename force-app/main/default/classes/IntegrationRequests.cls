/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        11/11/2022
* @Description: Handler class is on IntegrationRequestTrigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class IntegrationRequests {
    
    SPEN_IntegrationRequestService intReqst = new SPEN_IntegrationRequestService();
    
    public void onAfterInsert(List<SPEN_IntegrationRequest__c> newCreatedIntegrationRequestList)
    {
        if(Trigger.isInsert && Trigger.isAfter){
            intReqst.isStatusProcessing(newCreatedIntegrationRequestList);
            intReqst.isStatusProcessingForAssignIvrMsg(newCreatedIntegrationRequestList);
			intReqst.isStatusProcessingForMeterDetails(newCreatedIntegrationRequestList);
			intReqst.isStatusProcessingForPremise(newCreatedIntegrationRequestList);  //CRMD - 5165
        }
    }
    
    public void onAfterUpdate(Map<Id,SPEN_IntegrationRequest__c> oldUpdatedIntegrationRequestMap,List<SPEN_IntegrationRequest__c> newUpdatedIntegrationRequestList)
    {
        if(Trigger.isUpdate && Trigger.isAfter){
            intReqst.isStatusChanged(oldUpdatedIntegrationRequestMap, newUpdatedIntegrationRequestList);
            intReqst.isStatusProcessingForAssignIvrMsg(newUpdatedIntegrationRequestList);
            intReqst.isStatusProcessingForEchoesSearch(newUpdatedIntegrationRequestList);
        }   
    }
}