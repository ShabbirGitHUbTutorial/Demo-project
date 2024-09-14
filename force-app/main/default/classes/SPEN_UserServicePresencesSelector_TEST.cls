/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_UserServicePresencesSelector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
591				selectByUserIdsByState
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_UserServicePresencesSelector_TEST 
{
	@IsTest
	private static void selectByUserIdsByState() 
	{
		Test.startTest();

		// SCENARIO 1
		// User ID = Null
		// Status = with value
		List<UserServicePresence> results1 = new SPEN_UserServicePresencesSelector().selectByUserIdsByState(null, true);
		Assert.isTrue(results1.isEmpty(), 'The returned list must be empty if the User ID list parameter is null');

		// SCENARIO 2
		// User ID = with value
		// Status = Null
		List<UserServicePresence> results2 = new SPEN_UserServicePresencesSelector().selectByUserIdsByState(new Set<Id> { UserInfo.getUserId() }, true);
		Assert.isTrue(results2.isEmpty(), 'The returned list must be empty if the State parameter is null');

		Test.stopTest();
	}
}