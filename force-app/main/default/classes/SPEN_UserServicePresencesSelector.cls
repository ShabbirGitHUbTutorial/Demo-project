/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the UserServicePresence standard object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_UserServicePresencesSelector 
{
	/**
	 * @description	SELECT by User ID and Current State
	 */
	public List<UserServicePresence> selectByUserIdsByState(Set<Id> userIds, Boolean isCurrentState)
	{
		List<UserServicePresence> results = new List<UserServicePresence>(); 

		if(userIds != null && !userIds.isEmpty() && isCurrentState != null)
		{
			results = [
				SELECT		UserId, ServicePresenceStatusId
				FROM		UserServicePresence
				WHERE		UserId IN: userIds AND isCurrentState =: isCurrentState AND IsDeleted = false
				WITH		SECURITY_ENFORCED
			];
		}

		return results;
	} 
}