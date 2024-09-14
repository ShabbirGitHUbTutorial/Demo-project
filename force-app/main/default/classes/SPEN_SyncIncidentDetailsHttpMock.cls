@isTest
global class SPEN_SyncIncidentDetailsHttpMock implements HttpCalloutMock{
 global HttpResponse respond(HTTPRequest req){
     Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
     Incident incdnt = new Incident();
     incdnt.Subject = 'Test HV Incident';
     incdnt.SPEN_IncidentID__c = 'I001';
     incdnt.recordtypeId = recTypeId;
     //insert incdnt;
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
     
    res.setBody(JSON.serialize(incdnt));
    return res;
  }
}