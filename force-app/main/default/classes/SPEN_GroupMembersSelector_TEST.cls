/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_GroupMembersSelector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
120				selectByQueueId
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_GroupMembersSelector_TEST 
{
	@IsTest
	private static void selectByQueueId() 
	{
		Test.startTest();

		// SCENARIO 1
		// Parameter = NULL
		List<GroupMember> results1 = new SPEN_GroupMembersSelector().selectByQueueId(null);
		Assert.isTrue(results1.isEmpty(), 'The returned list must be empty if the parameter is null');

		// SCENARIO 2
		// Parameter = INVALID QUEUE ID
		List<GroupMember> results2 = new SPEN_GroupMembersSelector().selectByQueueId(UserInfo.getUserId());
		Assert.isTrue(results2.isEmpty(), 'The returned list must be empty if the Queue ID does not exist');

		Test.stopTest();
	}
}