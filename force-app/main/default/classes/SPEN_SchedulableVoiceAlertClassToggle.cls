public with sharing class SPEN_SchedulableVoiceAlertClassToggle implements Schedulable
{
    Id incidentId;
    String vcAlertMessage;
    datetime scheduleTime;
    Boolean pSRCheck;
    Boolean caseCheck;
    Boolean allCustCheck;
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public SPEN_SchedulableVoiceAlertClassToggle(Id incId,String vcAlertTemplt,datetime scTime,Boolean incpSRCheckbox,Boolean incCaseCheckbox,Boolean incAllCustCheckbox)
    {
        incidentId=incId;
        vcAlertMessage=vcAlertTemplt;
		scheduleTime = scTime;
        pSRCheck = incpSRCheckbox;
        caseCheck = incCaseCheckbox;
        allCustCheck = incAllCustCheckbox;
    }

    public void execute(SchedulableContext sC) 
    {
        List<SPEN_ImpactedPremise__c> imPLst=new List<SPEN_ImpactedPremise__c>();
        /*Incident Inc=[select id,(select id,SPEN_CustomerMobileNumberFormula__c,SPEN_RelatedCustomerFormula__c,SPEN_PSRCheckFormula__c from Impacted_Premises__r where SPEN_PSRCheckFormula__c=True),(select id,ContactId from cases__r) from Incident where id= :IncidentId];
        List<SPEN_ImpactedPremise__c> ImPLst=new List<SPEN_ImpactedPremise__c>();
        List<Case> CaseLst=new List<Case>();
        if(!inc.Impacted_Premises__r.isEmpty()){
            ImPLst.addALL(inc.Impacted_Premises__r);
        }
        if(!inc.cases__r.isEmpty()){
            CaseLst.addALL(inc.cases__r);
        }
        //ImPLst.addAll(inc.Impacted_Premises__r);
        //CaseLst.addAll(inc.Cases__r);
        if(!ImPLst.IsEmpty() && PSRCheck){
            for(SPEN_ImpactedPremise__c spi:ImPLst){
                if(spi.SPEN_PSRCheckFormula__c){
                SPEN_ScheduleVoiceAlertBatchPSRToggle scheduleBatch = new SPEN_ScheduleVoiceAlertBatchPSRToggle(IncidentId,vcAlertMessage,scheduleTime);
                Database.executeBatch(scheduleBatch); 
                }
            }
        }
        if(!CaseLst.IsEmpty() && CaseCheck){
            SPEN_ScheduleVoiceAlertBatchCaseToggle scheduleBatch = new SPEN_ScheduleVoiceAlertBatchCaseToggle(IncidentId,vcAlertMessage,scheduleTime);
                Database.executeBatch(scheduleBatch); 
        }
        if(Inc.Id!=Null && AllCustCheck){
                SPEN_ScheduleVoiceAlertBatchAllCusToggle scheduleBatch = new SPEN_ScheduleVoiceAlertBatchAllCusToggle(IncidentId,vcAlertMessage,scheduleTime);
                Database.executeBatch(scheduleBatch);
        }*/
    }
}