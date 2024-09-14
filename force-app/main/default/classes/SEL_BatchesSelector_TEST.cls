/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SEL_Batch__c Selector Layer.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
65  			selectByIds
74  			selectByIdsByStatuses
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_BatchesSelector_TEST 
{
	@TestSetup
	static void makeData()
	{
		SEL_Batch__c batch1 = new SEL_Batch__c( SEL_BatchTemplate__c = 'BatchesSelector_Test' );	
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
		step2.SEL_Class__c = 'Class1';
		step2.SEL_Sequence__c = 1;
		step2.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
		steps.add(step2);

		insert steps;
	}

	@IsTest
	private static void selectByIds() 
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
		Map<Id, SEL_Batch__c> testData = new Map<Id, SEL_Batch__c>([SELECT Id FROM SEL_Batch__c]);

		// ERROR SCENARIO
		// With null parameter 
		System.assert(new SEL_BatchesSelector().selectByIds(null).isEmpty(), 'Passing null parameter must result to an empty list.');

		// NORMAL SCENARIO
		List<SEL_Batch__c> result = new SEL_BatchesSelector().selectByIds(testData.keySet());
		System.assert(result.size() == 1, 'There must be a single row returned.');
		
		Test.stopTest();
		}
    }

	@IsTest
	private static void selectByIdsByStatuses() 
	{
		Test.startTest();

		// DATA
		Map<Id, SEL_Batch__c> testData = new Map<Id, SEL_Batch__c>([SELECT Id FROM SEL_Batch__c]);

		// ERROR SCENARIO
		// With null parameter 
		System.assert(new SEL_BatchesSelector().selectByIdsByStatuses(testData.keySet(), null).isEmpty(), 'Passing a null parameter must result to an empty list.');

		// NORMAL SCENARIO
		List<SEL_Batch__c> result = new SEL_BatchesSelector().selectByIdsByStatuses(testData.keySet(), new Set<String> { SEL_BatchConstants.STATUS_NOT_STARTED });
		System.assert(result.size() == 1, 'There must be a single row returned.');
		System.assert(result[0].SEL_BatchSteps__r.size() == 2, 'There must be two rows returned.');
		
		Test.stopTest();
	}
}