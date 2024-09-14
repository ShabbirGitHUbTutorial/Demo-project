/*-----------------------------------------------------------------------------
DESCRIPTION	:	Abstract class for batches ran from the Batch Framework.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing abstract class SEL_BatchStepBase 
{
	public Id batchId;
	public Id batchStepId;
	public Integer batchSize = 201;
	public static final String SUMMARY = 'Job Id: {0} \n Number of Errors: {1} \n Batches Processed: {2} \n Total Batches: {3} \n Created By: {4}';

	// UNIT TEST
	// These are variables that were pushed out from methods so it can be
	// accessibled and manipulated in unit test classes.
	@TestVisible
	private AsyncApexJob jobInfo = null;
	@TestVisible
	private DateTime jobCompletedDate;
	@TestVisible
	private String jobExtendedStatus;
	@TestVisible
	private String jobStatus;
	@TestVisible
	private Integer jobFailures = 0;

	// DESCRIPTION
	// Must be overwritten in the implementation class so it can be called from
	// the APEX trigger handler of BatchStep__c custom object.
	public virtual void executeBatch()
	{
		throw new HandledException('Execute batch must be overridden.');
	}

	// DESCRIPTION
	// Returns true if both the BatchId and BatchStepId are populated
	public Boolean isValid()
	{
		if(batchId == null || batchStepId == null) { return false; }
		return true;
	}

	// DESCRIPTION
	// This must be ran explicitly from the BatchStepBase batch implementation.
	public void finishBatch(Database.BatchableContext context, Id parentId, Id childId) 
	{
		Boolean isNextStepFound = false;
		Integer numberOfIncompleteSteps = 0;
		String formattedSummary = '';
		List<sObject> recordsToUpdate = new List<sObject>();
		
		// UNIT TEST WARNING
		// Skip the query if the method is being run from test classes
		if(!Test.isRunningTest())
		{
			jobInfo = new SEL_AsyncApexJobsSelector().selectByJobIds(new Set<Id> { context.getJobId() })?.get(0);
			formattedSummary = jobInfo == null ? '' : String.format(SEL_BatchStepBase.SUMMARY, new List<Object> { jobInfo.Id, jobInfo.NumberOfErrors, jobInfo.JobItemsProcessed, jobInfo.TotalJobItems, jobInfo.CreatedBy.Email });
			
			// NOTE
			// These are moved to class-level variables for unit testing purposes
			jobCompletedDate = jobInfo.CompletedDate;
			jobExtendedStatus = jobInfo.ExtendedStatus;
			jobFailures = jobInfo.NumberOfErrors;
			jobStatus = jobInfo.Status;
		}

		// RULE
		// If the current batch failed, THEN do the following
		// [1] Set the status of the BatchStep__c to FAILED
		// [2] Set the status of the parent Batch__c to FAILED 
		if(jobFailures > 0)
		{
			// [1]
			SEL_BatchStep__c step = new SEL_BatchStep__c(
				SEL_ErrorMessage__c = jobExtendedStatus,
				Id = childId, 
				SEL_Status__c = SEL_BatchConstants.STATUS_FAILED, 
				SEL_Stop__c = jobCompletedDate,
				SEL_Summary__c = formattedSummary);
			recordsToUpdate.add(step);

			// [2]
			SEL_Batch__c batchToFail = new SEL_Batch__c(Id = parentId, SEL_Status__c = SEL_BatchConstants.STATUS_FAILED);
			recordsToUpdate.add(batchToFail);
		}
		// RULE 
		// GIVEN that the batch completed, THEN do the following:
		// [1] Set the status of the BatchStep__c to COMPLETED
		// [2] Run the next BatchStep__c in the sequence that is set to NOT STARTED
		// [3] However, if there is nothing left then set the parent Batch__c status to COMPLETED
		else if (jobFailures == 0)
		{
			// [1]
			SEL_BatchStep__c step = new SEL_BatchStep__c(
				Id = childId, 
				SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED, 
				SEL_Stop__c = jobCompletedDate,
				SEL_Summary__c = formattedSummary);
			recordsToUpdate.add(step);

			for(SEL_BatchStep__c next : new SEL_BatchStepsSelector().selectByBatchId(parentId))
			{
				// Bypass the current BatchStep__c
				if(next.Id == childId) { continue; }

				// [2]
				if(next.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_NOT_STARTED) && isNextStepFound == false)
				{
					next.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
					recordsToUpdate.add(next);
					isNextStepFound = true;
				}

				// [3]
				if(	next.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_FAILED) || 
					next.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_NOT_STARTED) || 
					next.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
				{
					numberOfIncompleteSteps += 1;
				}
			}

			// [3] 
			if(numberOfIncompleteSteps == 0)
			{
				SEL_Batch__c batchToClose = new SEL_Batch__c(Id = parentId, SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED);
				recordsToUpdate.add(batchToClose);
			}
			else if(isNextStepFound)
			{
				// RULE
				// [1] Set the parent to PROCESSING only if its not already in PROCESSING
				List<SEL_Batch__c> batchToClose = new SEL_BatchesSelector().selectByIds(new Set<Id> { parentId });
				if(!batchToClose?.get(0).SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING)) 
				{
					recordsToUpdate.add(new SEL_Batch__c(Id = parentId, SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING));
				}
			}
		}

		// Update the status fields
		if(	recordsToUpdate.size() > 0 && 
			SEL_Batch__c.sObjectType.getDescribe().isUpdateable() && 
			SEL_BatchStep__c.sObjectType.getDescribe().isUpdateable()) 
		{ 
			update recordsToUpdate; 
		}
	}
}