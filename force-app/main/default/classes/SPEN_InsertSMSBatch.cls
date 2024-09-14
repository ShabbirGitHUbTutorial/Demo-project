/**
* @description       : This batch class is used to insert the SPEN_SMS__c records.
* 						class.
* @author            : ramesh.c.singh@accenture.com
* @group             : 
* @last modified on  : 01-24-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SPEN_InsertSMSBatch implements Database.Batchable<sObject>,Database.Stateful {
    Set<String> setOfUnplannedByPassFault = new Set<String>{'SPEN_UnplannedFault','SPEN_UnplannedBypass'};
    Id smsBroadCastRecordTypeId = Schema.SObjectType.SPEN_SMS__c.getRecordTypeInfosByName().get('Broadcast').getRecordTypeId();
    List<SPEN_SMS__c> listOfAllSMSRecords = new List<SPEN_SMS__c>();
    SPEN_CommunicationScheduler__c commSchdUpdated = new SPEN_CommunicationScheduler__c();
    Set<Id> setOfDuplicateContactIds=new Set<Id>();
    Map<SPEN_CommunicationScheduler__c, Id> mapOfCommSchVsIncident = new Map<SPEN_CommunicationScheduler__c, Id>();
    
    Map<SPEN_CommunicationScheduler__c, List<Boolean>> mapOfCommSchedulerWithCheckboxes = new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
    
    Set<Id> incidentIds = new Set<Id>();
    Set<Id> setSMSSurveyId = new Set<Id>();
    
    public Integer batchIndex = 0;
    String messagingTaskEventName ='';
    String incidentRestoredStatus = 'Restored';
    List<SPEN_CommunicationScheduler__c> lstCommunicationScheduler = new List<SPEN_CommunicationScheduler__c>();
    
    Map<String, SPEN_CommunicationScheduler__c> mapDistrictToCommSch = new Map<String, SPEN_CommunicationScheduler__c>();
    Set<String> setDistrict = new Set<String>();
    Set<String> setPremId = new Set<String>();
    List<SPEN_CommunicationScheduler__c> lstPremCommSchRecords = new List<SPEN_CommunicationScheduler__c>();
    //Boolean flagPsrCustomer = false;  SFAMS-594
    //Boolean flagNonPsrCustomer = false; SFAMS-594
    // Boolean flagPsrCalledInCustomer = false; SFAMS-594
    //Boolean flagNonPsrCalledInCustomer = false; SFAMS-594
    //Bulkification S
    Set<Id> setPSRIncident = new Set<Id>();
    Set<Id> setNonPSRIncident = new Set<Id>();
    Set<Id> setCalledInPSRIncident = new Set<Id>();
    Set<Id> setCalledInNonPSRIncident = new Set<Id>();
    Map<Id,Id> mapIncident2MsgTasK = new Map <Id,Id>();
    //SFAMS-594: Bulkification of Communication Schedular Append code to fix
    Map<String, String> incidentMessagingTaskIdMap = new Map<String, String>();
    Map<String, String> messagingTaskCommunicationSchedulerIdMap = new Map<String, String>();
    Map<String, SPEN_CommunicationScheduler__c> commSchedulerMap = new Map<String, SPEN_CommunicationScheduler__c>();
    //SFAMS-693: UAT - Communication Scheduler still failing when all scheduled at once
    List<PremiseSchedulerWrapperClass> premiseWrapperList = new List<PremiseSchedulerWrapperClass>();
    //Bulkification E
    public SPEN_InsertSMSBatch(Map<String, SPEN_CommunicationScheduler__c> mapDistrictToCommSch) {
        this.mapDistrictToCommSch = mapDistrictToCommSch;
        this.setDistrict = mapDistrictToCommSch.keySet();//test
        this.commSchdUpdated = mapDistrictToCommSch.values();
    }
    //[CRMD-4073]
    public SPEN_InsertSMSBatch(List<SPEN_CommunicationScheduler__c> lstPremCommSchRecords) {
        //this.setPremId = setPremId; //SFAMS-693:
        //this.lstPremCommSchRecords = lstPremCommSchRecords;//SFAMS-693:
       // this.commSchdUpdated = lstPremCommSchRecords[0];//SFAMS-693:
        //SFAMS-693: UAT - Communication Scheduler still failing when all scheduled at once
        Set<String> tempSetPremId = new Set<String>();
        for(SPEN_CommunicationScheduler__c comScheduler : lstPremCommSchRecords){
            Set<String> tempPremiseIds= new Set<String>();
            String messagingTasksPremiseIds = comScheduler.SPEN_MessagingTaskId__r.SPEN_PremiseIds__c;
            String removedWhiteSpacedString = messagingTasksPremiseIds.deleteWhitespace(); //INC2897181:white-space issue fixed
            this.setPremId.addAll(removedWhiteSpacedString.split(','));
            tempPremiseIds.addAll(removedWhiteSpacedString.split(','));
            PremiseSchedulerWrapperClass premiseWrapper = new PremiseSchedulerWrapperClass();
            premiseWrapper.messagingTask = comScheduler.SPEN_MessagingTaskId__c;
            premiseWrapper.commScheduler = comScheduler;
            premiseWrapper.premiseIds =  tempPremiseIds;
            premiseWrapperList.add(premiseWrapper);
        }
        
    }
    public SPEN_InsertSMSBatch( Map<SPEN_CommunicationScheduler__c, Id> mapOfCommSchVsIncident, Map<SPEN_CommunicationScheduler__c, List<Boolean>> mapOfCommSchedulerWithCheckboxes, Integer batchIndex) {
        this.batchIndex = batchIndex;
        this.mapOfCommSchVsIncident = mapOfCommSchVsIncident;
        this.mapOfCommSchedulerWithCheckboxes = mapOfCommSchedulerWithCheckboxes;
        
        lstCommunicationScheduler.addAll(mapOfCommSchedulerWithCheckboxes.keySet());
        
        //Incident vs PSR
        // Create separate set Incident Ids for Impacted Prem and Case
        //SFAMS-594: Bulkification of Communication Schedular
        for(SPEN_CommunicationScheduler__c commSch : lstCommunicationScheduler)
        {
            commSchedulerMap.put(commSch.Id, commSch);
            if(commSch.SPEN_SendSMSMCtoPSR__c ){
                setPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            } 
            if(commSch.SPEN_SendSMStoAllCustomerinScope__c){
                setNonPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            }
            if(commSch.SPEN_SendSMStoPSRCalledin__c ){
                setCalledInPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            }
            if(commSch.SPEN_SendSMSMCtocalledin__c){
                setCalledInNonPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            }
            
        }
        
        //Bulkification E
        //this.commSchdUpdated = lstCommunicationScheduler[0];
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select id from case where id = null';
        String psrContactValue= 'Customer';
        if(mapDistrictToCommSch.keySet().size() > 0){
            query = 'select Id,SPEN_RelatedContact__c,SPEN_Role__c,SPEN_RelatedContact__r.SPEN_PSR__c,SPEN_RelatedContact__r.MobilePhone,SPEN_DistrictValue__c,SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c,SPEN_Premise__c, SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c,SPEN_RelatedContact__r.Phone from SPEN_ContactPremise__c where  SPEN_DistrictValue__c in :setDistrict and SPEN_RelatedContact__r.SPEN_PSR__c = true and SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c = true and ' +' SPEN_Role__c = :psrContactValue'+  ' WITH SECURITY_ENFORCED';
        }
        if(!setPremId.isEmpty()){
            query = 'select Id,SPEN_RelatedContact__c,SPEN_Role__c,SPEN_RelatedContact__r.SPEN_PSR__c,SPEN_RelatedContact__r.MobilePhone,SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c,SPEN_Premise__c, SPEN_Premise__r.SPEN_PremiseID__c, SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c,SPEN_RelatedContact__r.Phone from SPEN_ContactPremise__c  WHERE SPEN_Role__c = :psrContactValue AND SPEN_Premise__r.SPEN_PremiseID__c IN: setPremId';
        }
        if((this.batchIndex == 1) && !mapOfCommSchVsIncident.isEmpty()  && (!setPSRIncident.isEmpty() || !setNonPSRIncident.isEmpty())){
            query = 'SELECT Id, SPEN_CustomerMobileNumberFormula__c, SPEN_RelatedCustomerFormula__c, SPEN_PSRCheckFormula__c, SPEN_ContactPremise__r.Id, SPEN_ContactPremise__r.SPEN_Premise__c,SPEN_ImpactedPremise__c.SPEN_RelatedIncident__c,SPEN_PreferredMethodofContactFormula__c,SPEN_PremiseId__c,SPEN_CustomerTelephoneNumberFormula__c,SPEN_Status__c,SPEN_CustomerOtherPhoneFormula__c FROM SPEN_ImpactedPremise__c where SPEN_RelatedIncident__c IN :setPSRIncident OR SPEN_RelatedIncident__c IN: setNonPSRIncident'/*+ ' WITH SECURITY_ENFORCED'*/;
        }
        /*else if((this.batchIndex == 1) && !mapOfCommSchVsIncident.isEmpty()  && !setNonPSRIncident.isEmpty()){
query = 'SELECT Id, SPEN_CustomerMobileNumberFormula__c, SPEN_RelatedCustomerFormula__c, SPEN_PSRCheckFormula__c, SPEN_ContactPremise__r.Id, SPEN_ContactPremise__r.SPEN_Premise__c,SPEN_ImpactedPremise__c.SPEN_RelatedIncident__c,SPEN_PreferredMethodofContactFormula__c,SPEN_PremiseId__c,SPEN_CustomerTelephoneNumberFormula__c,SPEN_Status__c,SPEN_CustomerOtherPhoneFormula__c FROM SPEN_ImpactedPremise__c where SPEN_RelatedIncident__c IN :setNonPSRIncident'+  ' WITH SECURITY_ENFORCED';
}*/
        else if((this.batchIndex == 2) && !mapOfCommSchVsIncident.isEmpty() && (!setCalledInPSRIncident.isEmpty() || !setCalledInNonPSRIncident.isEmpty())){
            // write query for case route.
            query = 'select id,ContactId, contact.MobilePhone,contact.SPEN_PSR__c, Contact.SPEN_PreferredMethodofContact__c,SPEN_AddressPremise__c,SPEN_Incident__c, Contact.Phone,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c,SPEN_PreferredMethodofContact__c,RecordType.Name,RecordType.DeveloperName,Status from case where (SPEN_Incident__c IN :setCalledInPSRIncident OR SPEN_Incident__c IN: setCalledInNonPSRIncident) AND RecordType.DeveloperName IN :setOfUnplannedByPassFault'/*+  ' WITH SECURITY_ENFORCED'*/;
        }
        /*else if((this.batchIndex == 2) && !mapOfCommSchVsIncident.isEmpty() && !setCalledInNonPSRIncident.isEmpty()){
// write query for case route.
query = 'select id,ContactId, contact.MobilePhone,contact.SPEN_PSR__c, Contact.SPEN_PreferredMethodofContact__c,SPEN_AddressPremise__c,SPEN_Incident__c, Contact.Phone,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c,SPEN_PreferredMethodofContact__c,RecordType.Name,RecordType.DeveloperName,Status from case where SPEN_Incident__c IN :setCalledInNonPSRIncident'+  ' WITH SECURITY_ENFORCED';
}*/
        
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<sObject> lstSobject){
        
        try{
            if( !setDistrict.isEmpty() && !lstSobject.isEmpty() && lstSobject[0].id.getSObjectType().getDescribe().getName() == 'SPEN_ContactPremise__c'){
                sendSMSToDistrict(lstSobject);
            }
            if(!setPremId.isEmpty() && !lstSobject.isEmpty() && lstSobject[0].id.getSObjectType().getDescribe().getName() == 'SPEN_ContactPremise__c'){
                sendSMSToPremise(lstSobject);
            }
            if((this.batchIndex == 1)   && !lstSobject.isEmpty() && /*this.flagPsrCustomer */ !setPSRIncident.isEmpty()){
                List<SPEN_ImpactedPremise__c> lstOfImpactedPremises = (List<SPEN_ImpactedPremise__c>)lstSobject;
                doOperationOnImpactedPremise(lstOfImpactedPremises,'PSRCustomer');
            }
            if((this.batchIndex == 1) && !lstSobject.isEmpty() && /*this.flagNonPsrCustomer*/ !setNonPSRIncident.isEmpty()){
                List<SPEN_ImpactedPremise__c> lstOfImpactedPremises = (List<SPEN_ImpactedPremise__c>)lstSobject;
                doOperationOnImpactedPremise(lstOfImpactedPremises, 'NonPSRCustomer');
            }
            if((this.batchIndex == 2)   && !lstSobject.isEmpty() &&  /*this.flagPsrCalledInCustomer*/ !setCalledInPSRIncident.isEmpty()){
                System.debug('BatchIndex setCalledInPSRIncident***'+this.batchIndex);
                List<Case> lstOfCases = (List<Case>)lstSobject;
                doOperationOnCases(lstOfCases,'PSRCalledInCustomer');
                
            }
            if((this.batchIndex == 2)   && !lstSobject.isEmpty() &&  /*this.flagNonPsrCalledInCustomer*/ !setCalledInNonPSRIncident.isEmpty()){
                System.debug('BatchIndex setCalledInNonPSRIncident***'+this.batchIndex);
                List<Case> lstOfCases = (List<Case>)lstSobject;
                doOperationOnCases(lstOfCases, 'NonPSRCalledInCustomer');
            }

            if (!setSMSSurveyId.isEmpty())
            { 
                Map<Id,SPEN_SMS__c> mapIdSMS = new Map <Id,SPEN_SMS__c> ([SELECT Id, Name, SPEN_IncidentId__c, SPEN_ContactId__c, SPEN_Message__c, SPEN_IsProactive__c, SPEN_CaseId__c FROM SPEN_SMS__c where id in :setSMSSurveyId and SPEN_Event__c='Incident Restored' and SPEN_Status__c = 'Created']);
                if (!mapIdSMS.isEmpty()) 
                {
                    Id jobId;
                    jobId = System.enqueueJob(new SPEN_FaultSurveyQueueable(mapIdSMS.keySet(), 'Faults', 'SMS')); 
                    setSMSSurveyId.clear();
                }
            }
                        
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
        
    }
    public void doOperationOnImpactedPremise(List<SPEN_ImpactedPremise__c> lstOfImpactedPremises, String psrNonPsrCheck){
        List<SPEN_SMS__c> lstSMS = new List<SPEN_SMS__c>();
        
        List<SPEN_CommunicationScheduler__c> lstCommSchToUpdate = new List<SPEN_CommunicationScheduler__c>();
        
        Map<Id, SPEN_ImpactedPremise__c> mapContactIdToImpactedPremise = new Map<Id, SPEN_ImpactedPremise__c>();
        Map<Id, Case> mapContactIdToCase = new Map<Id, Case>();
        Map<Id, SPEN_Sms__c> mapContactIdToSMS = new Map<Id, SPEN_Sms__c>(); 
        for(SPEN_ImpactedPremise__c impactedPremise : lstOfImpactedPremises){
            if(String.isNotBlank(impactedPremise.SPEN_RelatedCustomerFormula__c) && (impactedPremise.SPEN_PSRCheckFormula__c == true) && ('PSRCustomer'.equalsIgnoreCase(psrNonPsrCheck))){
                mapContactIdToImpactedPremise.put(impactedPremise.SPEN_RelatedCustomerFormula__c, impactedPremise);
            }
            else if(String.isNotBlank(impactedPremise.SPEN_RelatedCustomerFormula__c) && (impactedPremise.SPEN_PSRCheckFormula__c == false) && ('NonPSRCustomer'.equalsIgnoreCase(psrNonPsrCheck))){
                mapContactIdToImpactedPremise.put(impactedPremise.SPEN_RelatedCustomerFormula__c, impactedPremise);
            }
        }

        for(Case cse : [select id,ContactId from Case where ((SPEN_Incident__c IN :setPSRIncident OR SPEN_Incident__c IN :setNonPSRIncident) AND RecordType.DeveloperName ='SPEN_UnplannedFault' AND ContactId IN :mapContactIdToImpactedPremise.keySet())])
        {
            mapContactIdToCase.put(cse.ContactId,cse);
        }

        for(SPEN_Sms__c sms : [select id,SPEN_ContactId__c from SPEN_Sms__c where (SPEN_IncidentId__c IN :setPSRIncident OR SPEN_IncidentId__c IN :setNonPSRIncident) AND SPEN_ContactId__c IN :mapContactIdToImpactedPremise.keySet()])
        {
            mapContactIdToSMS.put(sms.SPEN_ContactId__c,sms);
        }

        for(Id contactId : mapContactIdToImpactedPremise.keySet()){
            
            if(!setOfDuplicateContactIds.contains(contactId)){
                SPEN_ImpactedPremise__c objImpactedPremise = mapContactIdToImpactedPremise.get(contactId);                
                // CRMD-5225 condition added at below places.
                if(objImpactedPremise!= null  && ((objImpactedPremise.SPEN_PreferredMethodofContactFormula__c =='T' && 
                                                   (objImpactedPremise.SPEN_CustomerMobileNumberFormula__c != null || 
                                                    (objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c != null && 
                                                     objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c.startsWith('07')))) ||
                                                  (objImpactedPremise.SPEN_PreferredMethodofContactFormula__c == null && 
                                                   (objImpactedPremise.SPEN_CustomerMobileNumberFormula__c != null || 
                                                    (objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c != null && 
                                                     objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c.startsWith('07')))) || 
                                                  (objImpactedPremise.SPEN_PreferredMethodofContactFormula__c == 'H' && 
                                                   objImpactedPremise.SPEN_CustomerTelephoneNumberFormula__c == null && 
                                                   (objImpactedPremise.SPEN_CustomerMobileNumberFormula__c != null || 
                                                    (objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c != null && 
                                                     objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c.startsWith('07'))))))
                {
                    String incidentId = mapContactIdToImpactedPremise.get(contactId).SPEN_RelatedIncident__c;
                    SPEN_CommunicationScheduler__c commSch = commSchedulerMap.get(messagingTaskCommunicationSchedulerIdMap.get(incidentMessagingTaskIdMap.get(incidentId)));
                    if((!mapContactIdToCase.isEmpty() && mapContactIdToCase.containsKey(contactId)) || (!mapContactIdToSMS.isEmpty() && mapContactIdToSMS.containsKey(contactId)) ||  !'Incident Restored'.equalsIgnoreCase(commSch.SPEN_Event__c))
                    {
                    if(!lstCommSchToUpdate.contains(commSch)){
                        commSch.SPEN_Status__c = 'Executed';
                        lstCommSchToUpdate.add(commSch);
                    }
                    if(commSch.SPEN_SendSMSMCtoPSR__c || commSch.SPEN_SendSMStoAllCustomerinScope__c ){
                        SPEN_SMS__c objSMS = new SPEN_SMS__c();
                        objSMS.SPEN_ContactId__c = contactId;
                        objSMS.SPEN_IncidentId__c = incidentId;
                        objSMS.SPEN_CommunicationSchedulerId__c = messagingTaskCommunicationSchedulerIdMap.get(incidentMessagingTaskIdMap.get(incidentId));
                        if(objImpactedPremise.SPEN_PSRCheckFormula__c){
                            objSMS.SPEN_Message__c = commSch.SPEN_Message__c;
                        }
                        else{
                            objSMS.SPEN_Message__c = commSch.SPEN_NonPSRMessage__c;
                        }
                        objSMS.SPEN_Event__c = commSch.SPEN_Event__c;
                        
                        objSMS.RecordTypeId = smsBroadCastRecordTypeId;
                            objSMS.SPEN_Status__c = commSch.SPEN_Event__c != 'Incident Restored' ? 'Ready' : 'Created';
                        objSMS.SPEN_MessageType__c = 'Outbound';
                        String mobilePhone = String.isNotBlank(mapContactIdToImpactedPremise.get(contactId).SPEN_CustomerMobileNumberFormula__c) ? mapContactIdToImpactedPremise.get(contactId).SPEN_CustomerMobileNumberFormula__c : mapContactIdToImpactedPremise.get(contactId).SPEN_CustomerOtherPhoneFormula__c;
                        objSMS.SPEN_Mobile__c = mobilePhone.startsWith('0') ? ('+44'+mobilePhone.removeStart('0')) : mobilePhone;
                        objSMS.SPEN_PremiseId__c = mapContactIdToImpactedPremise.get(contactId).SPEN_ContactPremise__r.SPEN_Premise__c;
                            objSMS.SPEN_CaseId__c = mapContactIdToCase.containskey(contactId) && commSch.SPEN_Event__c =='Incident Restored' ? mapContactIdToCase.get(contactId).id : null;
                            objSMS.SPEN_IsProactive__c = mapContactIdToSMS.containskey(contactId) && commSch.SPEN_Event__c =='Incident Restored' ? true : false;
                        lstSMS.add(objSMS);
                        }
                    }
                }
            }
            setOfDuplicateContactIds.add(contactId);
        }
        Set<Id> setSMSId = new Set<Id>();
        if(!lstSMS.isEmpty()){
            //if(!Test.isRunningTest()){
            Database.SaveResult[] srList = Database.insert(lstSMS, false);
            
            for (Database.SaveResult sr : srList) {
                if(sr.isSuccess()){
                    setSMSId.add(sr.getId());
                    setSMSSurveyId.add(sr.getId());
                }
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('BatchException', 'InsertSMSBatch','doOperationOnImpactedPremise',err.getMessage()); 
                    }
                }
            }
            //}
        }
        if(!lstCommSchToUpdate.isEmpty()){
            update lstCommSchToUpdate;
        }
    }
    
    public void doOperationOnCases(List<Case> lstOfCases,  String psrNonPsrCheck){
        List<SPEN_SMS__c> lstSMS = new List<SPEN_SMS__c>();
        String recordTypeBypass = CasesConstants.Case_UnplannedBypass;
        List<Contact> byPassContactName = new List<Contact>();
        byPassContactName = [SELECT Id, Name FROM Contact where Name = :System.Label.SPEN_SMSUnidentifiedContact LIMIT 1];
        List<Case> lstOfCasesforCalledIn = new List<Case>();
        //CRMD-5124 SMS Related Changes//
        Set<Id> setofContactIds= new  Set<Id>();
        List<SPEN_CommunicationScheduler__c> lstCommSchToUpdate = new List<SPEN_CommunicationScheduler__c>();
        for(Case cse : lstOfCases){
            if(((cse.contact != null && cse.contact.SPEN_PSR__c == false) ||  recordTypeBypass.equalsIgnoreCase(cse.RecordType.DeveloperName)) && ('NonPSRCalledInCustomer'.equalsIgnoreCase(psrNonPsrCheck))){
                lstOfCasesforCalledIn.add(cse);
            }
            if(cse.contact != null && (cse.contact.SPEN_PSR__c == true )  && 'PSRCalledInCustomer'.equalsIgnoreCase(psrNonPsrCheck)){
                lstOfCasesforCalledIn.add(cse);
            }
        }
        for(Case objCase : lstOfCasesforCalledIn){
            if((objCase.SPEN_PreferredMethodofContact__c =='T' && objCase.SPEN_CallerMobileTelephone__c != null) || 
               (objCase.SPEN_PreferredMethodofContact__c == null && objCase.SPEN_CallerMobileTelephone__c != null) || 
               (objCase.SPEN_PreferredMethodofContact__c == 'H' && objCase.SPEN_CallerTelephone__c == null && objCase.SPEN_CallerMobileTelephone__c != null)){
                   SPEN_CommunicationScheduler__c commSch = commSchedulerMap.get(messagingTaskCommunicationSchedulerIdMap.get(incidentMessagingTaskIdMap.get(objCase.SPEN_Incident__c)));
                   if(!lstCommSchToUpdate.contains(commSch)){
                        commSch.SPEN_Status__c = 'Executed';
                        lstCommSchToUpdate.add(commSch);
                    }
                   if(commSch.SPEN_SendSMSMCtocalledin__c || commSch.SPEN_SendSMStoPSRCalledin__c ){
                       SPEN_SMS__c objSMS = New SPEN_SMS__c();
                       if('Unplanned – Bypass'.equalsIgnoreCase(objCase.RecordType.Name) && objCase.ContactId == null && !byPassContactName.isEmpty()){
                           objSMS.SPEN_ContactId__c = byPassContactName[0].Id;
                       }
                       else if(objCase.ContactId == null && !byPassContactName.isEmpty()){
                           objSMS.SPEN_ContactId__c = byPassContactName[0].Id;
                       }
                       else{
                           objSMS.SPEN_ContactId__c = objCase.ContactId;
                       }
                       objSMS.RecordTypeId = smsBroadCastRecordTypeId;
                       objSMS.SPEN_IncidentId__c = objcase.SPEN_Incident__c;
                       objSMS.SPEN_CommunicationSchedulerId__c = commSch.Id;
                       if(objCase.contact.SPEN_PSR__c == true){
                           objSMS.SPEN_Message__c = commSch.SPEN_Message__c;
                       }
                       else{
                           objSMS.SPEN_Message__c = commSch.SPEN_NonPSRMessage__c;
                       }
                       objSMS.SPEN_Event__c = commSch.SPEN_Event__c;
                       //CRMD-5124 SMS Related Changes//
                       if(setofContactIds.contains(objCase.ContactId)){
                           objSMS.SPEN_Status__c = 'Potentially Duplicate';    
                       }
                       else if(!'Incident Restored'.equalsIgnoreCase(commSch.SPEN_Event__c))
                       {
                           objSMS.SPEN_Status__c = 'Ready';  
                       }
                       else
                       {
                            objSMS.SPEN_Status__c = 'Created';
                       }
                       String mobilephone = objCase.SPEN_CallerMobileTelephone__c;
                       objSMS.SPEN_Mobile__c = String.isNotBlank(mobilephone) && mobilephone.startsWith('0') ? '+44'+mobilePhone.removeStart('0'):mobilePhone ;
                       objSMS.SPEN_MessageType__c = 'Outbound';
                       objSMS.SPEN_CaseId__c = objCase.id;
                       objSMS.SPEN_PremiseId__c = objCase.SPEN_AddressPremise__c;
                       lstSMS.add(objSMS);
                   }
               }
            //CRMD-5124 SMS Related Changes//
            setofContactIds.add(objCase.ContactId);
        }
        System.debug('lstSMS****'+lstSMS);
        System.debug('lstCommSchToUpdate****'+lstCommSchToUpdate);
        Set<Id> setSMSId = new Set<Id>();
        if(!lstSMS.isEmpty()){
            // if(!Test.isRunningTest()){
            Database.SaveResult[] srList = Database.insert(lstSMS, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if(sr.isSuccess()){
                    setSMSId.add(sr.getId());
                    setSMSSurveyId.add(sr.getId());
                }
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('BatchException', 'InsertSMSBatch','doOperationOnCases',err.getMessage()); 
                    }
                }
            }
            
        }
        if(!lstCommSchToUpdate.isEmpty()){
            update lstCommSchToUpdate;
        }
    }
    
    
    public void sendSMSToDistrict(List<sObject> lstSobject){
        List<SPEN_SMS__c> lstSMS = New List<SPEN_SMS__c>();
        List<SPEN_ContactPremise__c> lstContactPremise = (List<SPEN_ContactPremise__c>)lstSobject;
        for(SPEN_ContactPremise__c objCP :lstContactPremise){
            if(String.isNotBlank(objCP.SPEN_DistrictValue__c) && objCP.SPEN_RelatedContact__c != null && objCP.SPEN_RelatedContact__r.SPEN_PSR__c && ((objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c =='T' && objCP.SPEN_RelatedContact__r.MobilePhone != null) || (objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == null && objCP.SPEN_RelatedContact__r.MobilePhone != null) || (objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == 'H' && objCP.SPEN_RelatedContact__r.Phone == null && objCP.SPEN_RelatedContact__r.MobilePhone != null))){
                SPEN_SMS__c objSMS = New SPEN_SMS__c();
                objSMS.SPEN_ContactId__c = objCP.SPEN_RelatedContact__c;
                objSMS.RecordTypeId = smsBroadCastRecordTypeId;
                objSMS.SPEN_CommunicationSchedulerId__c = mapDistrictToCommSch.get(objCP.SPEN_DistrictValue__c.toLowerCase()).Id;
                objSMS.SPEN_Message__c = mapDistrictToCommSch.get(objCP.SPEN_DistrictValue__c.toLowerCase()).SPEN_Message__c;
                objSMS.SPEN_Event__c = mapDistrictToCommSch.get(objCP.SPEN_DistrictValue__c.toLowerCase()).SPEN_Event__c;
                objSMS.SPEN_Status__c = 'Ready';
                objSMS.SPEN_MessageType__c = 'Outbound';
                String mobilePhone = objCP.SPEN_RelatedContact__r.MobilePhone;
                objSMS.SPEN_Mobile__c = mobilePhone.startsWith('0') ? '+44'+mobilePhone.removeStart('0'):mobilePhone ;
                objSMS.SPEN_PremiseId__c = objCP.SPEN_Premise__c;
                lstSMS.add(objSMS);
            }
        }
        
        if(!lstSMS.isEmpty()){
            if(!Test.isRunningTest()){
                //insert lstSMS;
                Database.SaveResult[] srList = Database.insert(lstSMS, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            SEL_LoggingService.log('BatchException', 'InsertSMSBatch','sendSMSToDistrict',err.getMessage()); 
                        }
                    }
                }
            }
        }
        
    }
    //[CRMD-4073]
    public void sendSMSToPremise(List<sObject> lstSobject){ 
        List<SPEN_SMS__c> lstSMS = New List<SPEN_SMS__c>();
        List<SPEN_ContactPremise__c> lstContactPremise = (List<SPEN_ContactPremise__c>)lstSobject;
        Map<String, SPEN_ContactPremise__c> premiseContactPremiseMap = new Map<String, SPEN_ContactPremise__c>();  //SFAMS-693      
        List<SPEN_CommunicationScheduler__c> updateCommunicationScheduler = new List<SPEN_CommunicationScheduler__c>();//SFAMS-693
        //SFAMS-693: UAT - Communication Scheduler still failing when all scheduled at once  logic start
        for(SPEN_ContactPremise__c conPremise : lstContactPremise){
            premiseContactPremiseMap.put(conPremise.SPEN_Premise__r.SPEN_PremiseID__c, conPremise);
        }
        for(PremiseSchedulerWrapperClass pSchWrapper : premiseWrapperList){
            if(!updateCommunicationScheduler.contains(pSchWrapper.commScheduler)){
                pSchWrapper.commScheduler.SPEN_Status__c = 'Executed';
                updateCommunicationScheduler.add(pSchWrapper.commScheduler);
            }
            for(String premiseId : pSchWrapper.premiseIds){
                if(premiseContactPremiseMap.containsKey(premiseId)){
                    SPEN_ContactPremise__c objCP = premiseContactPremiseMap.get(premiseId);
						if(objCP.SPEN_RelatedContact__c != null && ((objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c =='T' && objCP.SPEN_RelatedContact__r.MobilePhone != null) || 
                                                                    (objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == null && objCP.SPEN_RelatedContact__r.MobilePhone != null) || 
                                                                    (objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == 'H' && objCP.SPEN_RelatedContact__r.Phone == null && objCP.SPEN_RelatedContact__r.MobilePhone != null))){                        SPEN_SMS__c objSMS = New SPEN_SMS__c();
                        objSMS.SPEN_ContactId__c = objCP.SPEN_RelatedContact__c;
                        objSMS.RecordTypeId = smsBroadCastRecordTypeId;
                        objSMS.SPEN_CommunicationSchedulerId__c = pSchWrapper.commScheduler.Id;
                        objSMS.SPEN_Message__c = pSchWrapper.commScheduler.SPEN_Message__c;
                        objSMS.SPEN_Event__c = pSchWrapper.commScheduler.SPEN_Event__c;
                        objSMS.SPEN_Status__c = 'Ready';
                        objSMS.SPEN_MessageType__c = 'Outbound';
                        String mobilePhone = objCP.SPEN_RelatedContact__r.MobilePhone;
                        objSMS.SPEN_Mobile__c = mobilePhone.startsWith('0') ? '+44'+mobilePhone.removeStart('0'):mobilePhone ;
                        objSMS.SPEN_PremiseId__c = objCP.SPEN_Premise__c;
                        lstSMS.add(objSMS);
                    }
                }
            }
        }
        if(!lstSMS.isEmpty()){
            if(!Test.isRunningTest()){
                //insert lstSMS;
                Database.SaveResult[] srList = Database.insert(lstSMS, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            SEL_LoggingService.log('BatchException', 'InsertSMSBatch','sendSMSToPremise',err.getMessage()); 
                        }
                    }
                }
            }
        }
        //SFAMS-693: UAT - Communication Scheduler still failing when all scheduled at once  logic start
        if(!updateCommunicationScheduler.isEmpty()){
            update updateCommunicationScheduler;
        }
    }
    global void finish(Database.BatchableContext bc){
        Integer customLabelValueSMS=Integer.valueOf(System.Label.SPEN_InsertSMSBatchSize);
        if((this.batchIndex == 1)  && !mapOfCommSchVsIncident.isEmpty() ){            
            Database.executeBatch(new SPEN_InsertSMSBatch(this.mapOfCommSchVsIncident,this.mapOfCommSchedulerWithCheckboxes, 2),customLabelValueSMS);
        }
        System.debug('commSchdUpdated***'+commSchdUpdated);
        if(commSchdUpdated.Id != null){
            SPEN_CommunicationScheduler__c cmmsch = new SPEN_CommunicationScheduler__c();
            cmmsch.Id = commSchdUpdated.Id;
            cmmsch.SPEN_Status__c='Executed';
            update cmmsch;
        }
    }
    public class PremiseSchedulerWrapperClass{
        Public String messagingTask {get; set;}
        Public SPEN_CommunicationScheduler__c commScheduler {get; set;}
        Public Set<String> premiseIds {get; set;}
    }
}