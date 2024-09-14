/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the AsyncApexJobs Selector Class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Common
VERSION		:	1.0

Time (MS)		Method
50  			selectByJobIds
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_AsyncApexJobsSelector_TEST 
{
	@IsTest
	private static void selectByJobIds() 
	{
		// ERROR SCENARIO
		// Pass a null value
		System.assert(new SEL_AsyncApexJobsSelector().selectByJobIds(null).isEmpty(), 'Passing a null or empty parameter must return a empty list.');

		Test.startTest();

		// ERROR SCENARIO
		// Pass a non-existent ID
		Set<Id> input = new Set<Id> { UserInfo.getUserId() };
		System.assert(new SEL_AsyncApexJobsSelector().selectByJobIds(input).isEmpty(), 'Passing a non-existent ID returns an empty list.');

		Test.stopTest();
	}
}