/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  
AUTHOR     : 	Akshay Pandit
LIBRARY    :  	Salesforce Enterprise Library (SEL) 
VERSION    :  	1.0

HISTORY    :
Date      Author        Comment
Jan-02-2023      Initial version
-----------------------------------------------------------------------------------------*/
global with sharing class SPEN_InsertVoiceAlertBatchPSRToggle imPlements Database.Batchable<sObject>
{
    Id incidentId;
    String vcAlertMessage;
    Id recTypeIdOfInstant = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
    
    List<SPEN_VoiceAlert__C> vAlertList=new List<SPEN_VoiceAlert__c>();
    public SPEN_InsertVoiceAlertBatchPSRToggle(Id IncId,String vcAlertTemplt){
        incidentId=IncId;
        vcAlertMessage=vcAlertTemplt;
    } 
    
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        //system.debug('Start method of Batch');
        //SPEN_Contact__r.SPEN_incidentId__c added in Query for CRMD-549 
        return Database.getQueryLocator([select Id,(select id,SPEN_CustomerMobileNumberFormula__c,SPEN_RelatedCustomerFormula__c,SPEN_PSRCheckFormula__c,SPEN_ContactPremise__r.id from imPacted_Premises__r where SPEN_PSRCheckFormula__c=true) 
                                         from Incident where Id = :incidentId]);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Incident> incidentRec)
    {
        try{
            Set<Id> conSet=new Set<Id>();
            List<Incident> incLst=new List<Incident>();
            List<SPEN_imPactedPremise__c> imPLst=new List<SPEN_imPactedPremise__c>();
            Map<Id,Id> contactIdincidentIdMap = new Map<Id,Id>();//CRMD-549
            for(Incident inc:incidentRec)
            {
                incLst.add(inc);
                imPLst.addall(inc.imPacted_Premises__r);
                for(SPEN_imPactedPremise__c imP:imPLst){
                    conSet.add(imP.SPEN_RelatedCustomerFormula__c);
                    contactIdincidentIdMap.put(imP.SPEN_RelatedCustomerFormula__c,incidentId); //CRMD-549
                }
                
                
            }
            List<Contact> lstCon=new List<Contact>();
            //system.debug('conSet: '+conSet);
            //system.debug('imPLst'+imPLst);
            
            for(Id cS:conSet){
                //system.debug('lstCon'+lstCon);
                SPEN_VoiceAlert__C vcAlert=new SPEN_VoiceAlert__C(SPEN_ContactId__c=cS,SPEN_incidentId__c = contactIdincidentIdMap.get(cs), //CRMD-549 added SPEN_incidentId__c
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
    @SuppressWarnings('PMD.EmptyStatementBlock')
    global void finish(Database.BatchableContext bc){
    }

}