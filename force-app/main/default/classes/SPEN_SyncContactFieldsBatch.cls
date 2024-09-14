/*-------------------------------------------------------------------------------------------------
DESCRIPTION	:	Move contact number and email changes from SPEN_ContactNumberEmailStaging__c to 
				the Contact standard object.
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
15/2/2023		Asmita Rajput
-------------------------------------------------------------------------------------------------*/
public with sharing class SPEN_SyncContactFieldsBatch extends SEL_BatchStepBase implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents
{
	// BATCH FRAMEWORK
	// Do not remove or change.
	public Id batchParentId;
	public Id batchChildId;
	
	// OTHER VARIABLES
	public date adqmLoadDate;
	
	public SPEN_SyncContactFieldsBatch() 
	{
		// BATCH FRAMEWORK
		// Do nothing.
		return;
	}
	
	public SPEN_SyncContactFieldsBatch(Id batch, Id batchStep)
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
		return new SPEN_ContactStagingSelector().getQueryLocatorForNotStartedAndFailed(adqmLoadDate);
	}
	
	public void execute(Database.BatchableContext bc, List<SPEN_ContactNumberEmailStaging__c> lstContStaging)
	{
		List<Contact> contList = new List<Contact>();
		List<Contact> contUpdateList = new List<Contact>();
		Map<Id,Contact> contactUpdateMap = new Map<Id,Contact>();
		Set<String> setExternalId = new Set<String>();
		Map<String, Contact> mapCustId2Contact = new Map<String,Contact>();
		Map<String, List<SPEN_ContactNumberEmailStaging__c>> mapContId2ListStageRec = new Map<String,List<SPEN_ContactNumberEmailStaging__c>>();
		List<SPEN_ContactNumberEmailStaging__c> tempList;
		List<SPEN_ContactNumberEmailStaging__c> stageRecUpdateList = new List<SPEN_ContactNumberEmailStaging__c>();

		for(SPEN_ContactNumberEmailStaging__c staging : lstContStaging)
		{
			setExternalId.add(staging.SPEN_ExternalId__c);
		}

		if(!setExternalId.isEmpty())
		{
			contList = SPEN_ContactSelector.getContactsByCustomerId(setExternalId);
			if(!contList.isEmpty())
			{
				for(Contact c: contList)
				{
					mapCustId2Contact.put(c.SPEN_CustomerID__c, c);
				}
			}
			
			// RULE
			// Update the record only when there is a change coming from ADQM
			for(SPEN_ContactNumberEmailStaging__c staging : lstContStaging)
			{
				Boolean isChanged = false;
				Contact asIs = mapCustId2Contact.get(staging.SPEN_ExternalId__c);
                Contact toBe = new Contact();
                //Contact toBe = new Contact(Id = asIs.Id);
				if(asIs != null)
				{
					if(!contactUpdateMap.containsKey(asIs.Id))
					{
						toBe.Id = asIs.Id;
					}
					else{
						toBe = contactUpdateMap.get(asIs.Id);
					}
					contactUpdateMap.put(asIs.Id,toBe);
	
					if(staging.SPEN_Type__c.equalsIgnoreCase('Email') &&
					staging.SPEN_NumberOrEmail__c != asIs.Email)
					{
						//isChanged = true;
						toBe.Email = staging.SPEN_NumberOrEmail__c;
					}
					else if(staging.SPEN_Type__c.equalsIgnoreCase('Mobile') &&
					staging.SPEN_NumberOrEmail__c != asIs.MobilePhone)
					{
						//isChanged = true;
						toBe.MobilePhone = staging.SPEN_NumberOrEmail__c;
					}
					else if(staging.SPEN_Type__c.equalsIgnoreCase('Other') &&
					staging.SPEN_NumberOrEmail__c != asIs.OtherPhone)
					{
						//isChanged = true;
						toBe.OtherPhone = staging.SPEN_NumberOrEmail__c;
					}
					else if(staging.SPEN_Type__c.equalsIgnoreCase('Home') &&
					staging.SPEN_NumberOrEmail__c != asIs.Phone)
					{
						//isChanged = true;
						toBe.Phone = staging.SPEN_NumberOrEmail__c;
					}
	
					//if(isChanged)
					//{
						if(mapContId2ListStageRec.containsKey(asIs.Id))
						{
							mapContId2ListStageRec.get(toBe.Id).add(staging);
						}
						else
						{
							mapContId2ListStageRec.put(toBe.Id, new List<SPEN_ContactNumberEmailStaging__c> { staging });
						}
						if(!contUpdateList.contains(toBe))
						{
							contUpdateList.add(toBe);
						}
					//}
				}
				
			}
		}
		//system.debug('***contUpdateList**' +contUpdateList);	
		// COMMIT
		// Changes to both Contact and ContactNumberEmailStaging objects
		if(!contUpdateList.isEmpty())
		{
			Database.SaveResult[] srList = Database.update(contUpdateList, false);
			
			for (Database.SaveResult sr : srList) 
			{
				tempList = mapContId2ListStageRec.get(sr.getId());
				if (sr.isSuccess()) 
				{
					for(SPEN_ContactNumberEmailStaging__c stageRec : tempList)
					{
						stageRec.SPEN_SyncStatus__c = 'Successful';
					}
				}
				else 
				{
					for(SPEN_ContactNumberEmailStaging__c stageRec : tempList)
					{
						stageRec.SPEN_SyncStatus__c = 'Failed';
					}
				}
				stageRecUpdateList.addAll(tempList);
			}
			
			if(!stageRecUpdateList.isEmpty())
			{
				update stageRecUpdateList;
			}
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
			SPEN_SyncContactFieldsBatch runMe = new SPEN_SyncContactFieldsBatch(super.batchId, super.batchStepId);
			Database.executeBatch(runMe, super.batchSize);
		}
		else 
		{
			// TODO: Throw Application Exception
			return;
		}
	}
}