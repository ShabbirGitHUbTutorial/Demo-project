/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector Class for SPEN_PSRStaging__c records
LIBRARY		:	SPEN
VERSION		:	1.0
HISTORY		:

Date			Author				Comment
FEB-15-2023		Asmita Rajput		Initial version
MAR-23-2023		Macjules Sevilla	Added ORDER BY to getStageRecSyncPSRBatch
-----------------------------------------------------------------------------*/
public with sharing class SPEN_PSRStagingSelector 
{
	public Database.QueryLocator getQueryLocatorForSuccessful(Date adqmLoadDate)
	{
		Database.QueryLocator q;
		if(adqmLoadDate != null)
		{
			q = Database.getQueryLocator([
				SELECT	Id, 
						SPEN_PremiseID__c
				FROM	SPEN_PSRStaging__c
				WHERE	DAY_ONLY(CreatedDate) = :adqmLoadDate AND 
						SPEN_SyncStatus__c =: 'Successful'
				WITH	SECURITY_ENFORCED
			]);				
		}
		return q;
	}

	public  Database.QueryLocator getStageRecSyncPSRBatch(Date adqmLoadDate)
	{
		Database.QueryLocator q;
		if(adqmLoadDate != null)
		{  
			q = Database.getQueryLocator([
				SELECT		Id, 
							SPEN_PremiseID__c, 
							SPEN_PsrVulnerabilityTypeId__c,
							SPEN_FirstLanguage__c,
							SPEN_ADQMAction__c,
							SPEN_Code__c,
							SPEN_SyncStatus__c,
							SPEN_ADQMLastModifiedDateTime__c,SPEN_EffectiveDateFrom__c,SPEN_EffectiveDateTo__c
				FROM		SPEN_PSRStaging__c
				WHERE		DAY_ONLY(CreatedDate) = :adqmLoadDate AND 
							(SPEN_SyncStatus__c =: 'New' OR SPEN_SyncStatus__c =: 'Failed')
				WITH		SECURITY_ENFORCED
				ORDER BY	SPEN_ADQMAction__c
			]);			
		}
		return q;
	}
}