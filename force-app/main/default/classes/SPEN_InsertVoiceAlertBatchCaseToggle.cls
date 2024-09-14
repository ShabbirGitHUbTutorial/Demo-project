global with sharing class SPEN_InsertVoiceAlertBatchCaseToggle implements Database.Batchable<sObject>
{
    Id IncidentId;
    String vcAlertMessage;
    Id recTypeIdOfInstant = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
    
    List<SPEN_VoiceAlert__C> vAlertList=new List<SPEN_VoiceAlert__c>();
    public SPEN_InsertVoiceAlertBatchCaseToggle(Id IncId,String vcAlertTemplt)
    {
        IncidentId=IncId;
        vcAlertMessage=vcAlertTemplt;
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        system.debug('Start method of Batch');
        //SPEN_Contact__r.SPEN_IncidentId__c added in Query for CRMD-549 
        //return Database.getQueryLocator([select Id,SPEN_Contact__c,SPEN_contact__r.id,SPEN_Contact__r.SPEN_IncidentId__c,SPEN_ZoneFormula__c,SPEN_Premise__r.SPEN_Zone__r.SPEN_BroadcastMessage__c 
        //                                 from Incident where Id = :IncidentId]);
        return Database.getQueryLocator([select Id,(select id,ContactId from cases__r) from Incident where Id = :IncidentId ]);
    }
    global void execute(Database.BatchableContext bc, List<Incident> IncidentRec)
    {
        try{
            //system.debug('inside execute');
            Set<Id> conSet=new Set<Id>();
            List<Incident> IncLst=new List<Incident>();
            List<SPEN_ImpactedPremise__c> ImPLst=new List<SPEN_ImpactedPremise__c>();
            List<Case> CaseLst=new List<Case>();
            Map<Id,Id> contactIdIncidentIdMap = new Map<Id,Id>();//CRMD-549
            for(Incident inc:IncidentRec)
            {
                //system.debug('inside For Inc');
                CaseLst.addall(inc.Cases__r);
                if(!CaseLst.isEmpty()){
                    //system.debug('inside CaseLst If');
                    IncLst.add(inc);
                    //system.debug(IncLst);
                    //ImPLst.addall(inc.Impacted_Premises__r);
                    //system.debug(inc.Impacted_Premises__r);
                    for(Case Ca:CaseLst){
                        system.debug('inside Inside CaseList');
                        conSet.add(Ca.ContactId);
                        contactIdIncidentIdMap.put(Ca.ContactId,IncidentId); //CRMD-549
                    }
                }
                
            }
            List<Contact> lstCon=new List<Contact>();
            //system.debug('conSet: '+conSet);
            //system.debug('ImpLst'+ImpLst);
            
            for(Id cS:conSet){
                //system.debug('lstCon'+lstCon);
                SPEN_VoiceAlert__C vcAlert=new SPEN_VoiceAlert__C(SPEN_ContactId__c=cS,SPEN_IncidentId__c = contactIdIncidentIdMap.get(cs), //CRMD-549 added SPEN_IncidentId__c
                                                                  SPEN_BroadcastMessage__c=vcAlertMessage,RecordTypeId = recTypeIdOfInstant,
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