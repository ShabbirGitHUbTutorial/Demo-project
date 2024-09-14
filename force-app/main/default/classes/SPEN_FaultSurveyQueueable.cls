public class SPEN_FaultSurveyQueueable implements Queueable {
    public Set<Id> smsVAIDs ; 
    public String surveyType;
    public String channel;
    public SPEN_FaultSurveyQueueable(Set<Id> smsVAIDs, String surveyType, String channel){
       this.smsVAIDs = smsVAIDs ;  
	   this.surveyType = surveyType;
       this.channel = channel;
    }
    public void execute(QueueableContext context) {
        if(channel.equalsIgnoreCase('SMS')){
        	SPEN_SurveyUtility.updateSMSWithInvitation(smsVAIDs, surveyType);
        } else if(channel.equalsIgnoreCase('Voice Alert') && surveyType.equalsIgnoreCase('Single Premise')){
            List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
			system.debug('SPEN_SurveyUtility>>> before');
            SPEN_SurveyUtility.updateVoiceAlertWithInvitation(smsVAIDs, surveyType);
            system.debug('SPEN_SurveyUtility>>> after');
            for(SPEN_VoiceAlert__c va : [select id,SPEN_ContactId__c,SPEN_IncidentId__c,SPEN_Event__c,SPEN_CommunicationScheduler__c,SPEN_BroadcastMessage__c,SPEN_IsProactive__c,SPEN_Case__c,RecordTypeId,SPEN_Status__c  from SPEN_VoiceAlert__c where id in :smsVAIDs])
            {
                lstVoiceAlert.add(va);
            }
            if(!Test.isRunningTest())
            {
                SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
            }
        }
    }
}