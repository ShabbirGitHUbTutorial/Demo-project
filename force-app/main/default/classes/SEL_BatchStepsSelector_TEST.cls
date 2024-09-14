/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SEL_BatchStep__c Selector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
70  			selectByBatchId
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_BatchStepsSelector_TEST 
{
	private static final String CLASS_NAME = 'SEL_BatchStepsSelector_Test';

	@TestSetup
	static void makeData()
	{
		Test.startTest();

		SEL_Batch__c batch1 = new SEL_Batch__c(SEL_BatchTemplate__c = SEL_BatchStepsSelector_Test.CLASS_NAME);
		insert batch1;

		List<SEL_BatchStep__c> steps = new List<SEL_BatchStep__c>();

		SEL_BatchStep__c step1 = new SEL_BatchStep__c();
		step1.SEL_BatchId__c = batch1.Id;
		step1.SEL_BatchSize__c = 200;
		step1.SEL_Class__c = 'Class1';
		step1.SEL_Sequence__c = 1;
		step1.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
		steps.add(step1);

		SEL_BatchStep__c step2 = new SEL_BatchStep__c();
		step2.SEL_BatchId__c = batch1.Id;
		step2.SEL_BatchSize__c = 200;
		step2.SEL_Class__c = 'Class2';
		step2.SEL_Sequence__c = 1;
		step2.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
		steps.add(step2);

		insert steps;

		Test.stopTest();
	}

	@IsTest
	private static void selectByBatchId() 
	{
		Test.startTest();

		// DATA
		SEL_Batch__c batch = [SELECT Id FROM SEL_Batch__c LIMIT 1];

		// TEST
		// Normal scenario
		List<SEL_BatchStep__c> output = new SEL_BatchStepsSelector().selectByBatchId(batch.Id);

		// ASSERT
		System.assert(output.size() == 2, 'All the child Batch Steps must be returned.');

		// TEST
		// Error scenario
		System.assert(new SEL_BatchStepsSelector().selectByBatchId(null).isEmpty(), 'Passing a null value must return an empty list.');

		Test.stopTest();
	}
}