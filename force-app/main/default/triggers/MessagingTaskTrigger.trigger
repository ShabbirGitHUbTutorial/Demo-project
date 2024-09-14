/**********************************************************************************************
* @Author:      Patan Shabbir Ali Khan
* @Date:        25/09/2023
* @Description: CRMD-6968:Option to complete on demand messaging tasks
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
trigger MessagingTaskTrigger on SPEN_MessagingTask__c (before insert, before update, after insert, after update, after delete, after undelete){
    if(Trigger.isBefore && Trigger.isInsert){
    	SPEN_MessagingTaskHandler.onBeforeInsert(Trigger.new);
	}
    if(Trigger.isBefore && Trigger.isUpdate){
        SPEN_MessagingTaskHandler.onBeforeUpdate(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        SPEN_MessagingTaskHandler.onAfterInsert(Trigger.new);
    }
}