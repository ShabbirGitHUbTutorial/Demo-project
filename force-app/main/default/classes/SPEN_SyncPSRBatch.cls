public with sharing class SPEN_SyncPSRBatch extends SEL_BatchStepBase implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents
{
	// BATCH FRAMEWORK
	// Do not remove or change.
	public Id batchParentId;
	public Id batchChildId;
	
	// OTHER VARIABLES
	public date adqmLoadDate;
	
	// CONSTANTS
	public final static String ACTION_DELETE = 'Delete';
	public final static String ACTION_NEW = 'New';
	public final static String ACTION_UPDATE = 'Update';

	public SPEN_SyncPSRBatch() 
	{
		// BATCH FRAMEWORK
		// Do nothing.
		return;
	}
	
	public SPEN_SyncPSRBatch(Id batch, Id batchStep)
	{
		// BATCH FRAMEWORK
		// Do not remove.
		this.batchParentId = batch;
		this.batchChildId = batchStep;

		// Get the load date
		List<SEL_Batch__c> results = new SEL_BatchesSelector().selectByIds(new Set<Id> { batch });
		if(!results.isEmpty() && results.size() == 1)
		{
			adqmLoadDate = results[0].SPEN_AdqmLoadDate__c;
		}
	}
	
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
		return new SPEN_PSRStagingSelector().getStageRecSyncPSRBatch(adqmLoadDate);
	}

	public void execute(Database.BatchableContext bc, List<SPEN_PSRStaging__c> psrStageList)
	{
		// Delete Variables
		Set<String> deletePsrPremiseIds = new Set<String>();
		Set<String> deleteVulnerabilityCodeIds = new Set<String>();
		Map<String, SPEN_PSRStaging__c> deletePremiseCodeCombination = new Map<String, SPEN_PSRStaging__c>();
		List<SPEN_PSRStaging__c> deletePsrStagingRecords = new List<SPEN_PSRStaging__c>();
		List<SPEN_PSR__c> deletePSRRecords = new List<SPEN_PSR__c>();

		// Upsert Variables
		Set<String> upsertPsrPremiseIds = new Set<String>();
		Map<String, SPEN_PSRStaging__c> upsertPremiseCodeCombination = new Map<String, SPEN_PSRStaging__c>();
		List<SPEN_PSRStaging__c> upsertPsrStagingRecords = new List<SPEN_PSRStaging__c>();
		
		for(SPEN_PSRStaging__c psrStagRec : psrStageList)
		{
			if(String.isNotBlank(psrStagRec.SPEN_ADQMAction__c) && psrStagRec.SPEN_ADQMAction__c.equalsIgnoreCase(ACTION_DELETE))
			{
				deletePsrPremiseIds.add(psrStagRec.SPEN_PremiseId__c);
				deleteVulnerabilityCodeIds.add(psrStagRec.SPEN_PsrVulnerabilityTypeId__c);
				deletePremiseCodeCombination.put(psrStagRec.SPEN_PremiseId__c + '-' + psrStagRec.SPEN_PsrVulnerabilityTypeId__c, psrStagRec);
			}
			else if(String.isNotBlank(psrStagRec.SPEN_ADQMAction__c) && (psrStagRec.SPEN_ADQMAction__c.equalsIgnoreCase(ACTION_NEW) || psrStagRec.SPEN_ADQMAction__c.equalsIgnoreCase(ACTION_UPDATE)))
			{
				upsertPsrPremiseIds.add(psrStagRec.SPEN_PremiseId__c);
				upsertPremiseCodeCombination.put(psrStagRec.SPEN_PremiseId__c + '-' + psrStagRec.SPEN_PsrVulnerabilityTypeId__c, psrStagRec);
			}
		}
		
		// STEP 1
		// Process Deletes
		
		if(!deletePsrPremiseIds.isEmpty())
		{
			// QUERY
			// Get all impacted PSRs; Note that some of these might not be up for deletion so another check is required.
			List<SPEN_PSR__c> deleteRecordsInScope = SPEN_PSRSelector.getPSRForSyncPSRBatch(deletePsrPremiseIds, deleteVulnerabilityCodeIds);
			
            // FILTER
			// Only delete the correct PSRs
			for(SPEN_PSR__c r : deleteRecordsInScope)
			{ 
				if(deletePremiseCodeCombination.containsKey(r.SPEN_Premise__r.SPEN_PremiseId__c + '-' + r.SPEN_PSRVulnerabilityType__r.SPEN_Code__c))
				{
					deletePSRRecords.add(r);
					deletePsrStagingRecords.add(deletePremiseCodeCombination.get(r.SPEN_Premise__r.SPEN_PremiseId__c + '-' + r.SPEN_PSRVulnerabilityType__r.SPEN_Code__c));
				}
			}
            
			// RUN DELETE
			if(!deletePSRRecords.isEmpty())
			{
				Integer deleteIndex = 0;

				Database.DeleteResult[] deleteResults = Database.delete(deletePSRRecords, false);
				for(Database.DeleteResult dr : deleteResults) 
				{
					if (dr.isSuccess()) 
					{
						deletePsrStagingRecords.get(deleteIndex).SPEN_SyncStatus__c = 'Successful';
					}
					else 
					{
						deletePsrStagingRecords.get(deleteIndex).SPEN_SyncStatus__c = 'Failed';
						deletePsrStagingRecords.get(deleteIndex).SPEN_SyncComment__c = dr.getErrors()[0].getMessage().left(255);
					}
					deleteIndex++;
				}

				update deletePsrStagingRecords;
			}
		}
		
		// STEP 2
		// Process Inserts
		if(!upsertPsrPremiseIds.isEmpty())
		{
			// POPULATE
			// Derive PSR updates
			Map<String, SPEN_PSR__c> upsertRecordsInScope = SPEN_SyncPSRBatchService.createSFPSR(upsertPremiseCodeCombination.values(), upsertPsrPremiseIds);

			// FILTER
			// Get the PSR Staging records to be updated in the same order as the Map values
			for(String key : upsertRecordsInScope.keySet())
			{
				if(upsertPremiseCodeCombination.containsKey(key))
				{
					upsertPsrStagingRecords.add(upsertPremiseCodeCombination.get(key));
				}
			}

			// RUN UPSERT
			if(!upsertRecordsInScope.isEmpty())
			{
				Integer upsertIndex = 0;

				Database.UpsertResult[] upsertResults = Database.upsert(upsertRecordsInScope.values(), SPEN_PSR__c.SPEN_PSRId__c, false);
				for (Database.UpsertResult sr : upsertResults)
				{
					if (sr.isSuccess())
					{
						upsertPsrStagingRecords.get(upsertIndex).SPEN_SyncStatus__c = 'Successful';
					} 
					else 
					{
						upsertPsrStagingRecords.get(upsertIndex).SPEN_SyncStatus__c = 'Failed';
						upsertPsrStagingRecords.get(upsertIndex).SPEN_SyncComment__c = sr.getErrors()[0].getMessage().left(255);
					}
					upsertIndex++;
				}

				update upsertPsrStagingRecords;
			}
		}
	}

	public void finish(Database.BatchableContext bc) 
	{
		super.finishBatch(bc, this.batchParentId, this.batchChildId);
	}

	// BATCH FRAMEWORK METHOD
	// This is a Batch Framework method that must be overridden so the framework
	// can run batches from the sequencing logic. 
	public override void executeBatch()
	{
		if(super.isValid())
		{
			SPEN_SyncPSRBatch runMe = new SPEN_SyncPSRBatch(super.batchId, super.batchStepId);
			Database.executeBatch(runMe, super.batchSize);
		}
		else 
		{
			// TODO: Throw Application Exception
			return;
		}
	}
}