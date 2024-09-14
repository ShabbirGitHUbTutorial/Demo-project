trigger EmailMessageTrigger on EmailMessage (before insert,before update, after insert, after update) 
{
    if(Trigger.isInsert && Trigger.isBefore)
    {
        SPEN_EmailMessage.calculateAgentResponeTime(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore)
    {

    }

    if(Trigger.isInsert && Trigger.isAfter)
    {
        SPEN_EmailMessage.calculateAgentResponeTime(Trigger.New);
        SPEN_EmailMessage.changeStatusToOpenForIncomingMail(Trigger.new,Trigger.old);
	    EmailMessageUtility.afterCaseInsert(Trigger.new); //CRMD- 9163 Connection Changes
    }
    
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        
    }
}