/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector Class for the MessagingEndUser standard object
LIBRARY		:	SPEN
VERSION		:	1.0
HISTORY		:
Date			Author					Comment
OCT-27-2022		Ayush Mittal			Initial version
DEC-29-2022		Macjules Sevilla		Refactor to standards
-----------------------------------------------------------------------------*/
public with sharing class SPEN_MessagingEndUserSelector 
{
	public static List<MessagingEndUser> selectByIds(Set<Id> userIds)
	{
		List<MessagingEndUser> result = new List<MessagingEndUser>();

		if(userIds != null && !userIds.isEmpty())
		{
			result = [	
				SELECT	Id, Contact.SPEN_Premise__c 
				FROM	MessagingEndUser
				WHERE	Id IN :userIds 
				WITH 	SECURITY_ENFORCED
			];
		}

		return result;
	}
}