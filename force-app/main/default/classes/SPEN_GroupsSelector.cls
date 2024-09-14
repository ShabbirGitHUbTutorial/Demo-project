/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the Group standard object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_GroupsSelector 
{
	/**
	 * @description	SELECT by Developer Name and Type
	 */
	public Group selectByQueueName(String queueDeveloperName)
	{
		List<Group> results = new List<Group>();

		if(String.isNotBlank(queueDeveloperName))
		{
			results = [
				SELECT	Id
				FROM	Group
				WHERE	DeveloperName =: queueDeveloperName.trim() AND Type = 'Queue'
				WITH	SECURITY_ENFORCED];
		}

		return results.size() == 0 ? new Group() : results[0];
	}
	public static Map<String, String> getQueueMembers(Set<String> setQueueNames){
       	Map<String, String> mapGrpName2Id = new Map<String,String>();
        if(setQueueNames != null && !setQueueNames.isEmpty()){
            for(Group grp : [SELECT Id, Name FROM Group WHERE type='Queue' and Name IN:setQueueNames  WITH SECURITY_ENFORCED])
            {
               mapGrpName2Id.put(grp.Name, String.valueOf(grp.id));
            }
       }
       return mapGrpName2Id;
    }
}