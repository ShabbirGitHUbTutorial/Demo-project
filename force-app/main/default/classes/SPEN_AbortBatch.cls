global  with sharing class SPEN_AbortBatch 
{
  public static Map<Id, AsyncApexJob> mapOfCurrentJobs = new Map<Id, AsyncApexJob>([SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
FROM AsyncApexJob where Status != 'Completed' OR Status != 'Failed'  LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);

    @InvocableMethod
    public static void abortJob(List<inputVariables> variables)
    {
        List<SPEN_CommunicationScheduler__c> comList= variables.get(0).comSchedule;
        List<SPEN_CommunicationScheduler__c> cSToUpdate = new List<SPEN_CommunicationScheduler__c>();
        
        //system.debug('comList -->'+ comList);
        for(SPEN_CommunicationScheduler__c cS : comList)
        {   if('Scheduled'.equalsIgnoreCase(cs.SPEN_Status__c) || 'Not Started'.equalsIgnoreCase(cs.SPEN_Status__c)){
                 cS.SPEN_Status__c = 'Cancelled';
                 cSToUpdate.add(cS);
                 if(String.isNotBlank(cs.SPEN_BatchJobId__c) && !mapOfCurrentJobs.isEmpty() && mapOfCurrentJobs.keySet().contains(cs.SPEN_BatchJobId__c)){
                     System.abortJob(cS.SPEN_BatchJobId__c);
                 }
            }
        }
        try{
            update cSToUpdate;
        }
        catch(Exception e){
           throw e;
        }
       
    }
    
    public class inputVariables
    {
        @InvocableVariable
        public List<SPEN_CommunicationScheduler__c> comSchedule;
    }
}