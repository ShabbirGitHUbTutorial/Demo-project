public with sharing class SPEN_SyncPSRBatchService 
{
	// New PSR
	public static Map<String, SPEN_PSR__c> createSFPSR(List<SPEN_PSRStaging__c> psrStagingRecords, Set<String> premiseExtIdSet)
	{
		Id psrRecordTypeID = Schema.SObjectType.SPEN_PSR__c.getRecordTypeInfosByDeveloperName().get('SPEN_PSR').getRecordTypeId();
		Map<String, SPEN_PSR__c> psrByExternalId = new Map<String, SPEN_PSR__c>();

		for(SPEN_PSRStaging__c psrStaging : psrStagingRecords)
		{
			SPEN_PSR__c psrRecord;
			String externalId = psrStaging.SPEN_PremiseId__c + '-' + psrStaging.SPEN_PsrVulnerabilityTypeId__c;

			// Create PSR placeholder or update if there is an existing one
			if(psrByExternalId.containsKey(externalId))
			{
				psrRecord = psrByExternalId.get(externalId);
			}
			else
			{
				psrRecord = new SPEN_PSR__c(SPEN_PSRId__c = externalId);
				psrByExternalId.put(externalId, psrRecord);
			}
			
			// References
			Contact cont = new Contact(SPEN_CustomerID__c = psrStaging.SPEN_PremiseId__c);
			SPEN_Premise__c premise = new SPEN_Premise__c(SPEN_PremiseId__c = psrStaging.SPEN_PremiseId__c);
			SPEN_PSRVulnerabilityType__c code = new SPEN_PSRVulnerabilityType__c(SPEN_Code__c = psrStaging.SPEN_PsrVulnerabilityTypeId__c);

			// Populate data
			psrRecord.RecordTypeId = psrRecordTypeID;
			psrRecord.SPEN_ADQMLastSync__c = psrStaging.SPEN_ADQMLastModifiedDateTime__c;
			psrRecord.SPEN_Premise__r = premise;
			psrRecord.SPEN_Contact__r = cont;
			psrRecord.SPEN_PSRVulnerabilityType__r = code;

			// Special handling of 17s
			if(psrStaging.SPEN_PsrVulnerabilityTypeId__c.equalsIgnoreCase('17'))
			{
				if(psrStaging.SPEN_EffectiveDateFrom__c != null) { psrRecord.SPEN_PSREffectiveFromDate__c = psrStaging.SPEN_EffectiveDateFrom__c; }
				if(psrStaging.SPEN_EffectiveDateTo__c != null) { psrRecord.SPEN_PSREffectiveToDate__c = psrStaging.SPEN_EffectiveDateTo__c; }
				if(psrStaging.SPEN_FirstLanguage__c != null) { psrRecord.SPEN_FirstLanguage__c = psrStaging.SPEN_FirstLanguage__c; }
			}   
			else 
			{
				psrRecord.SPEN_PSREffectiveFromDate__c = psrStaging.SPEN_EffectiveDateFrom__c;
				psrRecord.SPEN_PSREffectiveToDate__c = psrStaging.SPEN_EffectiveDateTo__c;
			}
		}
		
		return psrByExternalId;
	}
}