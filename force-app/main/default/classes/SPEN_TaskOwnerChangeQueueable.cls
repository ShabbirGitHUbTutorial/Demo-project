global class SPEN_TaskOwnerChangeQueueable Implements Queueable
{
    Set<Id> caseIds = new Set<Id>();
    Map<Id,Case> cseMap = new Map<Id,Case>();
    List<Task> tskListToUpdate = new List<Task>();
    
    global SPEN_TaskOwnerChangeQueueable(Set<Id> caseIdSet, Map<Id,Case> cseNewMap) 
    { 
        caseIds.addAll(caseIdSet);
        cseMap = cseNewMap;
    }
    
    global void execute(QueueableContext context)
    {
        try
        {
            if(!caseIds.isEmpty()) 
			{
                for(Task tsk : [SELECT Id, WhatId FROM Task WHERE WhatId IN :caseIds and Status IN: SPEN_ConstantData.TASKSTATUS_LIST]) 
				{
                    if(caseIds.contains(tsk.WhatId)) 
					{
                        tsk.OwnerId = cseMap.get(tsk.WhatId).OwnerId;
						tskListToUpdate.add(tsk);
                    }
                }
            }
            update tskListToUpdate;
        }
        catch(exception ex)
        {
            SEL_LoggingService.log(ex);
        }
    }
}