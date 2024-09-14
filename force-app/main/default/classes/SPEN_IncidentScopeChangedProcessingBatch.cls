/**
 * @description       : This batch class is used to process the operations once caseRef goes beyond the defined limits
 * 					
 * @author            : rahul.dd.kumar@accenture.com
 * @group             : 
 * @last modified on  : 16-11-2023
 * @last modified by  : rahul.dd.kumar@accenture.com
**/
global with sharing class SPEN_IncidentScopeChangedProcessingBatch  implements Database.Batchable<sObject>,Database.Stateful,Database.RaisesPlatformEvents {
    
    List<String> callRefer = new List<String>();
    Incident incidentRec = new Incident();
    Set<String> setCaseIncType = SPEN_ImpactedPremisesConstants.SETCASEINCTYPE;
    Set<Id> mergedIncidentIdSet = new Set<Id>();

    public SPEN_IncidentScopeChangedProcessingBatch(Incident incidentRec, List<String> callRefer) {
        this.incidentRec = incidentRec;
        this.callRefer = callRefer;
    }
    // Start method to collect all the chunks of cases with callRef present.
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c from CASE where Id = :callRefer';
        return Database.getQueryLocator(query);
    }
    // Execute method to get all the chunks of cases with callRef present and process as per business.
    global void execute(Database.BatchableContext bc, List<sObject> lstSobject){
        
        List<Case> lstOfcases = (List<Case>)lstSobject;
        Map<String,String> incCaseMap = new Map<String,String>();
        Set<Id> caseIdIncTypeChangeSet = new Set<Id>();
        Incident newIncident = this.incidentRec;
        List<Case> caseUpdList = new List<Case>();

        for(SPEN_Incident_to_case_status_mapping__mdt mdtRec :SPEN_Incident_to_case_status_mapping__mdt.getAll().values()){
            incCaseMap.put(mdtRec.SPEN_IncidentStatus__c,mdtRec.SPEN_CaseStatus__c);
        }

        try{

            for(Case cse : lstOfcases){

                if( cse.SPEN_Incident__c!=null ){

                    if(cse.SPEN_Incident__c != this.incidentRec.Id){

                        mergedIncidentIdSet.add(cse.SPEN_Incident__c);

                        cse.SPEN_Incident__c = this.incidentRec.Id;

                        cse.SPEN_IsMerge__c=true;
                        
                        if(incCaseMap.containsKey(newIncident.SPEN_IncidentStatus__c)){
                            if(cse.Status != incCaseMap.get(newIncident.SPEN_IncidentStatus__c)){
                                cse.Status=incCaseMap.get(newIncident.SPEN_IncidentStatus__c);
                            }
                        }
                        if(setCaseIncType.contains(newIncident.SPEN_IncidentType__c) && cse.SPEN_Incident__r.SPEN_IncidentType__c =='SP'){
                            caseIdIncTypeChangeSet.add(cse.Id);
                        }
                        caseUpdList.add(cse);
                    }
                    else{
                        if(incCaseMap.containsKey(cse.SPEN_Incident__r.SPEN_IncidentStatus__c)){
                            if(cse.Status != incCaseMap.get(cse.SPEN_Incident__r.SPEN_IncidentStatus__c)){
                                cse.Status=incCaseMap.get(cse.SPEN_Incident__r.SPEN_IncidentStatus__c);
                                caseUpdList.add(cse);
                            }
                        }
                    }

                }
                else{
                    cse.SPEN_Incident__c = this.incidentRec.Id;
                    if(incCaseMap.containsKey(newIncident.SPEN_IncidentStatus__c)){
                        if(cse.Status != incCaseMap.get(newIncident.SPEN_IncidentStatus__c)){
                            cse.Status=incCaseMap.get(newIncident.SPEN_IncidentStatus__c);
                        }
                    }
                    caseUpdList.add(cse);
                }
            }
            if(!caseUpdList.isEmpty()){
                Database.SaveResult[] srList = Database.update(caseUpdList, false);
            }

            if(!caseIdIncTypeChangeSet.isEmpty()){
            
            SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
            SPEN_IVRMessage__c ivrMsg= ivrSel.selectByExternalId(SPEN_ImpactedPremisesConstants.SMSSINGLEPREMISENETWORKFAULT);
            SPEN_IVRMessage__c ivrNetworkFault= ivrSel.selectByExternalId(SPEN_ImpactedPremisesConstants.VASINGLEPREMISENETWORKFAULT);
            RecordType recType=[select id,RecordType.name from RecordType  where RecordType.name ='Case' LIMIT 1];
            Id VoiceAlertRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get(SPEN_ImpactedPremisesConstants.INSTANT).getRecordTypeId();
            List<SPEN_SMS__c> smsLst=new List<SPEN_SMS__c>();
            List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();

                for(Case c : [SELECT id, SPEN_Incident__c, SPEN_PreferredMethodofContact__c,
                SPEN_Incident__r.SPEN_IncidentType__c,SPEN_CaseCategoryOutcome__c,ContactId,
                SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c
                FROM Case WHERE Id IN: caseIdIncTypeChangeSet]){

                    if((c.SPEN_PreferredMethodofContact__c == 'T' && c.SPEN_CallerMobileTelephone__c != Null) || (c.SPEN_PreferredMethodofContact__c == Null && c.SPEN_CallerMobileTelephone__c != Null)){
                        //Send SMS
                        String mobNo= (c.SPEN_CallerMobileTelephone__c !=Null && c.SPEN_CallerMobileTelephone__c.startsWith('0')) ? '+44'+c.SPEN_CallerMobileTelephone__c.removeStart('0'):c.SPEN_CallerMobileTelephone__c ;
                        SPEN_SMS__c sms= new SPEN_SMS__c(SPEN_ContactId__c=c.ContactId,
                                                         SPEN_IvrMessageId__c=ivrMsg.id,
                                                         SPEN_Message__c = ivrMsg.SPEN_IVRMessage__c,
                                                         SPEN_Status__c='Ready',
                                                         SPEN_Event__c= SPEN_ImpactedPremisesConstants.MERGEDFROMSPTONETWORK,
                                                         SPEN_Mobile__c=mobNo,
                                                         RecordTypeId=recType.id,
                                                         SPEN_CaseId__c=c.id,
                                                         SPEN_IncidentId__c=c.SPEN_Incident__c,
                                                         SPEN_MessageType__c= SPEN_ImpactedPremisesConstants.OUTBOUND);
                        smsLst.add(sms);
                    }
                    else if((c.SPEN_PreferredMethodofContact__c =='H' && c.SPEN_CallerTelephone__c != null) || (c.SPEN_PreferredMethodofContact__c==null && c.SPEN_CallerTelephone__c != null)){
                        SPEN_VoiceAlert__c objVoiceAlert = new SPEN_VoiceAlert__c();
                        objVoiceAlert.SPEN_CalledInTelephone__c = c.SPEN_CallerTelephone__c;
                        objVoiceAlert.SPEN_ContactId__c = c.ContactId;
                        objVoiceAlert.RecordTypeId = VoiceAlertRecordTypeId;
                        objVoiceAlert.SPEN_IncidentId__c =c.SPEN_Incident__c;
                        objVoiceAlert.SPEN_BroadcastMessage__c = ivrNetworkFault.SPEN_IVRMessage__c;
                        objVoiceAlert.SPEN_Status__c = 'Ready';
                        lstVoiceAlert.add(objVoiceAlert);
                    }
                }

            Boolean isSMSOptOut = SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod(SPEN_ImpactedPremisesConstants.SMSBLACKOUTWINDOW);
            Boolean isVAOptOut = SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod(SPEN_ImpactedPremisesConstants.VABLACKOUTWINDOW);
                  
                if(smsLst != null && !smsLst.isEmpty()  && isSMSOptOut){
                    Database.SaveResult[] srList = Database.insert(smsLst, false);
                }
            
                if(lstVoiceAlert != null && !lstVoiceAlert.isEmpty() && isVAOptOut){
                    Database.SaveResult[] srList = Database.insert(lstVoiceAlert, false);
                    //Call VA Batch
                    SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
                }
            }

        }
        catch(Exception ex){
           SEL_LoggingService.log(ex);
           throw ex;
       }
    }
    //Finish method to process remaining tasks
    global void finish(Database.BatchableContext bc){

        List<Incident> inciupdate = new List<Incident>();
        for(Incident ic : [SELECT Id,ParentIncidentId, SPEN_IncidentStatus__c,(Select Id from Cases__r LIMIT 50000) FROM Incident WHERE id IN: mergedIncidentIdSet]){
            if(ic.Cases__r.size() == 0){
                inciupdate.add(new Incident(Id=ic.Id,SPEN_IncidentStatus__c = SPEN_ImpactedPremisesConstants.MERGED,ParentIncidentId=this.incidentRec.Id));
            }
        }
        if(!inciupdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(inciupdate, false);
        }
    }
}