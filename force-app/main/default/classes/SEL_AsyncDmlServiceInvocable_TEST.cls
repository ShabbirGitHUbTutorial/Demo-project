/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_AsyncDmlServiceInvocable.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

Time (MS)		Method
1259  			SEL_AsyncDmlServiceInvocable_Test
-----------------------------------------------------------------------------*/
@IsTest 
public with sharing class SEL_AsyncDmlServiceInvocable_TEST
{
	@IsTest
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern')
	private static void log()
	{
		// DATA
		String recordName = 'AsyncDmlServiceInvocable_Test log';
		SEL_AsyncDmlServiceInvocable.SEL_AsyncDmlServiceRequest request = new SEL_AsyncDmlServiceInvocable.SEL_AsyncDmlServiceRequest();
		request.dml = SEL_CoreConstants.DML_INSERT;
		request.objectApi = 'Account';
		request.records = new List<SObject> { new Account(Name = recordName) };

		Test.startTest();

		// TEST
		SEL_AsyncDmlServiceInvocable.log(new List<SEL_AsyncDmlServiceInvocable.SEL_AsyncDmlServiceRequest> { request });

		Test.stopTest();

		// ASSERT
		System.assert([SELECT id FROM Account WHERE Name =: recordName].size() == 1, 'There must be a single record created');
	}
}