global with sharing class SPEN_ScheduleVoiceAlertBatchCaseToggle implements Database.Batchable<sObject>
{
    Id IncidentId;
    String vcAlertMessage;
    datetime scheduleTime;
    Id recTypeIdOfSchedule = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('schedule').getRecordTypeId();
    
    List<SPEN_VoiceAlert__C> vAlertList=new List<SPEN_VoiceAlert__c>();
    public SPEN_ScheduleVoiceAlertBatchCaseToggle(Id IncId,String vcAlertTemplt, datetime scTime)
    {
        IncidentId=IncId;
        vcAlertMessage=vcAlertTemplt;
        scheduleTime = scTime;
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        //system.debug('Start method of Batch');
        //SPEN_Contact__r.SPEN_IncidentId__c added in Query for CRMD-549 
        //return Database.getQueryLocator([select Id,SPEN_Contact__c,SPEN_contact__r.id,SPEN_Contact__r.SPEN_IncidentId__c,SPEN_ZoneFormula__c,SPEN_Premise__r.SPEN_Zone__r.SPEN_BroadcastMessage__c 
        //                                 from Incident where Id = :IncidentId]);
        return Database.getQueryLocator([select Id,(select id,ContactId from cases__r) 
                                         from Incident where Id = :IncidentId]);
    }
    global void execute(Database.BatchableContext bc, List<Incident> IncidentRec)
    {
        try{
            Set<Id> conSet=new Set<Id>();
            List<Incident> IncLst=new List<Incident>();
            List<Case> CaseLst=new List<Case>();
            //List<SPEN_ImpactedPremise__c> ImPLst=new List<SPEN_ImpactedPremise__c>();
            Map<Id,Id> contactIdIncidentIdMap = new Map<Id,Id>();//CRMD-549
            for(Incident inc:IncidentRec)
            {
                IncLst.add(inc);
                CaseLst.addAll(inc.Cases__r);
                if(!CaseLst.isEmpty())
                {    
                    for(Case cse:CaseLst)
                    {
                        conSet.add(cse.ContactId);
                        contactIdIncidentIdMap.put(cse.ContactId,IncidentId); //CRMD-549
                    }
                }
            }
            List<Contact> lstCon=new List<Contact>();
            //system.debug('conSet: '+conSet);
            //system.debug('CaseLst'+CaseLst);
            
            for(Id cS:conSet){
                //system.debug('lstCon'+lstCon);
                SPEN_VoiceAlert__C vcAlert=new SPEN_VoiceAlert__C(SPEN_ContactId__c=cS,SPEN_IncidentId__c = contactIdIncidentIdMap.get(cs), //CRMD-549 added SPEN_IncidentId__c
                                                                  SPEN_BroadcastMessage__c=vcAlertMessage,RecordTypeId = recTypeIdOfSchedule,
                                                                  SPEN_Status__c='Ready');
                vAlertList.add(vcAlert);
                //system.debug('Voice Alert record inserted: '+vcAlert);
            }
            insert vAlertList;
            //system.debug('Voice Alert List inserted: '+vAlertList);
            SPEN_VoiceAlertService.isServiceCall(vAlertList);
        }
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    global void finish(Database.BatchableContext bc)
    {
    }
}