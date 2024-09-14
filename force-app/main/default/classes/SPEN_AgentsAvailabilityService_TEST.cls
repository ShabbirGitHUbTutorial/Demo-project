/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_AgentsAvailabilityService Service class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
135				selectByUserIdsByStatuses
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_AgentsAvailabilityService_TEST 
{
	@IsTest
	private static void checkAvailabilityByQueueDeveloperNameRule1() 
	{
		Test.startTest();

		// DATA
		SPEN_AgentsAvailabilityService service = new SPEN_AgentsAvailabilityService();

		// RULE 1: SCENARIO 1. 
		// Pass a null value
		Assert.isTrue(service.checkAvailabilityByQueueDeveloperName(null) == false, 'The method must return FALSE ');
		
		// RULE 1: SCENARIO 2.
		// Pass an non-existent queue name
		Assert.isTrue(service.checkAvailabilityByQueueDeveloperName('MacjulesFakeQueue') == false, 'The method must return FALSE ');

		Test.stopTest();
	}

	@IsTest
	private static void checkAvailabilityByQueueDeveloperNameRule2() 
	{
		Test.startTest();

		// DATA
		// Queue that is not supposed to have any members
		String queueWithoutMembers = 'SPEN_VoicemailSwitchQueue';
		SPEN_AgentsAvailabilityService service = new SPEN_AgentsAvailabilityService();

		// RULE 2: SCENARIO 1. 
		// Pass a null value
		Assert.isTrue(service.checkAvailabilityByQueueDeveloperName(queueWithoutMembers) == false, 'The method must return FALSE as the queue does not have members');
		
		Test.stopTest();
	}

	@IsTest
	private static void checkAvailabilityByQueueDeveloperNameRule3() 
	{
		Test.startTest();

		// DATA
		// Queue with members
		String queueWithMembers = 'SPEN_StreetWorkNorth';
		SPEN_AgentsAvailabilityService service = new SPEN_AgentsAvailabilityService();
		service.bypassAvailabilityCheck = true;
		service.executeOpenedWorkItemCheck = false;

		// RULE 2: SCENARIO 1. 
		// Pass a null value
		Assert.isTrue(service.checkAvailabilityByQueueDeveloperName(queueWithMembers) == false, 'The method must return FALSE as the queue does not have members');
		
		Test.stopTest();
	}
}