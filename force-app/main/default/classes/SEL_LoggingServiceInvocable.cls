/*-----------------------------------------------------------------------------
DESCRIPTION	:	Invocable class of the Logging Service.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
AUG-09-2021		Macjules Sevilla	Initial version
AUG-27-2021		Macjules Sevilla	Fixed field mapping
JAN-14-2022		Macjules Sevilla	Added running user.
-----------------------------------------------------------------------------*/
public without sharing class SEL_LoggingServiceInvocable 
{
	// CONSTANTS
	private static final String FLOW_EXCEPTION = 'FlowException';
	private static final String STACKTRACE_FORMAT = 'Interview GUID: {0} \n Current Record: {1} \n Running User Role: {2} \n Fault Message: {3}';

	@InvocableMethod(label='Log Fault' category='Salesforce Enterprise Library')
	public static void log(List<SEL_LoggingServiceRequest> errors) 
	{
		if(errors == null || errors.isEmpty() || errors.size() == 0) { return; }

		SEL_LoggingService service = new SEL_LoggingService();

		for(SEL_LoggingServiceRequest ex : errors)
		{
			SEL_LoggingService.Message log = new SEL_LoggingService.Message();
			log.category = SEL_ApplicationLogs.TYPE_FLOW;
			log.exceptionType = SEL_LoggingServiceInvocable.FLOW_EXCEPTION;
			log.errorId = ex.interviewGuid;
			log.method = ex.currentStage;
			log.message = ex.faultMessage;
			log.source = ex.flowName;
			log.stacktrace = String.format(SEL_LoggingServiceInvocable.STACKTRACE_FORMAT, new List<Object> { ex.interviewGuid, ex.currentRecord, ex.userRole, ex.faultMessage });
			log.runningUser = String.isEmpty(ex.runningUserId) ? null : Id.valueOf(ex.runningUserId);

			service.messages.add(log);
		}

		service.publish();
	}

	public class SEL_LoggingServiceRequest
	{
		@InvocableVariable(label='Current Record (Use $Flow.CurrentRecord)' description='Map this to $Flow.CurrentRecord' required=false)
		public String currentRecord;
		
		@InvocableVariable(label='Current Stage (Use $Flow.CurrentStage)' description='Map this to $Flow.CurrentStage' required=false)
		public String currentStage;

		@InvocableVariable(label='Flow Name' description='Name of the flow' required=true)
		public String flowName;

		@InvocableVariable(label='Fault Messsage (Use $Flow.FaultMessage)' description='Map this to $Flow.FaultMessage' required=true)
		public String faultMessage;

		@InvocableVariable(label='Interview GUID (Use $Flow.InterviewGuid)' description='Map this to $Flow.InterviewGuid' required=true)
		public String interviewGuid;

		@InvocableVariable(label='Running User ID (Use $User.Id)' description='Map this to $User.Id' required=true)
		public String runningUserId;

		@InvocableVariable(label='User Role (Use $UserRole.Name)' description='Map this to $UserRole.Name' required=false)
		public String userRole;
	}
}