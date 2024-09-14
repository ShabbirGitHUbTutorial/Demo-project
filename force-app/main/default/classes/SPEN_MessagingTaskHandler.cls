/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  CRMD-9211:Completed messaging tasks toggles are changing dependent on future outage state changes.
AUTHOR    :  Patan Shabbir Ali Khan
LIBRARY    :  Salesforce Enterprise Library 
VERSION    :  1.0

HISTORY    :
Date      		Author      	            Comment
21-11-2023    Patan Shabbir Ali Khan     Initial version
-----------------------------------------------------------------------------------------*/
public with sharing class SPEN_MessagingTaskHandler {
    public static void onBeforeInsert(List<SPEN_MessagingTask__c> newMessagingrecords){
        Set<Id> incidentIds = new Set<Id>();
        System.debug('OnBefore MessagigTask');
       // SPEN_Incident_Outage_Flag__c
       for(SPEN_MessagingTask__c mTask : newMessagingrecords){
            if(mTask.SPEN_IncidentId__c != null){
                incidentIds.add(mTask.SPEN_IncidentId__c);
            }
        }
        if(!incidentIds.isEmpty()){
            List<Incident> incList = [SELECT SPEN_Outage_State__c,SPEN_droppedsupply__c FROM Incident WHERE Id=: incidentIds WITH SECURITY_ENFORCED];
            if(incList.size() > 0){
                for(SPEN_MessagingTask__c mTask : newMessagingrecords){
                    if(incList[0].SPEN_Outage_State__c != null){
                        mTask.SPEN_Incident_Outage_Flag__c = true;
                        mTask.Incident_Outage_Status__c = incList[0].SPEN_Outage_State__c;
                    }
                     mTask.SPEN_DroppedSupplyCheckbox__c = incList[0].SPEN_droppedsupply__c;
                }
            }
        }

    }

    public static void onBeforeUpdate(List<SPEN_MessagingTask__c> newMessagingrecords){
        Map<String, List<String>> statusMap = new Map<String,List<String>>{'Completed'=> new List<String>{'New', 'In Progress', 'Cancelled'},'Cancelled'=> new List<String>{'New', 'In Progress', 'Completed'}};
        for(SPEN_MessagingTask__c mTask : newMessagingrecords){
            if(mTask.SPEN_Event__c == SPEN_ConstantData.ONDEMAND){
                SPEN_MessagingTask__c oldData= (SPEN_MessagingTask__c)Trigger.oldMap.get(mTask.Id);
                if(statusMap.get(oldData.SPEN_Status__c) != null){
                    if(mTask.SPEN_Status__c != oldData.SPEN_Status__c && statusMap.get(oldData.SPEN_Status__c).contains(mTask.SPEN_Status__c)) { //!SPEN_ConstantData.CHANGEDSTATUS.contains(oldData.SPEN_Status__c) && SPEN_ConstantData.CHANGEDSTATUS.contains(mTask.SPEN_Status__c)){
                        mTask.SPEN_Status__c.addError(SPEN_ConstantData.MESSAGINGTASKERRORMESSAGE);
                    }  
                }
            }
        }

    }
public static void onAfterInsert(List<SPEN_MessagingTask__c> newMessagingrecords){
        Id mTaskRecordTypeId = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            List<Incident> incidentTobeUpdated = new List<Incident>();
      		Set<Id> setOfIncidentIds = new Set<Id>();
            for(SPEN_MessagingTask__c msTask : newMessagingrecords){
                if(mTaskRecordTypeId == msTask.RecordTypeId){
                      setOfIncidentIds.add(msTask.SPEN_IncidentId__c);
                }
            }
         for(AggregateResult ar : [SELECT  SPEN_IncidentId__c, count(Id) totalCount  FROM SPEN_MessagingTask__c group by SPEN_IncidentId__c having SPEN_IncidentId__c IN :setOfIncidentIds])  {
      	  Incident inc = new Incident();
          inc.Id = String.valueOf(ar.get('SPEN_IncidentId__c'));
          inc.SPEN_TotalMessagingTaskPresent__c =  Integer.valueOf(ar.get('totalCount'));
          incidentTobeUpdated.add(inc);
      }
        if(!incidentTobeUpdated.isEmpty()){
            try{
                update incidentTobeUpdated;
            }
            catch(Exception ex){
                SEL_LoggingService.log(ex);
                throw ex;
       		 }
        }
    }
}