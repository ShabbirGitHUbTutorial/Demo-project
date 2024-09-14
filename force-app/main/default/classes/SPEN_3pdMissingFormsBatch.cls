public class SPEN_3pdMissingFormsBatch implements Schedulable, Database.Batchable<sObject>, Database.RaisesPlatformEvents
{
    Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_ThirdPartyDamage).getRecordTypeId();
    String className = 'SPEN_3pdMissingFormsBatch';
    String missingFormStatus = CasesConstants.missingFormStatus;
    String createdStatus = CasesConstants.createdStatus;
    
    public Database.QueryLocator start(Database.BatchableContext bc)
	{
        if(!Test.isRunningTest())
        {
            String query = 'Select Id,(Select Id from Case_Information__r) '+
                			'from CASE where RecordTypeId =:recordTypeId3PD and Status =:createdStatus and '+
                			'CreatedDate = YESTERDAY';
            return Database.getQueryLocator(query);
        }
        else
        {
            String query = 'Select Id,(Select Id from Case_Information__r) '+
                			'from CASE where RecordTypeId =:recordTypeId3PD and Status =:createdStatus';
            return Database.getQueryLocator(query);
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Case> caseList)
    {       
        List<Case> successCaseListToUpdate = new List<Case>(); ////////
        
        List<Case> caseListToUpdate = new List<Case>();
        for(Case cse : caseList)
        {
            Integer countOfCaseInformation = cse.Case_Information__r.size();
            if(countOfCaseInformation == 0)
            {
                cse.Status = missingFormStatus;
                caseListToUpdate.add(cse);
            }
        }
        
        Database.SaveResult[] updateResults = Database.update(caseListToUpdate, false);        
        for (Integer i = 0; i < updateResults.size(); i++) 
        {
            if (updateResults[i].isSuccess()) 
            {
                successCaseListToUpdate.add(caseListToUpdate[i]);
            }
        }
        
        SPEN_TaskUtility.InsertTask(successCaseListToUpdate,System.Label.SPEN_3pdMissingFormTaskDescription);
    }
    
    public void finish(Database.BatchableContext bc)
    {}
    
	public void execute(SchedulableContext sc) 
    {
        List<SPEN_BatchSettings__mdt> batchSettings = SPEN_BatchUtil.getBatchSettings(className);
        Integer scope = 200;
        if(!batchSettings.isEmpty() && batchSettings[0].SPEN_BatchSize__c != null)
        {
            scope = (Integer)batchSettings[0].SPEN_BatchSize__c;
        }
        Database.executeBatch(new SPEN_3pdMissingFormsBatch(), scope);   
    }
}