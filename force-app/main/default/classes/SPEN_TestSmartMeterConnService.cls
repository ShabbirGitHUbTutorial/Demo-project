/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex Service class for smart meter 
LIBRARY		:	Salesforce Enterprise Library - Smart Meter Connection
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
OCT-21-2022		Dhara Desai     Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_TestSmartMeterConnService {
    @AuraEnabled
    public static SPEN_MPAN__c getMPANDetails(Id recId){
        SPEN_LastGaspMockIntegrationService.getMockResponse(recId);
        //SPEN_TestMPANDetailsMock testMock = new SPEN_TestMPANDetailsMock();
        SPEN_MPAN__c mpanMock = SPEN_MPANSelector.getMpanRecord(recId);
        //testMock.send(recId);
        return mpanMock;
    }
    @AuraEnabled
    public static SPEN_MPAN__c getPingValue(Id recId){
      /*  SPEN_MPAN__c mpanMock = SPEN_MPANSelector.getMpanRecord(recId);
        mpanMock.SPEN_PingResult__c = 'TimedOut';
        Database.SaveResult dataSaveRes = Database.update(mpanMock);*/
        SPEN_MPAN__c mpanMock = [SELECT	Id,
						SPEN_AccountNumberMPAN__c,
						SPEN_PingResult__c,
						SPEN_LastGasp__c,
						ExternalId__c,
                        SPEN_PingResultFormula__c,
                        SPEN_DCCServiceFlag__c
				FROM	SPEN_MPAN__c 
				WHERE	Id = :recId
				WITH	SECURITY_ENFORCED LIMIT 1];
        
        return mpanMock;
    }
	@AuraEnabled
	public static void fetchMpanDetails(Id recId)
	{
		SPEN_MPAN__c mpanRec = SPEN_MPANSelector.getMpanRecord(recId);
		
		SPEN_IntegrationRequest__c intReq = new SPEN_IntegrationRequest__c();
		intReq.SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetMeterDetailsByMpanService';
		intReq.SPEN_Records__c = mpanRec.SPEN_AccountNumberMPAN__c;
		intReq.SPEN_Status__c = 'Processing';
		insert intReq;
	}
}