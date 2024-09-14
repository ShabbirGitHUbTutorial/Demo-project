/*---------------------------------------------------------------------------------
DESCRIPTION	:	Domain layer of ApplicationLog__c object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
AUG-09-2021		Macjules Sevilla	Initial version
JAN-14-2022		Macjules Sevilla	Replaced getRecordTypeInfosByName.
APR-20-2022		Macjules Sevilla	Added Warning record type and Platform Event
---------------------------------------------------------------------------------*/
public with sharing class SEL_ApplicationLogs 
{
	// OBJECT INFORMATION
	public static final String OBJECT_API = 'SEL_ApplicationLog__c';

	// RECORD TYPES
	public static final Id RECORD_TYPE_ID_EXCEPTION	= Schema.SObjectType.SEL_ApplicationLog__c.getRecordTypeInfosByDeveloperName().get('Exception').getRecordTypeId();
	public static final Id RECORD_TYPE_ID_WARNING	= Schema.SObjectType.SEL_ApplicationLog__c.getRecordTypeInfosByDeveloperName().get('Warning').getRecordTypeId();

	// TYPES
	public static final String TYPE_APEX = 'Apex';
	public static final String TYPE_BATCH = 'Batch';
	public static final String TYPE_FLOW = 'Flow';
	public static final String TYPE_PLATFORM_EVENT = 'Platform Event';

	// MESSSAGE
	public static final String MESSAGE = 'Extended Status: {0} \n Status: {1} \n Number of Errors: {2} \n Batches Processed: {3} \n Total Batches: {4} \n Created By: {5}';

	@TestVisible
	private static String getUnitTest()
	{
		// IMPORTANT
		// This is added as the Salesforce Enteprise Library is currently lifted 
		// and shifted to client Salesforce orgs using a non-pakage based
		// deployments. Remove this once SEL transitions to unlocked packaging.

		return SEL_ApplicationLogs.OBJECT_API;
	}
}