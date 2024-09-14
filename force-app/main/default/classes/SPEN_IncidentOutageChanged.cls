@RestResource(urlMapping ='/IncidentOutageChanged/*')
global with sharing class SPEN_IncidentOutageChanged {
	@HttpPost
    global static void incidentOutageUpdate()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<String> strList = new List<String>();
        String incidentId;
        SPEN_IncidentOutageChangedXMLNodes.SoapBodyNode soapNodeValues = new SPEN_IncidentOutageChangedXMLNodes.SoapBodyNode();
        strList = req.requestBody.toString().split('<soap:Body>');
        String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', '');
        String soapEnv = newStr.replaceAll('soap:', '');
        String finalRequest = soapEnv.replaceAll('<sdif:SDIFIncidentOutageChanged>', '<sdif:SDIFIncidentOutageChanged xmlns="SDIF">'); // added because SDIF not sending Namespace
        finalRequest = finalRequest.replaceAll('sdif:' ,'');
        soapNodeValues.load(finalRequest);
        
        SPEN_IncidentOutageChangedWrapper.RequestBody createResourceWrapper = (SPEN_IncidentOutageChangedWrapper.RequestBody) System.JSON.deserialize(JSON.serialize(soapNodeValues), SPEN_IncidentOutageChangedWrapper.RequestBody.class);
        List<SPEN_IncidentOutageChangedWrapper.IncidentOutageChangedStc> lstOfSDIFStc = new List<SPEN_IncidentOutageChangedWrapper.IncidentOutageChangedStc>();

        Incident incident = new Incident();
        
        if(!createResourceWrapper.SDIFIncidentOutageChanged.isEmpty()){
            for(SPEN_IncidentOutageChangedWrapper.SDIFIncidentOutageChanged outageChangeWrap : createResourceWrapper.SDIFIncidentOutageChanged){
                lstOfSDIFStc = (List<SPEN_IncidentOutageChangedWrapper.IncidentOutageChangedStc>)outageChangeWrap.IncidentOutageChangedStc;
            }
                incident.SPEN_IncidentID__c = lstOfSDIFStc[0].IncidentID;
                incident.SPEN_IncidentReference__c = lstOfSDIFStc[0].IncidentReference;
           		
            Incident incidentFetched;
            try{
                incidentFetched = [SELECT Id, SPEN_IncidentReference__c, SPEN_IncidentID__c,SPEN_GetAffectedPremisesScheduled__c FROM Incident where SPEN_IncidentReference__c = :incident.SPEN_IncidentReference__c and SPEN_IncidentID__c = :incident.SPEN_IncidentID__c LIMIT 1]; // Get incident details from sf based on poweron incident reference and incidentID.
            }catch(Exception ex){
                SEL_LoggingService.log(ex);
            }
            if(incidentFetched !=null && !incidentFetched.SPEN_GetAffectedPremisesScheduled__c){ // if Get Affected Premises Scheduled is false then proceed else do nothing
                incidentFetched.SPEN_GetAffectedPremisesScheduled__c = true;
                try{
                    update incidentFetched;
                }
                catch(Exception ex){
                    SEL_LoggingService.log(ex);
                }
			    enqueueGetAffectedPremiseJob(incidentFetched.SPEN_IncidentReference__c); 
                
            }else if(incidentFetched ==null){
                enqueueGetAffectedPremiseJob(lstOfSDIFStc[0].IncidentReference);
            }
			 
        }

    }
    private static void enqueueGetAffectedPremiseJob(String incidentReference){
        if(String.isNotBlank(incidentReference)){
            List<String> ConfiValueList = SPEN_ImpactedPremisesConstants.ConfigValueList;
            Map<string,integer> configMap = New Map<string,integer>();

            //Configurable delayed integer value in minute from predefined SPEN_ConfigurableSettings__c.
            for(SPEN_ConfigurableSettings__c ConfigSettings : [SELECT Name,SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name IN :ConfiValueList]){
                configMap.put(ConfigSettings.Name,integer.valueOf(ConfigSettings.SPEN_Value__c)); 
            }

            if(!configMap.isEmpty() && configMap.containskey(SPEN_ImpactedPremisesConstants.OUTAGECHANGEDELAY)){
                // Call queuable delayed by configurations 
                System.enqueueJob(new SPEN_GetAffectedPremiseQueueableClass(incidentReference),configMap.get(SPEN_ImpactedPremisesConstants.OUTAGECHANGEDELAY)); 
            }
        }  
    }
}