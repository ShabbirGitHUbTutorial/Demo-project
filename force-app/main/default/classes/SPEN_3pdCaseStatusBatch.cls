/*-----------------------------------------------------------------------------------------
DESCRIPTION  : Batch Class to change status to 'Ready for Billing' when a 3PD case is in status 
              'LOI issued' and there is no query received from the customer for 10 working days		   
AUTHOR : 
VERSION :  1.0
HISTORY :
Aug-10-2023      Initial version
-----------------------------------------------------------------------------------------*/
public with sharing class SPEN_3pdCaseStatusBatch implements Schedulable,Database.Batchable<sObject>
{
    Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_ThirdPartyDamage).getRecordTypeId();
    Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Query).getRecordTypeId();
    String statusLOIIssued = CasesConstants.loiIssuedStatus;
    String closedStatus = CasesConstants.closedStatus;
    String className = 'SPEN_3pdCaseStatusBatch';
    Integer customLabelValue = Integer.valueOf(System.Label.SPEN_WorkingDaysForComparison);
    
    Boolean notEligibleForStatusChange;         //Boolean variable which will be used in filtering Closed Query Cases in execute method. 
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'Select Id,Status,'+
                       '(Select Id,Status,SPEN_3PDOrQueryStatusWorkingDays__c from Cases '+ 
            			'where RecordTypeId =:recordTypeIdQuery) '+ 
            		    'from CASE '+
            			'where RecordTypeId =:recordTypeId3PD and '+
            			'Status =: statusLOIIssued and '+
            			'SPEN_3PDOrQueryStatusWorkingDays__c >= :customLabelValue';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> caseList)
    {
        List<Case> caseListToUpdate = new List<Case>();
        
        for(Case cse : caseList)
        {
            List<Case> queryCaseList = cse.Cases;
            if(queryCaseList.isEmpty())
            {
                cse.Status = CasesConstants.readyForBillingStatus;
                cse.SPEN_LastStatusChangeDate__c = System.now();
                caseListToUpdate.add(cse);
            }
            else
            {
                notEligibleForStatusChange = false;
                for(Case querycase : cse.Cases)
                {
                    if(querycase.Status == 'Open')
                    {
                        notEligibleForStatusChange = true;
                        break;
                    }
                    else if(querycase.Status == closedStatus && querycase.SPEN_3PDOrQueryStatusWorkingDays__c >= customLabelValue)
                    {
                        continue;
                    }
                }
                if(!notEligibleForStatusChange)
                {
                    cse.Status = CasesConstants.readyForBillingStatus;
                    cse.SPEN_LastStatusChangeDate__c = System.now();
                    caseListToUpdate.add(cse);
                }
            }
            if(!caseListToUpdate.isEmpty())
            {
                update caseListToUpdate;
            }
        }
    }
   
    public void finish(Database.BatchableContext bc)
    {}
    
    public void execute(SchedulableContext sc) 
    {
        List<SPEN_BatchSettings__mdt> batchSettings = SPEN_BatchUtil.getBatchSettings(className);
        Integer scope = 200;
		if(!batchSettings.isEmpty() && batchSettings[0].SPEN_BatchSize__c != null){
            scope = (Integer)batchSettings[0].SPEN_BatchSize__c;
        }
         Database.executeBatch(new SPEN_3pdCaseStatusBatch(), scope);        
    }
}