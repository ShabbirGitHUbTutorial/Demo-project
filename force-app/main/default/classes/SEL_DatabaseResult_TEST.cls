/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_DatabaseResult.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0

Time (MS)		Method
23  			getUnitTest
-----------------------------------------------------------------------------*/
@IsTest 
public with sharing class SEL_DatabaseResult_TEST 
{
	@IsTest
	private static void getUnitTest()
	{
		System.assert(SEL_DatabaseResult.getUnitTest(), 'Added for test coverage');
	}
}