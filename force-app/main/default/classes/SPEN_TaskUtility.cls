public with sharing class SPEN_TaskUtility {
    /*************************************************************************
    @Author: Amrita Sarkar
    @Date: 28/06/23
    @purpose: CRMD-3156 and CRMD-3097 Check duplicate pre or post task creation in same case record
    *************************************************************************************/
        public static void preventDuplicatePrePostContactTask(List<sObject> taskNewList){
            try{     
                List<Task> taskMapNewVal = (List<Task>)taskNewList;
                Id preQuoteRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(SPEN_ConstantData.PREPOSTASKRECRDTYPE).getRecordTypeId();
                Set<id> taskRecrTypeId = new  Set<id>();
                taskRecrTypeId.add(preQuoteRecordTypeId);
                Set<Id> caseId = new Set<Id>();
                Map<id,integer> preQuoteTaskWithCaseMap = new Map<id,integer>();
                Map<id,integer> postQuoteTaskWithCaseMap = new Map<id,integer>();
                if(!taskMapNewVal.isEmpty()){
                    for(Task taskObj: taskMapNewVal){
                        if(taskObj.RecordTypeId == preQuoteRecordTypeId){
                            caseId.add(taskObj.WhatId);
                        }
                    }
                }
                if(caseId.size() > 0){
                    for(Task taskList : SPEN_CaseSelector.getExistingPreQuoteTaskFromCase(caseId,taskRecrTypeId)){
                        if(taskList.SPEN_TaskType__c == SPEN_ConstantData.PREQUOTETASKTYPE){
                            preQuoteTaskWithCaseMap.put(taskList.WhatId,1);
                        }
                        if(taskList.SPEN_TaskType__c == SPEN_ConstantData.POSTENRUIRYTASKTYPE){
                            postQuoteTaskWithCaseMap.put(taskList.WhatId,1);
                        }

                    }
                    for(Task taskObj: taskMapNewVal){
                        if(taskObj.SPEN_TaskType__c == SPEN_ConstantData.PREQUOTETASKTYPE && !preQuoteTaskWithCaseMap.isEmpty() && preQuoteTaskWithCaseMap.containsKey(taskObj.whatId) &&
                           preQuoteTaskWithCaseMap.get(taskObj.whatId) == 1 ){
                               taskObj.addError(SPEN_ConstantData.PREQUOTEDUPERRORMSG);
                           }else if(taskObj.SPEN_TaskType__c == SPEN_ConstantData.POSTENRUIRYTASKTYPE && !postQuoteTaskWithCaseMap.isEmpty() && postQuoteTaskWithCaseMap.containsKey(taskObj.whatId) &&
                                    postQuoteTaskWithCaseMap.get(taskObj.whatId) == 1 ){
                                        taskObj.addError(SPEN_ConstantData.POSTENRUIRYDUPERRORMSG);
                                    }
                    }
                }

            }catch(exception e)
            {
                SEL_LoggingService.log(e);
            }
        }
    
    /*************************************************************************
@Author: Swaathi KR
@Date: 28/08/23
@User Story: CRMD-776
@purpose: Class with Reusable method to create Task 
*************************************************************************************/
          public static void InsertTask(List<sObject> CsList,String Description)
    {
        List<Case> caseList = (List<Case>)CsList;
        Set<Case> CaseSet = new Set<Case>();
        CaseSet.addAll(caseList);

        List<Task> taskList = new List<Task>();
        for(Case cs:CaseSet)
        {
            Task tsk = new Task();
            tsk.Subject = Description;
            tsk.WhatId = cs.Id;
            tsk.Description = Description;
            tsk.SPEN_DiaryReceivedDate__c = System.now();
            tsk.ActivityDate = System.today() + 1;
            tsk.SPEN_Due_DateTime__c = System.now().addHours(24);
            tsk.Status = 'Open';
            //tsk.IsReminderSet = true;
            //tsk.ReminderDateTime = System.now() + 1;
            taskList.add(tsk);
        }
    
        if(!taskList.isEmpty())
        {
         insert taskList;  
        }

    }
    /*************************************************************************
@Author: Swaathi KR
@Date: 22/03/24
@User Story: CRMD-9727
@purpose: Stamp Activity Date based on custom duedatetime (Date Syncing)
*************************************************************************************/
public static void populateActivityDateForEPOTask(List<Task> taskNewList, Map<ID, Task> oldTaskMap)
{
    
    Id ePOTaskRecordTypeID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SPEN_EPOTask').getRecordTypeId();
    
    for(Task tsk:taskNewList)
    {
        if(tsk.RecordTypeId == ePOTaskRecordTypeID)
        {
            if(Trigger.isBefore)
            {
                if(Trigger.isInsert)
                {
                    if(tsk.SPEN_Due_DateTime__c != NULL)
                    {
                        DateTime dt = tsk.SPEN_Due_DateTime__c;
                        tsk.ActivityDate = Date.newInstance(dt.year(),dt.month(),dt.day());
                        
                    }
                }
                else if(Trigger.isUpdate)
                {
                    if(tsk.SPEN_Due_DateTime__c != oldTaskMap.get(tsk.Id).SPEN_Due_DateTime__c)
                    {
                        DateTime dt = tsk.SPEN_Due_DateTime__c;
                        tsk.ActivityDate = Date.newInstance(dt.year(),dt.month(),dt.day());
                        
                    }
                }
                
            }
        }
    }
}
    /*************************************************************************
    @Author: Rohit Chowdhury
    @Date: 23/02/24
    @purpose: CRMD-9881 Prevent task deletion for all SPD users
    *************************************************************************************/
    public static void preventTaskDeletion(List<Task> taskList)
    {
        try
        {
            Set<String> taskConnectionRecType = new Set<String>(System.label.SPEN_SPDTaskRecordTypes.trim().split(';'));
            String profileId = [Select Id,Name from Profile where Name = 'System Administrator' ].Id;
            if(!taskList.isEmpty())
            {
                for(Task taskobj: taskList)
                {
                    String taskRecTypeName=Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosById().get(taskobj.RecordTypeId).getDeveloperName();
                    if(UserInfo.getProfileId() != profileId && taskConnectionRecType.contains(taskRecTypeName))
                    {
                        taskobj.addError('You are not authorized to delete a task');
                    }
                }
            }
            
        }catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }

}