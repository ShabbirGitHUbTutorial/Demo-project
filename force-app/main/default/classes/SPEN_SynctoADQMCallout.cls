/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        05/01/2023
* @Description: IVRToECOSIntegrationReq&Res class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_SynctoADQMCallout{
	public static final String adqmAuthDetails = 'ADQMAuthDetails';
    public static final String adqmURL = 'ADQMEndURL';
    @AuraEnabled  
    public static SPEN_IntegrationRequest__c getContactSynctoADQMVal(Id recId){
        SPEN_IntegrationRequest__c createIntegrationReqst= new SPEN_IntegrationRequest__c();
       	createIntegrationReqst.SPEN_RelatedRecord__c = recId;
		createIntegrationReqst.SPEN_RequestedBy__c = UserInfo.getUserId();
		createIntegrationReqst.SPEN_Status__c = 'Sent';
        insert createIntegrationReqst;
        Contact con =new Contact();
        SPEN_IntegrationRequest__c integrationReqst= new SPEN_IntegrationRequest__c();
        con= SPEN_ContactSelector.getSyncFromADQMVal(recId);
        if(con.SPEN_RequireSynctoADQM__c==true){
            
            integrationReqst=SPEN_IntegrationRequestSelector.getIntegrationRequestRecordByContact(recId);
        }
         return integrationReqst; 
    }
    @AuraEnabled  
    public static String getLastIntegrationStatus(Id recId){
        String intStatus;
        Contact con =new Contact();
        SPEN_IntegrationRequest__c integrationReqst= new SPEN_IntegrationRequest__c();
        con= SPEN_ContactSelector.getSyncFromADQMVal(recId);
        if(con.SPEN_RequireSynctoADQM__c==true){
            
            integrationReqst=SPEN_IntegrationRequestSelector.getIntegrationRequestRecordByContact(recId);
            if(integrationReqst.SPEN_Status__c=='Failed'){
                intStatus='Sync To ADQM Failed';
            }
            else if(integrationReqst.SPEN_Status__c=='Completed'){
                intStatus='Sync To ADQM is Successful';
            }
        }
         return intStatus; 
    }    
    @AuraEnabled
    public static void GetCustomerDetails(Id recId){
        
        List<String> strList = new List<String>();
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsToBeUpdated = new List<Contact>();
        Set<String> mpancores = new Set<String>();
        Map<String, String> contactToVersionNumMap = new Map<String, String> ();
        String VrsnNumber;
        String requestBody;
        //System.debug('recId'+recId);
              
        SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.GET_CUSTOMER_DETAILS_ADQM);
        SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);
        List<sObject> ps1 = SPEN_ContactPremisesSelector.getConPremise(recId);
        if(!ps1.isEmpty()){
        String reqMessage = ser.generateMessage(ps1[0]);
        SPEN_SynctoADQMCallout sADQMInst = new SPEN_SynctoADQMCallout();
   		SPEN_AuthorizationDetails__mdt authDetailRec = SPEN_AuthorizationDetails__mdt.getInstance(adqmAuthDetails);
        SPEN_AuthorizationDetails__mdt adqmURL = SPEN_AuthorizationDetails__mdt.getInstance(adqmURL);
        //Create Bearer Token
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authDetailRec.SPEN_EndpointURL__c);
        req.setMethod('POST');
        String authorizationHeader = authDetailRec.SPEN_Authheader__c;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('content-type', 'application/x-www-form-urlencoded'); 
        HTTPResponse res = http.send(req);
        Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        //System.debug('authMap.access_token'+authMap.get('access_token'));
        
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;
        
        httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
        httpRequest.setEndpoint(adqmURL.SPEN_EndpointURL__c);
        httpRequest.setHeader('content-type', 'text/xml'); 							
        httpRequest.setMethod('POST');
        httpRequest.setBody(reqMessage);
        System.debug('reqMessage : '+reqMessage);
        httpResponse = httpObject.send(httpRequest);
        
        if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201){
            SPEN_ContactPSRXMLNode.SoapBodyNode cntctPSR = new SPEN_ContactPSRXMLNode.SoapBodyNode();
            strList = httpResponse.getBody().split('<env:Body>');
            String newStr = httpResponse.getBody().replace(strList[0],'').replace('</env:Envelope>', '');  
            String soapString = newStr.replaceAll('m:', '');
            String soapString2 = soapString.replaceAll('env:', '');
            String soapString3 = soapString2.replaceAll('typ:', '');
            String soapString4 = soapString3.replaceAll(' xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"', '');
            String soapString6 = soapString4.replaceAll(':m', '');
            String soapNoNullString = soapString6.replaceAll(' xsi:nil="true"', '');
            system.debug('----soapNoNullString--'+soapNoNullString);
            cntctPSR.load(soapNoNullString); 
            SPEN_ContactPSRWrapper conADQMWrapper = (SPEN_ContactPSRWrapper) System.JSON.deserialize(JSON.serialize(cntctPSR), SPEN_ContactPSRWrapper.class);
            if(!conADQMWrapper.getcustomerdetailsResponse.isEmpty()){
                for(SPEN_ContactPSRWrapper.getcustomerdetailsResponse getCustDetails: conADQMWrapper.getcustomerdetailsResponse){
                    String mpancoreValue = getCustDetails.Customerdetails[0].mpanlist[0].mpandata[0].mpancore;
                    mpancores.add(mpancoreValue);
                    if(!contactToVersionNumMap.containsKey(mpancoreValue)){
                        contactToVersionNumMap.put(mpancoreValue, getCustDetails.customerdetails[0].customerversionnumber);
                    }
                    VrsnNumber = getCustDetails.customerdetails[0].customerversionnumber;
                    User userFederaionId = [SELECT Name,Username,EmployeeNumber 
                                    		FROM User 
                                    		WHERE Id =:UserInfo.getUserId()
                                    		WITH SECURITY_ENFORCED];
                    Contact contRec = new Contact(Id = recId);
                    contRec.SPEN_AgentID__c = userFederaionId.EmployeeNumber;
                    contRec.SPEN_VersionNumber__c = VrsnNumber;
                    update contRec;
                    requestBody = SPEN_UpdateCustomerDetailsService.generateCustomerDetailsRequest(recId, getCustDetails);
                }  
            }
            SPEN_IntegrationRequest__c integrationReqst= new SPEN_IntegrationRequest__c();
            integrationReqst=SPEN_IntegrationRequestSelector.getIntegrationRequestRecordByContact(recId);
            customerToADQMDetails(requestBody,recId,integrationReqst.Id);
        }
    }
    }

    @future(callout=true) 
	public static void customerToADQMDetails(String xmlBody, Id recId,Id integrationReqstId)
	{
		//system.debug('--xmlBody---'+xmlBody+'--recId--'+recId);
        SPEN_AuthorizationDetails__mdt authDetailRec = SPEN_AuthorizationDetails__mdt.getInstance(adqmAuthDetails);
        SPEN_AuthorizationDetails__mdt adqmURL = SPEN_AuthorizationDetails__mdt.getInstance(adqmURL);
		//Create Bearer Token for second callout
        Http httpScnd = new Http();
        HttpRequest reqScnd = new HttpRequest();
        reqScnd.setEndpoint(authDetailRec.SPEN_EndpointURL__c);
        reqScnd.setMethod('POST');
        String authorizationHeaderScnd = authDetailRec.SPEN_Authheader__c;
        reqScnd.setHeader('Authorization', authorizationHeaderScnd);
        reqScnd.setHeader('content-type', 'application/x-www-form-urlencoded'); 
        HTTPResponse resScnd = httpScnd.send(reqScnd);
        Map<String, Object> authMapScnd = (Map<String, Object>) JSON.deserializeUntyped(resScnd.getBody());
        			
		 httpRequest httpRequestScnd = new httpRequest();
                    Http httpObjectScnd = new Http();
                    HttpResponse httpResponseScnd;
                    
                    httpRequestScnd.setTimeout(120000);
        
                    httpRequestScnd.setHeader('Authorization', 'Bearer ' +authMapScnd.get('access_token'));
                    httpRequestScnd.setEndpoint(adqmURL.SPEN_EndpointURL__c);
                    httpRequestScnd.setHeader('content-type', 'text/xml'); 							
                    httpRequestScnd.setMethod('POST');
                    httpRequestScnd.setBody(xmlBody);
        try{
                    httpResponseScnd = httpObjectScnd.send(httpRequestScnd);
		if(httpResponseScnd.getStatusCode() == 200 || httpResponseScnd.getStatusCode() == 201)
		{
			//system.debug('PostCallout Successfull'); 
			system.debug('Response received -->>>> '+httpResponseScnd);
			//system.debug('Response received body - '+httpResponseScnd.getBody());
			List<Contact> lstCntc = SPEN_ContactSelector.getCntctFrADQM(new Set<Id>{recId});
			lstCntc[0].SPENAdqmLastSyncDateTime__c = System.now();
			lstCntc[0].SPEN_RequireSynctoADQM__c = false;
			lstCntc[0].SPEN_PSRSynctoADQM__c = false;
			update lstCntc[0]; 
            SPEN_IntegrationRequest__c createIntegrationReqst= new SPEN_IntegrationRequest__c();
            createIntegrationReqst=SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(integrationReqstId);
            createIntegrationReqst.SPEN_Response__c=httpResponseScnd.getBody();
            createIntegrationReqst.SPEN_Status__c='Completed';
            update createIntegrationReqst;
		}
        else{
            SPEN_IntegrationRequest__c createIntegrationReqst= new SPEN_IntegrationRequest__c();
            createIntegrationReqst=SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(integrationReqstId);
            createIntegrationReqst.SPEN_Response__c=httpResponseScnd.getBody();
            createIntegrationReqst.SPEN_Status__c='Failed';
            update createIntegrationReqst;
        
        }
        }
        catch (System.CalloutException e) {
    // Handle callout exceptions, including timeout
    System.debug('Callout Exception: ' + e.getMessage());

    // Update Integration Request record for failure
    SPEN_IntegrationRequest__c createIntegrationReqst = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(integrationReqstId);
    createIntegrationReqst.SPEN_Response__c = 'CalloutException: ' + e.getMessage();
    createIntegrationReqst.SPEN_Status__c = 'Failed';
    update createIntegrationReqst;

    // Log the error using your custom logging service
    SEL_LoggingService.log(e);
}
  
        }
        
}