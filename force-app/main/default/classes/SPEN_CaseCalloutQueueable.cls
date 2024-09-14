//Queueable class to call  @future(callout=true) postCallout method in CaseCallout class
public class SPEN_CaseCalloutQueueable Implements Queueable, Database.AllowsCallouts {
    Set<Id> caseIdList = new Set<Id> ();
    public SPEN_CaseCalloutQueueable(Set<Id> caseId){
        this.caseIdList.addAll(caseId);
    }
    public void execute(QueueableContext context){
        CaseCallouts.postCallout(caseIdList, true, true);
    }
}