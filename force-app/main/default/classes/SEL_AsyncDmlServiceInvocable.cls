/*-----------------------------------------------------------------------------
DESCRIPTION	:	Invocable method for raising Async DML Requests from Flows
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
APR-24-2022		Macjules Sevilla	Initial version	
-----------------------------------------------------------------------------*/
public with sharing class SEL_AsyncDmlServiceInvocable 
{
	public class SEL_AsyncDmlServiceRequest
	{
		@AuraEnabled
		@InvocableVariable(label='DML (String)' description='DML operation to perform.' required=true)
		public String dml;
		
		@AuraEnabled
		@InvocableVariable(label='Object API (String)' description='Object API of the record to execute asynchronously.' required=true)
		public String objectApi;
	
		@AuraEnabled
		@InvocableVariable(label='List of Records' description='Records perform DML. Must be List<SObject>.' required=true)
		public List<SObject> records;
	}

	@InvocableMethod(category='Enterprise Library' label='Run Asynchronous DML' description='Perform a single DML on a collection of records belogning to the same object')
	public static void log(List<SEL_AsyncDmlServiceInvocable.SEL_AsyncDmlServiceRequest> requests) 
	{
		if(!(requests == null || requests.isEmpty()))
		{
			List<SEL_AsyncDml__e> messages = new List<SEL_AsyncDml__e>();

			for(SEL_AsyncDmlServiceInvocable.SEL_AsyncDmlServiceRequest request : requests)
			{
				for(SObject obj : request.records)
				{
					SEL_AsyncDml__e e = new SEL_AsyncDml__e();
					e.SEL_Action__c = request.dml;
					e.SEL_Object__c = request.objectApi;
					e.SEL_Record__c = JSON.serialize(obj);
	
					messages.add(e);
				}
			}

			Eventbus.publish(messages);
		}
	}
}