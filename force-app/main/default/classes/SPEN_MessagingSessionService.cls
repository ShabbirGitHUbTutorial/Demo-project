/*---------------------------------------------------------------------------------------
DESCRIPTION	:	Service class for MessagingSessionTrigger
LIBRARY		:	SPEN
VERSION		:	1.0
HISTORY		:
Date			Author					Comment
NOV-11-2022		Ayush Mittal			Initial version
DEC-29-2022		Macjules Sevilla		Approved suppression of TryCatchRaiseException
---------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.CodeBestPracticesTryCatchRaiseException')
public class SPEN_MessagingSessionService 
{
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
	public void isUpdatingPremise(List<MessagingSession> newMessagingSession)
	{
		try
		{
			Set<Id> msgUserIds = new Set<Id>();
			for(MessagingSession msgSession: newMessagingSession)
			{
				if(msgSession.MessagingEndUserId != null) 
				{
					msgUserIds.add(msgSession.MessagingEndUserId);
				}
			}

			Map<Id,MessagingEndUser> msgEndUserMap = new Map<Id,MessagingEndUser>(SPEN_MessagingEndUserSelector.selectByIds(msgUserIds));
			
			if(!msgEndUserMap.isEmpty())
			{
				for(MessagingSession msgSession: newMessagingSession)
				{
					if(msgEndUserMap.containsKey(msgSession.MessagingEndUserId))
					{
						MessagingEndUser msgUser = new MessagingEndUser();
						msgUser = msgEndUserMap.get(msgSession.MessagingEndUserId);
						if(msgUser != null)
						{
							msgSession.SPEN_MessagingUserPremise__c = msgUser.Contact.SPEN_Premise__c;
						}
					}
				}
			}
		}
		catch(exception ex)
		{
			SEL_LoggingService.log(ex);
			throw ex;
		}
	}   
}