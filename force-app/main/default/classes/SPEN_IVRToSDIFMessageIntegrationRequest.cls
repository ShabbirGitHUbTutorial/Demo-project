/**********************************************************************************************
* @Author:      Smita Raikar
* @Date:        18/11/2022
* @Description: AdditionalService class from SPEN_IVRMessageRequestService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_IVRToSDIFMessageIntegrationRequest extends SEL_IntegrationsOutboundMessageBase{
    
    public static Id intgReqRecordId;
    public static List<String> incidntIdLst;
    public static final String sdifAuthDetails = 'SFTOSDIFAuthDetails';
    public static final String sdifURL = 'SFTOSDIFEndURL';
    
    public SPEN_IVRToSDIFMessageIntegrationRequest() 
    {
        super('SFToSDIFIVRMessageAPI');
    }
   
    public void send(Id ivrToSdifintgReqRecordId, String ivrToSdifintgReqPremiseID){
		//system.debug('ivrToSdifintgReqPremiseID '+ ivrToSdifintgReqPremiseID);
        SPEN_Premise__c premiseRcrd = SPEN_PremiseSelector.getPremiseRecord(ivrToSdifintgReqPremiseID);    
        SPEN_IntegrationRequest__c inteReqRcrd = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(ivrToSdifintgReqRecordId);
        try
        {
            HttpRequest request = super.getHttpRequest(premiseRcrd);
            //System.debug('request : '+request.getBody());
            if(super.getIsMockingEnabled())
            {
                HttpResponse response = super.send(request);
                String responseBody = response.getBody();
                if(response.getStatusCode() == 200)
                    
                {  
                    SPEN_AssignIVRMessageWrapper.RequestBody sdifWrapper = (SPEN_AssignIVRMessageWrapper.RequestBody) System.JSON.deserialize(response.getBody(), SPEN_AssignIVRMessageWrapper.RequestBody.class);
                                        
                    if(sdifWrapper.incidentId!= 'NULL')
                    {
                        Incident incFrmSdif = SPEN_IncidentSelector.getIncidentRecord(sdifWrapper.incidentId);
                        
                        if(!String.isBlank(incFrmSdif.SPEN_IVRMessage__c))
                        {
                            inteReqRcrd.SPEN_Response__c = incFrmSdif.SPEN_IVRMessage__c;
                            inteReqRcrd.SPEN_MessageType__c = 'Incident';				//CRMD-3754
                            inteReqRcrd.SPEN_Result__c = response.getStatus();
                        }
                        inteReqRcrd.SPEN_RelatedRecord__c = incFrmSdif.Id;				//CRMD-2168
                        inteReqRcrd.SPEN_Status__c = 'Completed';
                    }
                    
                    else
                    {
                        inteReqRcrd = checkFurtherMsg(premiseRcrd,inteReqRcrd,'CALLOUTSUCCESS',responseBody);
                    }
                    update inteReqRcrd; 
                }
            }
			else 
			{
				Set<ID> ImpactedPremiseRecIncIDSet = new Set<ID>();
				for(SPEN_ImpactedPremise__c imp : [Select SPEN_RelatedIncident__c from SPEN_ImpactedPremise__c where SPEN_PremiseId__c =:ivrToSdifintgReqPremiseID ORDER BY CreatedDate DESC LIMIT 20]){
					ImpactedPremiseRecIncIDSet.add(imp.SPEN_RelatedIncident__c);
					//System.debug(ImpactedPremiseRecIncIDSet);
				}
				//System.debug(ImpactedPremiseRecIncIDSet.size());
				if(ImpactedPremiseRecIncIDSet.size()>0)
				{
					List<Incident> IncidentRec = [Select Id,SPEN_IVRMessage__c from Incident where Id IN :ImpactedPremiseRecIncIDSet and SPEN_IncidentStatus__c in ('Awaiting','In Progress','On Site') ORDER BY CreatedDate DESC Limit 1]; 
					if( IncidentRec.size()>0)
					{
						inteReqRcrd.SPEN_Response__c = IncidentRec[0].SPEN_IVRMessage__c;
						inteReqRcrd.SPEN_MessageType__c = 'Incident';		
						inteReqRcrd.SPEN_RelatedRecord__c = IncidentRec[0].Id;
						inteReqRcrd.SPEN_Status__c = 'Completed';
					}
				}
				
				if(inteReqRcrd.SPEN_Status__c != 'Completed'){
					
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
					system.debug('res.getBody() ----------->'+res.getBody());
                    
					Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
					//System.debug('authMap.access_token'+authMap.get('access_token'));
					
					httpRequest httpRequest = new httpRequest();
					Http httpObject = new Http();
					HttpResponse httpResponse;
					httpRequest.setHeader('SOAPAction', sdifURL.SPEN_Authheader__c); 	
					httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
					httpRequest.setEndpoint(sdifURL.SPEN_EndpointURL__c+'='+premiseRcrd.SPEN_PremiseID__c);
					httpRequest.setHeader('content-type', 'text/plain'); 							
					httpRequest.setMethod('GET');
					system.debug('httpRequest------------->'+httpRequest);
					
					httpResponse = httpObject.send(httpRequest);
					system.debug('httpRes------------->'+httpResponse);
					String responseBody = httpResponse.getBody();
					if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201)
					{  
						System.debug('response >>'+httpResponse.getBody());
						//System.debug('response.getStatusCode() == 200');
						SPEN_AssignIVRMessageWrapper.RequestBody sdifWrapper = (SPEN_AssignIVRMessageWrapper.RequestBody) System.JSON.deserialize(httpResponse.getBody(), SPEN_AssignIVRMessageWrapper.RequestBody.class);
						//System.debug('sdifWrapper..'+sdifWrapper);
						//System.debug('sdifWrapper.incidentId...'+sdifWrapper.incidentId);
						
						Incident incFrmSdif=new Incident();
						if(sdifWrapper.incidentId!= 'NULL'){
							 incFrmSdif = SPEN_IncidentSelector.getIncidentRecordWithoutClosedStatus(sdifWrapper.incidentId);
						}
					 
						if(sdifWrapper != null && sdifWrapper.incidentId!= 'NULL' && incFrmSdif != null && incFrmSdif.SPEN_IncidentStatus__c != 'Delog' && incFrmSdif.SPEN_IncidentStatus__c != 'Complete' && incFrmSdif.SPEN_IncidentStatus__c != 'Cancelled' && !String.isBlank(incFrmSdif.SPEN_IVRMessage__c))
						{
							//System.debug('incFrmSdif : '+incFrmSdif);
							inteReqRcrd.SPEN_Response__c = incFrmSdif.SPEN_IVRMessage__c;
							inteReqRcrd.SPEN_MessageType__c = 'Incident';				//CRMD-3754
							inteReqRcrd.SPEN_Result__c = httpResponse.getStatus();
							inteReqRcrd.SPEN_RelatedRecord__c = incFrmSdif.Id;				//CRMD-2168
							inteReqRcrd.SPEN_Status__c = 'Completed';
						}
						else
						{
							inteReqRcrd = checkFurtherMsg(premiseRcrd,inteReqRcrd,'CALLOUTSUCCESS',responseBody);
						}
						
					}
					else {
						inteReqRcrd = checkFurtherMsg(premiseRcrd,inteReqRcrd,'CALLOUTFAIL',responseBody);
					}
				}
				update inteReqRcrd; 
			}
        }
        catch(Exception ex)
        {
			inteReqRcrd = checkFurtherMsg(premiseRcrd,inteReqRcrd,'CALLOUTFAIL','TIMEOUT');
			update inteReqRcrd;
            SEL_LoggingService.log(ex);
           // throw ex;
        }
    }

	public SPEN_IntegrationRequest__c checkFurtherMsg(SPEN_Premise__c premiseRcrd,SPEN_IntegrationRequest__c inteReqRcrd,String calloutStatus,String responseBody){
		SPEN_Premise__c pMsg = SPEN_PremiseSelector.getPremiseIVRMessages(premiseRcrd.Id);
						
		if(pMsg!=null && pMsg.SPEN_Zone__c != null && !String.isBlank(pMsg.SPEN_Zone__r.SPEN_BroadcastMessage__c)){
			inteReqRcrd.SPEN_Result__c = 'OK';
			inteReqRcrd.SPEN_MessageType__c = 'Zone';              //CRMD-3754
			inteReqRcrd.SPEN_Response__c = pMsg.SPEN_Zone__r.SPEN_BroadcastMessage__c;
			inteReqRcrd.SPEN_RelatedRecord__c = pMsg.SPEN_Zone__c;        //CRMD-2168
			inteReqRcrd.SPEN_Status__c = 'Completed';
		}
		else if(pMsg!=null && pMsg.SPEN_Zone__c != null && pMsg.SPEN_Zone__r.SPEN_Parent__c != null && !String.isBlank(pMsg.SPEN_Zone__r.SPEN_Parent__r.SPEN_BroadcastMessage__c)){
			inteReqRcrd.SPEN_Result__c = 'OK';
			inteReqRcrd.SPEN_MessageType__c = 'District';              //CRMD-3754
			inteReqRcrd.SPEN_Response__c = pMsg.SPEN_Zone__r.SPEN_Parent__r.SPEN_BroadcastMessage__c;
			inteReqRcrd.SPEN_RelatedRecord__c = pMsg.SPEN_Zone__r.SPEN_Parent__c;        //CRMD-2168
			inteReqRcrd.SPEN_Status__c = 'Completed';
		}
		else if(pMsg!=null && pMsg.SPEN_Zone__c != null && pMsg.SPEN_Zone__r.SPEN_Parent__r.SPEN_Parent__c != null && !String.isBlank(pMsg.SPEN_Zone__r.SPEN_Parent__r.SPEN_Parent__r.SPEN_BroadcastMessage__c)){
			inteReqRcrd.SPEN_Result__c = 'OK';
			inteReqRcrd.SPEN_MessageType__c = 'Region';              //CRMD-3754
			inteReqRcrd.SPEN_Response__c = pMsg.SPEN_Zone__r.SPEN_Parent__r.SPEN_Parent__r.SPEN_BroadcastMessage__c;
			inteReqRcrd.SPEN_RelatedRecord__c = pMsg.SPEN_Zone__r.SPEN_Parent__r.SPEN_Parent__c;        //CRMD-2168
			inteReqRcrd.SPEN_Status__c = 'Completed';
		}
		else if(calloutStatus == 'CALLOUTSUCCESS'){
			inteReqRcrd.SPEN_Result__c = 'No Message Found';
			inteReqRcrd.SPEN_Status__c = 'Completed';
			inteReqRcrd.SPEN_Response__c = responseBody;
		}
        else{
            inteReqRcrd.SPEN_Result__c = 'CALLOUT FAILED';
			inteReqRcrd.SPEN_Status__c = 'Completed';
            inteReqRcrd.SPEN_Response__c = responseBody;
        }
        return inteReqRcrd;
	}
}