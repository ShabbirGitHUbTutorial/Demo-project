/*-----------------------------------------------------------------------------
DESCRIPTION	:	Wrapper class for Database.<DML>Result errors
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0
UNIT TEST	:	DatabaseResults_Test

HISTORY		:
Date			Author				Comment
APR-19-2022		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SEL_DatabaseResult 
{
	public string dml;
	public string fields;
	public string message;
	public string record;
	public string statusCode;

	@TestVisible
	private static Boolean getUnitTest()
	{
		// IMPORTANT
		// This is added as the Salesforce Enteprise Library is currently lifted 
		// and shifted to client Salesforce orgs using a non-pakage based
		// deployments. Remove this once SEL transitions to unlocked packaging.
		
		return true;
	}
}