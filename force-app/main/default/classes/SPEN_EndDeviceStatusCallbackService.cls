@RestResource(urlMapping = '/EDS/ReceiveEndDevicePingStatus/*')
global class SPEN_EndDeviceStatusCallbackService {
    
    @HttpPost
    global static SPEN_MPAN__c dopost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;   
        SPEN_MPAN__c mpan = new SPEN_MPAN__c();
        
        List<String> strList = new List<String>();
        //system.debug('req' +req.requestBody);

        SPEN_EnddeviceXMLNodes.SoapBodyNode MPANNODE = New SPEN_EnddeviceXMLNodes.SoapBodyNode();
        strList = req.requestBody.toString().split('<soapenv:Body>');
        //system.debug('strList' +strList);
        
		/*String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soapenv:Envelope>', '');
        newStr = newStr.replaceAll('soapenv:', '');
        String soapNoNullString = newStr.replaceAll('end:', '');
        soapNoNullString = soapNoNullString.replaceAll(':end', '');
        //system.debug('newStr' +newStr);*/
        strList = req.requestBody.toString().split('<soap:Body>');
		String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', '');
        //String req2 =  newStr.substring(0, newStr.length()-16);   
        String soapString = newStr.replaceAll('soap:', '');
        String soapNoNullString = soapString.replaceAll('xsi:nil=\"true\"', '');
        soapNoNullString = soapNoNullString.replaceAll('xmlns:ns2=\"SDIF\"','');// added for actual 2 namespace in request
        soapNoNullString = soapNoNullString.replaceAll('ns2:', '');
        soapNoNullString = soapNoNullString.replaceAll(':ns2', '');
        soapNoNullString = soapNoNullString.replaceAll('ns3:', '');
        soapNoNullString = soapNoNullString.replaceAll(':ns3', '');
        soapNoNullString = soapNoNullString.replaceAll('xmlns:ns3=\"http://ge.com/dsp/bf/service/commonfault\"', '');
        
        //system.debug('soapNoNullString-->' +soapNoNullString);
        
        MPANNODE.load(soapNoNullString);
        string JSONSTRING =JSON.serialize(MPANNODE);
        //system.debug('JSONSTRING' +JSONSTRING);

        SPEN_CallbackServiceWrapper callBackWrapper = (SPEN_CallbackServiceWrapper) System.JSON.deserialize(JSON.serialize(MPANNODE), SPEN_CallbackServiceWrapper.class);
        system.debug('callBackWrapper ---->'+callBackWrapper);
        
        if(!callBackWrapper.SDIFReceiveEndDevicePingStatus.isEmpty()) 
        {
            mpan = [SELECT Id,SPEN_AccountNumberMPAN__c,SPEN_PingResult__c,SPEN_PremiseMeterType__c FROM SPEN_MPAN__c WHERE SPEN_AccountNumberMPAN__c = :callBackWrapper.SDIFReceiveEndDevicePingStatus[0].StatusReading[0].EndDeviceAsset[0].mRID WITH SECURITY_ENFORCED];
            //system.debug('mpan----------->'+mpan);
            mpan.SPEN_PingResult__c = callBackWrapper.SDIFReceiveEndDevicePingStatus[0].StatusReading[0].status;
            //system.debug('SPEN_PingResult__c '+mpan.SPEN_PingResult__c);
            update mpan;
            
            List<SPEN_IntegrationRequest__c> intRqstRcd = [Select Id,SPEN_Result__c,SPEN_Status__c,SPEN_Records__c,SPEN_IntegrationRequestServiceClass__c 
                                                     from SPEN_IntegrationRequest__c where SPEN_IntegrationRequestServiceClass__c='SPEN_MeterPingService' and SPEN_Status__c ='Processing' 
                                                     order by LastModifiedById DESC];
            
            List<SPEN_IntegrationRequest__c> intToUpdate  = new List<SPEN_IntegrationRequest__c>();
            for(SPEN_IntegrationRequest__c intRqst : intRqstRcd)
            {
                if(intRqst.SPEN_Records__c == mpan.SPEN_AccountNumberMPAN__c)
                {
                    //system.debug('intRqst.SPEN_Records__c ----->'+intRqst.SPEN_Records__c);
                    intRqst.SPEN_Status__c = 'Completed';
                    intRqst.SPEN_Result__c = mpan.SPEN_PingResult__c;
                    intToUpdate.add(intRqst);
                } 
            }
			update intToUpdate;
            //system.debug('intToUpdate----->'+ intToUpdate);
        }
    	
        return mpan;
    }
}