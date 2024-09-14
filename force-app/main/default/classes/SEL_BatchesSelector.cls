/*-------------------------------------------------------------------------------------------------
DESCRIPTION	:	Selectore layer of Batch__c custom object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
FEB-13-2023		Macjules Sevilla	Added SPEN_AdqmLoadDate__c field to the selectByIds method
-------------------------------------------------------------------------------------------------*/
public inherited sharing class SEL_BatchesSelector 
{
	// DESCRIPTION
	// Returns a list of Batch__c records based on the IDs parameters.
	public List<SEL_Batch__c> selectByIds(Set<Id> ids) 
	{
		List<SEL_Batch__c> result = new List<SEL_Batch__c>();

		if(ids != null && !ids.isEmpty()) 
		{ 
			result = [	
				SELECT	Id, SEL_Status__c, SPEN_AdqmLoadDate__c
				FROM	SEL_Batch__c
				WHERE	Id IN :ids
				WITH	SECURITY_ENFORCED
			];
		}

		return result;
	}

	// DESCRIPTION
	// Returns a list of Batch__c records based on the IDs parameters
	// along with their respective child BatchStep__c records based on status. 
	public List<SEL_Batch__c> selectByIdsByStatuses(Set<Id> ids, Set<String> statuses) 
	{
		List<SEL_Batch__c> result = new List<SEL_Batch__c>();

		if(ids != null && statuses != null && !ids.isEmpty() && !statuses.isEmpty()) 
		{ 
			result = [
				SELECT	Id, (SELECT Id, SEL_BatchId__c, SEL_BatchSize__c, SEL_Sequence__c, SEL_Status__c FROM SEL_BatchSteps__r WHERE SEL_Status__c IN :statuses ORDER BY SEL_Sequence__c)
				FROM	SEL_Batch__c
				WHERE	Id IN :ids 
				WITH	SECURITY_ENFORCED
			];	
		}

		return result;
	}
    public List<SEL_Batch__c> getTodaysBatchRecord()
	{
		List<SEL_Batch__c> ExistingBatch= new List<SEL_Batch__c>();
        ExistingBatch=	[
                    SELECT Id, SEL_Status__c
                    FROM SEL_Batch__c 
                    WHERE  CreatedDate = Today  AND
                    SEL_BatchTemplate__c = 'ADQM Delta Sync'
                    LIMIT 1
                    ];			
		return ExistingBatch;
	}
}