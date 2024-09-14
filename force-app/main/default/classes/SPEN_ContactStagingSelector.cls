/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector Class for SPEN_ContactNumberEmailStaging__c object.
LIBRARY		:	SPEN
VERSION		:	1.0
HISTORY		:
Date			Author		    Comment
TODO
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_ContactStagingSelector 
{
	public Database.QueryLocator getQueryLocatorForNotStartedAndFailed(Date adqmLoadDate)
	{
		Database.QueryLocator q;

		if(adqmLoadDate != null)
		{
			q = Database.getQueryLocator([
				SELECT	Id, SPEN_ExternalId__c, SPEN_NumberOrEmail__c, SPEN_Type__c
				FROM	SPEN_ContactNumberEmailStaging__c
				WHERE	DAY_ONLY(CreatedDate) = :adqmLoadDate AND 
                (SPEN_SyncStatus__c =: 'Not Started' OR SPEN_SyncStatus__c =: 'Failed') AND
                SPEN_Type__c != null
			]);				
		}
	   
		return q;
	}

	public Database.QueryLocator getStageRecForContSync(Date adqmLoadDate)
	{
		Database.QueryLocator q;

		if(adqmLoadDate != null)
		{
			q = Database.getQueryLocator([
				SELECT  ID,SPEN_ContactType__c,SPEN_ExternalId__c,SPEN_AdqmAction__c,SPEN_AdqmLastModifiedDateTime__c,SPEN_AdqmSource__c,
                        SPEN_Email__c,SPEN_FirstName__c,SPEN_Initials__c, SPEN_LastName__c,SPEN_Mobile__c,
                        SPEN_Other__c,SPEN_OtherContactId__c, SPEN_PremiseId__c,SPEN_Salutation__c,
                        SPEN_SyncComment__c,SPEN_SyncStatus__c,SPEN_Telephone__c 
                FROM    SPEN_ContactStaging__c 
                WHERE   DAY_ONLY(CreatedDate) = :adqmLoadDate 
				AND (SPEN_AdqmAction__c =: 'New' OR SPEN_AdqmAction__c =: 'Update') 
				AND (SPEN_SyncStatus__c =: 'Not Started' OR SPEN_SyncStatus__c =: 'Failed')
			]);
		}

		return q;
	}
	public List<SPEN_ContactNumberEmailStaging__c> getStageRecordForContactUpdate(Date adqmLoadDate,Set<String> contactExtIdSet)
	{
		List<SPEN_ContactNumberEmailStaging__c> lstStage= new List<SPEN_ContactNumberEmailStaging__c>();
        if(adqmLoadDate != null && !contactExtIdSet.isEmpty())
		{
			lstStage=	[
						SELECT Id,SPEN_ExternalId__c,SPEN_NumberOrEmail__c,SPEN_Type__c 
						FROM SPEN_ContactNumberEmailStaging__c 
						WHERE  DAY_ONLY(CreatedDate) =: adqmLoadDate  
						AND SPEN_SyncStatus__c ='Not Started' and SPEN_ExternalId__c =:contactExtIdSet
						];			
		}
		
		return lstStage;
	}
}