/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_AsyncDmlConstants.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Async
VERSION		:	1.0

Time (MS)		Method
23  			getUnitTest
-----------------------------------------------------------------------------*/
@IsTest
public with sharing class SEL_AsyncDmlConstants_TEST 
{
	@IsTest 
	private static void getUnitTest()
	{
		System.assert(SEL_AsyncDmlConstants.getUnitTest().equalsIgnoreCase(SEL_AsyncDmlConstants.EVENT), 'Added for test coverage');
	}
}