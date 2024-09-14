/**
 * @description       : Service class for SPEN_CommunicationSchedulerTrigger 
 * @author            : rahul.dd.kumar@accenture.com
 * @last modified on  : 03-06-2023
 * @last modified by  : 
**/
public class SPEN_CommunicationSchedulers {
     public void beforeCommunicationSchInsert(List<sObject> commSchNewList){
         SPEN_ConfigurableSettings__c batchDelayInMinutes = [SELECT Id, SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='CreationBatchDelayForMessagingTask' Limit 1];
         Integer delayMinutes = Integer.valueOf(batchDelayInMinutes.SPEN_Value__c);
         SPEN_ConfigurableSettings__c onDemandDelayInMinutes = [SELECT Id, SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='OnDemandMessageDelayForMessagingTask' Limit 1];
         Integer delayMinutesForOnDemandMessage = Integer.valueOf(onDemandDelayInMinutes.SPEN_Value__c);
         List<SPEN_CommunicationScheduler__c> commSchList = (List<SPEN_CommunicationScheduler__c>)commSchNewList;
         for(SPEN_CommunicationScheduler__c commSch : commSchList){
           if(commSch.SPEN_Event__c=='On Demand')
           {
               commSch.SPEN_Creation_Batch_Delay__c = System.now().addMinutes(delayMinutesForOnDemandMessage);
           }
           else
           {
               commSch.SPEN_Creation_Batch_Delay__c = System.now().addMinutes(delayMinutes);
           }
             
        }
     }
}