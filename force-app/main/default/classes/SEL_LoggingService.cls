/*-------------------------------------------------------------------------------------------
DESCRIPTION	:	Service layer for Logging services.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
FEB-11-2021		Macjules Sevilla	Initial version
AUG-27-2021		Macjules Sevilla	Added category field and support to BatchApexErrorEvent
JAN-14-2022		Macjules Sevilla	Added running user field.
-------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class SEL_LoggingService 
{
	// PROPERTIES
	public List<SEL_LoggingService.Message> messages = new List<SEL_LoggingService.Message>();

	// DESCRIPTION
	// Use this method to log an exception while defaulting the type to APEX
	public static void log(Exception ex)
	{
		SEL_LoggingService.log(ex, SEL_ApplicationLogs.TYPE_APEX);
	}

	// DESCRIPTION
	// Use this method to log an exception
	public static void log(Exception ex, String category)
	{
		if(ex == null) { return; }

		ExceptionInfo info = new ExceptionInfo(ex);

		SEL_LoggingService.Message log = new SEL_LoggingService.Message();
		log.category = category;
		log.exceptionType = info.exceptionType;
		log.runningUser = UserInfo.getUserId();
		log.source = info.className;
		log.stacktrace = ex.getStackTraceString();
		log.method = info.Method;
		log.message = ex.getMessage();

		SEL_LoggingService service = new SEL_LoggingService();
		service.messages.add(log);
		service.publish();
	}

	// DESCRIPTION
	// Use this method on BatchApexErrorEvent Platform Event ONLY. This is not using
	// custom platform event as this method is called from a platform event.
	@SuppressWarnings('PMD.TestDoNotUseIsRunningTest')
	public static void log(List<BatchApexErrorEvent> events)
	{
		if((events == null || events.isEmpty()) && !Test.isRunningTest()) { return; }

		List<SEL_ApplicationLog__c> logs = new List<SEL_ApplicationLog__c>();

		for(BatchApexErrorEvent e : events)
		{
			SEL_ApplicationLog__c log = new SEL_ApplicationLog__c(
				RecordTypeId = SEL_ApplicationLogs.RECORD_TYPE_ID_EXCEPTION,
				SEL_Category__c = SEL_ApplicationLogs.TYPE_BATCH,
				SEL_Details__c = 'JobScope: ' + e.JobScope + '/nRequestId: ' + e.RequestId?.left(50),
				SEL_ErrorId__c = e.AsyncApexJobId?.left(100),
				SEL_Exception__c = e.ExceptionType?.replace('System.', '').left(255),
				SEL_Message__c = e.Message.left(255),
				SEL_Method__c = e.Phase?.left(50),
				SEL_RunningUserId__c = UserInfo.getUserId(),
				SEL_Source__c = e.StackTrace.replace('Class.', '').substringBefore('.'),
				SEL_Stacktrace__c = e.StackTrace
			);
			logs.add(log);
		}

		if(Schema.sObjectType.SEL_ApplicationLog__c.isCreateable())
		{
			insert logs;
		}
	}
	public static void log(String category, String className,String methodName,String message)
	{

		SEL_LoggingService.Message log = new SEL_LoggingService.Message();
		log.category = category;
		//log.exceptionType = info.exceptionType;
		log.runningUser = UserInfo.getUserId();
		log.source = className;
		log.stacktrace = message;
		log.method = methodName;
		log.message = message;

		SEL_LoggingService service = new SEL_LoggingService();
		service.messages.add(log);
		service.publish();
	}
	
	// DESCRIPTION
	// Save the ApplicationLog via platform event
	public void publish()
	{
		if(messages.size() > 0)
		{
			List<SEL_AsyncDml__e> events = new List<SEL_AsyncDml__e>();

			for(SEL_LoggingService.Message m : this.messages)
			{
				// Write exception details to Application Log
				SEL_ApplicationLog__c log = new SEL_ApplicationLog__c(
					RecordTypeId = SEL_ApplicationLogs.RECORD_TYPE_ID_EXCEPTION,
					SEL_Category__c = m?.category,
					SEL_ErrorId__c = m?.errorId?.left(100),
					SEL_Exception__c = m?.exceptionType?.left(255),
					SEL_Message__c = m?.message?.left(255),
					SEL_Method__c = m?.method?.left(50),
					SEL_RunningUserId__c = m?.runningUser,
					SEL_Source__c = m?.source?.left(50),
					SEL_Stacktrace__c = m?.stacktrace
				);

				// Platform Event to issue DML
				SEL_AsyncDml__e event = new SEL_AsyncDml__e(
					SEL_Action__c = SEL_CoreConstants.DML_INSERT,
					SEL_Object__c = SEL_ApplicationLogs.OBJECT_API,
					SEL_Record__c = JSON.serialize(log)
				);
				events.add(event);
			}

			Eventbus.publish(events);
		}
	}

	// DESCRIPTION
	// Detects the class, method, and exception type from Exception class
	@TestVisible
	private without sharing class ExceptionInfo
	{
		public String className { get; private set; }
		public String method { get; private set; }
		public String exceptionType { get; private set; }

		public ExceptionInfo(Exception ex)
		{
			String classAndMethod = ex.getStackTraceString().substringBefore(':').replace('Class.', '');
			this.className = classAndMethod.substringBefore('.');
			this.method = classAndMethod.substringAfter('.');
			this.exceptionType = ex.getTypeName().replace('System.', '');
		}
	}

	// CLASS
	// Wrapper class containing all data fields to log
	public without sharing class Message
	{
		public Id runningUser { get; set; }
		public String category { get; set; }
		public String errorId { get; set; }
		public String exceptionType { get; set; }
		public String source { get; set; }
		public String stacktrace { get; set; }
		public String method { get; set; }
		public String message { get; set; }
	}
}