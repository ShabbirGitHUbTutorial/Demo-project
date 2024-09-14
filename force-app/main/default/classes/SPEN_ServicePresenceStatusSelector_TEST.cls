/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_ServicePresenceStatusSelector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
77				selectByMasterLabel
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_ServicePresenceStatusSelector_TEST 
{
	@IsTest
	private static void selectByMasterLabel() 
	{
		Test.startTest();

		// SCENARIO 1
		// Queue Developer Name = NO MATCHING RECORD
		List<ServicePresenceStatus> results1 = new SPEN_ServicePresenceStatusSelector().selectByMasterLabel('MacjulesPresence');
		Assert.isTrue(results1.isEmpty() == true, 'The returned value must be empty no matching record is found');

		// SCENARIO 2
		// Queue Developer Name = MATCHING QUEUE IN PROD
		List<ServicePresenceStatus> results2 = new SPEN_ServicePresenceStatusSelector().selectByMasterLabel('Available');
		Assert.isTrue(results2.size() > 1, 'The returned value must be greater than zero as there should be at least 2 in PROD.');

		Test.stopTest();
	}
}