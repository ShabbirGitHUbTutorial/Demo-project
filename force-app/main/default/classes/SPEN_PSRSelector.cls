/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector Class for the PSR Custom UI
LIBRARY		:	Salesforce Enterprise Library - 
VERSION		:	1.0
HISTORY		:
Date			Author		    Comment
OCT-27-2022		Ayush Mittal     Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_PSRSelector 
{
	public static List<SPEN_PSR__c> getPSRList(Id recordId) 
	{
		List<SPEN_PSR__c> psrList;
		if(recordId != null){
			psrList = [SELECT Id, Name, SPEN_Premise__c, SPEN_AdditionalInfo__c,
											SPEN_PSRVulnerabilityType__c, SPEN_PSRVulnerabilityType__r.Name,
											SPEN_Contact__c, SPEN_SpecificVulnerability__c 
											from SPEN_PSR__c where SPEN_Contact__c=:recordId 
											WITH SECURITY_ENFORCED
											LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
		}
		
		return psrList;
	}
	public static List<SPEN_PSR__c> getPSRprimaryConList(Set<Id> recordIdSet){
		  List<SPEN_PSR__c> psrList;
		if(recordIdSet != null && !recordIdSet.isEmpty()){
	   		psrList= [SELECT Id, Name, SPEN_Premise__c, SPEN_AdditionalInfo__c,
											SPEN_PSRVulnerabilityType__c, SPEN_PSRVulnerabilityType__r.Name,
											SPEN_Contact__c, SPEN_SpecificVulnerability__c,SPEN_PSRVulnerabilityType__r.SPEN_Description__c 
											from SPEN_PSR__c where SPEN_Contact__c in:recordIdSet and SPEN_Contact__r.SPEN_IsPrimaryContact__c = true
											WITH SECURITY_ENFORCED
											LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
		}
		return psrList;
	}
	
	public static List<SPEN_PSR__c> getPSRForInsertVABatch(List<Id> recordIdList){
		List<SPEN_PSR__c> psrList;
		if(recordIdList != null && recordIdList.isEmpty())
			psrList = [select Id,SPEN_Contact__c,SPEN_ZoneFormula__c,SPEN_Premise__r.SPEN_Zone__r.SPEN_BroadcastMessage__c 
										 from SPEN_PSR__C where Id in :recordIdList];
		return psrList;
	}

	public static List<SPEN_PSR__c> getPSRForSyncPSRBatch(Set<String> psrIdSet, Set<String> psrVulCodeSet)
	{    
		return [SELECT  Id,
						SPEN_Premise__r.Id, 
						SPEN_Premise__r.SPEN_PremiseID__c, 
						SPEN_Contact__r.SPEN_CustomerID__c, 
						SPEN_PSRVulnerabilityType__r.SPEN_Code__c,
						SPEN_ADQMLastSync__c
				FROM	SPEN_PSR__c 
				WHERE	SPEN_Premise__r.SPEN_PremiseID__c IN: psrIdSet AND 
						SPEN_PSRVulnerabilityType__r.SPEN_Code__c IN: psrVulCodeSet
				WITH	SECURITY_ENFORCED];
	}

	public static List<SPEN_PSR__c> getPSRForSyncPSRBatchService(Set<String> premiseExtIdSet){
		List<SPEN_PSR__c> psrList = new List<SPEN_PSR__c>();
		if(premiseExtIdSet != null && !premiseExtIdSet.isEmpty())
			psrList = [SELECT Id, SPEN_PSREffectiveFromDate__c, SPEN_PSREffectiveToDate__c,SPEN_Premise__r.SPEN_PremiseID__c, SPEN_Contact__r.SPEN_CustomerID__c, 
									 SPEN_PSRVulnerabilityType__r.SPEN_Code__c,SPEN_ADQMLastSync__c  FROM SPEN_PSR__c 
									 WHERE SPEN_Premise__r.SPEN_PremiseID__c IN:premiseExtIdSet 
									 WITH SECURITY_ENFORCED];
		return psrList;
	}
	
	public static List<SPEN_PSR__c> getPSRRecordsBasedOnIds (Set<Id> psrIds)
	{
		List<SPEN_PSR__c> psrList = new List<SPEN_PSR__c>();
		psrList = [Select Id,SPEN_Premise__r.SPEN_PremiseID__c,
				   SPEN_PSRVulnerabilityType__r.SPEN_Code__c,SPEN_ADQMLastSync__c
				   from SPEN_PSR__c
				   WHERE ID IN: psrIds
				   ];
		return psrList;
	}
}