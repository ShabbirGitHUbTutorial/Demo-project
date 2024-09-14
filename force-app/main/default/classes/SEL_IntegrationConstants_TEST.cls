/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SEL_IntegrationConstants_TEST.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0

Time (MS)		Method
23  			getUnitTest
-----------------------------------------------------------------------------*/
@IsTest 
public with sharing class SEL_IntegrationConstants_TEST 
{
	@IsTest 
	private static void getUnitTest()
	{
		System.assert(SEL_IntegrationConstants.getUnitTest().equalsIgnoreCase(SEL_IntegrationConstants.HEADER), 'Added for test coverage');
	}
}