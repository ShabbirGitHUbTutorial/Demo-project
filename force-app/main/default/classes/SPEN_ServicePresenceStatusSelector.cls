/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the ServicePresenceStatus standard object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_ServicePresenceStatusSelector 
{
	/**
	 * @description	SELECT by MasterLabel using LIKE
	 */
	public List<ServicePresenceStatus> selectByMasterLabel(String search)
	{
		List<ServicePresenceStatus> results = new List<ServicePresenceStatus>(); 

		if(String.isNotBlank(search))
		{
			search = '%'+ search +'%';
			results = [
				SELECT		Id, DeveloperName, MasterLabel
				FROM		ServicePresenceStatus
				WHERE		MasterLabel LIKE :search AND IsDeleted = false
				WITH		SECURITY_ENFORCED
			];
		}

		return results;
	} 
}