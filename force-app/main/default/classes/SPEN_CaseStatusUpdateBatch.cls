/**********************************************************************************************
* @Author:      Rahul Kumar
* @Date:        11/08/2023
* @Description: Batch class to process the List of cases for ETR/Status Update in bulk
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public class SPEN_CaseStatusUpdateBatch implements Database.Batchable<sObject> {
   	 Map<Id, Case> mapOfcasesTopick = new Map<Id, Case>();
     Set<Id> setOfCaseIds = new Set<Id>();
    Set<Id> setOfFailedRecords = new Set<Id>();
    public SPEN_CaseStatusUpdateBatch(Map<Id, Case> mapOfIdVsCases){
        this.mapOfcasesTopick = mapOfIdVsCases;
        this.setOfCaseIds.addAll(mapOfIdVsCases.keySet());
    }
	public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Status FROM Case where Id IN :setOfCaseIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> caseList) {
       	List<Case> caseToBeUpdated = new List<Case>();
        for(Case cse : caseList){
       		cse.status =  mapOfcasesTopick.get(cse.Id).Status; 
            cse.SPEN_ETROutage__c = mapOfcasesTopick.get(cse.Id).SPEN_ETROutage__c;
            caseToBeUpdated.add(cse);
        }
        try {
            if(!caseToBeUpdated.isEmpty()){
                update caseToBeUpdated;
            }
         } catch(Exception e) {
           SEL_LoggingService.log(e);
            throw e;
        }
        
    }   
    
    public void finish(Database.BatchableContext BC) {
    }
}