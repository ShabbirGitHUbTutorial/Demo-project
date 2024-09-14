/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SEL_BatchStepTemplate__mdt Domain class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
15  			groupByTemplate
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_BatchStepTemplates_TEST 
{
	@IsTest
	private static void groupByTemplate() 
	{
		// DATA
		List<SEL_BatchStepTemplate__mdt> data = new List<SEL_BatchStepTemplate__mdt>();

		SEL_BatchStepTemplate__mdt step1 = new SEL_BatchStepTemplate__mdt();
		step1.SEL_BatchSize__c = 200;
		step1.SEL_Class__c = 'Step 1';
		step1.SEL_Sequence__c = 1;
		data.add(step1);

		SEL_BatchStepTemplate__mdt step2 = new SEL_BatchStepTemplate__mdt();
		step2.SEL_BatchSize__c = 2000;
		step2.SEL_Class__c = 'Step 2';
		step2.SEL_Sequence__c = 2;
		data.add(step2);

		// TEST
		Map<String, List<SEL_BatchStepTemplate__mdt>> result = SEL_BatchStepTemplates.groupByTemplate(data);

		// ASSERT
		System.assert(result.containsKey('SEL_BatchStepTemplate'), 'The return must have a template called BatchStepTemplate');
		System.assert(result.get('SEL_BatchStepTemplate').size() == data.size(), 'The return must have two steps');
	}
}