public with sharing class CaseCallouts {
    
    public static void sendUpdatedCaseToPowerOnAPI(Map<Id,Case> oldUpdatedCaseMap, List<Case> newUpdatedCaseList){
        Map<Id, Case> updatedCaseMap = new Map<Id, Case>();
        List<Id> casePlaceCallLst = new List<Id>();
        Boolean criticalINfoFlag = false;
        Id bypasscaseRecordTypeId = ((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();
        try{
        for(Case newCases : newUpdatedCaseList){
            Case caseOldValues = oldUpdatedCaseMap.get(newCases.Id);
            if(newCases.Status == 'Closed'){
                //Do Nothing as it should not be sent to powerON
            }
            else if(isCriticalInfoChanged(caseOldValues,newCases)){ //oldUpdatedCaseMap.get(newCases.Id),newCases)){
                criticalINfoFlag = ((caseOldValues.SPEN_CriticalInformation__c != newCases.SPEN_CriticalInformation__c) && newCases.SPEN_CriticalInformation__c != Null) ? true : criticalINfoFlag;
                updatedCaseMap.put(newCases.Id, newCases);
            }else if(newCases.SPEN_SendtoPowerOn__c == TRUE && newCases.Origin == 'Web'){
                updatedCaseMap.put(newCases.Id, newCases);
            }else if(newCases.SPEN_SendtoPowerOn__c == TRUE && newCases.RecordTypeId == bypasscaseRecordTypeId){
                updatedCaseMap.put(newCases.Id, newCases);
            }
        }
        ////system.debug('updatedCaseMap:' +updatedCaseMap);
        
        if(!updatedCaseMap.isEmpty()){
            //Post Callout
            //system.debug('Calling Post Callout');
            postCallout(updatedCaseMap.keySet(), false, criticalINfoFlag);
        }
        ////system.debug('System.isFuture()------------------------->'+System.isFuture()); 
            
        if(System.isFuture() == false && !System.isBatch() && system.isQueueable() == false)
        {
            //system.debug('TO DEBUG CHECK IN CASE CALLOUT');
            uncheckedSendToPowerOn(updatedCaseMap.keySet());
        }
        }catch(exception ex){
            //system.debug(ex);
            SEL_LoggingService.log(ex);
        }
    }
    
    public static void sendCancelledCaseToPowerOnAPI(Map<Id,Case> oldUpdatedCaseMap, List<Case> newCancelledCaseList){
        Map<Id, Case> cancelledCaseMap = new Map<Id, Case>();
        try{
        for(Case newCancelCases : newCancelledCaseList){
            if(newCancelCases.SPEN_Incident__c == NULL && newCancelCases.Status == 'Cancelled'){
                cancelledCaseMap.put(newCancelCases.Id, newCancelCases);
            }
        }
        //system.debug('cancelledCaseMap:' +cancelledCaseMap);
        
        if(!cancelledCaseMap.isEmpty()){
            //Post Callout
            ////system.debug('Calling Cancle Case Post Callout');
            cancelCasepostCallout(cancelledCaseMap.keySet());
        }
        }catch(exception ex){
            //system.debug(ex);
            SEL_LoggingService.log(ex);
        }
    }
    
    Private static Boolean isCriticalInfoChanged(Case oldCse, Case newCse){
        Boolean isActive = false;
        try{
            //CRMD-4653 : Update PowerOn Calls from SF Case updates
            //CRMD-5257: Update the ThirdParty Damage Details
            if (oldCse.SPEN_CriticalInformation__c != newCse.SPEN_CriticalInformation__c || oldCse.SPEN_Remarks__c != newCse.SPEN_Remarks__c || oldCse.SPEN_CallerName__c != newCse.SPEN_CallerName__c || oldCse.SPEN_CallerTelephone__c != newCse.SPEN_CallerTelephone__c || 
                oldCse.SPEN_CaseCategoryOutcome__c != newCse.SPEN_CaseCategoryOutcome__c || oldCse.SPEN_ThirdPartyName__c != newCse.SPEN_ThirdPartyName__c || oldCse.SPEN_ThirdPartyMobile__c != newCse.SPEN_ThirdPartyMobile__c || oldCse.SPEN_ThirdPartyTelephone__c != newCse.SPEN_ThirdPartyTelephone__c ||
                oldCse.ThirdPartyAddress__c != newCse.ThirdPartyAddress__c || oldCse.SPEN_ThirdPartyDescription__c != newCse.SPEN_ThirdPartyDescription__c || oldCse.SPEN_ThirdPartyCause__c != newCse.SPEN_ThirdPartyCause__c){
                isActive = true;
            }
            
        return isActive;
        }catch(exception ex){
            ////system.debug(ex);
            SEL_LoggingService.log(ex);
            return isActive;
        }
    }
    
    public static void sendCreatedCaseToPowerOnAPI(List<Case> newCreatedCaseList){
        Map<Id, Case> createdCaseMap = new Map<Id, Case>();
        Set<Id> premId = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        List<SPEN_Premise__c> pList = new List<SPEN_Premise__c>();
        Id byPassCaseRecordTypeId = ((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();
        try{
       for(Case newCreatedCases : newCreatedCaseList){
            //system.debug('newCreatedCases.RecordTypeId------>'+newCreatedCases.RecordTypeId);
            ////system.debug('newCreatedCases.RecordType.Name------>'+newCreatedCases.RecordType.Name);
            Id caseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();
            //system.debug('caseRecordTypeId------>'+caseRecordTypeId);
            //Do not send closed cases to powerON
            if(newCreatedCases.Origin!='Web' && newCreatedCases.RecordTypeId != caseRecordTypeId && newCreatedCases.Status !='Closed'){
                 //if(newCreatedCases.Origin!='Web' && newCreatedCases.Status !='Closed'){
                //system.debug('newCreatedCases.Origin');
                createdCaseMap.put(newCreatedCases.Id, newCreatedCases);
            } 
        }
        //system.debug('createdCaseMap:' +createdCaseMap);
        
        if(!createdCaseMap.isEmpty()){
            //Post Callout
            //system.debug('Calling Post Callout');
            postCallout(createdCaseMap.keySet(), false , true);
        } 
        }catch(exception ex){
            //system.debug(ex);
            SEL_LoggingService.log(ex);
        }
    }
    
    @future(callout=true)
    public static void postCallout(Set<Id> caseIdSet, Boolean retry, Boolean criticalInfoFlag){
        Id bypasscaseRecordTypeId = ((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();
        Id faultcaseRecordTypeId = ((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
       
        Case con1 = SPEN_CaseSelector.getUpdateCse(caseIdSet);
        SEL_IntegrationSetting__mdt cmt;
        String criticalinfoData;
        if(retry){
            //system.debug('PowerOnCallByPassAPIErrorStatus');
            cmt = new SEL_IntegrationsSelector().selectByDeveloperName('PowerOnCallByPassAPIErrorStatus');
        }
        else{
            if(con1.SPEN_PowerOnCallReference__c!=null && con1.RecordTypeId == bypasscaseRecordTypeId )
            {
                //system.debug('PowerOnCallByPassAPI');
                cmt = new SEL_IntegrationsSelector().selectByDeveloperName('PowerOnCallByPassAPI');
            }
            
            else
            {
               
               
                    cmt = new SEL_IntegrationsSelector().selectByDeveloperName('PowerOnCallAPI');
                
            }
        }
            
        //system.debug('cmt'+cmt);
        SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);        
        //system.debug(JSON.serialize(con1));
        String message = ser.generateMessage(con1);
        //system.debug('Expected Message'+message);
        /*if(!criticalInfoFlag  && (con1.RecordTypeId == faultcaseRecordTypeId || con1.RecordTypeId == bypasscaseRecordTypeId)){
            //String HTML_TAG_PATTERN = '<sdif:CriticalInformation*?>(.*?)</sdif:CriticalInformation>';
            Pattern objPattren = Pattern.compile(CasesConstants.CRITICALINFORMATION);
            Matcher objMatcher = objPattren.matcher(message);
            while (objMatcher.find()) {
                criticalinfoData = objMatcher.group();
                message = message.remove(criticalinfoData);
            }
        }*/
        //system.debug('After update ***** Message'+ message);
        
        
        SPEN_AuthorizationDetails__mdt authDetailRec = SPEN_AuthorizationDetails__mdt.getInstance('CaseCalloutAuthDetails');
        SPEN_AuthorizationDetails__mdt caseURL = SPEN_AuthorizationDetails__mdt.getInstance('CaseCalloutEndURL');
        //Create Bearer Token
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authDetailRec.SPEN_EndpointURL__c);
        req.setMethod('POST');
        String authorizationHeader =authDetailRec.SPEN_Authheader__c ;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('content-type', 'application/x-www-form-urlencoded'); 
        HTTPResponse res = http.send(req);
        Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        //system.debug('authMap.access_token'+authMap.get('access_token'));
        
        Case caseobj= new Case();
 		if(cmt.SEL_IsMockingEnabled__c==true){

        String expectedResponse = message;
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;    
        httpRequest.setHeader('Content-type', 'application/xml');
        httpRequest.setEndpoint('https://test.salesforce.com');
        httpRequest.setMethod('POST');
        httpRequest.setBody(expectedResponse);
        httpResponse = httpObject.send(httpRequest);
        //system.debug('Response received -->>>> '+httpResponse);

        }
        else{
            try{
                 httpRequest httpRequest = new httpRequest();
                Http httpObject = new Http();
                HttpResponse httpResponse;
                
                httpRequest.setTimeout(2000);
                httpRequest.setHeader('SOAPAction','Call/LogCall');
                httpRequest.setHeader('Content-type', 'text/plain');
                //httpRequest.setHeader('Content-type', 'text/xml');
                httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
                httpRequest.setEndpoint(caseURL.SPEN_EndpointURL__c);
                httpRequest.setMethod('POST');
                httpRequest.setBody(message);
                httpResponse = httpObject.send(httpRequest);
                 /*if(httpResponse.getStatusCode() != 200 || httpResponse.getStatusCode() != 201){
                     SPEN_IntegrationRequest__c createIntegrationReqst= new SPEN_IntegrationRequest__c();
                     createIntegrationReqst.SPEN_RelatedRecord__c = con1.Id;
                     createIntegrationReqst.SPEN_RequestedBy__c = UserInfo.getUserId();
                     createIntegrationReqst.SPEN_Response__c= httpResponse.getBody();
                     createIntegrationReqst.SPEN_Status__c='Completed';
                     insert createIntegrationReqst; 
                 }*/ // Fixed for incident INC3319046_SFAMS-561
          
                /*if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201){
                    //system.debug('PostCallout Successfull'); 
                    //system.debug('Response received -->>>> '+httpResponse);
                    //system.debug('Response received body - '+httpResponse.getBody()); 
                }*/
                //system.debug('Response received -->>>> '+httpResponse);
                //system.debug('Response received body - '+httpResponse.getBody());
            }Catch(CalloutException ex){
                SPEN_IntegrationRequest__c createIntegrationReqst= new SPEN_IntegrationRequest__c();
                createIntegrationReqst.SPEN_RelatedRecord__c = con1.Id;
                createIntegrationReqst.SPEN_RequestedBy__c = UserInfo.getUserId();
                createIntegrationReqst.SPEN_Response__c= ex.getMessage();
                createIntegrationReqst.SPEN_Status__c='Failed';
                insert createIntegrationReqst; 
            }
        }
    }
    
    @future
    Private static void uncheckedSendToPowerOn(Set<Id> caseIdSet){
        //system.debug('Inside uncheckedSendToPowerOn()');
        List<Case> uncheckedSendToPowerOnCaseList = new List<Case>();
        
        if(caseIdSet.IsEmpty()){
            return;
        }else{
            Id bypasscaseRecordTypeId = ((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();
            uncheckedSendToPowerOnCaseList = SPEN_CaseSelector.getUncheckedSendToPowerOnCaseList(caseIdSet);
            for (Case uncheckedSendToPowerOnCase : uncheckedSendToPowerOnCaseList){
                if(uncheckedSendToPowerOnCase.SPEN_SendtoPowerOn__c == true && (uncheckedSendToPowerOnCase.recordTypeId == bypasscaseRecordTypeId)){
                 uncheckedSendToPowerOnCase.SPEN_SendtoPowerOn__c = false; 
                }
                update uncheckedSendToPowerOnCase;
            ////system.debug('uncheckedSendToPowerOnCase.SPEN_SendtoPowerOn__c' +uncheckedSendToPowerOnCase.SPEN_SendtoPowerOn__c);
            }
        }
    }
    
    @future(callout=true)
    private static void cancelCasepostCallout(Set<Id> cancelCaseIdSet){
        SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName('SDIFCancelCallAPI');
        //system.debug('cmt'+cmt);
        SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);
        Case con1 = SPEN_CaseSelector.getCancelCse(cancelCaseIdSet);
        //system.debug(JSON.serialize(con1));
        String message = ser.generateMessage(con1);
        //system.debug('Expected Cancel Case Message'+message);
        
		SPEN_AuthorizationDetails__mdt authDetailRec = SPEN_AuthorizationDetails__mdt.getInstance('CaseCalloutAuthDetails');
        SPEN_AuthorizationDetails__mdt caseURL = SPEN_AuthorizationDetails__mdt.getInstance('CaseCalloutEndURL');
        //Create Bearer Token
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authDetailRec.SPEN_EndpointURL__c);
        req.setMethod('POST');
        String authorizationHeader =authDetailRec.SPEN_Authheader__c ;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //res.getBody();
		Map<String, Object> authMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        if(cmt.SEL_IsMockingEnabled__c==true){
        String expectedCancelledResponse = message;
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;    
        httpRequest.setHeader('Content-type', 'application/xml');
        httpRequest.setEndpoint('https://test.salesforce.com');
        httpRequest.setMethod('POST');
        httpRequest.setBody(expectedCancelledResponse);
        httpResponse = httpObject.send(httpRequest);
        system.debug('Response received -->>>> '+httpResponse);
        }
        else{
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;
        
        httpRequest.setHeader('SOAPAction','Call/LogCall');
        httpRequest.setHeader('Content-type', 'text/plain');
		httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
        //httpRequest.setHeader('Authorization', 'Bearer 582f752b-fd41-31af-882d-bf5f9fc2e403');
        httpRequest.setEndpoint(caseURL.SPEN_EndpointURL__c);
        httpRequest.setMethod('POST');
        httpRequest.setBody(message);
        httpResponse = httpObject.send(httpRequest);

        /*httpRequest.setHeader('SOAPAction','Call/LogCall');
        httpRequest.setHeader('Content-type', 'text/plain');
		httpRequest.setHeader('Authorization', 'Bearer ' +authMap.get('access_token'));
        //httpRequest.setHeader('Authorization', 'Bearer 582f752b-fd41-31af-882d-bf5f9fc2e403');
        httpRequest.setEndpoint('https://spdeveloper.scottishpower.com/SDIF-CRM/0.0.1/service/CrmConector');
        httpRequest.setMethod('POST');
        httpRequest.setBody(message);
        httpResponse = httpObject.send(httpRequest);*/
        
        if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201){
            //system.debug('CancelCasepostCallout Successfull'); 
            //system.debug('CancelCasepostCallout Response received -->>>> '+httpResponse);
            ////system.debug('CancelCasepostCallout Response received body - '+httpResponse.getBody()); 
        }
        ////system.debug('CancelCasepostCallout Response received -->>>> '+httpResponse);
        system.debug('CancelCasepostCallout Response received body - '+httpResponse.getBody());
        }
    }

    /***
     * Author : Rahul Kumar
     * Jira story reference : CRMD-5320
     * Description : To update the Mobile/Telephone number present on the case record to the attached contact's Mobile/Telephone number respectively.
     */
    public static void mobileTelephoneUpdateOnContact(List<Case> lstOfCases, Map<Id, Case> oldMapCases){
        List<Contact> listOfContacts = new List<Contact>();
        
        Set<Id> contactIdSet = new Set<Id>();
        for (Case cse : lstOfCases){
   			contactIdSet.add(cse.ContactId);
		}
        Map<ID,contact> contactMapping = new Map<id,Contact>();
        for (Contact con : [Select id, MobilePhone, Phone, OtherPhone from Contact where ID IN :contactIdSet]){
            contactMapping.put(con.Id, con);
        }

        for(case cse : lstOfCases){
            
            Case oldCase = (oldMapCases.containsKey(cse.Id)) ? oldMapCases.get(cse.Id) : null;
            /** Prepare contacts in case of case updates either of the scenarios:
             * 1. Mobile number or Telephone number are not empty.
             * 2. Contact is linked with case record
             * Scenario in case of insertion of cases.
             *  */ 
            if(oldCase == null && cse.ContactId != null && 'IVR'.equalsIgnoreCase(cse.Origin) && cse.SPEN_CallerMobileTelephone__c!= null ){
        		
                Contact con = new Contact();
                con.Id = cse.ContactId;
               
                if(contactMapping.get(con.Id).MobilePhone != cse.SPEN_CallerMobileTelephone__c && contactMapping.get(con.Id).phone != cse.SPEN_CallerMobileTelephone__c && contactMapping.get(con.Id).OtherPhone != cse.SPEN_CallerMobileTelephone__c)

                {
                	con.MobilePhone = cse.SPEN_CallerMobileTelephone__c;
                }
                
                listOfContacts.add(con);
            }
            else if(oldCase == null && cse.ContactId != null && 'IVR'.equalsIgnoreCase(cse.Origin) && cse.SPEN_CallerTelephone__c!= null ){
                Contact con = new Contact();
                con.Id = cse.ContactId;
                
                if(contactMapping.get(con.Id).phone != cse.SPEN_CallerTelephone__c && contactMapping.get(con.Id).MobilePhone !=cse.SPEN_CallerTelephone__c && contactMapping.get(con.Id).OtherPhone != cse.SPEN_CallerTelephone__c)
                {
                	con.Phone = cse.SPEN_CallerTelephone__c;
                }
                listOfContacts.add(con);
            }
            
            /** Prepare contacts in case of case updates either of the scenarios:
             * 1. Mobile number gets changed on case
             * 2. Telephone number gets changed on case
             * 3. Linked contact got changed on cases
             * Scenario in case of updation of cases.
             *  */ 

            else if(oldCase != null && cse.ContactId != null &&  'IVR'.equalsIgnoreCase(cse.Origin) && ( oldCase.SPEN_CallerMobileTelephone__c != cse.SPEN_CallerMobileTelephone__c || oldCase.ContactId != cse.ContactId)) {

                Contact con = new Contact();
                con.Id = cse.ContactId;
               
                if(contactMapping.get(con.Id).MobilePhone != cse.SPEN_CallerMobileTelephone__c && contactMapping.get(con.Id).phone != cse.SPEN_CallerMobileTelephone__c && contactMapping.get(con.Id).OtherPhone != cse.SPEN_CallerMobileTelephone__c)
                {
                    con.MobilePhone = cse.SPEN_CallerMobileTelephone__c;
                }
               
                listOfContacts.add(con);
                
            }	
            else if(oldCase != null && cse.ContactId != null && 'IVR'.equalsIgnoreCase(cse.Origin) &&  (oldCase.SPEN_CallerTelephone__c != cse.SPEN_CallerTelephone__c  || oldCase.ContactId != cse.ContactId)) {
				
                Contact con = new Contact();
                con.Id = cse.ContactId;
               
                if(contactMapping.get(con.Id).phone != cse.SPEN_CallerTelephone__c && contactMapping.get(con.Id).MobilePhone !=cse.SPEN_CallerTelephone__c && contactMapping.get(con.Id).OtherPhone != cse.SPEN_CallerTelephone__c)
                {
                	con.Phone = cse.SPEN_CallerTelephone__c;
                }
                listOfContacts.add(con);
                
            }
        }
        // Perform the mobile/telephone updates on contacts 
        if(!listOfContacts.isEmpty()){
            try{
                update listOfContacts;
            }
            catch(Exception ex){
                SEL_LoggingService.log(ex);
                throw ex;
            }
            
        }
    }
}