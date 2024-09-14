public with sharing class SPEN_ActiveIncidentGetPremiseIntRequest extends SEL_IntegrationsOutboundMessageBase
{
    public static final String sdifAuthDetails = 'SFTOSDIFAuthDetails';
    public static final String sdifURL = 'SFTOSDIFEndURL';
   
    public SPEN_ActiveIncidentGetPremiseIntRequest() 
    {
        super('SFToSDIFIVRMessageAPI');
    }
    
    public void send(Id ivrToSdifintgReqRecordId, String ivrToSdifintgReqPremiseID)
    {
        //system.debug('ivrToSdifintgReqPremiseID '+ ivrToSdifintgReqPremiseID);
        SPEN_Premise__c premiseRcrd = SPEN_PremiseSelector.getPremiseRecord(ivrToSdifintgReqPremiseID);
        
        SPEN_IntegrationRequest__c inteReqRcrd = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(ivrToSdifintgReqRecordId);
        
        SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.SDIF_IVR_MESSAGE_API);
        SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);
        SPEN_AuthorizationDetails__mdt authDetailRec = SPEN_AuthorizationDetails__mdt.getInstance(sdifAuthDetails);
        SPEN_AuthorizationDetails__mdt sdifURL = SPEN_AuthorizationDetails__mdt.getInstance(sdifURL);
        //Create Bearer Token
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authDetailRec.SPEN_EndpointURL__c);
        req.setMethod('POST');
        String authorizationHeader = authDetailRec.SPEN_Authheader__c;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('content-type', 'application/x-www-form-urlencoded'); 
        HTTPResponse res = http.send(req);
        //system.debug('res.getBody() ----------->'+res.getBody());
        Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        //system.debug('authMap.access_token'+authMap.get('access_token'));
        
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;
        httpRequest.setHeader('SOAPAction', sdifURL.SPEN_Authheader__c); 	
        httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
        httpRequest.setEndpoint(sdifURL.SPEN_EndpointURL__c+'='+premiseRcrd.SPEN_PremiseID__c);
        httpRequest.setHeader('content-type', 'text/plain'); 							
        httpRequest.setMethod('GET');
        //system.debug('httpRequest------------->'+httpRequest);
        
        httpResponse = httpObject.send(httpRequest);
        //system.debug('httpRes------------->'+httpResponse);
        if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201)
        {
            //system.debug('response >>'+httpResponse.getBody());
            //system.debug('response.getStatusCode() == 200');
            SPEN_AssignIVRMessageWrapper.RequestBody sdifWrapper = (SPEN_AssignIVRMessageWrapper.RequestBody) System.JSON.deserialize(httpResponse.getBody(), SPEN_AssignIVRMessageWrapper.RequestBody.class);
            //system.debug('sdifWrapper..'+sdifWrapper);
            //system.debug('sdifWrapper.incidentId...'+sdifWrapper.incidentId);
            
            Incident incFrmSdif=new Incident();
            if(sdifWrapper.incidentId!= 'NULL')
            {
                incFrmSdif = SPEN_IncidentSelector.getIncidentRecordWithoutClosedStatus(sdifWrapper.incidentId);
            }
            else{
                inteReqRcrd.SPEN_Status__c = 'Completed';
                inteReqRcrd.SPEN_Result__c = 'No Incident Found';
                update inteReqRcrd;
            }
            if(sdifWrapper != null && sdifWrapper.incidentId!= 'NULL' && incFrmSdif != null && incFrmSdif.SPEN_IncidentStatus__c != 'Delog' && incFrmSdif.SPEN_IncidentStatus__c != 'Complete' && incFrmSdif.SPEN_IncidentStatus__c != 'Cancelled')
            {
                inteReqRcrd.SPEN_Status__c = 'Completed';
                inteReqRcrd.SPEN_Result__c = httpResponse.getStatus();
                inteReqRcrd.SPEN_MessageType__c = 'Incident';
                inteReqRcrd.SPEN_RelatedRecord__c = incFrmSdif.Id;
                update inteReqRcrd;
            }
        }
        else{
            inteReqRcrd.SPEN_Status__c = 'Completed';
            inteReqRcrd.SPEN_Result__c = 'CALLOUT FAILURE';
            inteReqRcrd.SPEN_Response__c = httpResponse.getBody();
            update inteReqRcrd;
        }
    }
}