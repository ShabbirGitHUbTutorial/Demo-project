public class SPEN_CaseAssignmentNotificationQueueable Implements Queueable{
    List<Case> lstCase = new List<Case>();
    Set<Id> caseIdSet =new Set<Id>();
    Set<String> setQueueNames = new Set<String>();
    Map<String, String> mapGrpName2GrpId = new Map<String,String>();
    public static Id recordTypeIdReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Referral).getRecordTypeId();
    public SPEN_CaseAssignmentNotificationQueueable(Set<Id> setCaseId) {
        caseIdSet = setCaseId;
    }
    public void execute(QueueableContext context)
    {
        lstCase = SPEN_CaseSelector.getCaseInfoForQueuable(caseIdSet);
        
    
        List<CustomNotificationType> caseAssignmentTemplate = SPEN_CustomNotificationSelector.getCaseAssignmentNotification();
        for(Case cs: lstCase)
        {
            //if(setCJRecordTypes.contains(cs.recordtypeId) && cs.Owner.type == 'Queue')
            if(cs.recordtypeId != recordTypeIdReferral && cs.Owner.type == 'Queue')
            {
                setQueueNames.add(cs.owner.Name);
            }
        }
        if(!setQueueNames.isEmpty())
        {
            mapGrpName2GrpId = SPEN_GroupsSelector.getQueueMembers(setQueueNames);
        }
        for(Case caseRec : lstCase){
            if(!mapGrpName2GrpId.isEmpty())
            {
                if(mapGrpName2GrpId.get(caseRec.owner.Name) != null)
                {
                    String title = 'Case Assignment Notification';
                    String body =  'Case '+caseRec.caseNumber + ' has been assigned to queue : ' + caseRec.owner.Name; 
                    sendNotification(title,body,caseRec.Id,new Set<String>{mapGrpName2GrpId.get(caseRec.owner.Name)},caseAssignmentTemplate[0].Id);
                }
            }
            else if(caseRec.Owner.type == 'User')
            {
                String title = 'Case Assignment Notification';
                String body =  'Case '+caseRec.caseNumber + ' is assigned to you'; 
                sendNotification(title,body,caseRec.Id,new Set<String>{caseRec.ownerId},caseAssignmentTemplate[0].Id);
            }
        }
    }

    public void sendNotification(String title, String body, Id targetId, Set<String> setUser, id templateId)
    {
        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        currNotification.setTitle(title);
        currNotification.setBody(body);
        currNotification.setNotificationTypeId(templateId);
        currNotification.setTargetId(targetId);
        currNotification.send(setUser);
    }
}