/**
* @description       : Queueable class to make callout to insert impacted premises
* @author            : Rahul Kumar
* @group             : 
* @last modified on  : 22-11-2023
* @last modified by  : rahul.dd.kumar@accenture.com
**/
public with sharing class SPEN_GetAffectedPremiseQueueableClass implements Queueable{
    String incidentRef;
    public SPEN_GetAffectedPremiseQueueableClass(String incidentRef) {
        this.incidentRef = incidentRef;
    }
    public void execute(QueueableContext context){

        Incident incidentFetched;
        try{
            incidentFetched = [SELECT Id, SPEN_IncidentReference__c,SPEN_GetAffectedPremisesScheduled__c,SPEN_IncidentID__c FROM Incident where SPEN_IncidentReference__c = :incidentRef  LIMIT 1];
            incidentFetched.SPEN_GetAffectedPremisesScheduled__c = false; // set incident Get Affected Premises Scheduled flag as false.
            update incidentFetched;
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
        try{
            //Called get affected customers
            List<String> incStrLst = new List<String>();
            incStrLst.add(incidentFetched.SPEN_IncidentID__c);
            // Call the existing service which will make outbound API call
            SPEN_GetAffectedPremiseService.createRecord(incStrLst);
        }
        catch(Exception ex){
            SEL_LoggingService.log(ex);
        }     
    }
}