/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the SEL_BatchStepTemplate__mdt custom metadata type
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-27-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SEL_BatchStepTemplatesSelector 
{
	// DESCRIPTION
	// Returns all active SEL_BatchStepTemplate__mdt related to a batch name
	public List<SEL_BatchStepTemplate__mdt> selectByTemplate(Set<String> batchNames)
	{
        List<SEL_BatchStepTemplate__mdt> result = new List<SEL_BatchStepTemplate__mdt>();

		if(batchNames != null && !batchNames.isEmpty()) 
        {
            result = [
                SELECT		SEL_BatchSize__c, SEL_BatchTemplateId__r.MasterLabel, SEL_Class__c, SEL_Sequence__c
                FROM		SEL_BatchStepTemplate__mdt
                WHERE		SEL_IsActive__c = true AND SEL_BatchTemplateId__r.MasterLabel IN :batchNames
                WITH		SECURITY_ENFORCED
                ORDER BY	SEL_Sequence__c 
            ];
        }

        return result;
	}
}