/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_GroupsSelector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
120				selectByQueueName
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_GroupsSelector_TEST 
{
	@IsTest
	private static void selectByQueueName() 
	{
		Test.startTest();

		// SCENARIO 1
		// Queue Developer Name = NO MATCHING RECORD
		Group results1 = new SPEN_GroupsSelector().selectByQueueName('faketestqueue101');
		Assert.isTrue(results1.isSet('Id') == false, 'The returned value must be empty no matching record is found');

		// SCENARIO 2
		// Queue Developer Name = MATCHING QUEUE IN PROD
		Group results2 = new SPEN_GroupsSelector().selectByQueueName('SPEN_StreetWorkNorth');
		Assert.isTrue(results2.isSet('Id') == true, 'The returned value must be valid');

        Map<String, String> results3 = SPEN_GroupsSelector.getQueueMembers(new Set<String>{'SPEN_StreetWorkNorth'});
		Test.stopTest();
	}
}