/**
 * @description       : This class is called from flow.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SPEN_SMSCtrlInvokedByFlow {

    @InvocableMethod(Label='Invoke apex method to process SMS with Batch')
    public static void callBatchApexFromFlow(List<Id> lstComScheId){
       

        Id vABroadCastRecTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('Voice Alert Broadcast').getRecordTypeId();

        Id smsBroadCastRecTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('SMS Broadcast').getRecordTypeId();
       
        Map<SPEN_CommunicationScheduler__c, Id> mapOfCommSchVsIncident = new map<SPEN_CommunicationScheduler__c, Id>();

        Map<SPEN_CommunicationScheduler__c, Id> mapOfCommSchVsIncidentVA = new map<SPEN_CommunicationScheduler__c, Id>();

        Map<SPEN_CommunicationScheduler__c, List<Boolean>> mapOfCommSchedulerWithCheckboxes = new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();

        Map<SPEN_CommunicationScheduler__c, List<Boolean>> mapOfCommSchedulerWithCheckboxesVA = new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
        
        Map<String, SPEN_CommunicationScheduler__c> mapDistrictToCommSch = new Map<String, SPEN_CommunicationScheduler__c>();

        Map<String, SPEN_CommunicationScheduler__c> mapDistrictToCommSchVA = new Map<String, SPEN_CommunicationScheduler__c>();

        //[CRMD:4073]
        List<SPEN_CommunicationScheduler__c> listPremiseSMSCommSch = new List<SPEN_CommunicationScheduler__c>();
        List<SPEN_CommunicationScheduler__c> listPremiseVACommSch = new List<SPEN_CommunicationScheduler__c>();
        //On Demand List intialize
        List<SPEN_CommunicationScheduler__c> listOnDemandPremiseVACommSch = new List<SPEN_CommunicationScheduler__c>();
        List<SPEN_CommunicationScheduler__c> listOnDemandPremiseSMSCommSch = new List<SPEN_CommunicationScheduler__c>();

         for(SPEN_CommunicationScheduler__c commSch  : [select id, name,recordTypeId, SPEN_IncidentId__c, SPEN_Event__c, SPEN_IncidentId__r.SPEN_IncidentCategory__c,SPEN_SendSMSMCtoPSR__c,SPEN_SendSMStoAllCustomerinScope__c,SPEN_SendSMSMCtocalledin__c,SPEN_Message__c,SPEN_NonPSRMessage__c,SPEN_District__c,SPEN_SendVAtoAllCustomerinScope__c,SPEN_SendSMStoPSRCalledin__c,SPEN_SendVoiceAlerttocalledin__c,SPEN_SendVoiceAlerttoPSR__c,SPEN_SendVAtoPSRCalledin__c,SPEN_PremiseQuery__c,SPEN_MessagingTaskId__r.SPEN_PremiseIds__c  from SPEN_CommunicationScheduler__c where Id IN :lstComScheId   WITH SECURITY_ENFORCED]){
            if(commSch.recordTypeId == smsBroadCastRecTypeId &&  commSch.SPEN_IncidentId__c == null && commSch.SPEN_Event__c == 'Medically Dependent by District' && commSch.SPEN_District__c != null ){
                mapDistrictToCommSch.put(commSch.SPEN_District__c.toLowerCase(), commSch);
            }
            else if(commSch.recordTypeId == vABroadCastRecTypeId &&  commSch.SPEN_IncidentId__c == null && commSch.SPEN_Event__c == 'Medically Dependent by District' && commSch.SPEN_District__c != null ){
                mapDistrictToCommSchVA.put(commSch.SPEN_District__c.toLowerCase(), commSch);
            }
            //[CRMD:4073] S
           /* else if(commSch.recordTypeId == smsBroadCastRecTypeId &&  commSch.SPEN_IncidentId__c == null && commSch.SPEN_Event__c == 'Planned Outage Communication' && commSch.SPEN_PremiseQuery__c != null ){
                listPremiseSMSCommSch.add(commSch);
            }
            else if(commSch.recordTypeId == vABroadCastRecTypeId &&  commSch.SPEN_IncidentId__c == null && commSch.SPEN_Event__c == 'Planned Outage Communication' && commSch.SPEN_PremiseQuery__c != null ){
                listPremiseVACommSch.add(commSch);
            }
            //[CRMD:4073] E */
            else if(commSch.recordTypeId == smsBroadCastRecTypeId && commSch.SPEN_Event__c == 'On Demand'){
                listOnDemandPremiseSMSCommSch.add(commSch);
            }
            else if(commSch.recordTypeId == vABroadCastRecTypeId && commSch.SPEN_Event__c == 'On Demand'){
                listOnDemandPremiseVACommSch.add(commSch);
            }
            else if(commSch.recordTypeId == smsBroadCastRecTypeId && commSch.SPEN_IncidentId__c !=null){
                mapOfCommSchVsIncident.put(commSch, commSch.SPEN_IncidentId__c);
                List<Boolean> lstOfCommSchedulerCheckboxes = new List<Boolean>();
                lstOfCommSchedulerCheckboxes.add(commSch.SPEN_SendSMSMCtoPSR__c);
                lstOfCommSchedulerCheckboxes.add(commSch.SPEN_SendSMStoAllCustomerinScope__c);
                lstOfCommSchedulerCheckboxes.add(commSch.SPEN_SendSMStoPSRCalledin__c);
                lstOfCommSchedulerCheckboxes.add(commSch.SPEN_SendSMSMCtocalledin__c);
                mapOfCommSchedulerWithCheckboxes.put(commSch,lstOfCommSchedulerCheckboxes);
            }
            else if(commSch.recordTypeId == vABroadCastRecTypeId && commSch.SPEN_IncidentId__c !=null){
                mapOfCommSchVsIncidentVA.put(commSch, commSch.SPEN_IncidentId__c);
                List<Boolean> lstOfCommSchedulerCheckboxesforVA = new List<Boolean>();
                lstOfCommSchedulerCheckboxesforVA.add(commSch.SPEN_SendVoiceAlerttoPSR__c);
                lstOfCommSchedulerCheckboxesforVA.add(commSch.SPEN_SendVAtoAllCustomerinScope__c);
                lstOfCommSchedulerCheckboxesforVA.add(commSch.SPEN_SendVAtoPSRCalledin__c);
                lstOfCommSchedulerCheckboxesforVA.add(commSch.SPEN_SendVoiceAlerttocalledin__c);
                mapOfCommSchedulerWithCheckboxesVA.put(commSch,lstOfCommSchedulerCheckboxesforVA);
            }
         }

         //Calculation of blackout window period.
         Boolean isOptoutForSMS = checkBlackoutWindowPeriod('SMS Blackout Window');
         Boolean isOptoutForVA = checkBlackoutWindowPeriod('VA Blackout Window');
         Integer customLabelValueSMS=Integer.valueOf(System.Label.SPEN_InsertSMSBatchSize);
         //Integer customLabelValueVA=Integer.valueOf(System.Label.SPEN_InsertVABatchSize);
         Integer customLabelValueVA=Integer.valueof(SPEN_BatchSettings__mdt.getInstance('SPEN_InsertVoiceBatchSize').SPEN_BatchSize__c);

         // send sms functionality to psr, nonpsr, psr called in , non-psr called in customer 
         if(!mapOfCommSchVsIncident.isEmpty() && !mapOfCommSchedulerWithCheckboxes.isEmpty() && isOptoutForSMS){
            
            Database.executeBatch(new SPEN_InsertSMSBatch(mapOfCommSchVsIncident, mapOfCommSchedulerWithCheckboxes, 1),customLabelValueSMS);
         }
         if(!mapOfCommSchVsIncidentVA.isEmpty() && !mapOfCommSchedulerWithCheckboxesVA.isEmpty() && isOptoutForVA){
            
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(mapOfCommSchVsIncidentVA, mapOfCommSchedulerWithCheckboxesVA, 1),customLabelValueVA);
         }
         if(!mapDistrictToCommSch.isEmpty()){
           Database.executeBatch(new SPEN_InsertSMSBatch(mapDistrictToCommSch), customLabelValueSMS);
        }
        if(!mapDistrictToCommSchVA.isEmpty()){
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(mapDistrictToCommSchVA), customLabelValueVA);
         }
       /*  if(!listPremiseSMSCommSch.isEmpty()){
            String query = 'SELECT id FROM SPEN_Premise__c WHERE '+ listPremiseSMSCommSch[0].SPEN_PremiseQuery__c;
            List<SPEN_Premise__c> lstPrem = Database.query(query);
            Set<String> setPremId = new Set<String>();
            for(SPEN_Premise__c prem: lstPrem)
                setPremId.add(prem.id);
            Database.executeBatch(new SPEN_InsertSMSBatch(setPremId,listPremiseSMSCommSch), 200);
         }
         if(!listPremiseVACommSch.isEmpty()){
            String query = 'SELECT id FROM SPEN_Premise__c WHERE '+ listPremiseVACommSch[0].SPEN_PremiseQuery__c;
            List<SPEN_Premise__c> lstPrem = Database.query(query);
            Set<String> setPremId = new Set<String>();
            for(SPEN_Premise__c prem: lstPrem)
                setPremId.add(prem.id);
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(setPremId,listPremiseVACommSch), 200);
         }*/
         if(!listOnDemandPremiseSMSCommSch.isEmpty()){
            Database.executeBatch(new SPEN_InsertSMSBatch(listOnDemandPremiseSMSCommSch), 200);
         }
         if(!listOnDemandPremiseVACommSch.isEmpty()){
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(listOnDemandPremiseVACommSch), 200);
         }
    }


    // Method to check SMS Black out window period to send the Communication by sms.
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