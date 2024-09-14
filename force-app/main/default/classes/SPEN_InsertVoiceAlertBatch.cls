/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  
AUTHOR     : 	Akshay Pandit
LIBRARY    :  	Salesforce Enterprise Library (SEL) 
VERSION    :  	1.0

HISTORY    :
Date      Author        Comment
DEC-05-2022      Initial version
-----------------------------------------------------------------------------------------*/
global with sharing class SPEN_InsertVoiceAlertBatch implements Database.Batchable<sObject>
{
    List<Id> psrIdLst=new List<Id>();
    String vcAlertMessage;
    DateTime scheduleDateTime;
    Id recTypeIdOfInstant = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
    
    List<SPEN_VoiceAlert__C> vAlertList=new List<SPEN_VoiceAlert__c>();
    public SPEN_InsertVoiceAlertBatch(List<Id> psrId,String vcAlertTemplt){
        psrIdLst=psrId;
        vcAlertMessage=vcAlertTemplt;
    }
    
    public SPEN_InsertVoiceAlertBatch(List<Id> psrId,String vcAlertTemplt, DateTime dt){
        psrIdLst=psrId;
        vcAlertMessage=vcAlertTemplt;
        scheduleDateTime = dt;
    }    
    
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        //system.debug('Start method of Batch');
        return Database.getQueryLocator([select Id,SPEN_Contact__c,SPEN_contact__r.id,SPEN_Contact__r.SPEN_IncidentId__c,SPEN_ZoneFormula__c,SPEN_Premise__r.SPEN_Zone__r.SPEN_BroadcastMessage__c 
                                         from SPEN_PSR__C where Id in :psrIdLst]);
        
    }
    
    global void execute(Database.BatchableContext bc, List<SPEN_PSR__c> PSRList)
    {
        try{
            Set<Id> conSet=new Set<Id>();
            Map<Id,Id> contactIdIncidentIdMap = new Map<Id,Id>();//CRMD-549
            for(SPEN_PSR__c spr:PSRList)
            {
                conSet.add(spr.SPEN_Contact__c);
                contactIdIncidentIdMap.put(spr.SPEN_Contact__c,spr.SPEN_Contact__r.SPEN_IncidentId__c); //CRMD-549
            }
            List<Contact> lstCon=new List<Contact>();
            //system.debug('conSet: '+conSet);
            //system.debug('PSRList'+PSRList);
            
            for(Id cS:conSet){
                //system.debug('lstCon'+lstCon);
                SPEN_VoiceAlert__C vcAlert=new SPEN_VoiceAlert__C(SPEN_ContactId__c=cS, SPEN_IncidentId__c = contactIdIncidentIdMap.get(cs),
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
    
    global void finish(Database.BatchableContext bc){
        //system.debug(bc);
    }

}