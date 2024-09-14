/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_AsyncBatch Trigger.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
1693			insertTest
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.SOQLSelectorPattern')
@IsTest(isParallel = true)
public without sharing class SPEN_AsyncBatch_TEST 
{
	@IsTest
	private static void insertTest() 
	{
		Test.startTest();

		// DATA
		EventBus.publish(new SPEN_AsyncBatch__e(SPEN_Action__c = 'MACJULESTESTACTION'));
		
		Test.stopTest();

		// QUERY
		List<SEL_Batch__c> results = [SELECT Id FROM SEL_Batch__c WHERE SEL_BatchTemplate__c =: 'MACJULESTESTACTION'];

		// ASSERT
		Assert.isTrue(results.isEmpty() == true, 'The batch list must be empty if the parameter is null');

	}
}