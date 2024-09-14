public with sharing class SPEN_SyncContactsBatch  extends SEL_BatchStepBase implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents
{
	// BATCH FRAMEWORK
	// Do not remove or change.
	public Id batchParentId;
	public Id batchChildId;
	
	// OTHER VARIABLES
	public date adqmLoadDate;

	public SPEN_SyncContactsBatch() 
	{
		// BATCH FRAMEWORK
		// Do nothing.
		return;
	}

	public SPEN_SyncContactsBatch(Id batch, Id batchStep)
	{
		// BATCH FRAMEWORK
		// Do not remove.
		this.batchParentId = batch;
		this.batchChildId = batchStep;
		
		// Get the ADQM Load Date to process
		List<SEL_Batch__c> results = new SEL_BatchesSelector().selectByIds(new Set<Id> { batch });
		if(!results.isEmpty() && results.size() == 1)
		{
			adqmLoadDate = results[0].SPEN_AdqmLoadDate__c;
		}
	}
	
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		return new SPEN_ContactStagingSelector().getStageRecForContSync(adqmLoadDate);
	}
	
	public void execute(Database.BatchableContext bc, List<SPEN_ContactStaging__c> conStageList)
	{	
		List<SPEN_ContactStaging__c> contactsToBeInserted = new List<SPEN_ContactStaging__c>();
		List<SPEN_ContactStaging__c> contactsToBeUpdated = new List<SPEN_ContactStaging__c>();
		List<SPEN_ContactStaging__c> contactsToBeDeleted = new List<SPEN_ContactStaging__c>();
		
		Set<String> contactsUpdateUniq = new Set<String>();
		Set<String> contactsToBeDeletedId = new Set<String>();
	
		for(SPEN_ContactStaging__c conStagRec : conStageList)
		{
			if(conStagRec.SPEN_AdqmAction__c.equalsIgnoreCase('Delete'))
			{
				contactsToBeDeletedId.add(conStagRec.SPEN_ExternalId__c);
				contactsToBeDeleted.add(conStagRec);
			}
			else if(conStagRec.SPEN_AdqmAction__c.equalsIgnoreCase('New') || conStagRec.SPEN_AdqmAction__c.equalsIgnoreCase('Update'))
			{
				contactsToBeInserted.add(conStagRec);
			}
		}

		// Write the correct status and populate the status comment if there is an error
		if(!contactsToBeInserted.isEmpty())
			SPEN_SyncContactsBatchService.createSFContact(contactsToBeInserted);
		if(!contactsToBeDeleted.isEmpty())
			SPEN_SyncContactsBatchService.deleteSyncProcess(contactsToBeDeletedId,contactsToBeDeleted);
		
		
	}
	public void finish(Database.BatchableContext context) 
	{
		super.finishBatch(context, this.batchParentId, this.batchChildId);
	}
	public override void executeBatch()
	{
		if(super.isValid())
		{
			SPEN_SyncContactsBatch runMe = new SPEN_SyncContactsBatch(super.batchId, super.batchStepId);
			Database.executeBatch(runMe, super.batchSize);
		}
		else 
		{
			// TODO: Throw Application Exception
			return;
		}
	}
}