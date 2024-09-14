public with sharing class SPEN_PremisesSelector 
//extends fflib_SObjectSelector
	//implements SPEN_IPremisesSelector
{
    /*public static SPEN_IPremisesSelector newInstance()
	{
		return (SPEN_IPremisesSelector) Application.Selector.newInstance(SPEN_Premise__c.SObjectType);
	}
	 
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			SPEN_Premise__c.Id,
			SPEN_Premise__c.SPEN_PremiseID__c,
			SPEN_Premise__c.SPEN_PostCode__c,
            SPEN_Premise__c.SPEN_BuildingNameNumber__c,
            SPEN_Premise__c.SPEN_Zone__c,
            SPEN_Premise__c.SPEN_FlatNumber__c,    
            SPEN_Premise__c.SPEN_AccountNumberMPAN__c,
            SPEN_Premise__c.SPEN_AccountNumberMPAN__r.SPEN_AccountNumberMPAN__c    
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return SPEN_Premise__c.SObjectType;
	}

	public List<SPEN_Premise__c> selectById(Set<Id> idSet)
	{
		return (List<SPEN_Premise__c>) selectSObjectsById(idSet);
	}
	
    public List<SPEN_Premise__c> selectByExternalId(Set<String> premiseExternalIds,String externalField)
	{
		return (List<SPEN_Premise__c>) selectSObjectsByExternalId(premiseExternalIds,'SPEN_PremiseID__c');
	}
    
	public List<SPEN_Premise__c> selectByCustomerContact(List<Contact> contacts)
	{
		// Related Premises
		Set<String> premiseExternalIds = new Set<String>();
		for (Contact con : (List<Contact>) contacts)
		{
			if (con.SPEN_CustomerID__c != null)
			{
				premiseExternalIds.add(con.SPEN_CustomerID__c);
			}
		}
		return selectByExternalId(premiseExternalIds,'SPEN_PremiseID__c');
	}*/
    
	public static SPEN_Premise__c getPremiseRecord(String premiseId)
    {
        //SPEN_Premise__c premiseRecord = [SELECT Id, SPEN_PremiseID__c,SPEN_Zone__c,SPEN_AccountNumberMPAN__c FROM SPEN_Premise__c WHERE SPEN_PremiseID__c =: premiseId WITH SECURITY_ENFORCED];
        SPEN_Premise__c premiseRecord = [SELECT Id, SPEN_PremiseID__c,SPEN_FlatNumber__c,SPEN_PostCode__c,SPEN_BuildingNameNumber__c,SPEN_Zone__c FROM SPEN_Premise__c WHERE SPEN_PremiseID__c =: premiseId WITH SECURITY_ENFORCED];
        return premiseRecord;
    }
    public static List<SPEN_Premise__c> premDetailsForSyncContactsBatchService(Set<String> premiseExtIdSet){
        List<SPEN_Premise__c> premIdList = new List<SPEN_Premise__c>();
        premIdList = [Select Id,SPEN_PremiseID__c
                                         FROM SPEN_Premise__c
                                         WHERE SPEN_PremiseID__c IN: premiseExtIdSet
                     					 WITH SECURITY_ENFORCED];
        return premIdList;
    }
    
    public static List<SPEN_Premise__c> getPresmise(Set<Id> contactId){
		List<SPEN_Premise__c> sPremises = new List<SPEN_Premise__c>();
		if(!contactId.isEmpty()){
    		 sPremises = [select id, SPEN_PremiseId__c from SPEN_Premise__c where id in(select SPEN_Premise__c from contact where id=:contactId)];
		}
        return sPremises;
	
    }
    
    public static SPEN_Premise__c getPremiseFromUniqueCustomerId(String customerId)
    {
        List<SPEN_Premise__c> results = new List<SPEN_Premise__c>();
        
        results = [
            SELECT Id,SPEN_PremiseId__c FROM SPEN_Premise__c 
            WHERE SPEN_PremiseId__c =: customerId 
            WITH SECURITY_ENFORCED
            LIMIT:(Limits.getLimitQueryRows()-Limits.getQueryRows())
        ];
        
        return results.size() == 0 ? new SPEN_Premise__c() : results[0];
    }
	public List<SPEN_Premise__c> getPremiseForBeforeTrigger(Set<String> setPremiseId)
	{
		List<SPEN_Premise__c> results = new List<SPEN_Premise__c>();
		if(!setPremiseId.isEmpty())
		{
			results = [SELECT id, SPEN_PremiseId__c
						FROM SPEN_Premise__c 
						WHERE id IN:setPremiseId];
		}
		return results;
	}
}