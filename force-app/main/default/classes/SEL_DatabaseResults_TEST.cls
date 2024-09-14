/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_DatabaseResults.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0

Time (MS)		Method
94  			getExceptionsDeleteResult
135				getExceptionsSaveResult
44				getExceptionsUndeleteResult
62				getExceptionsUpsertResult
-----------------------------------------------------------------------------*/
@IsTest 
public with sharing class SEL_DatabaseResults_TEST 
{
	@IsTest
	private static void getExceptionsDeleteResult()
	{
		Test.startTest();

		// DATA
		// Create invalid data
		Id invalidId = UserInfo.getUserId().replaceFirst('005', '001');
		List<Account> sample = new List<Account>{ new Account(Id = invalidId, Name = 'Invalid') };

		// RUN
		Database.DeleteResult[] results = Database.delete(sample, false);
		List<SEL_DatabaseResult> exceptions = SEL_DatabaseResults.getExceptions(sample, results);

		// ASSERT
		System.assert(exceptions.size() == 1, 'Record delete must fail');
		System.assert(exceptions[0].statusCode.equalsIgnoreCase('INVALID_CROSS_REFERENCE_KEY'), 'The error must be INVALID_CROSS_REFERENCE_KEY');

		Test.stopTest();
	}

	@IsTest
	private static void getExceptionsSaveResult()
	{
		Test.startTest();

		// DATA. Create invalid data
		List<Contact> sample = new List<Contact>{ new Contact(FirstName = 'getExceptionsSaveResult') };

		// RUN
		Database.SaveResult[] results = Database.insert(sample, false);
		List<SEL_DatabaseResult> exceptions = SEL_DatabaseResults.getExceptions('insert', sample, results);

		// ASSERT
		System.assert(exceptions.size() == 1, 'Record insert must fail');
		System.assert(exceptions[0].statusCode.equalsIgnoreCase('REQUIRED_FIELD_MISSING'), 'The error must be REQUIRED_FIELD_MISSING');

		Test.stopTest();
	}

	@IsTest
	private static void getExceptionsUndeleteResult()
	{
		Test.startTest();

		// DATA. Create invalid data
		Id invalidId = UserInfo.getUserId().replaceFirst('005', '001');
		List<Account> sample = new List<Account>{ new Account(Id = invalidId) };

		// RUN
		Database.UndeleteResult[] results = Database.undelete(sample, false);
		List<SEL_DatabaseResult> exceptions = SEL_DatabaseResults.getExceptions(sample, results);

		// ASSERT
		System.assert(exceptions.size() == 1, 'Record undelete must fail');
		System.assert(exceptions[0].statusCode.equalsIgnoreCase('UNDELETE_FAILED'), 'The error must be UNDELETE_FAILED');

		Test.stopTest();
	}

	@IsTest
	private static void getExceptionsUpsertResult()
	{
		Test.startTest();

		// DATA. Create invalid data
		Id invalidId = UserInfo.getUserId().replaceFirst('005', '001');
		List<Account> sample = new List<Account>{ new Account(Id = invalidId) };

		// RUN
		Database.UpsertResult[] results = Database.upsert(sample, false);
		List<SEL_DatabaseResult> exceptions = SEL_DatabaseResults.getExceptions(sample, results);

		// ASSERT
		System.assert(exceptions.size() == 1, 'Record undelete must fail');
		System.assert(exceptions[0].statusCode.equalsIgnoreCase('INVALID_CROSS_REFERENCE_KEY'), 'The error must be INVALID_CROSS_REFERENCE_KEY');
		Test.stopTest();
	}
}