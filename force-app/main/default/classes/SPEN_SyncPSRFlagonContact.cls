/*-------------------------------------------------------------------------------------------------
DESCRIPTION	:	Batch to update the PSR flag on Contact from SPEN_PSRStaging__c records.
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
15/2/2023       Nitish Dharm
-------------------------------------------------------------------------------------------------*/
public with sharing class SPEN_SyncPSRFlagonContact  extends SEL_BatchStepBase implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents
{
	// BATCH FRAMEWORK
	// Do not remove or change.
	public Id batchParentId;
	public Id batchChildId;
	
	// OTHER VARIABLES
	public date adqmLoadDate;
	
	public SPEN_SyncPSRFlagonContact() 
	{
		// BATCH FRAMEWORK
		// Do nothing.
		return;
	}
	
	public SPEN_SyncPSRFlagonContact(Id batch, Id batchStep)
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
		return new SPEN_PSRStagingSelector().getQueryLocatorForSuccessful(adqmLoadDate);
	}
	
	public void execute(Database.BatchableContext bc, List<SPEN_PSRStaging__c> psrStageList)
	{	
		Set<String> customerIdSet = new Set<String>();
		List<Contact> contactList = new List<Contact>();
		
		for(SPEN_PSRStaging__c psrStgRec : psrStageList)
		{
			customerIdSet.add(psrStgRec.SPEN_PremiseID__c);
		}
		
		if(!customerIdSet.isEmpty())
		{
			List<Contact> lstContact = new SPEN_ContactSelector().getContactForSyncPSRFlag(customerIdSet);
            for(Contact asIs :lstContact)
			{
				Boolean isChanged = false;
				Contact toBe = new Contact(Id = asIs.Id);

				if(asIs.PSRs__r.size() > 0)
				{
					if(asIs.SPEN_PSR__c == false)
					{
						isChanged = true;
						toBe.SPEN_PSR__c = true;
					}
				}
				else
				{
					if(asIs.SPEN_PSR__c == true)
					{
						isChanged = true;
						toBe.SPEN_PSR__c = false;
					}
				}

				if(isChanged)
				{
					contactList.add(toBe);
				}
			}
		}
		if(!contactList.isEmpty())
		{
			update contactList;
		}
	}

	public void finish(Database.BatchableContext context) 
	{
		// BATCH FRAMEWORK
		// Do not remove or change.
		super.finishBatch(context, this.batchParentId, this.batchChildId);
	}
	
	// BATCH FRAMEWORK METHOD
	// This is a Batch Framework method that must be overridden so the framework
	// can run batches from the sequencing logic. 
	public override void executeBatch()
	{
		if(super.isValid())
		{
			SPEN_SyncPSRFlagonContact runMe = new SPEN_SyncPSRFlagonContact(super.batchId, super.batchStepId);
			Database.executeBatch(runMe, super.batchSize);
		}
		else 
		{
			// TODO: Throw Application Exception
			return;
		}
	}
}