/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_AsyncDmlService.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

Time (MS)		Method
36  			constructor
15  			convertUnprocessRecords
981 			executeDmlForDelete
76  			executeDmlForInsert
60  			executeDmlForUpdate
72  			executeDmlForUpsert
10  			getConfig
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_AsyncDmlService_TEST
{
	@TestSetup
	private static void makeData()
	{
		List<Account> records = new List<Account>();
		records.add(new Account( Name = 'AsyncDmlService_ForUpdate' ));
		records.add(new Account( Name = 'AsyncDmlService_ForDelete' ));
		insert records;
	}

	@IsTest
	private static void constructor() 
	{
		Test.startTest();

		// DATA
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "constructor 1" }'),
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "constructor 2" }'),
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Contact', SEL_Record__c = '{ "LastName" : "constructor 3" }'),
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '')
		};

		// TEST
		SEL_AsyncDmlService dmlService = new SEL_AsyncDmlService(recordsSet);

		// ASSERT
		System.assert(dmlService.actionByObjectByData.containsKey(SEL_CoreConstants.DML_INSERT), 'First and only action must be insert');
		System.assert(dmlService.actionByObjectByData.get(SEL_CoreConstants.DML_INSERT).containsKey('Account'), 'There must be an account object');
		System.assert(dmlService.actionByObjectByData.get(SEL_CoreConstants.DML_INSERT).containsKey('Contact'), 'There must be an contact object');
		System.assert(dmlService.logs.size() == 1, 'There must be a single invalid message.');

		Test.stopTest();
	}

	@IsTest
	private static void captureExceptions()
	{
		Test.startTest();

		// DATA
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "captureExceptions 1" }')
		};

		SEL_DatabaseResult result = new SEL_DatabaseResult();
		result.dml = 'insert';
		result.message = 'captureExceptions';
		result.record = JSON.serialize(new Account(Name = 'captureExceptions'));

		// TEST
		SEL_AsyncDmlService service = new SEL_AsyncDmlService(recordsSet);
		service.captureExceptions(new List<SEL_DatabaseResult>{ result });

		// ASSERT
		System.assert(service.logs.size() == 1, 'There must be a single entry');
		System.assert(service.logs[0].SEL_Exception__c.equalsIgnoreCase(SEL_AsyncDmlConstants.MESSAGE_EXCEPTION_TITLE), 'Message must be Asynchronous DML Exception.');

		Test.stopTest();
	}

	@IsTest
	private static void convertUnprocessRecords()
	{
		Test.startTest();

		// DATA
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "convertUnprocessRecords 1" }')
		};

		// TEST
		SEL_AsyncDmlService dmlService = new SEL_AsyncDmlService(recordsSet);
		List<SObject> records = dmlService.actionByObjectByData.get(SEL_CoreConstants.DML_INSERT).get('Account');

		// ERROR SCENARIO 1
		dmlService.convertUnprocessRecords('', 'Account', records);
		System.assert(dmlService.unprocessedRecordsDueToLimits.size() == 0, 'Passing a blank parameter must return an empty list');

		// ERROR SCENARIO 2
		dmlService.convertUnprocessRecords(SEL_CoreConstants.DML_INSERT, null, records);
		System.assert(dmlService.unprocessedRecordsDueToLimits.size() == 0, 'Passing a blank parameter must return an empty list');

		// ERROR SCENARIO 3
		dmlService.convertUnprocessRecords(SEL_CoreConstants.DML_INSERT, 'Account', null);
		System.assert(dmlService.unprocessedRecordsDueToLimits.size() == 0, 'Passing a blank parameter must return an empty list');

		// NORMAL SCENARIO
		dmlService.convertUnprocessRecords(SEL_CoreConstants.DML_INSERT, 'Account', records);
		System.assert(dmlService.unprocessedRecordsDueToLimits.size() == 1, 'Passing a single record must return a list size of 1');

		Test.stopTest();
	}

	@IsTest
	@SuppressWarnings('PMD.SOQLSelectorPattern')
	private static void executeDmlForInsert()
	{
		Test.startTest();

		// DATA
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "executeDmlForInsert" }')
		};
		
		// TEST
		SEL_AsyncDmlService dmlService1 = new SEL_AsyncDmlService(recordsSet);
		dmlService1.executeDml(SEL_CoreConstants.DML_INSERT);

		// ASSERT
		System.assert([SELECT count() FROM Account WHERE Name =: 'executeDmlForInsert'] == 1, 'Record must be created');

		Test.stopTest();
	}

	@IsTest
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern')
	private static void executeDmlForUpdate()
	{
		Test.startTest();

		// DATA
		Account record = [SELECT Id FROM Account WHERE Name =: 'AsyncDmlService_ForUpdate' LIMIT 1];
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_UPDATE, SEL_Object__c = 'Account', SEL_Record__c = '{ "Description" : "Update", "Id" : "' + record.Id + '" }')
		};

		// TEST
		SEL_AsyncDmlService dmlService = new SEL_AsyncDmlService(recordsSet);
		dmlService.executeDml(SEL_CoreConstants.DML_UPDATE);
		
		// ASSERT
		System.assert([SELECT Description FROM Account WHERE Id =: record.Id LIMIT 1]?.Description.equalsIgnoreCase('update'), 'Record must be updated');

		Test.stopTest();
	}

	@IsTest
	@SuppressWarnings('PMD.SOQLSelectorPattern')
	private static void executeDmlForUpsert()
	{
		Test.startTest();

		// DATA
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_UPSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "executeDmlUpsertTest" }')
		};
		
		// TEST
		SEL_AsyncDmlService dmlService = new SEL_AsyncDmlService(recordsSet);
		dmlService.executeDml(SEL_CoreConstants.DML_UPSERT);

		// ASSERT
		System.assert([SELECT count() FROM Account WHERE Name =: 'executeDmlUpsertTest'] == 1, 'Record must be created');

		Test.stopTest();
	}

	@IsTest
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern')
	private static void executeDmlForDelete()
	{
		Test.startTest();
		
		// DATA FOR DELETE
		Account record = [SELECT Id FROM Account WHERE Name =: 'AsyncDmlService_ForDelete' LIMIT 1];
		SEL_AsyncDml__e event = new SEL_AsyncDml__e(
			SEL_Action__c = SEL_CoreConstants.DML_DELETE,
			SEL_Object__c = 'Account',
			SEL_Record__c = '{ "Id" : "' + record.Id + '" }'
		);

		// TEST 1
		SEL_AsyncDmlService dmlService1 = new SEL_AsyncDmlService(new List<SEL_AsyncDml__e>{ event });
		dmlService1.executeDml(SEL_CoreConstants.DML_DELETE);
		
		// ASSERT 1
		System.assert([SELECT IsDeleted FROM Account WHERE Id =: record.Id LIMIT 1 ALL ROWS]?.IsDeleted, 'Record must be deleted');

		// DATA FOR UNDELETE
		event.SEL_Action__c = SEL_CoreConstants.DML_UNDELETE;

		// TEST 2
		SEL_AsyncDmlService dmlService2 = new SEL_AsyncDmlService(new List<SEL_AsyncDml__e>{ event });
		dmlService2.executeDmls();

		// ASSERT 2
		System.assert([SELECT IsDeleted FROM Account WHERE Id =: record.Id LIMIT 1 ALL ROWS]?.IsDeleted == false, 'Record must be restored');

		Test.stopTest();
	}

	@IsTest
	private static void getConfiguration()
	{
		Test.startTest();

		// DATA
		List<SEL_AsyncDml__e> recordsSet = new List<SEL_AsyncDml__e>
		{
			new SEL_AsyncDml__e(SEL_Action__c = SEL_CoreConstants.DML_INSERT, SEL_Object__c = 'Account', SEL_Record__c = '{ "Name" : "getConfiguration" }')
		};

		// TEST
		SEL_AsyncDmlService dmlService = new SEL_AsyncDmlService(recordsSet);

		// ASSERT
		System.assert(dmlService.objectByConfig.size() == 1, 'There should be at least a single config');

		Test.stopTest();
	}
}