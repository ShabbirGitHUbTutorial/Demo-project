public with sharing class SPEN_SyncContactsBatchService 
{
	/**
	 * @description Delete the contact and contact premise records
	 */	
	public static void deleteSyncProcess(Set<String> conUniqueIds,  List<SPEN_ContactStaging__c> conStgRecList)
	{
		List<Contact> conToBeDeleted = new List<Contact>();
		Map<String,String> mapCustId2ConId = new Map<String,String>();
		Set<String> setSuccessContId = new Set<String>();
		conToBeDeleted = SPEN_ContactSelector.getIdForSyncContactsBatchService(conUniqueIds);
		List<SPEN_ContactPremise__c> conPremisedToBeDeleted = new List<SPEN_ContactPremise__c>();
		
		if(!conToBeDeleted.isEmpty())
		{
			for(Contact con: conToBeDeleted)
			{
				mapCustId2ConId.put(con.SPEN_CustomerID__c,con.Id);
			}
			conPremisedToBeDeleted = new SPEN_ContactPremisesSelector().selectByCustomerContactExternalId(new set<String>(mapCustId2ConId.values()));
			if(!conPremisedToBeDeleted.isEmpty())
			{
				Database.delete(conPremisedToBeDeleted,false);
			}
			Database.DeleteResult[] drList = Database.delete(conToBeDeleted, false);
			for (Database.DeleteResult dr : drList) 
			{
				if (dr.isSuccess()) 
				{
					setSuccessContId.add(dr.getId());
				}
			}
			for(SPEN_ContactStaging__c conStgRec : conStgRecList)
			{
				if(setSuccessContId.contains(mapCustId2ConId.get(conStgRec.SPEN_ExternalId__c)))
				{
					conStgRec.SPEN_SyncStatus__c = 'Successful';
				}
				else {
					conStgRec.SPEN_SyncStatus__c = 'Failed';
				}
			}
			update conStgRecList;
		} 
	}

	/**
	 * @description Creates the Account and Contact records from SPEN_ContactStaging__c
	 */
	public static void createSFContact(List<SPEN_ContactStaging__c> conStgRecList)
	{
		List<Account> accountsToBeCreated = new List<Account>();
		List<Contact> conRecList = new List<Contact>();
		Id customerRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SPEN_Contact').getRecordTypeId();
		Id otherRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SPEN_Other_Contact').getRecordTypeId();
		Map<String,SPEN_ContactStaging__c> mapContId2StageRec = new Map<String,SPEN_ContactStaging__c>();
		List<SPEN_ContactPremise__c> lstConPremise = new List<SPEN_ContactPremise__c>();
		Map<String,SPEN_Premise__c> mapContId2Premise = new Map<String,SPEN_Premise__c>();
		Set<String> setPremiseId = new Set<String>();
		List<SPEN_Premise__c> lstPremise = new List<SPEN_Premise__c>();
		Set<String> setContactCustId = new Set<String>();
		Set<String> setSuccessContId = new Set<String>();
		List<Contact> lstSucccessContact = new List<Contact>();

		for(SPEN_ContactStaging__c conStgRec : conStgRecList)
		{
			setPremiseId.add(conStgRec.SPEN_PremiseId__c);

			Contact conRec = new Contact();
			conRec.FirstName = conStgRec.SPEN_FirstName__c;

			if(conStgRec.SPEN_AdqmSource__c.equalsIgnoreCase('Customer'))
			{
				conRec.SPEN_IsPrimaryContact__c = true;
				conRec.RecordTypeId = customerRecTypeId;
			}
			else
			{
				conRec.RecordTypeId = otherRecTypeId;
			}
            
            // BUSINESS RULE
            // If a new Customer is created in ADQM, then create a corresponding Account first
            if(!string.isEmpty(conStgRec.SPEN_PremiseId__c)){
                Account tempAccount = new Account(Name = conStgRec.SPEN_PremiseId__c, SPEN_ExternalID__c = conStgRec.SPEN_PremiseId__c);
                if(!accountsToBeCreated.contains(tempAccount))
                    accountsToBeCreated.add(tempAccount);
            }
            
            
			Account accountReference = new Account(SPEN_ExternalID__c = conStgRec.SPEN_PremiseId__c);
			conRec.Account = accountReference;
			conRec.LastName = conStgRec.SPEN_LastName__c;
			conRec.SPEN_CustomerID__c = conStgRec.SPEN_ExternalId__c;
			conRec.Salutation = conStgRec.SPEN_Salutation__c;
			conRec.SPEN_Initials__c = conStgRec.SPEN_Initials__c;
			conRec.SPENAdqmLastSyncDateTime__c = conStgRec.SPEN_AdqmLastModifiedDateTime__c;
			conRecList.add(conRec);
			mapContId2StageRec.put(conRec.SPEN_CustomerID__c,conStgRec);
		}
		//system.debug('conRecList >>' + conRecList);
		//Create Contact Premise
		if(!setPremiseId.isEmpty())
		{
			lstPremise = SPEN_PremisesSelector.premDetailsForSyncContactsBatchService(setPremiseId);
		}
		if(!lstPremise.isEmpty())
		{
			for(SPEN_Premise__c prm: lstPremise)
			{
				for(SPEN_ContactStaging__c conStgRec: conStgRecList)
				{
					if(conStgRec.SPEN_PremiseId__c == prm.SPEN_PremiseID__c)
					{ 
						 mapContId2Premise.put(conStgRec.SPEN_ExternalId__c,prm);
					}
				}
			}
		}                                   
		if(!conRecList.isEmpty())
		{
			// STEP 1
			// Create the Account records for new customers
			//system.debug('accountsToBeCreated >>' +accountsToBeCreated);
			if(!accountsToBeCreated.isEmpty())
			{
				upsert accountsToBeCreated SPEN_ExternalID__c;
			}
			
			// STEP 2
			// Insert the Contacts
			Database.UpsertResult[] srList = Database.upsert(conRecList, contact.SPEN_CustomerID__c,false);
			for (Database.UpsertResult sr : srList) 
			{
				if (sr.isSuccess()) 
				{
					setSuccessContId.add(sr.getId());
				}
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Contact Record has failed :' + err.getStatusCode() + ': ' + err.getMessage());                    
                    }
                }
            }
			lstSucccessContact = new SPEN_ContactSelector().getSuccessContactsForbatch(setSuccessContId);
			
			if(!lstSucccessContact.isEmpty())
			{
				for(Contact con: lstSucccessContact)
				{
					setContactCustId.add(con.SPEN_CustomerID__c);
					SPEN_ContactStaging__c stageRec= mapContId2StageRec.get(con.SPEN_CustomerID__c);
					if(stageRec.SPEN_AdqmAction__c.equalsIgnoreCase('New'))
					{
						
						SPEN_ContactPremise__c conPre = new SPEN_ContactPremise__c();
						conPre.SPEN_RelatedContact__c = con.Id;
						conPre.SPEN_PremisePrimaryContact__c  = con.SPEN_IsPrimaryContact__c;
						// IMPORTANT
						// This is a mapping exception as the API between staging and contact premise 
						// records are out of sync when the value is PSR Contact (PSR)
						conPre.SPEN_Role__c = stageRec?.SPEN_ContactType__c.equalsIgnoreCase('PSR Contact (Primary)') ? 'PSR Contact' : stageRec.SPEN_ContactType__c;
						conPre.SPEN_Premise__c = mapContId2Premise.get(con.SPEN_CustomerID__c).id;
	
						lstConPremise.add(conPre);
					}
					
				}
				//system.debug('lstConPremise >>' + lstConPremise);
				if(!lstConPremise.isEmpty()) 
				{
					//upsert lstConPremise;
					Database.UpsertResult[] cpList = Database.upsert(lstConPremise, false);
					for (Database.UpsertResult sr : cpList) 
					{
						if (!sr.isSuccess()) 
						{
							for(Database.Error err : sr.getErrors()) {
								System.debug('Contact Premise record failed: '+err.getStatusCode() + ' :' + err.getMessage());                    
							}
						}
					}
					
				}
			}

			for(SPEN_ContactStaging__c conStgRec : conStgRecList)
			{
				if(!setContactCustId.isEmpty() && setContactCustId.contains(conStgRec.SPEN_ExternalId__c))
				{
					conStgRec.SPEN_SyncStatus__c = 'Successful';
				}
				else 
				{
					conStgRec.SPEN_SyncStatus__c = 'Failed';
				}
			}
			update conStgRecList;
		}
	}
	

}