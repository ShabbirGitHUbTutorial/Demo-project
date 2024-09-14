@isTest
global class SPEN_PremiseCommFlowHandlerHTTPMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
    	res.setStatus('OK');
    	res.setStatusCode(200);
        Map<String,String> mapResp = new Map <String,String>();
        mapResp.put('query','SELECT Name, SPEN_PremiseID__c, SPEN_FullAddress__c, SPEN_SubstationName__c, SPEN_Zone__r.Name, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp, SPEN_Zone__c FROM SPEN_Premise__c WHERE SPEN_PremiseID__c =:'+ 'test'+' ORDER BY SPEN_PremiseID__c');
        res.setBody(JSON.serialize(mapResp));
    return res;
    }

}