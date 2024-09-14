/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the BatchStepBase abstract class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
30  			executeBatch
14  			isValid
660 			finishBatch
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_BatchStepBase_TEST 
{
	// TEST CLASS
	private class SEL_BatchStepTest extends SEL_BatchStepBase {}

	// CONSTANTS
	private static final String BATCH_TEMPLATE_A = 'BatchStepBase_Test_A'; 

	@TestSetup
	static void makeData()
	{
		SEL_Batch__c batch1 = new SEL_Batch__c( SEL_BatchTemplate__c = SEL_BatchStepBase_Test.BATCH_TEMPLATE_A );	
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
	private static void executeBatch() 
	{
		try 
		{
			// TEST
			new SEL_BatchStepTest().executeBatch();
		} 
		catch (Exception ex) 
		{
			// ASSERT
			System.assert(ex.getMessage().equalsIgnoreCase('Execute batch must be overridden.'), 'Exception must be thrown.');
		}
	}

	@IsTest
	private static void isValid()
	{
		// ERROR SCENARIO
		SEL_BatchStepTest testA = new SEL_BatchStepTest();
		System.assert(testA.isValid() == false, 'Not passing BatchId or BatchStepId will result to invalid state.');

		// NORMAL SCENARIO
		testA.batchId = UserInfo.getUserId();
		testA.batchStepId = UserInfo.getUserId();
		System.assert(testA.isValid() == true, 'Setting both parameters must result to a valid state.');
	}

	@IsTest
	private static void finishBatch()
	{
		Test.startTest();
		Id profileId = [SELECT Id FROM Profile WHERE Name =: 'System Administrator' LIMIT 1].Id;
        User user = new User(	FirstName= 'Macjules', 
								LastName = 'Sevilla', 
								Email = 'msevilla@spenergynetworks.co.uk.test',
								Username = 'Sevilla' + System.currentTimeMillis() + '@spenergynetworks.co.uk.test',
								Alias = 'macj',
								ProfileId =  profileId,
								IsActive = true,
								TimeZoneSidKey = 'America/Los_Angeles',
	                            EmailEncodingKey = 'UTF-8',
                            	LanguageLocaleKey = 'en_US',
								LocaleSidKey = 'en_US');
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SEL_BatchFrameworkUser'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
       System.runAs(user)
       {
		// DATA
		SEL_BatchStep__c child1 = [SELECT Id, SEL_BatchId__c FROM SEL_BatchStep__c WHERE SEL_BatchId__r.SEL_BatchTemplate__c =: SEL_BatchStepBase_Test.BATCH_TEMPLATE_A LIMIT 1];

		// TEST 1
		// Scenario with successful batch run
		SEL_BatchStepTest stepRun = new SEL_BatchStepTest();
		stepRun.jobCompletedDate = Datetime.now();
		stepRun.jobExtendedStatus = 'Completed'; 
		stepRun.jobFailures = 0;
		stepRun.jobStatus = 'Completed';
		stepRun.finishBatch(null, child1.SEL_BatchId__c, child1.Id);

		// ASSERT 1
		SEL_Batch__c parent1 = [SELECT Id, SEL_Status__c FROM SEL_Batch__c WHERE SEL_BatchTemplate__c =: SEL_BatchStepBase_Test.BATCH_TEMPLATE_A LIMIT 1];
		System.assert(parent1.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING), 'Parent Batch__c must be set to processing.');

		// TEST 2
		// Scenario with failed batch run
		stepRun.jobExtendedStatus = 'Failed'; 
		stepRun.jobFailures = 1;
		stepRun.jobStatus = 'Failed';
		stepRun.finishBatch(null, child1.SEL_BatchId__c, child1.Id);

		// ASSERT 2
		parent1 = [SELECT Id, SEL_Status__c FROM SEL_Batch__c WHERE SEL_BatchTemplate__c =: SEL_BatchStepBase_Test.BATCH_TEMPLATE_A LIMIT 1];
		System.assert(parent1.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_FAILED), 'Parent Batch__c must be set to failed.');

		Test.stopTest();
       }
	}
}