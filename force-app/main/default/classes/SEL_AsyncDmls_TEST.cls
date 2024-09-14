/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_AsyncDmls and SEL_AsyncDml trigger.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

Time (MS)		Method
41 				onAfterInsertNormal
493 			onAfterInsertException	
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_AsyncDmls_TEST 
{
	@IsTest
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern')
	private static void onAfterInsertNormal()
	{
		// DATA
		String recordName = 'AsyncDmls_Test onAfterInsertNormal';
		SEL_AsyncDml__e recordInsert = new SEL_AsyncDml__e(
			SEL_Action__c = SEL_CoreConstants.DML_INSERT,
			SEL_Object__c = 'Account',
			SEL_Record__c = '{ "Name" : "' + recordName + '" }'
		);
		
		Test.startTest();

		// TEST
		Eventbus.publish(recordInsert);

		Test.stopTest();

		// ASSERT
		System.assert([SELECT count() FROM Account WHERE Name =: recordName] == 1, 'An account must be created');
	}

	@IsTest
	private static void onAfterInsertException() 
	{
		Test.startTest();

		// DATA
		SEL_AsyncDml__e recordInsert = new SEL_AsyncDml__e(
			SEL_Action__c = SEL_CoreConstants.DML_INSERT,
			SEL_Object__c = 'Account',
			SEL_Record__c = '{ "Name" : "AsyncDmls_Test onAfterInsertException" }'
		);

		try
		{
			// TEST. Exception Scenario
			SEL_AsyncDmls domain = new SEL_AsyncDmls();
			domain.isDmlExceptionThrown = true;
			domain.onAfterInsert(new List<SEL_AsyncDml__e> { recordInsert });
		} 
		catch (DmlException ex)
		{
			// ASSERT. Exception Scenario
			System.assert(ex.getMessage().contains(SEL_AsyncDmlConstants.ERROR_UNABLE_TO_LOCK_ROW), 'There must be 2 retries before throwing an exception');
		}

		Test.stopTest();
	}
}