/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain layer of Batch__c custom object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SEL_Batches 
{
	// TRIGGER HANDLER
	// After Insert
	public static void onAfterInsert(Map<Id, SEL_Batch__c> records)
	{
		List<SEL_BatchStep__c> stepsToInsert = new List<SEL_BatchStep__c>();

		// STEP 1
		// Grab all the step templates and group those by the batch template name
		Map<String, List<SEL_BatchStepTemplate__mdt>> steps = SEL_BatchStepTemplates.groupByTemplate(new SEL_BatchStepTemplatesSelector().selectByTemplate(SEL_Batches.getDistinctNames(records.values())));

		// STEP 2
		// Loop through all records and create the related steps
		for(SEL_Batch__c record : records.values())
		{
			stepsToInsert.addAll(SEL_BatchSteps.convert(steps.get(record.SEL_BatchTemplate__c), record.Id, record.SEL_Status__c.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING)));
		}
		
		// STEP 3
		// Create child records
		if(SEL_BatchStep__c.sObjectType.getDescribe().isCreateable())
		{
			insert stepsToInsert;
		}
	}

	// TRIGGER HANDLER
	// After Update
	public static void onAfterUpdate(Map<Id, SEL_Batch__c> oldMap, Map<Id, SEL_Batch__c> newMap)
	{
		Map<Id, String> transitionFromById = new Map<Id, String>();
		for(Id recordId : newMap.keySet())
		{
			// Focus is on status changes
			String oldStatus = oldMap.get(recordId).SEL_Status__c;
			String newStatus = newMap.get(recordId).SEL_Status__c;

			if(oldStatus != newStatus)
			{
				// TRANSITION 1
				// From "Not Started" to "Processing"
				if(oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_NOT_STARTED) && newStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
				{
					transitionFromById.put(recordId, oldStatus);
				}

				// TRANSITION 2
				// From "Failed" to "Processing"
				if(oldStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_FAILED) && newStatus.equalsIgnoreCase(SEL_BatchConstants.STATUS_PROCESSING))
				{
					transitionFromById.put(recordId, oldStatus);
				}
			}
		}

		if(transitionFromById.size() > 0)
		{
			// SET CHILD RECORD STATUS
			// By moving a SEL_Batch__c record to "Processing", the corresponding child
			// SEL_BatchStep__c record should also move to "Processing"
			update SEL_BatchSteps.setStatusToProcessing(transitionFromById);
		}
	}

	// DESCRIPTION
	// Returns a set of distinct batch names
	@TestVisible
	private static Set<String> getDistinctNames(List<SEL_Batch__c> records)
	{
		Set<String> batchNames = new Set<String>();
		for(SEL_Batch__c record : records) { batchNames.add(record.SEL_BatchTemplate__c); }
		return batchNames;
	}
}