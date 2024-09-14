/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the BatchStep__c custom object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-27-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SEL_BatchStepsSelector 
{
	// DESCRIPTION
	// Returns the list of SEL_BatchStep__c records that are
	// associated to the parameter batch ID.
	public List<SEL_BatchStep__c> selectByBatchId(Id batchId) 
	{
		List<SEL_BatchStep__c> result = new List<SEL_BatchStep__c>(); 
		
		if(batchId != null) 
		{  
			result = [
				SELECT		Id, SEL_BatchId__c, SEL_BatchSize__c, SEL_Sequence__c, SEL_Status__c
				FROM		SEL_BatchStep__c
				WHERE		SEL_BatchId__c =: batchId 
				WITH		SECURITY_ENFORCED
				ORDER BY 	SEL_Sequence__c
			];
		}


		return result;
	}
}