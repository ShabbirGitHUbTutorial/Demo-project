/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the Group Member standard object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_GroupMembersSelector 
{
	/**
	 * @description	SELECT by Queue ID
	 */
	public List<GroupMember> selectByQueueId(Id queueId)
	{
		List<GroupMember> results = new List<GroupMember>();

		if(queueId != null)
		{
			results = [
				SELECT	UserOrGroupId 
				FROM	GroupMember
				WHERE	GroupId =: queueId
				WITH	SECURITY_ENFORCED];
		}

		return results;
	}
}