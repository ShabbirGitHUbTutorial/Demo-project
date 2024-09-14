/*-----------------------------------------------------------------------------------------
DESCRIPTION	:	Unit test class for ApexErrorBatch and BatchApexError Trigger.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
NOV-11-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------------------*/
@IsTest
public with sharing class SEL_ApexErrorBatch_TEST 
{
	@IsTest
	@SuppressWarnings('PMD.EmptyCatchBlock, PMD.SOQLSelectorPattern')
	private static void apexErrorBatchTrigger() 
	{
		// TEST
		try 
		{
			Test.startTest();
			Database.executeBatch(new SEL_ApexErrorBatch());
			Test.stopTest();
		} 
		catch(Exception ex) 
		{
			// KEEP THIS SECTION EMPTY
		}
		
		// FORCE PLATFORM EVENT TO RUN
		Test.getEventBus().deliver();
		
		// ASSERT
		SEL_ApplicationLog__c log = [SELECT Id, SEL_Exception__c, SEL_Method__c FROM SEL_ApplicationLog__c WHERE SEL_Source__c =: 'SEL_ApexErrorBatch' LIMIT 1];
		//System.debug(log);
		System.assert(log.SEL_Exception__c.equalsIgnoreCase('MathException'), 'The exception must be set to MathException.');
		System.assert(log.SEL_Method__c.equalsIgnoreCase('EXECUTE'), 'The method must be set to EXECUTE.');
	}
}