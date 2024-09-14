/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain class of the SEL_BatchStep__c custom object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SEL_BatchSteps
{
	// UNIT TEST WARNING
	// These variables are moved out their respective methods for unit testing purposes
	@TestVisible
	private static List<SEL_BatchStep__c> recordsOnBeforeInsert = new List<SEL_BatchStep__c>();
	@TestVisible
	private static Map<Id, Map<Id, String>> recordsOnAfterInsert = new Map<Id, Map<Id, String>>();
	@TestVisible
	private static Map<Id, SEL_BatchStep__c> recordsOnBeforeUpdate = new Map<Id, SEL_BatchStep__c>();
	@TestVisible
	private static Map<Id, Map<Id, String>> recordsOnAfterUpdate = new Map<Id, Map<Id, String>>();

	// TRIGGER HANDLER
	// Before Insert
	public static void onBeforeInsert(List<SEL_BatchStep__c> records)
	{
		for(SEL_BatchStep__c record : records)
		{
			// RULE
			// [1] Set the start date and time when status is set to Processing
			if(record.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
			{
				record.SEL_Start__c = Datetime.now();
			}
		}

		// UNIT TEST
		if(Test.isRunningTest() && records != null)
		{
			SEL_BatchSteps.recordsOnBeforeInsert.addAll(records);
		}
	}

	// TRIGGER HANDLER
	// After Insert
	public static void onAfterInsert(Map<Id, SEL_BatchStep__c> records)
	{
		Map<Id, Map<Id, String>> classByBatchStepIdByBatch = new Map<Id, Map<Id, String>>();

		// STEP 1
		// Get Processing
		for(SEL_BatchStep__c record : records.values())
		{
			// RULES
			// [1] Automatically run the batch step that's inserted with status of PROCESSING.
			// [2] Run only the first step per parent batch record, however this sorting is controlled elsewhere.
			if(	record.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING) && 
				!classByBatchStepIdByBatch.containsKey(record.SEL_BatchId__c))
			{
				classByBatchStepIdByBatch.put(record.SEL_BatchId__c, new Map<Id, String> { record.Id => record.SEL_Class__c });
			}
		}

		// STEP 2
		// Instantiate and run the corresponding batch
		SEL_BatchSteps.runBatch(classByBatchStepIdByBatch, records);

		// UNIT TEST
		if(Test.isRunningTest())
		{
			SEL_BatchSteps.recordsOnAfterInsert = classByBatchStepIdByBatch;
		}
	}

	// TRIGGER HANDLER
	// Before Update
	public static void onBeforeUpdate(Map<Id, SEL_BatchStep__c> oldMap, Map<Id, SEL_BatchStep__c> newMap)
	{
		for(Id i : newMap.keySet())
		{
			String newStatus = newMap.get(i).SEL_Status__c;
			String oldStatus = oldMap.get(i).SEL_Status__c;

			// RULE
			// [1] Set the stop date and time if the change is from PROCESSING to COMPLETED or FAILED only.
			if(	oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING) && (
				newStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_COMPLETED) ||
				newStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_FAILED)))
			{
				newMap.get(i).SEL_Stop__c = Datetime.now();
			}
			// RULE
			// [1] Reset the start AND empty stop if the change is from FAILED or NOT STARTED to PROCESSING only.
			else if((oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_FAILED) ||
					oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_NOT_STARTED)) &&
					newStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
			{
				newMap.get(i).SEL_Start__c = Datetime.now();
				newMap.get(i).SEL_Stop__c = null;
			}
		}
		
		// UNIT TEST
		if(Test.isRunningTest())
		{
			SEL_BatchSteps.recordsOnBeforeUpdate = newMap;
		}
	}

	// TRIGGER HANDLER
	// After Update
	public static void onAfterUpdate(Map<Id, SEL_BatchStep__c> oldMap, Map<Id, SEL_BatchStep__c> newMap)
	{
		Map<Id, Map<Id, String>> classByBatchStepIdByBatch = new Map<Id, Map<Id, String>>();

		// STEP 1
		// Get Processing
		for(SEL_BatchStep__c record : newMap.values())
		{
			String newStatus = record.SEL_Status__c;
			String oldStatus = oldMap.get(record.Id).SEL_Status__c;

			// RULES
			// [1] Run the batch step when the status is changed from FAILED or NOT STARTED to PROCESSING.
			if((oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_FAILED) ||
				oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_NOT_STARTED)) &&
				newStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
			{
				classByBatchStepIdByBatch.put(record.SEL_BatchId__c, new Map<Id, String> { record.Id => record.SEL_Class__c });
			}
		}

		// STEP 2
		// Instantiate and run the corresponding batch
		SEL_BatchSteps.runBatch(classByBatchStepIdByBatch, newMap);

		// UNIT TEST
		if(Test.isRunningTest())
		{
			SEL_BatchSteps.recordsOnAfterUpdate = classByBatchStepIdByBatch;
		}
	}

	// -------------------------------------------------------------------
	// -------------------------------------------------------------------
	// --------------------------OTHER METHODS----------------------------
	// -------------------------------------------------------------------
	// -------------------------------------------------------------------

	// DESCRIPTION
	// Run batches dynamically
	public static void runBatch(Map<Id, Map<Id, String>> classByBatchStepIdByBatch, Map<Id, SEL_BatchStep__c> records)
	{
		if(classByBatchStepIdByBatch == null || records == null || classByBatchStepIdByBatch.isEmpty() || records.isEmpty()) { return; }

		for(Id batchId : classByBatchStepIdByBatch.keySet())
		{
			Id batchStepId = new List<Id>(classByBatchStepIdByBatch.get(batchId).keySet()).get(0);
			String className = classByBatchStepIdByBatch.get(batchId).get(batchStepId);

			// UNIT TEST WARNING
			// Do not run any batch from unit tests
			if(!Test.isRunningTest())
			{
				// DYNAMIC RUN
				// Instantiate and run the batch that is specified in the Class__c field
				// on the BatchStep__c custom object.
				SEL_BatchStepBase step = (SEL_BatchStepBase) Type.forName(className).newInstance();
				step.batchId = batchId;
				step.batchStepId = batchStepId;
				step.batchSize = Integer.valueOf(records.get(batchStepId).SEL_batchSize__c);
				step.executeBatch();
			}
		}
	}

	// DESCRIPTION
	// Returns a list of BatchStep__c converted from BatchStepTemplate__mdt
	public static List<SEL_BatchStep__c> convert(List<SEL_BatchStepTemplate__mdt> steps, Id batchRunId, Boolean isFirstStepProcessing)
	{
		List<SEL_BatchStep__c> results = new List<SEL_BatchStep__c>();

		if(steps != null)
		{
			Integer index = 0;
			for(SEL_BatchStepTemplate__mdt step : steps)
			{
				SEL_BatchStep__c b = new SEL_BatchStep__c();
				b.SEL_BatchId__c = batchRunId;
				b.SEL_BatchSize__c = step.SEL_BatchSize__c;
				b.SEL_Class__c = step.SEL_Class__c;
				b.SEL_Sequence__c = step.SEL_Sequence__c;
				b.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;

				// PARAMETER
				// Set the first in the sequence to Processing to kick start the process.
				if(index == 0 && isFirstStepProcessing)
				{
					b.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
					index += 1;
				}

				results.add(b);
			}
		}

		return results;
	}

	// DESCRIPTION
	// Returns a list of BatchStep__c that will be changed to 'Processing'
	// as a result to its parent Batch__c record being changed to 'Processing' too. 
	// This is specifically useful from the Batch__c Domain Layer.
	public static List<SEL_BatchStep__c> setStatusToProcessing(Map<Id, String> statusByBatchId)
	{
		List<SEL_BatchStep__c> stepsToUpdate = new List<SEL_BatchStep__c>();
		List<SEL_Batch__c> batches = new SEL_BatchesSelector().selectByIdsByStatuses(statusByBatchId.keySet(), new Set<String>(statusByBatchId.values()));

		for(SEL_Batch__c batch : batches)
		{
			for(SEL_BatchStep__c step : batch.SEL_BatchSteps__r)
			{
				// NOTE
				// Pick up anything where the status is either FAILED or NOT STARTED
				// so it can be set to PROCESSING again
				if(step.SEL_Status__c?.equalsIgnoreCase(statusByBatchId.get(batch.Id)))
				{
					step.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
					stepsToUpdate.add(step);
					break;
				}
			}
		}

		return stepsToUpdate;
	}
}