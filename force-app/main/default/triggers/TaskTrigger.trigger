/**********************************************************************************************
* @Author:      Sumit Biswas
* @Date:        13/05/2023
* @Description: Task Trigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
trigger TaskTrigger on Task (before insert,before update, after insert, after update, before delete) 
{
    if(!FeatureManagement.checkPermission('SPEN_BypassTriggerTask')){
    if(Trigger.isInsert && Trigger.isBefore)
    {
        SPEN_Tasks.beforeTaskInsert(Trigger.new); 
        SPEN_TaskUtility.preventDuplicatePrePostContactTask(Trigger.new);//Added for CRMD-3156 Connection Story
        SPEN_TaskUtility.populateActivityDateForEPOTask(Trigger.new,null);//CRMD-9727
    }
    
    if(Trigger.isUpdate && Trigger.isBefore)
    {
        SPEN_TaskUtility.populateActivityDateForEPOTask(Trigger.new,Trigger.oldMap);//CRMD-9727
    }
    if(Trigger.isInsert && Trigger.isAfter)
    {
        
    }
    
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        
    }
    if(Trigger.isDelete && Trigger.isBefore)
    {
        SPEN_TaskUtility.preventTaskDeletion(Trigger.old);
    }
    }
}