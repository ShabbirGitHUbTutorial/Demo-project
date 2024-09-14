/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the AgentWork standard object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_AgentWorksSelector 
{
	/**
	 * @description	SELECT by User ID and Status
	 */
	public List<AgentWork> selectByUserIdsByStatuses(Set<Id> userIds, Set<String> statuses)
	{
		List<AgentWork> results = new List<AgentWork>(); 

		if(userIds != null && statuses != null && !userIds.isEmpty() && !statuses.isEmpty())
		{
			results = [
				SELECT		UserId, WorkItemId
				FROM		AgentWork
				WHERE		UserId IN :userIds AND Status IN :statuses
				WITH		SECURITY_ENFORCED
			];
		}

		return results;
	}
}