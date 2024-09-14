/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_CoreConstants.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0

Time (MS)		Method
23  			getUnitTest
-----------------------------------------------------------------------------*/
@IsTest 
public with sharing class SEL_CoreConstants_TEST 
{
	@IsTest 
	private static void getUnitTest()
	{
		System.assert(SEL_CoreConstants.getUnitTest().equalsIgnoreCase(SEL_CoreConstants.DML_INSERT), 'Added for test coverage');
	}
}