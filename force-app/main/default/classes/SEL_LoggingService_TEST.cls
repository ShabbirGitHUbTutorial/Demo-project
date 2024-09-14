/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for Logging Service.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

Time (MS)		Method
262				ExceptionInfo
20 				logBatchApexErrorEvent
13 				save
-----------------------------------------------------------------------------*/
@IsTest
public with sharing class SEL_LoggingService_TEST 
{
	@IsTest
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern')
	private static void exceptionInfo() 
	{
		try 
		{
			throw new DmlException('Test Dml Error');    
		} 
		catch (Exception ex) 
		{
			Test.startTest();

			SEL_LoggingService.log(ex);

			Test.stopTest();   

			SEL_ApplicationLog__c log = [SELECT SEL_Source__c, SEL_Method__c, SEL_Message__c, SEL_Exception__c FROM SEL_ApplicationLog__c WHERE SEL_Source__c =: 'SEL_LoggingService_TEST' ORDER BY CreatedDate DESC LIMIT 1];
			System.assert(log.SEL_Method__c == 'exceptionInfo', 'The method name in the application log must be exceptionInfo');
			System.assert(log.SEL_Message__c == 'Test Dml Error', 'The message in the application log must be Test Dml Error');
			System.assert(log.SEL_Exception__c == 'DmlException', 'The type name in the application log must be DmlException');

			// NOTE
			// If there is a need to create the SELECTOR layer for application log objects, then move the SOQL above into that class
		} 
	}

	@IsTest
	@SuppressWarnings('PMD.CodeBestPracticesAvoidEmptyQueries, PMD.SOQLSelectorPattern')
	private static void logBatchApexErrorEvent()
	{
		Test.startTest();

		// TEST
		SEL_LoggingService.log(new List<BatchApexErrorEvent>());
		List<SEL_ApplicationLog__c> logs = [SELECT Id FROM	SEL_ApplicationLog__c WHERE RecordTypeId =: SEL_ApplicationLogs.RECORD_TYPE_ID_EXCEPTION];
		
		// NOTE
		// If there is a need to create the SELECTOR layer for application log objects, then move the SOQL above into that class

		// ASSERT
		System.assert(logs.isEmpty(), 'No application log record must be returned.');

		Test.stopTest();
	}

	@IsTest
	private static void save()
	{
		Test.startTest();

		try 
		{
			SEL_LoggingService log = new SEL_LoggingService();
			log.publish();
		} 
		catch (Exception ex) 
		{
			// ASSERT
			System.assert(ex.getTypeName().contains('IllegalArgumentException'), 'Calling the save button without parameters throws an exception.');
		}
		
		Test.stopTest();
	}
}