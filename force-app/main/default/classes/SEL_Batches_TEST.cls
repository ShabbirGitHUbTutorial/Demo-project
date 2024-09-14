/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the Batch__c Domain Layer.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
13  			getDistinctNames
45  			onAfterInsert
156 			onAfterUpdate
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_Batches_TEST 
{
	private static final String TEMPLATE_NAME_A = 'NonExistentBatches_Test_A';
	private static final String TEMPLATE_NAME_B = 'NonExistentBatches_Test_B';

	@TestSetup
	static void makeData()
	{
		SEL_Batch__c batchA = new SEL_Batch__c();
		batchA.SEL_BatchTemplate__c = SEL_Batches_TEST.TEMPLATE_NAME_A;
		batchA.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
		insert batchA;

		SEL_Batch__c batchB = new SEL_Batch__c();
		batchB.SEL_BatchTemplate__c = SEL_Batches_TEST.TEMPLATE_NAME_B;
		batchB.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
		insert batchB;

		SEL_BatchStep__c step1 = new SEL_BatchStep__c();
		step1.SEL_BatchId__c = batchB.Id;
		step1.SEL_BatchSize__c = 200;
		step1.SEL_Class__c = SEL_Batches_TEST.TEMPLATE_NAME_B;
		step1.SEL_Sequence__c = 1;
		step1.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
		insert step1;
	}

	@IsTest
	private static void getDistinctNames()
	{
		// DATA
		// with two duplicates
		List<SEL_Batch__c> records = new List<SEL_Batch__c>();
		records.add(new SEL_Batch__c( SEL_BatchTemplate__c = 'Type 1' ));
		records.add(new SEL_Batch__c( SEL_BatchTemplate__c = 'Type 1' ));
		records.add(new SEL_Batch__c( SEL_BatchTemplate__c = 'Type 2' ));

		// TEST
		Set<String> names = SEL_Batches.getDistinctNames(records);

		// ASSERT
		System.assert(names.size() == 2, 'The getDistinctNames must return two unique names only.');
	}

	@IsTest
	private static void onAfterInsert()
	{
		Test.startTest();

		// DATA
		SEL_Batch__c record = [SELECT Id, SEL_BatchTemplate__c, SEL_Status__c FROM SEL_Batch__c WHERE SEL_BatchTemplate__c =: SEL_Batches_TEST.TEMPLATE_NAME_A LIMIT 1];

		// TEST
		SEL_Batches.onAfterInsert(new Map<Id, SEL_Batch__c> { UserInfo.getUserId() => record });

		// ASSERT
		System.assert([SELECT Id FROM SEL_BatchStep__c WHERE SEL_BatchId__c =: record.Id].isEmpty(), 'No child steps must be created');

		Test.stopTest();
	}

	@IsTest
	private static void onAfterUpdate()
	{
		Test.startTest();

		// DATA
		SEL_Batch__c recordOld = [SELECT Id, SEL_Status__c FROM SEL_Batch__c WHERE SEL_BatchTemplate__c =: SEL_Batches_TEST.TEMPLATE_NAME_B LIMIT 1];
		SEL_Batch__c recordNew = recordOld.clone(true, true, true, true);
		recordNew.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
		SEL_BatchStep__c step = [SELECT Id, SEL_Status__c FROM SEL_BatchStep__c WHERE SEL_BatchId__c =: recordOld.Id LIMIT 1];

		// TEST
		SEL_Batches.onAfterUpdate(new Map<Id, SEL_Batch__c> { recordOld.Id => recordOld }, new Map<Id, SEL_Batch__c> { recordNew.Id => recordNew });

		// ASSERT
		System.assert(step.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_NOT_STARTED), 'The batch step child record must have an initial status of Not Started.');
		System.assert([SELECT Id, SEL_Status__c FROM SEL_BatchStep__c WHERE SEL_BatchId__c =: recordOld.Id LIMIT 1]?.SEL_Status__c == SEL_BatchConstants.STATUS_PROCESSING, 'The batch step child record must be set to Processing.');

		Test.stopTest();
	}
}