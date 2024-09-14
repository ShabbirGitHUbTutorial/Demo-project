/*----------------------------------------------------------------------------------
DESCRIPTION	:	Invocable method for SPEN_GroupsSelector > selectByQueueName 
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-14-2023		Macjules Sevilla	Initial version
----------------------------------------------------------------------------------*/
public with sharing class SPEN_GroupsSelectorByNameInvocable 
{
	public class SPEN_GroupsSelectorByNameRequest
	{
		@AuraEnabled
		@InvocableVariable(label='Queue Developer Name (String)' description='Queue to query.' required=true)
		public String queueName;
	}

	/**
	 * @description At the moment, the feature is limited to one queue name
	 */
	@InvocableMethod(category='SPEN' label='Query Queue ID' description='Returns the Queue ID based on the Queue Developer name. Pass a single value only.')
	public static List<Id> getQueueId(List<SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest> requests) 
	{
		List<Id> result = new List<Id>();

		if(!(requests == null || requests.isEmpty()))
		{
			SPEN_GroupsSelectorByNameInvocable.SPEN_GroupsSelectorByNameRequest request = requests[0];
			Group queueResult = new SPEN_GroupsSelector().selectByQueueName(request.queueName);

			if(queueResult.isSet('Id'))
			{
				result.add(queueResult.Id);
			}
		}

		return result;
	}
}