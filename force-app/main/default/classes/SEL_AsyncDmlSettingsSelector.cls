/*------------------------------------------------------------------------------------
DESCRIPTION	:	Selector class for SEL_AsyncDmlSetting__mdt
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
AUG-07-2021		Macjules Sevilla	Initial version
APR-04-2022		Macjules Sevilla	Added Active = true filter; API version to 54.0
------------------------------------------------------------------------------------*/
public inherited sharing class SEL_AsyncDmlSettingsSelector
{
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries')
	public List<SEL_AsyncDmlSetting__mdt> selectByObjectApisByStatus(Set<String> objectApis, Boolean isActive)
	{
		List<SEL_AsyncDmlSetting__mdt> results = new List<SEL_AsyncDmlSetting__mdt>();
		
		if(!(objectApis == null || objectApis.isEmpty()))
		{
			// SET DEFAULTS
			// If the second parameter is not specified, default the value to TRUE
			if(isActive == null) { isActive = true; }

			results = [
				SELECT	SEL_IsDeleteAllowed__c, SEL_IsInsertAllowed__c, SEL_IsUndeleteAllowed__c, SEL_IsUpdateAllowed__c, SEL_IsUpsertAllowed__c, SEL_Object__c
				FROM	SEL_AsyncDmlSetting__mdt
				WHERE	SEL_Object__c IN :objectApis AND SEL_IsActive__c =: isActive
				WITH	SECURITY_ENFORCED
			];
		}

		return results;
	}
}