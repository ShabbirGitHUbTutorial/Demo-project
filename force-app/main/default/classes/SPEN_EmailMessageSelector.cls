public class SPEN_EmailMessageSelector 
{
	public static Map<Id, EmailMessage> getParentEmailMsg(Set<Id> setReplyMsgId)
    {
        Map<Id, EmailMessage> mapParentMsgId2Msg = new Map<Id,EmailMessage>();
        if(!setReplyMsgId.isEmpty())
            mapParentMsgId2Msg =  new Map<Id, EmailMessage>([SELECT id, createdDate,Incoming,SPEN_AgentResponseTime__c
                        FROM EmailMessage WHERE id IN: setReplyMsgId]);
        return mapParentMsgId2Msg;
    }
    public static Map<Id,List<EmailMessage>> getAllIncoming(Set<Id> setCaseId)
    {
        Map<Id,List<EmailMessage>> mapCaseId2EmailMessage= new Map<Id,List<EmailMessage>>();
        if(!setCaseId.isEmpty())
        {
            for(EmailMessage msg: [SELECT id, createdDate,parentId, Incoming, SPEN_AgentResponseTime__c FROM EmailMessage WHERE ParentId IN: setCaseId
                                   AND Incoming =true AND SPEN_AgentResponseTime__c = null 
                                   ORDER BY createdDate ASC])
            {
                if(mapCaseId2EmailMessage.containsKey(msg.parentId)){
                    mapCaseId2EmailMessage.get(msg.parentId).add(msg);
                }
                else {
                    mapCaseId2EmailMessage.put(msg.parentId,new List<EmailMessage>{msg});
                }
            }
        }
        return mapCaseId2EmailMessage;
    }
    public static List<EmailMessage> getIncomingEmailMsg(Set<Id> setCaseId)
    {
        List<EmailMessage> listEmailMessage = new List<EmailMessage>();
        if(!setCaseId.isEmpty())
        {
            listEmailMessage = [SELECT id, createdDate,parentId FROM EmailMessage WHERE ParentId IN: setCaseId
                                                    AND Incoming =true 
                                                    ORDER BY createdDate DESC LIMIT 1
                                                    ];
        }
        return listEmailMessage;
    }
}