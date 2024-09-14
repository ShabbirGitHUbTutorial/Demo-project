/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of SEL_LoggingServiceInvocable.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

Time (MS)		Method
338				log
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_LoggingServiceInvocable_TEST 
{
	@IsTest
	@SuppressWarnings('PMD.SOQLSelectorPattern')
	private static void log() 
	{
		Test.startTest();

		// DATA
		SEL_LoggingServiceInvocable.SEL_LoggingServiceRequest request = new SEL_LoggingServiceInvocable.SEL_LoggingServiceRequest();
		request.currentStage = 'Stage 1';
		request.faultMessage = 'Stacktrace';
		request.flowName = 'SEL_LoggingServiceInvocable_TEST';
		request.runningUserId = UserInfo.getUserId();

		// TEST
		SEL_LoggingServiceInvocable.log(new List<SEL_LoggingServiceInvocable.SEL_LoggingServiceRequest> { request });
		Test.stopTest();

		// ASSERT
		SEL_ApplicationLog__c log = [SELECT SEL_Source__c, SEL_Method__c, SEL_Message__c, SEL_Exception__c FROM SEL_ApplicationLog__c WHERE SEL_Source__c =: 'SEL_LoggingServiceInvocable_TEST' ORDER BY CreatedDate DESC LIMIT 1];
		System.assert(log.SEL_Method__c == 'Stage 1', 'The method name in the application log must be set to Stage 1');
		System.assert(log.SEL_Message__c == 'Stacktrace', 'The message in the application log must be set to Stacktrace');
		System.assert(log.SEL_Exception__c == 'FlowException', 'The type name in the application log must be set to FlowException');
	}
}