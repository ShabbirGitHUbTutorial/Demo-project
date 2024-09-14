/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        11/11/2022
* @Description: IntegrationRequest Trigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/

trigger IntegrationRequestTrigger on SPEN_IntegrationRequest__c(after insert, after update){
    new IntegrationRequests().onAfterInsert(Trigger.new);
    new IntegrationRequests().onAfterUpdate(Trigger.oldMap,Trigger.new);
}