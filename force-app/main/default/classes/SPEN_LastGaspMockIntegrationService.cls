/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex class for the Last Gasp Mock API. 
LIBRARY		:	Salesforce Enterprise Library - Integration Framework
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
OCT-27-2022		Smita Raikar     Initial version

-----------------------------------------------------------------------------*/
public with sharing class SPEN_LastGaspMockIntegrationService 
{
    @AuraEnabled
    public static void getMockResponse(Id recordId) 
    {
        SPEN_MPAN__c mpanRec = SPEN_MPANSelector.getMpanRecord(recordId);
        SPEN_IntegrationRequest__c intReq = new SPEN_IntegrationRequest__c();
        intReq.SPEN_IntegrationRequestServiceClass__c = 'SPEN_MeterPingService';
        intReq.SPEN_Records__c = mpanRec.SPEN_AccountNumberMPAN__c;
        intReq.SPEN_Status__c = 'Processing';
        insert intReq;
        //system.debug('recID >> ' + recordId);
        
        /*HttpResponse httpResponse;
httpResponse=sendRequest(recordId);
//System.debug('response' + httpResponse);
if(httpResponse.getStatusCode() == 200){
SPEN_MPAN__c mpan = new SPEN_MPAN__c();
mpan.Id = recordId;
mpan.SPEN_PingResult__c = 'Energized';
//mpan.SPEN_LastGasp__c= DateTime.now();
System.debug('LastGasp--->>' +mpan.SPEN_LastGasp__c);
Database.SaveResult dataSaveRes = Database.update(mpan);
System.debug('database res' +dataSaveRes);
}
*/
        
    }
    /*
@TestVisible
public static HttpResponse sendRequest(Id recordId){

Id mpanId=recordId;
//System.debug('mpanId' + mpanId);
SPEN_MPAN__c mpanobj;
if(mpanId != null)
mpanobj=[Select id, Name, SPEN_Status__c,SPEN_AccountNumberMPAN__c, SPEN_LastGasp__c,SPEN_PingResult__c FROM SPEN_MPAN__c WHERE id=:mpanId];
SEL_IntegrationSetting__mdt s = new SEL_IntegrationsSelector().selectByDeveloperName('LastGaspMockAPI');
//system.debug('setting---->>>'+s);
SEL_IntegrationsTransformService dms=new SEL_IntegrationsTransformService(s);
//system.debug('dms-->>'+dms);
httpRequest httpRequest = new httpRequest();
Http httpObject = new Http();
HttpResponse httpResponse;
//System.debug('XML--->>'+dms.generateMessage(mpanobj));
if(s.SEL_IsMockingEnabled__c==true){
httpRequest.setHeader('Content-type', 'application/xml');
httpRequest.setEndpoint('https://test.salesforce.com');
httpRequest.setMethod('POST');
httpRequest.setBody(dms.generateMessage(mpanobj));
httpResponse = httpObject.send(httpRequest);

system.debug('Response received -->>>> '+httpResponse);

//system.debug('Response received body - '+httpResponse.getBody());
}
return httpResponse;
}
*/ 
}