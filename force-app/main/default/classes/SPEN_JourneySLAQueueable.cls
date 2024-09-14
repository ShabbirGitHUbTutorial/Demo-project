public class SPEN_JourneySLAQueueable Implements Queueable{
	Set<Id> caseIdSet =new Set<Id>();
    List<Case> listCasetoUpdate = new List<Case>();
    public SPEN_JourneySLAQueueable(Set<Id> setCaseId) {
        caseIdSet = setCaseId;
    }
    public void execute(QueueableContext context)
    {
         Map<Id,DateTime> mapCaseId2SLADate = SPEN_JourneySLAUtils.getCaseSLADueDate(caseIdSet);
         if(!mapCaseId2SLADate.isEmpty())
         {
             for(Id caseId:mapCaseId2SLADate.keySet()){
                 Case updateCase = new Case(Id=caseId);
                 updateCase.SPEN_SLADueDate__c = mapCaseId2SLADate.get(caseId);
                 listCasetoUpdate.add(updateCase);
             }
             
         }
        if(!listCasetoUpdate.isEmpty())
            update listCasetoUpdate;
    }
        
}