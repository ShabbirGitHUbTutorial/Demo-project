/*-----------------------------------------------------------------------------
DESCRIPTION	:	Constants class for SEL_AsyncDml
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
FEB-04-2021		Macjules Sevilla	Initial version	
-----------------------------------------------------------------------------*/
public without sharing class SEL_AsyncDmlConstants 
{
	// APPLICATION LOG - RECORD TYPES
	public static final Id APPLICATION_LOG_RECORD_TYPE_ID_EXCEPTION = Schema.SObjectType.SEL_ApplicationLog__c.getRecordTypeInfosByDeveloperName().get('Exception').getRecordTypeId();
	public static final Id APPLICATION_LOG_RECORD_TYPE_ID_WARNING = Schema.SObjectType.SEL_ApplicationLog__c.getRecordTypeInfosByDeveloperName().get('Warning').getRecordTypeId();

	// APPLICATION LOG - TYPES
	public static final String TYPE_PLATFORM_EVENT = 'Platform Event';

	// ERRORS
	public static final String ERROR_UNABLE_TO_LOCK_ROW = 'UNABLE_TO_LOCK_ROW';

	// MESSAGES
	public static final String MESSAGE_EXCEPTION_TITLE = 'Asynchronous DML Exception';
	public static final String MESSAGE_INVALID = 'Invalid Event Message';
	public static final String MESSAGE_RETRY = 'The DML failed due to record locking. The system will try to reprocess the records again. Retry attempt {0}.';

	// OTHERS
	public static final String EVENT = 'SEL_AsyncDml__e';

	@TestVisible
	private static String getUnitTest()
	{
		// IMPORTANT
		// This is added as the Salesforce Enteprise Library is currently lifted 
		// and shifted to client Salesforce orgs using a non-pakage based
		// deployments. Remove this once SEL transitions to unlocked packaging.

		return SEL_AsyncDmlConstants.EVENT;
	}
}