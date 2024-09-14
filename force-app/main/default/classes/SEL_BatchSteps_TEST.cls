/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the BatchStep__c Domain class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
40  			convert
34  			onAfterInsert
33  			onAfterUpdate
31  			onBeforeInsert
32  			onBeforeUpdate
195 			setStatusToProcessing
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_BatchSteps_TEST 
{
	private static final String CLASS_NAME = 'SEL_BatchSteps_Test';
	private static final String SETTING_NAME = 'sample';

	@TestSetup
	static void makeData()
	{
		SEL_Batch__c batch1 = new SEL_Batch__c(
			SEL_BatchTemplate__c = SEL_BatchSteps_Test.CLASS_NAME,
			SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED
		);
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
	}

	@IsTest
	private static void convert() 
	{
		Test.startTest();

		// SETUP DATA
		SEL_Batch__c testRun = [SELECT Id FROM SEL_Batch__c WHERE SEL_BatchTemplate__c =: SEL_BatchSteps_Test.CLASS_NAME LIMIT 1];
		SEL_BatchStepTemplate__mdt sample = new SEL_BatchStepTemplate__mdt(SEL_Class__c = SEL_BatchSteps_Test.SETTING_NAME, SEL_Sequence__c = 1);

		// RUN
		List<SEL_BatchStep__c> steps = SEL_BatchSteps.convert(new List<SEL_BatchStepTemplate__mdt> { sample }, testRun.Id, true);

		// ASSERT
		System.assert(steps.size() == 1, 'A single SEL_BatchStep__c record must be created.');
		System.assert(steps[0].SEL_Class__c.equalsIgnoreCase(SEL_BatchSteps_Test.SETTING_NAME), 'The generated SEL_BatchStep__c must have the same class name.');

		Test.stopTest();
	}

	@IsTest
	private static void onBeforeInsert()
	{
		Test.startTest();

		// DATA
		List<SEL_BatchStep__c> steps = [SELECT Id, SEL_Start__c, SEL_Status__c FROM SEL_BatchStep__c];
		steps[0].SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;

		// RUN
		// Normal scenario
		SEL_BatchSteps.onBeforeInsert(steps);

		// ASSERT
		List<SEL_BatchStep__c> output = SEL_BatchSteps.recordsOnBeforeInsert;
		for(SEL_BatchStep__c s : output)
		{
			if(s.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
			{
				System.assert(s.SEL_Start__c != null, 'SEL_BatchStep__c that is set to Processing must have a Start__c value.');
			} 
			else 
			{
				System.assert(s.SEL_Start__c == null, 'Other SEL_BatchStep__c must have blank Start__c value.');	
			}
		}

		Test.stopTest();
	}

	@IsTest
	private static void onAfterInsert()
	{
		Test.startTest();

		// DATA
		SEL_BatchStep__c step = [SELECT Id, SEL_BatchId__c, SEL_Class__c, SEL_Start__c, SEL_Status__c FROM SEL_BatchStep__c LIMIT 1];
		step.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;

		// TEST
		SEL_BatchSteps.onAfterInsert(new Map<Id, SEL_BatchStep__c> { step.Id => step });

		// ASSERT
		System.assert(SEL_BatchSteps.recordsOnAfterInsert.containsKey(step.SEL_BatchId__c), 'The map must have the BatchId of the Processing BatchStep__c record.');
		System.assert(SEL_BatchSteps.recordsOnAfterInsert.get(step.SEL_BatchId__c).containsKey(step.Id), 'The map must have the BatchStepId of the Processing BatchStep__c record.');

		Test.stopTest();
	}

	@IsTest
	private static void onBeforeUpdate()
	{
		Test.startTest();

		// DATA 1
		// From PROCESSING to COMPLETED/FAILED
		SEL_BatchStep__c oldStep = [SELECT Id, SEL_BatchId__c, SEL_Class__c, SEL_Start__c, SEL_Stop__c, SEL_Status__c FROM SEL_BatchStep__c LIMIT 1];
		oldStep.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
		oldStep.SEL_Stop__c = null;

		SEL_BatchStep__c newStep = oldStep.clone(true, true, true, true);
		newStep.SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED;

		// TEST 1
		SEL_BatchSteps.onBeforeUpdate(new Map<Id, SEL_BatchStep__c> { oldStep.Id => oldStep }, new Map<Id, SEL_BatchStep__c> { newStep.Id => newStep });

		// ASSERT 1
		System.assert(SEL_BatchSteps.recordsOnBeforeUpdate.containsKey(newStep.Id), 'The map must contain ID of the newStep.');
		System.assert(SEL_BatchSteps.recordsOnBeforeUpdate.get(newStep.Id).SEL_Stop__c != null, 'The SEL_Stop__c field must be populated.');

		// DATA 2
		// From NOT STARTED/FAILED to PROCESSING
		oldStep.SEL_Status__c = SEL_BatchConstants.STATUS_FAILED;
		oldStep.SEL_Start__c = null;
		oldStep.SEL_Stop__c = null;

		newStep.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
		newStep.SEL_Start__c = null;
		newStep.SEL_Stop__c = null;

		// TEST 2
		SEL_BatchSteps.onBeforeUpdate(new Map<Id, SEL_BatchStep__c> { oldStep.Id => oldStep }, new Map<Id, SEL_BatchStep__c> { newStep.Id => newStep });

		// ASSERT 2
		System.assert(SEL_BatchSteps.recordsOnBeforeUpdate.containsKey(newStep.Id), 'The map must contain ID of the olnewStepdStep.');
		System.assert(SEL_BatchSteps.recordsOnBeforeUpdate.get(newStep.Id).SEL_Start__c != null, 'The SEL_Start__c field must be populated.');

		Test.stopTest();
	}

	@IsTest
	private static void onAfterUpdate()
	{
		Test.startTest();

		// DATA
		SEL_BatchStep__c oldStep = [SELECT Id, SEL_BatchId__c, SEL_Class__c, SEL_Start__c, SEL_Stop__c, SEL_Status__c FROM SEL_BatchStep__c LIMIT 1];
		oldStep.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;

		SEL_BatchStep__c newStep = oldStep.clone(true, true, true, true);
		newStep.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;

		// TEST
		// Transition from FAILED/NOT STARTED to PROCESSING
		SEL_BatchSteps.onAfterUpdate(new Map<Id, SEL_BatchStep__c> { oldStep.Id => oldStep }, new Map<Id, SEL_BatchStep__c> { newStep.Id => newStep });

		// ASSERT
		System.assert(SEL_BatchSteps.recordsOnAfterUpdate.containsKey(newStep.SEL_BatchId__c), 'The map must have the BatchId of the Processing BatchStep__c record.');
		System.assert(SEL_BatchSteps.recordsOnAfterUpdate.get(newStep.SEL_BatchId__c).containsKey(newStep.Id), 'The map must have the BatchStepId of the Processing BatchStep__c record.');

		Test.stopTest();
	}

	@IsTest
	private static void setStatusToProcessing()
	{
		Test.startTest();

		// DATA
		List<SObject> recordsToUpdate = new List<SObject>();
		
		// For batch
		SEL_Batch__c batchTest = [SELECT Id, SEL_Status__c, (SELECT Id, SEL_Class__c, SEL_Start__c, SEL_Status__c, SEL_Stop__c FROM SEL_BatchSteps__r) FROM SEL_Batch__c LIMIT 1];
		batchTest.SEL_Status__c = SEL_BatchConstants.STATUS_FAILED;
		recordsToUpdate.add(batchTest);

		// For batch steps
		for(SEL_BatchStep__c step : batchTest.SEL_BatchSteps__r)
		{
			if(step.SEL_Class__c.equalsIgnoreCase('Class1')) 
			{ 
				step.SEL_Status__c = SEL_BatchConstants.STATUS_FAILED;
			}
			else 
			{
				step.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;	
			}
			recordsToUpdate.add(step);
		}
		update recordsToUpdate;

		// TEST
		List<SEL_BatchStep__c> output = SEL_BatchSteps.setStatusToProcessing(new Map<Id, String> { batchTest.Id => SEL_BatchConstants.STATUS_FAILED});

		// ASSERT
		System.assert(output.size() == 1, 'The output must be a single batch step.');
		System.assert(output.get(0).SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING), 'The batch step must be set to PROCESSING');

		Test.stopTest();
	}
}