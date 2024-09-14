/*
This Service class will be used to update the Outbound tasks on Incident Status change
@Date: 19/02/2023
*/
public with sharing class SPEN_OutboundDialerService {
    //When the INC status changes to Merge then all outbound task in queue to be dropped for that INC
    @future
    public static void dropOlderODTasksOnMerge(List<String> incidentIdLst){
        List<SPEN_CustomerUpdate__c> odUpdList = new List<SPEN_CustomerUpdate__c>();
        group odQueue = [Select Id FROM GROUP WHERE DeveloperName = 'Outbound_Dialer'];
        User dropUser = [Select Id FROM User WHERE Name = 'Dropped Outbound Task User' LIMIT 1];
        for(SPEN_CustomerUpdate__c odObj :[SELECT Id,SPEN_IncidentId__c,OwnerId FROM SPEN_CustomerUpdate__c WHERE SPEN_IncidentId__c =:incidentIdLst AND OwnerId =:odQueue.Id]){
            odObj.OwnerId=dropUser.Id;
            odUpdList.add(odObj);
        }
        if(!odUpdList.isEmpty()){
            update odUpdList;
        }
    }
    //When the INC status changes to Delog then all outbound task in queue without Restored stage to be dropped for that INC
    //Creation - Stage 1, ERT change - Stage 2, Comfort - Stage 3 and Restored is Stage 4
    @future
    public static void dropOlderODTasksOnDelog(List<String> incidentIdLst){
        List<SPEN_CustomerUpdate__c> odUpdList = new List<SPEN_CustomerUpdate__c>();
        group odQueue = [Select Id FROM GROUP WHERE DeveloperName = 'Outbound_Dialer'];
        User dropUser = [Select Id FROM User WHERE Name = 'Dropped Outbound Task User' LIMIT 1];
        for(SPEN_CustomerUpdate__c odObj :[SELECT Id,SPEN_IncidentId__c,OwnerId FROM SPEN_CustomerUpdate__c WHERE SPEN_IncidentId__c =:incidentIdLst AND OwnerId =:odQueue.Id AND SPEN_Campaign__c !='Stage 4']){
            odObj.OwnerId=dropUser.Id;
            odUpdList.add(odObj);
        }
        if(!odUpdList.isEmpty()){
            update odUpdList;
        }
    }
    //When the INC ERT changes and if there are any Comfort OD then it needs to be dropped
    //Creation - Stage 1, ERT change - Stage 2, Comfort - Stage 3 and Restored is Stage 4
    @future
    public static void dropComfortODTasksOnERTChange(List<String> incidentIdLst){
        List<SPEN_CustomerUpdate__c> odUpdList = new List<SPEN_CustomerUpdate__c>();
        group odQueue = [Select Id FROM GROUP WHERE DeveloperName = 'Outbound_Dialer'];
        User dropUser = [Select Id FROM User WHERE Name = 'Dropped Outbound Task User' LIMIT 1];
        for(SPEN_CustomerUpdate__c odObj :[SELECT Id,SPEN_IncidentId__c,OwnerId FROM SPEN_CustomerUpdate__c WHERE SPEN_IncidentId__c =:incidentIdLst AND OwnerId =:odQueue.Id AND SPEN_Campaign__c ='Stage 3']){
            odObj.OwnerId=dropUser.Id;
            odUpdList.add(odObj);
        }
        if(!odUpdList.isEmpty()){
            update odUpdList;
        }
    }
    //When the INC ERT changes and if there are any Comfort OD then it needs to be dropped
    //Creation - Stage 1, ERT change - Stage 2, Comfort - Stage 3 and Restored is Stage 4
    @future
    public static void dropODTasksOnDROPChange(List<String> incidentIdLst){
        List<SPEN_CustomerUpdate__c> odUpdList = new List<SPEN_CustomerUpdate__c>();
        group odQueue = [Select Id FROM GROUP WHERE DeveloperName = 'Outbound_Dialer'];
        User dropUser = [Select Id FROM User WHERE Name = 'Dropped Outbound Task User' LIMIT 1];
        for(SPEN_CustomerUpdate__c odObj :[SELECT Id,SPEN_IncidentId__c,OwnerId FROM SPEN_CustomerUpdate__c WHERE SPEN_IncidentId__c =:incidentIdLst AND OwnerId =:odQueue.Id AND SPEN_Campaign__c IN :SPEN_ConstantData.CAMPAIGN_LIST]){
            odObj.OwnerId=dropUser.Id;
            odUpdList.add(odObj);
        }
        if(!odUpdList.isEmpty()){
            update odUpdList;
        }
    }
}