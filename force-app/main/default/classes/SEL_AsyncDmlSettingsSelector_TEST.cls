/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of SEL_AsyncDmlSettingsSelector
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Asynchronous DML Framework
VERSION		:	2.0

Time (MS)		Method
64  			selectByObjectApisByStatus
-----------------------------------------------------------------------------*/
@IsTest
public with sharing class SEL_AsyncDmlSettingsSelector_TEST 
{
	@IsTest
	@SuppressWarnings('PMD.SOQLSelectorPattern')
	private static void selectByObjectApisByStatus()
	{
		Test.startTest();

		// ERROR SCENARIO. Pass a null parameter
		List<SEL_AsyncDmlSetting__mdt> config1 = new SEL_AsyncDmlSettingsSelector().selectByObjectApisByStatus(null, false);
		System.assert(config1.size() == 0, 'Passing null will result to an empty list.');

		// ERROR SCENARIO. Pass a non-existent object API
		List<SEL_AsyncDmlSetting__mdt> config2 = new SEL_AsyncDmlSettingsSelector().selectByObjectApisByStatus(new Set<String> { 'RandomObj__c' }, null);
		System.assert(config2.size() == 0, 'Passing a non-existent object API will result to an empty list.');

		Test.stopTest();
	}
}