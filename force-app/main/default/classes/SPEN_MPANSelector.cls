/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex  Class to hold without sharing methods. 
LIBRARY		:	Salesforce Enterprise Library - Smart Meter Connection
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
OCT-20-2022		Dhara Desai			Initial version
DEC-29-2022		Macjules Sevilla	Refactored but names should be fixed
-----------------------------------------------------------------------------*/
public with sharing class SPEN_MPANSelector
{
	// TODO: The method name should be selectById
	public static SPEN_MPAN__c getMpanRecord(Id recordId)
	{
		List<SPEN_MPAN__c> results = new List<SPEN_MPAN__c>();

		if(recordId != null)
		{
			results = [	
				SELECT	Id,
						SPEN_AccountNumberMPAN__c,
						SPEN_PingResult__c,
						SPEN_LastGasp__c,
						ExternalId__c 
				FROM	SPEN_MPAN__c 
				WHERE	Id =: recordId
				WITH	SECURITY_ENFORCED
				LIMIT	:(Limits.getLimitQueryRows()-Limits.getQueryRows())
			];
		}

		return results.size() == 0 ? new SPEN_MPAN__c() : results[0];
	}

	// TODO: Method name should be selectByAccountNumber
	public static SPEN_MPAN__c getMpanRecordForMeterPing(String accountNumberMPAN)
	{
		List<SPEN_MPAN__c> results = new List<SPEN_MPAN__c>();

		if(String.isNotBlank(accountNumberMPAN))
		{
			results = [
				SELECT	Id,
						SPEN_AccountNumberMPAN__c,
						SPEN_PingResult__c,
						SPEN_LastGasp__c,
						ExternalId__c 
				FROM	SPEN_MPAN__c 
				WHERE	Id =: accountNumberMPAN
				WITH	SECURITY_ENFORCED
				LIMIT	:(Limits.getLimitQueryRows()-Limits.getQueryRows())
			];
		}
		
		return results.size() == 0 ? new SPEN_MPAN__c() : results[0];
	}

	// TODO: Method name should be selectByAccountNumber
	// TODO: Should be merged with the previous method. The previous method looks wrong
	public static SPEN_MPAN__c getRecordForMpan(String accNumberMPAN)
	{
		List<SPEN_MPAN__c> results = new List<SPEN_MPAN__c>();

		if(String.isNotBlank(accNumberMPAN))
		{
			results = [
				SELECT	Id,
						SPEN_Premise__c,
						SPEN_Premise__r.SPEN_PremiseId__c,
						SPEN_DCCServiceFlag__c,
						SPEN_AccountNumberMPAN__c,
						SPEN_LastEchoesSyncDate__c,
						SPEN_SmartMeterPingDateTime__c,
						SPEN_MeterType__c,
						SPEN_PingResult__c,
						SPEN_PremiseMeterType__c,
						SPEN_SupplierMPID__c,
						SPEN_SupplierName__c,
						SPEN_SupplierPhoneNumber__c 
				FROM	SPEN_MPAN__c
				WHERE	SPEN_AccountNumberMPAN__c =: accNumberMPAN
				WITH	SECURITY_ENFORCED 
				LIMIT	:(Limits.getLimitQueryRows()-Limits.getQueryRows())];
		}
		
		return results.size() == 0 ? new SPEN_MPAN__c() : results[0];
	}
}