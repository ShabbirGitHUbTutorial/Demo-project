/*-----------------------------------------------------------------------------
DESCRIPTION :   Utility class to handle incident reparent sync call.
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
DEC-01-2023     Shubhi Vijayvergia        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_SyncIncidentUtility {
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method invoked from SPEN_SyncIncidentDetails and SPEN_IncidentQueueableClass 
		for incident reparenting
    ***************************************************************/ 
     //As part of CRMD-5175 
    public static void incidentReparentSyncCall(list<case> caseList,Incident newIncident){
        List<Incident> inciupdate = new List<Incident>();
        Set<Id> mergedIncidentIdSet = new Set<Id>();
        Set<Id> caseIdIncTypeChangeSet = new Set<Id>();
        List<Case> caseUpdList = new List<Case>();
        
        Map<String,String> incCaseMap = new Map<String,String>();
        
        try{
            for(SPEN_Incident_to_case_status_mapping__mdt mdtRec : [SELECT SPEN_IncidentStatus__c,SPEN_CaseStatus__c FROM SPEN_Incident_to_case_status_mapping__mdt]){
            incCaseMap.put(mdtRec.SPEN_IncidentStatus__c,mdtRec.SPEN_CaseStatus__c);
            }
            for(Case c : caseList){
                if(c.SPEN_Incident__c!=null){
                    //below check added as Incident controller can cancel and link the call log to new INC without merge also
                    if(c.SPEN_Incident__c != newIncident.Id){
                        mergedIncidentIdSet.add(c.SPEN_Incident__c);
                        c.SPEN_Incident__c = newIncident.Id;
                        c.SPEN_IsMerge__c=true;
                        if(incCaseMap.containsKey(newIncident.SPEN_IncidentStatus__c)){
                            if(c.Status != incCaseMap.get(newIncident.SPEN_IncidentStatus__c)){
                                c.Status=incCaseMap.get(newIncident.SPEN_IncidentStatus__c);
                            }
                        }
                        Set<String> setCaseIncType = SPEN_ImpactedPremisesConstants.SETCASEINCTYPE;
                        if(setCaseIncType.contains(newIncident.SPEN_IncidentType__c) && c.SPEN_Incident__r.SPEN_IncidentType__c ==SPEN_ImpactedPremisesConstants.SPENSP){
                            caseIdIncTypeChangeSet.add(c.Id);
                        }
                        caseUpdList.add(c);
                    }
                    else{
                        if(incCaseMap.containsKey(c.SPEN_Incident__r.SPEN_IncidentStatus__c)){
                            if(c.Status != incCaseMap.get(c.SPEN_Incident__r.SPEN_IncidentStatus__c)){
                                c.Status=incCaseMap.get(c.SPEN_Incident__r.SPEN_IncidentStatus__c);
                                caseUpdList.add(c);
                            }
                        }
                    }
                }else{
                    c.SPEN_Incident__c = newIncident.Id;
                    if(incCaseMap.containsKey(newIncident.SPEN_IncidentStatus__c)){
                        if(c.Status != incCaseMap.get(newIncident.SPEN_IncidentStatus__c)){
                            c.Status=incCaseMap.get(newIncident.SPEN_IncidentStatus__c);
                        }
                    }
                    caseUpdList.add(c);
                }
            }
            
            if(!caseUpdList.isEmpty()){
                update caseUpdList;
            }
            if(!caseIdIncTypeChangeSet.isEmpty()){
                List<Case> lstNewCases = [SELECT id, SPEN_Incident__c, SPEN_PreferredMethodofContact__c,
                                          SPEN_Incident__r.SPEN_IncidentType__c,SPEN_CaseCategoryOutcome__c,ContactId,
                                          SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c
                                          FROM Case WHERE Id IN: caseIdIncTypeChangeSet];
                
                SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
                SPEN_IVRMessage__c ivrMsg= ivrSel.selectByExternalId(SPEN_ImpactedPremisesConstants.SMSSINGLEPREMISENETWORKFAULT);
                SPEN_IVRMessage__c ivrNetworkFault= ivrSel.selectByExternalId(SPEN_ImpactedPremisesConstants.VASINGLEPREMISENETWORKFAULT);
                
                RecordType recType=[select id,RecordType.name from RecordType  where RecordType.name =:SPEN_ImpactedPremisesConstants.SMS_CASERECORDTYPE LIMIT 1];
                Id VoiceAlertRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get(SPEN_ImpactedPremisesConstants.INSTANT).getRecordTypeId();
                List<SPEN_SMS__c> smsLst=new List<SPEN_SMS__c>();
                List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
                List<Id> lstOfCaseIds = new List<Id>();
                for(Case c : lstNewCases){
                    if((c.SPEN_PreferredMethodofContact__c == SPEN_ImpactedPremisesConstants.T_PREFEREDMETHODOFCONTACT && c.SPEN_CallerMobileTelephone__c != Null) || (c.SPEN_PreferredMethodofContact__c == Null && c.SPEN_CallerMobileTelephone__c != Null))
                    {
                        //Send SMS
                        String mobNo= (c.SPEN_CallerMobileTelephone__c !=Null && c.SPEN_CallerMobileTelephone__c.startsWith('0')) ? '+44'+c.SPEN_CallerMobileTelephone__c.removeStart('0'):c.SPEN_CallerMobileTelephone__c ;
                        SPEN_SMS__c sms= new SPEN_SMS__c(SPEN_ContactId__c=c.ContactId,
                                                         SPEN_IvrMessageId__c=ivrMsg.id,
                                                         SPEN_Message__c = ivrMsg.SPEN_IVRMessage__c,
                                                         SPEN_Status__c=SPEN_ImpactedPremisesConstants.SMSREADYSTATUS,
                                                         SPEN_Event__c= SPEN_ImpactedPremisesConstants.MERGEDFROMSPTONETWORK,
                                                         SPEN_Mobile__c=mobNo,
                                                         RecordTypeId=recType.id,
                                                         SPEN_CaseId__c=c.id,
                                                         SPEN_IncidentId__c=c.SPEN_Incident__c,
                                                         SPEN_MessageType__c= SPEN_ImpactedPremisesConstants.OUTBOUND);
                        smsLst.add(sms);
                    }else if((c.SPEN_PreferredMethodofContact__c ==SPEN_ImpactedPremisesConstants.H_PREFEREDMETHODOFCONTACT && c.SPEN_CallerTelephone__c != null) || (c.SPEN_PreferredMethodofContact__c==null && c.SPEN_CallerTelephone__c != null)){
                        lstOfCaseIds.add(c.Id);
                    }
                }
                Boolean isSMSOptOut = SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod(SPEN_ImpactedPremisesConstants.SMSBLACKOUTWINDOW);
                if(smsLst != null && !smsLst.isEmpty()  && isSMSOptOut){
                    insert smsLst;
                }
                
                Boolean isVAOptOut = SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod(SPEN_ImpactedPremisesConstants.VABLACKOUTWINDOW);
                
                if(!lstOfCaseIds.isEmpty() && isVAOptOut){
                    Integer voiceAlertBatchSize=Integer.valueof(SPEN_BatchSettings__mdt.getInstance('SPEN_InsertVoiceBatchSize').SPEN_BatchSize__c);
                    Database.executeBatch(new SPEN_VoiceAlertServiceBatch(lstOfCaseIds,ivrNetworkFault.SPEN_IVRMessage__c,VoiceAlertRecordTypeId),voiceAlertBatchSize);               
                 }
                
            }
            
            for(Incident ic : [SELECT Id,ParentIncidentId, SPEN_IncidentStatus__c,(Select Id from Cases__r) FROM Incident WHERE id IN: mergedIncidentIdSet]){
                if(ic.Cases__r.size() == 0){
                    inciupdate.add(new Incident(Id=ic.Id,SPEN_IncidentStatus__c = SPEN_ImpactedPremisesConstants.MERGED,ParentIncidentId=newIncident.Id));
                }
            }
            if(inciupdate.size()>0){
                update inciupdate;
            }
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
        
    }

}