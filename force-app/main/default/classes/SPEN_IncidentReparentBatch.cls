/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  
AUTHOR    : 
LIBRARY    :  Salesforce Enterprise Library (SEL) 
VERSION    :  1.0

HISTORY    :
Date      Author        Comment
NOV-11-2021      Initial version
-----------------------------------------------------------------------------------------*/
public with sharing class SPEN_IncidentReparentBatch implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents
{
    Id incidentId;
    //List<Incident> incToUpdate = new List<Incident>();
    List<String> callRef = new List<String>();
    List<Incident> inciupdate = new List<Incident>();
    Incident newIncident = new Incident();

    public SPEN_IncidentReparentBatch(Incident incNew, List<String> cRef)
    {
        incidentId=incNew.Id;
        newIncident=incNew;
        callRef = cRef;
    }

    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([Select Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c from CASE where Id =:callRef]);
    }
    public void execute(Database.BatchableContext bc, List<Case> caseList)
    {
        Set<Id> mergedIncidentIdSet = new Set<Id>();
        Set<Id> caseIdIncTypeChangeSet = new Set<Id>();
        List<Case> caseUpdList = new List<Case>();
        List<SPEN_Incident_to_case_status_mapping__mdt> incToCaseLst = [SELECT SPEN_IncidentStatus__c,SPEN_CaseStatus__c FROM SPEN_Incident_to_case_status_mapping__mdt];
        Map<String,String> incCaseMap = new Map<String,String>();
        for(SPEN_Incident_to_case_status_mapping__mdt mdtRec : incToCaseLst){
            incCaseMap.put(mdtRec.SPEN_IncidentStatus__c,mdtRec.SPEN_CaseStatus__c);
        }
        for(Case c : caseList)
        {
            if(c.SPEN_Incident__c!=null)
            {
                //below check added as Incident controller can cancel and link the call log to new INC without merge also
				if(c.SPEN_Incident__c != incidentId)
                {
                    mergedIncidentIdSet.add(c.SPEN_Incident__c);
                    c.SPEN_Incident__c = incidentId;
                    c.SPEN_IsMerge__c=true;
                    if(incCaseMap.containsKey(newIncident.SPEN_IncidentStatus__c)){
                        if(c.Status != incCaseMap.get(newIncident.SPEN_IncidentStatus__c)){
                            c.Status=incCaseMap.get(newIncident.SPEN_IncidentStatus__c);
                        }
                    }
                    Set<String> setCaseIncType = new Set<String> {'HV_N','HV_S','LV'};
                    if(setCaseIncType.contains(newIncident.SPEN_IncidentType__c) && c.SPEN_Incident__r.SPEN_IncidentType__c =='SP'){
                        caseIdIncTypeChangeSet.add(c.Id);
                    }
                    caseUpdList.add(c);
                }
                else{
                    //c.SPEN_Incident__c = incidentId;
                    if(incCaseMap.containsKey(c.SPEN_Incident__r.SPEN_IncidentStatus__c)){
                        if(c.Status != incCaseMap.get(c.SPEN_Incident__r.SPEN_IncidentStatus__c)){
                            c.Status=incCaseMap.get(c.SPEN_Incident__r.SPEN_IncidentStatus__c);
                            caseUpdList.add(c);
                        }
                    }
                }
            }
            else
            {
                c.SPEN_Incident__c = incidentId;
                if(incCaseMap.containsKey(newIncident.SPEN_IncidentStatus__c)){
                    if(c.Status != incCaseMap.get(newIncident.SPEN_IncidentStatus__c)){
                        c.Status=incCaseMap.get(newIncident.SPEN_IncidentStatus__c);
                    }
                }
                caseUpdList.add(c);
            }
        }
        /*for(Incident incRec : [Select id,ParentIncidentId from Incident where id IN: mergedIncidentIdSet])
        {
			incRec.ParentIncidentId = incidentId;
			incToUpdate.add(incRec);            
        }*/
        //update caseList;
        if(!caseUpdList.isEmpty()){
            update caseUpdList;
        }
        if(!caseIdIncTypeChangeSet.isEmpty()){
            List<Case> lstNewCases = [SELECT id, SPEN_Incident__c, SPEN_PreferredMethodofContact__c,
            SPEN_Incident__r.SPEN_IncidentType__c,SPEN_CaseCategoryOutcome__c,ContactId,
            SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c
            FROM Case WHERE Id IN: caseIdIncTypeChangeSet];

            SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
            SPEN_IVRMessage__c ivrMsg= ivrSel.selectByExternalId('SMS – Single Premise – Network Fault');
            SPEN_IVRMessage__c ivrNetworkFault= ivrSel.selectByExternalId('Single Premise Network Fault VA');
    
            RecordType recType=[select id,RecordType.name from RecordType  where RecordType.name ='Case' LIMIT 1];
            Id voiceAlertRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
            List<SPEN_SMS__c> smsLst=new List<SPEN_SMS__c>();
            List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
            for(Case c : lstNewCases){
                if((c.SPEN_PreferredMethodofContact__c == 'T' && c.SPEN_CallerMobileTelephone__c != Null) || (c.SPEN_PreferredMethodofContact__c == Null && c.SPEN_CallerMobileTelephone__c != Null))
                {
                    //Send SMS
                    String mobNo= (c.SPEN_CallerMobileTelephone__c !=Null && c.SPEN_CallerMobileTelephone__c.startsWith('0')) ? '+44'+c.SPEN_CallerMobileTelephone__c.removeStart('0'):c.SPEN_CallerMobileTelephone__c ;
                    SPEN_SMS__c sms= new SPEN_SMS__c(SPEN_ContactId__c=c.ContactId,
                    SPEN_IvrMessageId__c=ivrMsg.id,
                    SPEN_Message__c = ivrMsg.SPEN_IVRMessage__c,
                    SPEN_Status__c='Ready',
                    SPEN_Event__c='Merged from SP to Network',
                    SPEN_Mobile__c=mobNo,
                    RecordTypeId=recType.id,
                    SPEN_CaseId__c=c.id,
                    SPEN_IncidentId__c=c.SPEN_Incident__c,
                    SPEN_MessageType__c='Outbound');
                    smsLst.add(sms);
                }
                else if((c.SPEN_PreferredMethodofContact__c =='H' && c.SPEN_CallerTelephone__c != null) || (c.SPEN_PreferredMethodofContact__c==null && c.SPEN_CallerTelephone__c != null))
                {
                    SPEN_VoiceAlert__c objVoiceAlert = new SPEN_VoiceAlert__c();
                    objVoiceAlert.SPEN_CalledInTelephone__c = c.SPEN_CallerTelephone__c;
                    objVoiceAlert.SPEN_ContactId__c = c.ContactId;
                    objVoiceAlert.RecordTypeId = voiceAlertRecordTypeId;
                    objVoiceAlert.SPEN_IncidentId__c =c.SPEN_Incident__c;
                    objVoiceAlert.SPEN_BroadcastMessage__c = ivrNetworkFault.SPEN_IVRMessage__c;
                    objVoiceAlert.SPEN_Status__c = 'Ready';
                    lstVoiceAlert.add(objVoiceAlert);
                }
            }
            Boolean isSMSOptOut = checkBlackoutWindowPeriod('SMS Blackout Window');
            //System.debug('isSMSOptOut >>'+isSMSOptOut);
            //System.debug('smsLst >>'+smsLst);            
            if(smsLst != null && !smsLst.isEmpty()  && isSMSOptOut)
                insert smsLst;
                
            Boolean isVAOptOut = checkBlackoutWindowPeriod('VA Blackout Window');
            //System.debug('isVAOptOut >>'+isVAOptOut);
            
            if(lstVoiceAlert != null && !lstVoiceAlert.isEmpty() && isVAOptOut){
                insert lstVoiceAlert;
                //System.debug('lstVoiceAlert >>'+lstVoiceAlert);
                //Call VA Batch
                SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
            }
        }
        /*if(!incToUpdate.isEmpty()){
            update incToUpdate;
        }*/

        for(Incident ic : [SELECT Id,ParentIncidentId, SPEN_IncidentStatus__c,(Select Id from Cases__r) FROM Incident WHERE id IN: mergedIncidentIdSet])
        {
            if(ic.Cases__r.size() == 0)
            {
                //ic.SPEN_IncidentStatus__c = 'Merged';
                inciupdate.add(new Incident(Id=ic.Id,SPEN_IncidentStatus__c = 'Merged',ParentIncidentId=incidentId));
            }
        }
    }
   
    public void finish(Database.BatchableContext bc)
    {
        if(!inciupdate.isEmpty())
        {
          update inciupdate;
        }
    }

    public static Boolean checkBlackoutWindowPeriod(String typeCheck){
        Boolean result = false;
        Id recTypeIdOfBlackoutWindowRT = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get(typeCheck).getRecordTypeId();
       
        List<SPEN_IVROperatingHours__c> lstIvrHour = [select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordTypeId = :recTypeIdOfBlackoutWindowRT and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
        
        if(!lstIvrHour.isEmpty() && lstIvrHour[0] != null){
            if(lstIvrHour[0].SPEN_StartTime__c == null && lstIvrHour[0].SPEN_EndTime__c == null){
                result = true;
            }
            else if((lstIvrHour[0].SPEN_StartTime__c < lstIvrHour[0].SPEN_EndTime__c) && ((System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() < lstIvrHour[0].SPEN_EndTime__c) || (System.now().time() > lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c))){
             
                 result = true;
             }
             else if((lstIvrHour[0].SPEN_StartTime__c > lstIvrHour[0].SPEN_EndTime__c) && (System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c)){
                 result = true;
             }
            
        }
        return result;
    }
}