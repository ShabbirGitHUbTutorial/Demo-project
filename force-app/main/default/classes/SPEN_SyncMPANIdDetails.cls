@RestResource(urlMapping='/EDP/EndDevicePowerDownEvent/*')
global with sharing class SPEN_SyncMPANIdDetails {
    
    @HttpPost
    global static SPEN_MPAN__c UpdateMpanLastGasp(){
        
        List<SPEN_MPAN__c> mpanObjFromPowerDownEvent = new List<SPEN_MPAN__c>();
        RestRequest req = RestContext.request;  
        RestResponse res = Restcontext.response;
        List<String> strList = new List<String>();
        String mpanIdValue = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String requestBody = req.requestBody.toString();
        //System.debug('>>>>>req>>>'+req);
        //System.debug('>>>>>requestBody>>>'+requestBody);
        SPEN_MpanXmlNode.SoapBodyNode mpanxml = new SPEN_MpanXmlNode.SoapBodyNode();
        /*String soapString = req.requestBody.toString().replaceAll('soap:', '');
        String soapNoNullString = soapString.replaceAll('xsi:', '');
        mpanxml.load(soapNoNullString);
     	System.debug('>>>>>soapString>>>'+soapNoNullString);*/
		strList = req.requestBody.toString().split('<soap:Body>');
		String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', '');
        //String req2 =  newStr.substring(0, newStr.length()-16);   
        String soapString = newStr.replaceAll('soap:', '');
        String soapNoNullString = soapString.replaceAll('xsi:nil=\"true\"', '');
        soapNoNullString = soapNoNullString.replaceAll('xmlns:ns2=\"SDIF\"','');// added for actual 2 namespace in request
        soapNoNullString = soapNoNullString.replaceAll('ns2:', '');
        soapNoNullString = soapNoNullString.replaceAll('<EndDevicePowerDownEvent>', '');
        soapNoNullString = soapNoNullString.replaceAll('</EndDevicePowerDownEvent>', '');
        soapNoNullString = soapNoNullString.replaceAll(':ns2', '');
        soapNoNullString = soapNoNullString.replaceAll('ns3:', '');
        soapNoNullString = soapNoNullString.replaceAll(':ns3', '');
        soapNoNullString = soapNoNullString.replaceAll('xmlns:ns3=\"http://ge.com/dsp/bf/service/commonfault\"', '');
        system.debug('---soapNoNullString---'+soapNoNullString);
        mpanxml.load(soapNoNullString);
        //System.debug('+++JSON.serialize(mpanxml)'+JSON.serialize(mpanxml));
        System.debug('+++Jtest)'+System.JSON.deserializeUntyped(JSON.serialize(mpanxml)));
        SPEN_SyncMPANIdDetailsWrapper.RequestBody mpanWrapper = (SPEN_SyncMPANIdDetailsWrapper.RequestBody) System.JSON.deserialize(JSON.serialize(mpanxml), SPEN_SyncMPANIdDetailsWrapper.RequestBody.class);
        System.debug('>>>>mpanWrapper'+mpanWrapper);
        
        if(!mpanWrapper.sdifEndDevicePowerDownEvent.isEmpty()){
        for(SPEN_SyncMPANIdDetailsWrapper.sdifEndDevicePowerDownEvent sdifEvent: mpanWrapper.sdifEndDevicePowerDownEvent){
			//mpanObjFromPowerDownEvent = [SELECT Id,SPEN_AccountNumberMPAN__c,SPEN_LastGasp__c FROM SPEN_MPAN__c WHERE SPEN_AccountNumberMPAN__c = :sdifEvent.assets[0].mRID];
			//system.debug('----sdifEvent.mRID-----'+sdifEvent.mRID);
            mpanObjFromPowerDownEvent = [SELECT Id,SPEN_AccountNumberMPAN__c,SPEN_LastGasp__c FROM SPEN_MPAN__c WHERE SPEN_AccountNumberMPAN__c = :sdifEvent.mRID];
            if(!mpanObjFromPowerDownEvent.isEmpty() && !string.isEmpty(sdifEvent.createdDateTime))
            {
                mpanObjFromPowerDownEvent[0].SPEN_LastGasp__c = DateTime.valueOfGmt((sdifEvent.createdDateTime.replace('T', ' ')));
            }
            }
        }
        try{
            if(!mpanObjFromPowerDownEvent.isEmpty()){
                update mpanObjFromPowerDownEvent[0];
                return mpanObjFromPowerDownEvent[0];
            }
        }
        catch(exception e){
            SEL_LoggingService.log(e);
        }
     	return null;
		     
    } 
}