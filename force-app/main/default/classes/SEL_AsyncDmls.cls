/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain layer for SEL_AsyncDml trigger.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
FEB-04-2021		Macjules Sevilla	Initial version
FEB-07-2021		Macjules Sevilla	Added the convert methods.
-----------------------------------------------------------------------------*/
public with sharing class SEL_AsyncDmls 
{
	@TestVisible
	private Boolean isDmlExceptionThrown = false;

	// DESCRIPTION
	// This is the trigger handler for the AsyncDml__e Platform Event
	@SuppressWarnings('PMD.TestDoNotUseIsRunningTest, PMD.CodeBestPracticesTryCatchRaiseException')
	public void onAfterInsert(List<SEL_AsyncDml__e> records)
	{
		try 
		{
			// NOTE
			// The contents of this IF statement is purely for unit test purposes
			if(Test.isRunningTest() && isDmlExceptionThrown)
			{
				simulateDmlException();
			}

			// IMPORTANT
			// Batch size is configured through PlatformEventSubscriberConfig
			new SEL_AsyncDmlService(records).executeDmls();
		} 
		catch (DmlException ex) 
		{
			// NOTE
			// In case the trigger fails as a result of record locking then
			// let the trigger reprocess the transaction two more times.
			if(ex.getMessage().containsIgnoreCase(SEL_AsyncDmlConstants.ERROR_UNABLE_TO_LOCK_ROW))
			{
				Integer numberOfRetries = EventBus.TriggerContext.currentContext().retries;
				if (numberOfRetries < 3) 
				{
					// NOTE
					// Contents of the IF statement is only for unit test purposes
					if(Test.isRunningTest() && isDmlExceptionThrown)
					{
						throw ex;
					}
					throw new EventBus.RetryableException(String.format(SEL_AsyncDmlConstants.MESSAGE_RETRY, new List<object> { String.valueOf(numberOfRetries) }));
				}
			}
		}
	}

	// DESCRIPTION
	// This is used for unit test purposes only
	private void simulateDmlException()
	{
		throw new DmlException(SEL_AsyncDmlConstants.ERROR_UNABLE_TO_LOCK_ROW);
	}
}