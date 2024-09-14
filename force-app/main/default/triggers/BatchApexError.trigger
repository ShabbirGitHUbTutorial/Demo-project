/*-----------------------------------------------------------------------------
DESCRIPTION	:	Batch error logging using Database.RaisesPlatformEvents.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	1.4

HISTORY		:
Date			Author				Comment
AUG-30-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
trigger BatchApexError on BatchApexErrorEvent (after insert) 
{
	SEL_LoggingService.log(Trigger.New);
}