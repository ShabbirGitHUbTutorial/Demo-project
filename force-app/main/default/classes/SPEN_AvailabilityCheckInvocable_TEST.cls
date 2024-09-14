/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_AvailabilityCheckInvocable class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
135				selectByUserIdsByStatuses
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_AvailabilityCheckInvocable_TEST 
{
	@IsTest
	private static void check() 
	{
		Test.startTest();

		// DATA
		SPEN_AvailabilityCheckInvocable.SPEN_AvailabilityCheckRequest data1 = new SPEN_AvailabilityCheckInvocable.SPEN_AvailabilityCheckRequest();
		data1.queueName = 'FakeQueueNameMacjules';

		// RUN
		List<Boolean> result = SPEN_AvailabilityCheckInvocable.check(new List<SPEN_AvailabilityCheckInvocable.SPEN_AvailabilityCheckRequest> { data1 });

		// ASSERT
		Assert.isTrue(result.size() > 0, 'There must be a response');
		Assert.isTrue(result[0] == false, 'The response must be false as the queue name is fake and therefore signalling that there is no availability');

		Test.stopTest();
	}
}