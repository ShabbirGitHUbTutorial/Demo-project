@RestResource(urlMapping='/SPEN_MPAN/*')
global with sharing class SPEN_ReceiveEndDevicePingStatus {
@HttpGet
    global static SPEN_MPAN__c doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String extId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        SPEN_MPAN__c result;
        if(extId != null)
        	result = [SELECT Id FROM SPEN_MPAN__c WHERE ExternalId__c = :extId];
        return result;
    }
  
  @HttpPatch
    global static ID doPatch() {
        RestRequest request = RestContext.request;
        String mpanId = request.requestURI.substring(
        request.requestURI.lastIndexOf('/')+1);
        SPEN_MPAN__c mpanObj;
        if(mpanId != null)
        	mpanObj = [SELECT Id,SPEN_LastGasp__c FROM SPEN_MPAN__c WHERE Id = :mpanId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Case sObject
            //system.debug('fieldName'+fieldName);
            //system.debug('fieldValue'+params.get(fieldName));
            mpanObj.put(fieldName, params.get(fieldName));
        }
        update mpanObj;
        return mpanObj.Id;
    }    
}