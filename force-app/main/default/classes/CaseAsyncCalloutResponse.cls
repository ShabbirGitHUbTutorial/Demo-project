@RestResource(urlMapping ='/SDIFLogCallReply/*')
global with sharing class CaseAsyncCalloutResponse {
    
	@HttpPost
    global static Case updateCase(){
        
        List<String> strList = new List<String>();
        Case cseObjFromPowerOn = new Case();
        RestRequest req = RestContext.request;
        //String cseId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
       	CaseXmlNodes.SoapBodyNode csePowerOn = new CaseXmlNodes.SoapBodyNode();
        strList = req.requestBody.toString().split('<soap:Body>');
		String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', '');
        String replacedString = newStr.replaceAll('soap:', '');
        //system.debug('replacedString: '+replacedString);
        csePowerOn.load(replacedString);
        
        PowerOnToCaseWrapper cseWrapper = (PowerOnToCaseWrapper) System.JSON.deserialize(JSON.serialize(csePowerOn), PowerOnToCaseWrapper.class);
		system.debug('cseWrapper: '+cseWrapper);
        
        for(PowerOnToCaseWrapper.SDIFLogCallReply cseLogCall: cseWrapper.SDIFLogCallReply){ 
            
            cseObjFromPowerOn = [Select Id,SPEN_PowerOnCallReference__c,CaseNumber,RecordType.DeveloperName,CreatedById from Case WHERE CaseNumber =: string.valueof(cseLogCall.logCallReplyStc[0].correlationID).leftPad(8,'0')];
            if(cseLogCall.logCallReplyStc[0].callReference != NULL)
            {
               cseObjFromPowerOn.SPEN_PowerOnCallReference__c	 =  cseLogCall.logCallReplyStc[0].callReference; 
            }
            else{
                if(cseObjFromPowerOn.RecordType.DeveloperName == 'SPEN_UnplannedFault'){
                    List<SPEN_IntegrationRequest__c> intRequestValue =[SELECT Id from SPEN_IntegrationRequest__c  WHERE SPEN_RelatedRecord__c=:cseObjFromPowerOn.Id AND SPEN_IntegrationRequestServiceClass__c='SDIFLogCallReply'];
                    if(intRequestValue.isEmpty() && cseLogCall.logCallReplyStc[0].status =='1668'){
                        Set<Id> idValues = new Set<Id>();
                        idValues.add(cseObjFromPowerOn.Id);
                        //CaseCallouts.postCallout(idValues,true);
                        Id jobId= System.enqueueJob(new SPEN_CaseCalloutQueueable(idValues));
                    }
                    SPEN_IntegrationRequest__c intReqst = new SPEN_IntegrationRequest__c();
            		intReqst.SPEN_Status__c = 'Failed';
            		intReqst.SPEN_RequestedBy__c = cseObjFromPowerOn.CreatedById;
            		intReqst.SPEN_IntegrationRequestServiceClass__c = 'SDIFLogCallReply';
                    intReqst.SPEN_RelatedRecord__c = cseObjFromPowerOn.Id;
                    intReqst.SPEN_Response__c = replacedString;
                    intReqst.SPEN_ErrorMessage__c = cseLogCall.logCallReplyStc[0].errorMsg;
                    insert intReqst;
                    //system.debug('==intReqst=='+intReqst);
                    //system.debug('cseObjFromPowerOn.SPEN_PowerOnCallReference__c: '+cseObjFromPowerOn.SPEN_PowerOnCallReference__c);
                }  
            }   
        }
        upsert cseObjFromPowerOn;
        return cseObjFromPowerOn;  
    }  
}