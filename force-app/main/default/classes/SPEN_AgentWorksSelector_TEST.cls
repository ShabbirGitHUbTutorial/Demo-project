/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_AgentWorksSelector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
135				selectByUserIdsByStatuses
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_AgentWorksSelector_TEST 
{
	@IsTest
	private static void selectByUserIdsByStatuses() 
	{
		Test.startTest();

		// SCENARIO 1
		// User ID = NULL
		// Status  = NOT NULL + VALID
		List<AgentWork> results1 = new SPEN_AgentWorksSelector().selectByUserIdsByStatuses(null, new Set<String> { 'Opened' });
		Assert.isTrue(results1.isEmpty(), 'The returned list must be empty if the User ID list parameter is null');

		// SCENARIO 2
		// User ID = NOT NULL + VALID
		// Status  = NULL
		List<AgentWork> results2 = new SPEN_AgentWorksSelector().selectByUserIdsByStatuses(new Set<Id> { UserInfo.getUserId() }, null);
		Assert.isTrue(results2.isEmpty(), 'The returned list must be empty if the status parameter is null');

		// SCENARIO 3
		// User ID = NOT NULL + VALID
		// Status  = NOT NULL + INVALID
		List<AgentWork> results3 = new SPEN_AgentWorksSelector().selectByUserIdsByStatuses(new Set<Id> { UserInfo.getUserId() }, new Set<String> { 'INVALIDVALUE' });
		Assert.isTrue(results3.isEmpty(), 'The returned list must be empty if no value is found');

		Test.stopTest();
	}
}