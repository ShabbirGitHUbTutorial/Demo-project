/**
 * @description       : This class will be called from SPEN_UpdateZoneDataController and in this class
 *                      HttpCallout will be done.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 12-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SPEN_UpdateZoneDataService extends SEL_IntegrationsOutboundMessageBase {

    public SPEN_UpdateZoneDataService () 
    {
        super('SDIFGetTownZoneList');
    }
	
	public void send()
    {
		try{
			HttpRequest request = super.getHttpRequest();
           // System.debug('request : '+request);
            if(super.getIsMockingEnabled()){
				HttpResponse response = super.send(request);
               // System.debug('response.getStatusCode() ---->'+ response.getStatusCode());
                if(response.getStatusCode() == 200){
                    String jsonContent = response.getBody();
                    Map<String, String> mapZoneIdToParentId = new Map<String,String>();
                    SPEN_UpdateZoneDataController.ZoneWrapper objZoneWrapper = (SPEN_UpdateZoneDataController.ZoneWrapper)JSON.deserialize(jsonContent, SPEN_UpdateZoneDataController.ZoneWrapper.class);
                    SPEN_UpdateZoneDataService.getZoneParentMap(objZoneWrapper);    
				}
			}else{
				SPEN_UpdateZoneDataService.getZoneData();
        	}  
		}catch(Exception ex){
            SEL_LoggingService.log(ex); 
		} 
	}

    private static Map<String, String> getZoneParentMap(SPEN_UpdateZoneDataController.ZoneWrapper objZoneWrapper){
        Map<String, String> mapZoneIdToParentId = new Map<String,String>();
        if(objZoneWrapper != null){
            List<SPEN_UpdateZoneDataController.OperatingZoneList> lstZone = objZoneWrapper.operatingZoneList;
            for(SPEN_UpdateZoneDataController.OperatingZoneList objZone : lstZone){
                mapZoneIdToParentId.put(objZone.ozId, objZone.ozParentId);	
            }
        }
        return mapZoneIdToParentId;
    }
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    public static string getZoneData(){
        String responseData;
        try {
            SPEN_AuthorizationDetails__mdt authDetailRec = SPEN_AuthorizationDetails__mdt.getInstance('SDIFGetTownZoneList');
            Http objHttp = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(authDetailRec.SPEN_EndpointURL__c);
            req.setMethod('POST');
            String authorizationHeader = authDetailRec.SPEN_Authheader__c;
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/x-www-form-urlencoded'); 
            HTTPResponse res = objHttp.send(req);
           // System.debug('res.getBody():'+res.getBody());
            Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
           // System.debug('authMap.access_token'+authMap.get('access_token'));
            String accessToken = String.valueOf(authMap.get('access_token'));
            
            SPEN_AuthorizationDetails__mdt authDetailEndURL = SPEN_AuthorizationDetails__mdt.getInstance('SDIFGetTownZoneEndURL');
            HTTP http = new HTTP();
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint(authDetailEndURL.SPEN_EndpointURL__c);
            
            request.setTimeout(120000);
            request.setHeader('Content-Type','application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setMethod('GET');   
            HTTPResponse response = new HttpResponse();
            response = http.send(request); 
            if (response.getStatusCode() == 200) {
               // System.debug('response::'+response.getBody());
                responseData = 'success' +response.getBody();
            } else {
               // System.debug('response::'+response.getBody());
                responseData = '';
            }  
        } catch (Exception ex) {
            SEL_LoggingService.log(ex); 
            responseData = ex.getMessage()+'   '+ex.getLineNumber();
        }
        return responseData;
    }   
}