/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  
AUTHOR    : 
LIBRARY    :  Salesforce Enterprise Library (SEL) 
VERSION    :  1.0


HISTORY    :
Date      Author        Comment
NOV-30-2022      Initial version
-----------------------------------------------------------------------------------------*/
public with sharing class SPEN_GetAffectedPremiseService
{
    @InvocableMethod(category='getAffetcedtPremise' label='getAffetcedtPremise' description='class for invoking get affected premise')
    public static void createRecord(List<String> IncidentId)
    {
        try{

            SPEN_ConfigurableSettings__c getAffectedINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='GetAffectedPremiseINCType' Limit 1];
            List<String> MessageINCTypeList = getAffectedINCType.SPEN_Value__c.split(',');
            Incident incRec = [SELECT Id, SPEN_IncidentType__c FROM Incident WHERE SPEN_IncidentID__c =:IncidentId[0] LIMIT 1];
            if(MessageINCTypeList.contains(String.ValueOf(incRec.SPEN_IncidentType__c))){
                String incId=IncidentId[0];
                integer chunkSize = integer.valueof(System.Label.SPEN_BatchSizeLabel);
                SPEN_IntegrationRequest__c inteReqRecord = new SPEN_IntegrationRequest__c();
                inteReqRecord.SPEN_Records__c = incId;
                inteReqRecord.SPEN_RelatedRecord__c = incId;
                inteReqRecord.SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetAffectedPremiseService' ;
                inteReqRecord.SPEN_Status__c = 'Processing';
                insert inteReqRecord;
                //system.debug('inteReqRecord --------->>>>>>>'+inteReqRecord);
                SPEN_GetAffectedPremiseService.sdifApiCalloutFirIncident(incId, chunkSize);
            }
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    
    @future (callout=true)
    public static void sdifApiCalloutFirIncident(String incidentId, integer batchSize)
    {	try{
        
        //Create Bearer Token
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        List<SEL_IntegrationValue__mdt> intValuesAll = SEL_IntegrationValue__mdt.getAll().values();

        SEL_IntegrationSetting__mdt cmtBrTkn = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.API_CALL_BEARER_TOKEN_FOR_GET_AFFECTED);
        SEL_IntegrationsTransformService serBrTkn = new SEL_IntegrationsTransformService(cmtBrTkn);

        SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.SDIF_GET_AFFECTED_PREMISES);
        SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);

        List<SEL_IntegrationValue__mdt> intValuesBrTkn = new List<SEL_IntegrationValue__mdt>();
        List<SEL_IntegrationValue__mdt> intValues = new List<SEL_IntegrationValue__mdt>();
        for(SEL_IntegrationValue__mdt intValueInstance : intValuesAll){
            if(intValueInstance.SEL_IntegrationSettingId__r.DeveloperName == SEL_IntegrationConstants.API_CALL_BEARER_TOKEN_FOR_GET_AFFECTED){
                intValuesBrTkn.add(intValueInstance);
            }
            else if(intValueInstance.SEL_IntegrationSettingId__r.DeveloperName == SEL_IntegrationConstants.SDIF_GET_AFFECTED_PREMISES){
                intValues.add(intValueInstance);
            }
            else{
                continue;
            }
        }
        List<Map<String,String>> lstMapIntValuesBrTkn = serBrTkn.groupValuesByType(intValuesBrTkn);
        //System.debug('exepected values.. '+lstMapIntValuesBrTkn);
        req = SPEN_IntegrationUtility.prepareRequestsWithBearerToken(lstMapIntValuesBrTkn, req);
        req.setMethod(cmtBrTkn.SEL_HttpMethod__c);
        //System.debug('req : '+req);

        /*req.setEndpoint('https://spdeveloper.scottishpower.com/token?grant_type=client_credentials');
        req.setMethod('POST');
        //String authorizationHeader = 'Basic QVJYUkRVZERsdEFkaHhYUkZFV1FaQW5QUHNFYTpIczBTOGI3SUx3UGdyRTNoUFlqeFp2cUxONzhh';
        String authorizationHeader ='Basic dHVBV04zdG5kOFZsamhlSW83NXFpWlJlUmZFYTpPaTJfZjBfek83WmRaQ3lrRnBaRmZHZk5CbjRh';
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('content-type', 'application/x-www-form-urlencoded'); */

        HTTPResponse res = http.send(req);
        Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        //System.debug('authMap.access_token'+authMap.get('access_token'));
        
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;

        List<Map<String,String>> lstMapIntValues = ser.groupValuesByType(intValues);
        //System.debug('exepected values.. '+lstMapIntValues);
        
        if(lstMapIntValues.isEmpty()) return;
        for ( Map<String, String> mapIntValueInstance : lstMapIntValues){
            if(mapIntValueInstance.containsKey(SEL_IntegrationConstants.AUTHORIZATION) && mapIntValueInstance.get(SEL_IntegrationConstants.AUTHORIZATION)!=null){
                httpRequest.setHeader(SEL_IntegrationConstants.AUTHORIZATION, mapIntValueInstance.get(SEL_IntegrationConstants.AUTHORIZATION)+ ' ' +authMap.get('access_token'));
            }
            if(mapIntValueInstance.containsKey(SEL_IntegrationConstants.ENDPOINT) && mapIntValueInstance.get(SEL_IntegrationConstants.ENDPOINT)!=null){
                httpRequest.setEndpoint(mapIntValueInstance.get(SEL_IntegrationConstants.ENDPOINT)+ '?name='+incidentId+'&chunkSize='+batchSize+'&CorrelationId='+generateCorrelationId()); //added correlation id for impacted premise change CRMD-9236
                httpRequest.setTimeout(SPEN_ImpactedPremisesConstants.TIMEOUT);
            }
        }
        httpRequest.setMethod(cmt.SEL_HttpMethod__c);
        //System.debug('httpRequest : '+httpRequest);

        /*httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
        httpRequest.setEndpoint(' https://spdeveloper.scottishpower.com/SDIF-CRM/0.0.1/service/CrmConector/SDIFGetAffectedPremises/?name='+incidentId+'&chunkSize='+batchSize);
        httpRequest.setMethod('GET');*/

        httpResponse = httpObject.send(httpRequest);
        //system.debug('httpRequest --------->>>>>'+ httpRequest);
        //system.debug('httpResponse --------->>>>>'+ httpResponse);
        system.debug('httpResponseBody --------->>>>>'+ httpResponse.getBody());
		
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    //added new method for CRMD-9236(impacted premise change to send correlation id)
    private static String generateCorrelationId() {
        // Generating a unique correlation ID using a combination of timestamp and random value
        Long timestamp = DateTime.now().getTime();
        Integer randomNumber = Integer.valueOf(Math.random() * 1000000);        
        String correlationId = 'CID-' + timestamp + '-' + randomNumber;
        return correlationId;
    }
}