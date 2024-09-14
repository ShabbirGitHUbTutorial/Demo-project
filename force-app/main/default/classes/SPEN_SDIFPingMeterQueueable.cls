global class SPEN_SDIFPingMeterQueueable Implements Queueable, Database.AllowsCallouts 
{
    public String message;
    Id intRqtId;
    global SPEN_SDIFPingMeterQueueable(Id intRequestId, String msg) 
    { 
        this.intRqtId = intRequestId;  
        this.message = msg;        
    } 
    
    global void execute(QueueableContext context) 
    {
        SPEN_IntegrationRequest__c inteReqRecord = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(intRqtId);
        try
        {
            Http ht = new Http();
            HttpRequest requests = new HttpRequest();
            List<SEL_IntegrationValue__mdt> intValuesAll = SEL_IntegrationValue__mdt.getAll().values();
            
            SEL_IntegrationSetting__mdt cmtBrTkn = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.API_CALL_BEARER_TOKEN_PING_METER);
            SEL_IntegrationsTransformService serBrTkn = new SEL_IntegrationsTransformService(cmtBrTkn);
            
            SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.SDIF_PING_METER);
            SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);
            
            List<SEL_IntegrationValue__mdt> intValuesBrTkn = new List<SEL_IntegrationValue__mdt>();
            List<SEL_IntegrationValue__mdt> intValues = new List<SEL_IntegrationValue__mdt>();
            for(SEL_IntegrationValue__mdt intValueInstance : intValuesAll)
            {
                if(intValueInstance.SEL_IntegrationSettingId__r.DeveloperName == SEL_IntegrationConstants.API_CALL_BEARER_TOKEN_PING_METER){
                    intValuesBrTkn.add(intValueInstance);
                }
                else if(intValueInstance.SEL_IntegrationSettingId__r.DeveloperName == SEL_IntegrationConstants.SDIF_PING_METER){
                    intValues.add(intValueInstance);
                }
                else{
                    continue;
                }
            }
            
            List<Map<String,String>> lstMapIntValuesBrTkn = serBrTkn.groupValuesByType(intValuesBrTkn);
            //System.debug('exepected values.. '+lstMapIntValuesBrTkn);
            requests = SPEN_IntegrationUtility.prepareRequestsWithBearerToken(lstMapIntValuesBrTkn, requests);
            requests.setMethod(cmtBrTkn.SEL_HttpMethod__c);
            //System.debug('requests : '+requests);
            
            HTTPResponse resp = ht.send(requests);
            Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            //system.debug('authMap---->'+authMap.get('access_token'));
            
            httpRequest httpRequest = new httpRequest();
            Http httpObject = new Http();
            HttpResponse httpResponse;
            
            List<Map<String,String>> lstMapIntValues = ser.groupValuesByType(intValues);
            //System.debug('exepected values.. '+lstMapIntValues);
            
            httpRequest = SPEN_IntegrationUtility.prepareRequestsForAPICallout(lstMapIntValues, httpRequest, authMap);
            httpRequest.setMethod(cmt.SEL_HttpMethod__c);
            
            httpRequest.setBody(message);
            //system.debug('httpRequest------------->'+httpRequest);
            httpResponse = httpObject.send(httpRequest);
            
            if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201)
            {
                //system.debug('PostCallout Successfull'); 
                system.debug('Response received -->>>> '+httpResponse);
                //system.debug('Response received body - '+httpResponse.getBody()); 
            }
            //system.debug('Response received -->>>> '+httpResponse);
            //system.debug('Response received body - '+httpResponse.getBody());
            
        }
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
            throw ex;
        }      
    }
}