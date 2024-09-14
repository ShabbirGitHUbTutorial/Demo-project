@isTest
global with sharing class SPEN_IncidentOutageChangedMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get(SPEN_ImpactedPremisesConstants.SPENINCIDENT).getRecordTypeId();
        Incident incdnt = new Incident();
        incdnt.Subject = 'Test HV Incident';
        incdnt.SPEN_IncidentID__c = '0hbjdgfyj';
        incdnt.recordtypeId = recTypeId;
        incdnt.SPEN_IncidentReference__c = 'TEST5044AB';
        //insert incdnt;
       HttpResponse res = new HttpResponse();
       res.setStatus('OK');
       res.setStatusCode(200);
        
       res.setBody(JSON.serialize(incdnt));
       return res;
     }
}