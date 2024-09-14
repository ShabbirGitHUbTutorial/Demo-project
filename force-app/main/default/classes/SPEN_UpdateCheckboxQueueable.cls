public without sharing class SPEN_UpdateCheckboxQueueable Implements Queueable
{
	Set<Id> incdntIdSet = new Set<Id>();
    
    public SPEN_UpdateCheckboxQueueable(Set<Id> idSet) 
    { 
        incdntIdSet.addAll(idSet);
    }
    public void execute(QueueableContext context) 
	{ 
        List<Incident> incList = new List<Incident>();
        try
        { 
            incList = IncidentSelector.getRelatedIncInfoForStatusUnchecked(incdntIdSet);
            List<Incident> updateInc = new List<Incident>();
            for (Incident incdntAllTrueValue:incList)
            {
                if(incdntAllTrueValue.SPEN_StatusUpdated__c == true)
                {
                    incdntAllTrueValue.SPEN_StatusUpdated__c = False; 
                    updateInc.add(incdntAllTrueValue);
                }
            }  
            if(updateInc != null){
                update updateInc;
            } 
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }     
    }
}