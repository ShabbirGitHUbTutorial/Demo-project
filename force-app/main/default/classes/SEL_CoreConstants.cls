/*-----------------------------------------------------------------------------
DESCRIPTION	:	Constants file for Core Library
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
APR-21-2022		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SEL_CoreConstants 
{
	// DML
	public static final String DML_DELETE = 'delete';
	public static final String DML_INSERT = 'insert';
	public static final String DML_UNDELETE = 'undelete';
	public static final String DML_UPDATE = 'update';
	public static final String DML_UPSERT = 'upsert';

	@TestVisible
	private static String getUnitTest()
	{
		// IMPORTANT
		// This is added as the Salesforce Enteprise Library is currently lifted 
		// and shifted to client Salesforce orgs using a non-pakage based
		// deployments. Remove this once SEL transitions to unlocked packaging.

		return SEL_CoreConstants.DML_INSERT;
	}
}