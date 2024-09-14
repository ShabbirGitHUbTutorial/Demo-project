/*-----------------------------------------------------------------------------------------
DESCRIPTION	:	Unit test class for SEL_ApplicationLogs Domain class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
SEP-17-2022		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------------------*/
@IsTest
public with sharing class SEL_ApplicationLogs_TEST 
{
	@IsTest 
	private static void getUnitTest()
	{
		System.assert(SEL_ApplicationLogs.getUnitTest().equalsIgnoreCase(SEL_ApplicationLogs.OBJECT_API), 'Added for test coverage');
	}
}