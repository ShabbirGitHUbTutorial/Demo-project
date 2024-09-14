/*-------------------------------------------------------------------------------------------------------------------
DESCRIPTION	:	Invocable method for SPEN_AgentsAvailabilityService > checkAvailabilityByQueueDeveloperName 
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-07-2023		Macjules Sevilla	Initial version
-------------------------------------------------------------------------------------------------------------------*/
public with sharing class SPEN_AvailabilityCheckInvocable 
{
	public class SPEN_AvailabilityCheckRequest
	{
		@AuraEnabled
		@InvocableVariable(label='Queue Developer Name (String)' description='Queue to perform agent availability check on.' required=true)
		public String queueName;
	}

	/**
	 * @description At the moment, the feature is limited to one queue name
	 */
	@InvocableMethod(category='SPEN' label='Check Agent Availability (Entire Queue)' description='Check if any agent in the queue is available to pick up new work.')
	public static List<Boolean> check(List<SPEN_AvailabilityCheckInvocable.SPEN_AvailabilityCheckRequest> requests) 
	{
		List<Boolean> result = new List<Boolean>();

		if(!(requests == null || requests.isEmpty()))
		{
			// IMPORTANT
			// Due to the number of SOQL that the availability check is doing, the functionality
			// has been restricted to only check one queue name at a time.

			SPEN_AvailabilityCheckInvocable.SPEN_AvailabilityCheckRequest request = requests[0];
			result.add(new SPEN_AgentsAvailabilityService().checkAvailabilityByQueueDeveloperName(request.queueName));
		}

		return result;
	}
}