/*-----------------------------------------------------------------------------
DESCRIPTION :   Batch class to handle creation of voice alert in batch.
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
DEC-01-2023     Shubhi Vijayvergia        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_VoiceAlertServiceBatch implements Database.Batchable<sObject>,Database.RaisesPlatformEvents {
    List<Id> caseidList=new List<Id>();
    Id recordtypeId;
    String broadcastMessage;
    String status;
    public SPEN_VoiceAlertServiceBatch(List<Id> caseidList,String broadcastMessage, Id recordtypeId){
       this.caseidList=caseidList;
       this.broadcastMessage=broadcastMessage;
       this.recordtypeId=recordtypeId;
    }
    public Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator([select Id,SPEN_PreferredMethodofContact__c,SPEN_CallerTelephone__c,SPEN_Incident__c,ContactId
                                         from Case where Id in :caseidList]);
        
    }
    public void execute(Database.BatchableContext bc, List<Case> caseList)
    {
            List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
			for(Case c : caseList){
            if((c.SPEN_PreferredMethodofContact__c ==SPEN_ImpactedPremisesConstants.H_PREFEREDMETHODOFCONTACT && c.SPEN_CallerTelephone__c != null) || (c.SPEN_PreferredMethodofContact__c==null && c.SPEN_CallerTelephone__c != null))
            {
                SPEN_VoiceAlert__c objVoiceAlert = new SPEN_VoiceAlert__c();
                objVoiceAlert.SPEN_CalledInTelephone__c = c.SPEN_CallerTelephone__c;
                objVoiceAlert.SPEN_ContactId__c = c.ContactId;
                objVoiceAlert.RecordTypeId = recordtypeId;
                objVoiceAlert.SPEN_IncidentId__c =c.SPEN_Incident__c;
                objVoiceAlert.SPEN_BroadcastMessage__c = broadcastMessage;
                objVoiceAlert.SPEN_Status__c = SPEN_ImpactedPremisesConstants.SMSREADYSTATUS;
                lstVoiceAlert.add(objVoiceAlert);
            }
        }
        if(!lstVoiceAlert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lstVoiceAlert, false);
            SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
        }

    }
    public void finish(Database.BatchableContext bc){
    }

}