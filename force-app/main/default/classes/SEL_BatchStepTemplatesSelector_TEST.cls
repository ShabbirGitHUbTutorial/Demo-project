/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SEL_BatchStepTemplate__mdt Selector class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

Time (MS)		Method
50  			selectByTemplate
-----------------------------------------------------------------------------*/
@IsTest
public without sharing class SEL_BatchStepTemplatesSelector_TEST 
{
	@IsTest
	private static void selectByTemplate() 
	{
		Test.startTest();

		// ERROR SCENARIO 1
		// Pass a null value
		System.assert(new SEL_BatchStepTemplatesSelector().selectByTemplate(null).isEmpty() == true, 'Passing null must return an empty list');

		// ERROR SCENARIO 2
		// Pass a non-existent value
		System.assert(new SEL_BatchStepTemplatesSelector().selectByTemplate(new Set<String> { 'DoesNotExist' }).isEmpty(), 'Passing a non-existent parameter must return an empty list');

		Test.stopTest();
	}
}