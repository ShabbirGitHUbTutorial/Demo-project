/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the standard AsyncApexJob object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Common
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-24-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SEL_AsyncApexJobsSelector 
{
	// DESCRIPTION
	// Returns a list of AsyncApexJob records based on Job IDs
	public List<AsyncApexJob> selectByJobIds(Set<Id> jobIds) 
	{
		List<AsyncApexJob> result = new List<AsyncApexJob>();
		
		if(jobIds != null && !jobIds.isEmpty()) 
		{ 
			result = [
				SELECT	Id, ApexClass.Name, CompletedDate, CreatedBy.Email, ExtendedStatus, JobItemsProcessed, NumberOfErrors, Status, TotalJobItems 
				FROM	AsyncApexJob
				WHERE	Id IN :jobIds
				WITH	SECURITY_ENFORCED
			];
		}

		return result;
	}
}