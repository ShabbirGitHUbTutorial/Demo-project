/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_GroupsSelectorByNameInvocable class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
116				getQueueId
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_GroupsSelectorByNameInvocable_TEST 
{
	@SuppressWarnings('PMD.SOQLSelectorPattern')
	@IsTest
	private static void getQueueId() 
	{
		Test.startTest();

		// DATA
		SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest data1 = new SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest();
		data1.queueName = 'FakeQueueNameMacjules';

		// SCENARIO 1
		// Where the parameter is NULL
		List<Id> result1 = SPEN_GroupsSelectorByNameInvocable.getQueueId(null);
		Assert.isTrue(result1.isEmpty() == true, 'The result must be empty if the parameter is null');

		// SCENARIO 2
		// Where the parameter contains fake queue name
		List<Id> result2 = SPEN_GroupsSelectorByNameInvocable.getQueueId(new List<SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest> { data1 });
		Assert.isTrue(result2.isEmpty() == true, 'The result must be empty if the parameter is a non-existent queue name');

		// DATA 
		Group actualQueue = [SELECT Id, DeveloperName FROM Group WHERE Type =: 'Queue' WITH SECURITY_ENFORCED LIMIT 1];

		// SCENARIO 3
		// Where the parameter contains a real queue
		if(actualQueue != null)
		{
			SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest data2 = new SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest();
			data2.queueName = actualQueue.DeveloperName;

			List<Id> result3 = SPEN_GroupsSelectorByNameInvocable.getQueueId(new List<SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest> { data2 });
			Assert.isTrue(result3.size() == 1, 'The result must return one queue');
			Assert.isTrue(result3[0] == actualQueue.Id, 'The result ID must be equal as the actual queue');
		}

		Test.stopTest();
	}
}