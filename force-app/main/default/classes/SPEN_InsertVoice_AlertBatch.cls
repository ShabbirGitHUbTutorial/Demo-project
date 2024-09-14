/**
* @description       : This batch class is used to insert the Voice Alert records.
* 						class.
* @author            : ramesh.c.singh@accenture.com
* @group             : 
* @last modified on  : 01-24-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SPEN_InsertVoice_AlertBatch implements Database.Batchable<sObject>,Database.Stateful{
    Set<String> setOfUnplannedByPassFault = new Set<String>{'SPEN_UnplannedFault','SPEN_UnplannedBypass'};
    Map<String, SPEN_CommunicationScheduler__c> mapDistrictToCommSchVA = new Map<String, SPEN_CommunicationScheduler__c>();
    Set<String> setDistrict = new Set<String>();
    SPEN_CommunicationScheduler__c commSchdUpdated = new SPEN_CommunicationScheduler__c();
    public Integer batchIndex = 0;
    Map<SPEN_CommunicationScheduler__c, Id> mapOfCommSchVsIncident = new Map<SPEN_CommunicationScheduler__c, Id>();
    Map<SPEN_CommunicationScheduler__c, List<Boolean>> mapOfCommSchedulerWithCheckboxes = new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
    List<SPEN_CommunicationScheduler__c> lstCommunicationScheduler = new List<SPEN_CommunicationScheduler__c>();
    Set<String> setPremId = new Set<String>();
    Boolean flagPsrCustomer = false;
    Boolean flagNonPsrCustomer = false;
    Boolean flagPsrCalledInCustomer = false;
    Boolean flagNonPsrCalledInCustomer = false;
    
    //Bulkification S
    Set<Id> setPSRIncident = new Set<Id>();
    Set<Id> setNonPSRIncident = new Set<Id>();
    Set<Id> setCalledInPSRIncident = new Set<Id>();
    Set<Id> setCalledInNonPSRIncident = new Set<Id>();
    Map<Id,Id> mapIncident2MsgTasK = new Map <Id,Id>();
    //Bulkification E
    //SFAMS-594: Bulkification of Communication Schedular
    Map<String, String> incidentMessagingTaskIdMap = new Map<String, String>();
    Map<String, String> messagingTaskCommunicationSchedulerIdMap = new Map<String, String>();
    Map<String, SPEN_CommunicationScheduler__c> commSchedulerMap = new Map<String, SPEN_CommunicationScheduler__c>();
    //SFAMS-693: UAT - Communication Scheduler still failing when all scheduled at once
    List<PremiseSchedulerWrapperClass> premiseWrapperList = new List<PremiseSchedulerWrapperClass>();   
    Set<Id> incidentIds = new Set<Id>();
    Set<Id> setOfDuplicateContactIds=new Set<Id>();
    
    Id instantRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
    List<SPEN_CommunicationScheduler__c> lstPremCommSchRecords = new List<SPEN_CommunicationScheduler__c>();
    
    public SPEN_InsertVoice_AlertBatch(Map<String, SPEN_CommunicationScheduler__c> mapDistrictToCommSchVA) {
        this.mapDistrictToCommSchVA = mapDistrictToCommSchVA;
        this.setDistrict = mapDistrictToCommSchVA.keySet();
        this.commSchdUpdated = mapDistrictToCommSchVA.values();
    }
    //[CRMD-4073]
    public SPEN_InsertVoice_AlertBatch(List<SPEN_CommunicationScheduler__c> lstPremCommSchRecords) {
        //this.setPremId = setPremId;//SFAMS-693:
        //this.lstPremCommSchRecords = lstPremCommSchRecords;//SFAMS-693:
        //this.commSchdUpdated = lstPremCommSchRecords[0];//SFAMS-693:
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
    public SPEN_InsertVoice_AlertBatch(Map<SPEN_CommunicationScheduler__c, Id> mapOfCommSchVsIncident, Map<SPEN_CommunicationScheduler__c, List<Boolean>> mapOfCommSchedulerWithCheckboxes, Integer batchIndex) {
        this.batchIndex = batchIndex;
        this.mapOfCommSchVsIncident = mapOfCommSchVsIncident;
        this.mapOfCommSchedulerWithCheckboxes = mapOfCommSchedulerWithCheckboxes;
        
        lstCommunicationScheduler.addAll(mapOfCommSchedulerWithCheckboxes.keySet());
        for(SPEN_CommunicationScheduler__c commSch : lstCommunicationScheduler)
        {
            commSchedulerMap.put(commSch.Id, commSch);
            if(commSch.SPEN_SendVoiceAlerttoPSR__c ){
                setPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            } 
            if(commSch.SPEN_SendVAtoAllCustomerinScope__c){
                setNonPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            }
            if(commSch.SPEN_SendVAtoPSRCalledin__c ){
                setCalledInPSRIncident.add(commSch.SPEN_IncidentId__c);
                if(!incidentMessagingTaskIdMap.containsKey(commSch.SPEN_IncidentId__c)){
                    incidentMessagingTaskIdMap.put(commSch.SPEN_IncidentId__c, commSch.SPEN_MessagingTaskId__c);
                }
                if(!messagingTaskCommunicationSchedulerIdMap.containsKey(commSch.SPEN_MessagingTaskId__c)){
                    messagingTaskCommunicationSchedulerIdMap.put(commSch.SPEN_MessagingTaskId__c, commSch.Id);
                }
            }
            if(commSch.SPEN_SendVoiceAlerttocalledin__c){
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
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'Select id from case where id = null';
        String psrContactValue= 'Customer';
        if(!mapDistrictToCommSchVA.isEmpty()){
            
            query = 'select Id,SPEN_RelatedContact__c,SPEN_Role__c,SPEN_RelatedContact__r.SPEN_PSR__c,SPEN_RelatedContact__r.MobilePhone,SPEN_RelatedContact__r.Phone, SPEN_DistrictValue__c,SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c,SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c from SPEN_ContactPremise__c where  SPEN_DistrictValue__c in :setDistrict and SPEN_RelatedContact__r.SPEN_PSR__c = true and SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c = true';
            query += ' and SPEN_Role__c = \'' + psrContactValue + '\' WITH SECURITY_ENFORCED';
        } 
        if(!setPremId.isEmpty()){
            query = 'select Id,SPEN_RelatedContact__c,SPEN_Role__c,SPEN_RelatedContact__r.SPEN_PSR__c,SPEN_RelatedContact__r.MobilePhone,SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c,SPEN_Premise__c, SPEN_Premise__r.SPEN_PremiseID__c, SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c,SPEN_RelatedContact__r.Phone from SPEN_ContactPremise__c  WHERE SPEN_Role__c = :psrContactValue AND SPEN_Premise__r.SPEN_PremiseID__c IN: setPremId';
        }
        if((this.batchIndex == 1) && !mapOfCommSchVsIncident.isEmpty()  && /*(this.flagPsrCustomer)*/ !setPSRIncident.isEmpty()){
            query = 'SELECT Id, SPEN_CustomerMobileNumberFormula__c, SPEN_RelatedCustomerFormula__c, SPEN_PSRCheckFormula__c, SPEN_ContactPremise__r.Id, SPEN_ContactPremise__r.SPEN_Premise__c,SPEN_ImpactedPremise__c.SPEN_RelatedIncident__c,SPEN_PreferredMethodofContactFormula__c,SPEN_PremiseId__c,SPEN_CustomerTelephoneNumberFormula__c,SPEN_CustomerOtherPhoneFormula__c FROM SPEN_ImpactedPremise__c where SPEN_RelatedIncident__c IN :setPSRIncident';
        }
        else if((this.batchIndex == 2) && !mapOfCommSchVsIncident.isEmpty()  && /*(this.flagNonPsrCustomer)*/ !setNonPSRIncident.isEmpty()){
            query = 'SELECT Id, SPEN_CustomerMobileNumberFormula__c, SPEN_RelatedCustomerFormula__c, SPEN_PSRCheckFormula__c, SPEN_ContactPremise__r.Id, SPEN_ContactPremise__r.SPEN_Premise__c,SPEN_ImpactedPremise__c.SPEN_RelatedIncident__c,SPEN_PreferredMethodofContactFormula__c,SPEN_PremiseId__c,SPEN_CustomerTelephoneNumberFormula__c,SPEN_CustomerOtherPhoneFormula__c FROM SPEN_ImpactedPremise__c where SPEN_RelatedIncident__c IN :setNonPSRIncident';
        }
        else if((this.batchIndex == 3) && !mapOfCommSchVsIncident.isEmpty() &&  /*(this.flagPsrCalledInCustomer)*/ !setCalledInPSRIncident.isEmpty()){
            // write query for case route.
            query = 'select id,ContactId, contact.MobilePhone,contact.SPEN_PSR__c, Contact.SPEN_PreferredMethodofContact__c,SPEN_AddressPremise__c,SPEN_Incident__c, Contact.Phone,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c,SPEN_PreferredMethodofContact__c,RecordType.Name,RecordType.DeveloperName from case where SPEN_Incident__c IN :setCalledInPSRIncident AND RecordType.DeveloperName IN :setOfUnplannedByPassFault';
        }
        else if((this.batchIndex == 4) && !mapOfCommSchVsIncident.isEmpty() &&  /*(this.flagNonPsrCalledInCustomer)*/ !setCalledInNonPSRIncident.isEmpty()){
            // write query for case route.
            query = 'select id,ContactId, contact.MobilePhone,contact.SPEN_PSR__c, Contact.SPEN_PreferredMethodofContact__c,SPEN_AddressPremise__c,SPEN_Incident__c, Contact.Phone,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c,SPEN_PreferredMethodofContact__c,RecordType.Name,RecordType.DeveloperName from case where SPEN_Incident__c IN :setCalledInNonPSRIncident AND RecordType.DeveloperName IN :setOfUnplannedByPassFault';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> lstSobject){
        
        try{
            
            if(!setDistrict.isEmpty() && !lstSobject.isEmpty() && lstSobject[0].id.getSObjectType().getDescribe().getName() == 'SPEN_ContactPremise__c'){
                sendVAToDistrict(lstSobject);
            }
            if(!setPremId.isEmpty() && !lstSobject.isEmpty() && lstSobject[0].id.getSObjectType().getDescribe().getName() == 'SPEN_ContactPremise__c'){
                sendVAToPremise(lstSobject);
            }
            if((this.batchIndex == 1)   && !lstSobject.isEmpty() && /*this.flagPsrCustomer*/ !setPSRIncident.isEmpty()){
                List<SPEN_ImpactedPremise__c> lstOfImpactedPremises = (List<SPEN_ImpactedPremise__c>)lstSobject;
                doOperationOnImpactedPremise(lstOfImpactedPremises,'PSRCustomer');
            }
            if((this.batchIndex == 2) && !lstSobject.isEmpty() && /*this.flagNonPsrCustomer*/ !setNonPSRIncident.isEmpty()){
                List<SPEN_ImpactedPremise__c> lstOfImpactedPremises = (List<SPEN_ImpactedPremise__c>)lstSobject;
                doOperationOnImpactedPremise(lstOfImpactedPremises, 'NonPSRCustomer');
            }
            if((this.batchIndex == 3)   && !lstSobject.isEmpty() &&  /*this.flagPsrCalledInCustomer*/ !setCalledInPSRIncident.isEmpty()){
                List<Case> lstOfCases = (List<Case>)lstSobject;
                doOperationOnCases(lstOfCases,'PSRCalledInCustomer');
            }
            if((this.batchIndex == 4)   && !lstSobject.isEmpty() &&  /*this.flagNonPsrCalledInCustomer*/ !setCalledInNonPSRIncident.isEmpty()){
                List<Case> lstOfCases = (List<Case>)lstSobject;
                doOperationOnCases(lstOfCases, 'NonPSRCalledInCustomer');
            }
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    
    public void sendVAToPremise(List<sObject> lstSobject){
        List<SPEN_VoiceAlert__c> lstVoiceAlert = New List<SPEN_VoiceAlert__c>();
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
                if( objCP.SPEN_RelatedContact__c != null && 
                    ((objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == null && objCP.SPEN_RelatedContact__r.MobilePhone == null && objCP.SPEN_RelatedContact__r.Phone != null ) || 
                    (objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == 'H' && objCP.SPEN_RelatedContact__r.Phone != null))){
                    SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                    objVoiceAlert.SPEN_ContactId__c = objCP.SPEN_RelatedContact__c;
                    objVoiceAlert.RecordTypeId = instantRecordTypeId;
                    objVoiceAlert.SPEN_CommunicationScheduler__c = pSchWrapper.commScheduler.Id;
                    objVoiceAlert.SPEN_BroadcastMessage__c = pSchWrapper.commScheduler.SPEN_Message__c;
                    objVoiceAlert.SPEN_Status__c = 'Ready';
                    lstVoiceAlert.add(objVoiceAlert);
                    }
                }
            }
        }

        if(!lstVoiceAlert.isEmpty()){
            //insert lstVoiceAlert;
            Database.SaveResult[] srList = Database.insert(lstVoiceAlert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('BatchException', 'InsertVoice_AlertBatch','sendVAToPremise',err.getMessage()); 
                    }
                }
            }
        }
        //SFAMS-693: UAT - Communication Scheduler still failing when all scheduled at once  logic start
        if(!updateCommunicationScheduler.isEmpty()){
            update updateCommunicationScheduler;
        }
        if(!lstVoiceAlert.isEmpty()){
            SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
        }
    }
    public void sendVAToDistrict(List<sObject> lstSobject){
        List<SPEN_VoiceAlert__c> lstVoiceAlert = New List<SPEN_VoiceAlert__c>();
        List<SPEN_ContactPremise__c> lstContactPremise = (List<SPEN_ContactPremise__c>)lstSobject;
        
        for(SPEN_ContactPremise__c objCP :lstContactPremise){
            if( objCP.SPEN_RelatedContact__c != null && objCP.SPEN_RelatedContact__r.SPEN_PSR__c && ((objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == null && objCP.SPEN_RelatedContact__r.MobilePhone == null && objCP.SPEN_RelatedContact__r.Phone != null ) || (objCP.SPEN_RelatedContact__r.SPEN_PreferredMethodofContact__c == 'H' && objCP.SPEN_RelatedContact__r.Phone != null))){
                
                SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                objVoiceAlert.SPEN_ContactId__c = objCP.SPEN_RelatedContact__c;
                objVoiceAlert.RecordTypeId = instantRecordTypeId;
                if(String.isNotBlank(objCP.SPEN_DistrictValue__c)  && mapDistrictToCommSchVA.get(objCP.SPEN_DistrictValue__c.toLowerCase()) != null){
                    objVoiceAlert.SPEN_CommunicationScheduler__c = mapDistrictToCommSchVA.get(objCP.SPEN_DistrictValue__c.toLowerCase()).Id;
                    objVoiceAlert.SPEN_BroadcastMessage__c = mapDistrictToCommSchVA.get(objCP.SPEN_DistrictValue__c.toLowerCase()).SPEN_Message__c;
                }
                objVoiceAlert.SPEN_Status__c = 'Ready';
                lstVoiceAlert.add(objVoiceAlert);
            }
        }
        if(!lstVoiceAlert.isEmpty()){
            //insert lstVoiceAlert;
            Database.SaveResult[] srList = Database.insert(lstVoiceAlert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('BatchException', 'InsertVoice_AlertBatch','sendVAToDistrict',err.getMessage()); 
                    }
                }
            }
        }
        if(!lstVoiceAlert.isEmpty()){
            SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
        }
    }
    // Driven by impacted premises
    public void doOperationOnImpactedPremise(List<SPEN_ImpactedPremise__c> lstOfImpactedPremises, String psrNonPsrCheck){
        List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
        Map<Id, SPEN_ImpactedPremise__c> mapContactIdToImpactedPremise = new Map<Id, SPEN_ImpactedPremise__c>();
        Map<Id, Case> mapContactIdToCase = new Map<Id, Case>();
        Map<Id, SPEN_VoiceAlert__c> mapContactIdToVoice = new Map<Id, SPEN_VoiceAlert__c>();
        List<SPEN_CommunicationScheduler__c> lstCommSchToUpdate = new List<SPEN_CommunicationScheduler__c>();
        
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
            System.debug('Line 215');
        }

        for(SPEN_VoiceAlert__c voice : [select id,SPEN_ContactId__c from SPEN_VoiceAlert__c where SPEN_MessageHeard__c ='Listened' AND (SPEN_IncidentId__c IN :setPSRIncident OR SPEN_IncidentId__c IN :setNonPSRIncident) AND SPEN_ContactId__c IN :mapContactIdToImpactedPremise.keySet()])
        {
            mapContactIdToVoice.put(voice.SPEN_ContactId__c,voice);
            System.debug('Line 221');
        }
        for(Id contactId : mapContactIdToImpactedPremise.keySet()){
            if(!setOfDuplicateContactIds.contains(contactId)){
                SPEN_ImpactedPremise__c objImpactedPremise = mapContactIdToImpactedPremise.get(contactId);
                // CRMD-5225 condition added at below places.
                if(objImpactedPremise!= null  && ((objImpactedPremise.SPEN_PreferredMethodofContactFormula__c == null 
                                                   && objImpactedPremise.SPEN_CustomerMobileNumberFormula__c == null 
                                                   && (objImpactedPremise.SPEN_CustomerTelephoneNumberFormula__c != null 
                                                       || (objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c != null 
                                                           && !objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c.startsWith('07')))) || 
                                                  (objImpactedPremise.SPEN_PreferredMethodofContactFormula__c == 'H' && 
                                                   (objImpactedPremise.SPEN_CustomerTelephoneNumberFormula__c != null || 
                                                    (objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c != null && 
                                                     !objImpactedPremise.SPEN_CustomerOtherPhoneFormula__c.startsWith('07'))))))
                {
                    String incidentId = mapContactIdToImpactedPremise.get(contactId).SPEN_RelatedIncident__c;
                    SPEN_CommunicationScheduler__c commSch = commSchedulerMap.get(messagingTaskCommunicationSchedulerIdMap.get(incidentMessagingTaskIdMap.get(incidentId)));
                    if((!mapContactIdToCase.isEmpty() && mapContactIdToCase.containsKey(contactId)) || (!mapContactIdToVoice.isEmpty() && mapContactIdToVoice.containsKey(contactId)) || !'Incident Restored'.equalsIgnoreCase(commSch.SPEN_Event__c) )
                    {
                    if(!lstCommSchToUpdate.contains(commSch)){
                        commSch.SPEN_Status__c = 'Executed';
                        lstCommSchToUpdate.add(commSch);
                    }
                    if(commSch.SPEN_SendVoiceAlerttoPSR__c ||commSch.SPEN_SendVAtoAllCustomerinScope__c )
                    {
                        SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                        objVoiceAlert.SPEN_ContactId__c = contactId;
                        objVoiceAlert.SPEN_IncidentId__c = incidentId;
                        objVoiceAlert.SPEN_Event__c = commSch.SPEN_Event__c ; 
                        
                        objVoiceAlert.SPEN_CommunicationScheduler__c = commSch.Id;
                        if(objImpactedPremise.SPEN_PSRCheckFormula__c){
                            objVoiceAlert.SPEN_BroadcastMessage__c = commSch.SPEN_Message__c;
                        }
                        else{
                            objVoiceAlert.SPEN_BroadcastMessage__c = commSch.SPEN_NonPSRMessage__c;
                        }
                        objVoiceAlert.SPEN_IsProactive__c = mapContactIdToVoice.containskey(contactId) && commSch.SPEN_Event__c =='Incident Restored' ? true : false;
                        objVoiceAlert.SPEN_Case__c = mapContactIdToCase.containskey(contactId) && commSch.SPEN_Event__c =='Incident Restored' ? mapContactIdToCase.get(contactId).id : null;
                        objVoiceAlert.RecordTypeId = instantRecordTypeId;
                        objVoiceAlert.SPEN_Status__c = 'Ready';
                         //incident restored marker
                        lstVoiceAlert.add(objVoiceAlert);
                    }
                }
                }
            }
            setOfDuplicateContactIds.add(contactId);
        }
        Set<Id> setVAId = new Set<Id>();
        if(!lstVoiceAlert.isEmpty()){
            //if(!Test.isRunningTest()){
            //insert lstVoiceAlert;
            Database.SaveResult[] srList = Database.insert(lstVoiceAlert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if(sr.isSuccess()){
                    setVAId.add(sr.getId());
                }
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('BatchException', 'InsertVoice_AlertBatch','doOperationOnImpactedPremise',err.getMessage()); 
                    }
                }
            }
            
            //}
	        Set<Id> setVAIdSurvey = new Set<Id>();
            for(SPEN_VoiceAlert__c va : [select id,SPEN_Event__c from SPEN_VoiceAlert__c where Id in :setVAId and SPEN_Event__c = 'Incident Restored'])
            {
                setVAIdSurvey.add(va.id);
            }
            if(!setVAIdSurvey.isEmpty())
            {
                SPEN_SurveyUtility.updateVoiceAlertWithInvitation(setVAIdSurvey, 'Faults');
            }
            SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
        }
        if(!lstCommSchToUpdate.isEmpty()){
            update lstCommSchToUpdate;
        }
    }
    // Driven by cases
    public void doOperationOnCases(List<Case> lstOfCases,  String psrNonPsrCheck){
        List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
        String recordTypeBypass = CasesConstants.Case_UnplannedBypass;
        List<Contact> byPassContactName = new List<Contact>();
        byPassContactName = [SELECT Id, Name FROM Contact where Name = :System.Label.SPEN_SMSUnidentifiedContact LIMIT 1];
        List<Case> lstOfCasesforCalledIn = new List<Case>();
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
            if((objCase.SPEN_PreferredMethodofContact__c =='H' && objCase.SPEN_CallerTelephone__c != null) 
               || (objCase.SPEN_PreferredMethodofContact__c == null && objCase.SPEN_CallerMobileTelephone__c == null && objCase.SPEN_CallerTelephone__c != null)){
                SPEN_CommunicationScheduler__c commSch = commSchedulerMap.get(messagingTaskCommunicationSchedulerIdMap.get(incidentMessagingTaskIdMap.get(objCase.SPEN_Incident__c)));
                if(!lstCommSchToUpdate.contains(commSch)){
                    commSch.SPEN_Status__c = 'Executed';
                    lstCommSchToUpdate.add(commSch);
                }
                if(commSch.SPEN_SendVAtoPSRCalledin__c || commSch.SPEN_SendVoiceAlerttocalledin__c)
                {
                    SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                    objVoiceAlert.SPEN_ContactId__c = objCase.ContactId;
                    objVoiceAlert.RecordTypeId = instantRecordTypeId;
                    objVoiceAlert.SPEN_IncidentId__c = objCase.SPEN_Incident__c;
                    objVoiceAlert.SPEN_Event__c = commSch.SPEN_Event__c ; 
                    
                    objVoiceAlert.SPEN_CommunicationScheduler__c = commSch.Id;
                    if(objCase.contact.SPEN_PSR__c == true){
                        objVoiceAlert.SPEN_BroadcastMessage__c = commSch.SPEN_Message__c;
                    }
                    else{
                        objVoiceAlert.SPEN_BroadcastMessage__c = commSch.SPEN_NonPSRMessage__c;
                    }
                    objVoiceAlert.SPEN_Status__c = 'Ready';
                    objVoiceAlert.SPEN_Case__c = objCase.id;
                    objVoiceAlert.SPEN_CalledInTelephone__c = objCase.SPEN_CallerTelephone__c ;
                    lstVoiceAlert.add(objVoiceAlert);
                    
                }  
            }
            setofContactIds.add(objCase.ContactId);
        }
        Set<Id> setVAId = new Set<Id>();
        if(!lstVoiceAlert.isEmpty()){
            //insert lstVoiceAlert;
            Database.SaveResult[] srList = Database.insert(lstVoiceAlert, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if(sr.isSuccess()){
                    setVAId.add(sr.getId());
                }
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('BatchException', 'InsertVoice_AlertBatch','doOperationOnCases',err.getMessage()); 
                    }
                }
            }

            Set<Id> setVAIdSurvey = new Set<Id>(); 
            for(SPEN_VoiceAlert__c va : [select id,SPEN_Event__c from SPEN_VoiceAlert__c where Id in :setVAId and SPEN_Event__c = 'Incident Restored'])
            {
                setVAIdSurvey.add(va.id);
            }
            if(!setVAIdSurvey.isEmpty())
            {
                SPEN_SurveyUtility.updateVoiceAlertWithInvitation(setVAIdSurvey, 'Faults');
            }
            SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
        }
        if(!lstCommSchToUpdate.isEmpty()){
            update lstCommSchToUpdate;
        }
    }
    global void finish(Database.BatchableContext bc){
        //Integer customLabelValueVA=Integer.valueOf(System.Label.SPEN_InsertVABatchSize);
        Integer customLabelValueVA=Integer.valueof(SPEN_BatchSettings__mdt.getInstance('SPEN_InsertVoiceBatchSize').SPEN_BatchSize__c);
        if((this.batchIndex == 1)  && !mapOfCommSchVsIncident.isEmpty() ){
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(this.mapOfCommSchVsIncident, this.mapOfCommSchedulerWithCheckboxes, 2), customLabelValueVA);
        }
        else if((this.batchIndex == 2)  && !mapOfCommSchVsIncident.isEmpty() ){
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(this.mapOfCommSchVsIncident, this.mapOfCommSchedulerWithCheckboxes, 3), customLabelValueVA);
        }
        else if((this.batchIndex == 3)  && !mapOfCommSchVsIncident.isEmpty() ){
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(this.mapOfCommSchVsIncident, this.mapOfCommSchedulerWithCheckboxes, 4), customLabelValueVA);
        }
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