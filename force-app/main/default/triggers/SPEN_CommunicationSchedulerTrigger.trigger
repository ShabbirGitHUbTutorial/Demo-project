/**
 * @description       : Trigger to update SPEN_Creation_Batch_Delay__c field on before insert.
 * @author            : rahul.dd.kumar@accenture.com
 * @last modified on  : 03-06-2023
 * @last modified by  : 
**/
trigger SPEN_CommunicationSchedulerTrigger on SPEN_CommunicationScheduler__c (before insert) {
	SPEN_CommunicationSchedulers commSch = new SPEN_CommunicationSchedulers();
    if(Trigger.isInsert){
        commSch.beforeCommunicationSchInsert(Trigger.new);
    }
}