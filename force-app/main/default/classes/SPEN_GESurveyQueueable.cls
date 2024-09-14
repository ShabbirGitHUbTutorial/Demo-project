public class SPEN_GESurveyQueueable implements Queueable {
    public Set<Id> smsVAIDs ; 
    public String surveyType;
    public String channel;
    Map<Id,Id> mapCseIdConId;
    Map<Id,String> mapCseIdEmailId;
    public SPEN_GESurveyQueueable(Set<Id> smsVAIDs, String surveyType, String channel)
    {
        this.smsVAIDs = smsVAIDs ;  
        this.surveyType = surveyType;
        this.channel = channel;
    }
    public SPEN_GESurveyQueueable(Map<Id,Id> mapCseIdConId,Map<Id,String> mapCseIdEmailId,String surveyType, String channel)
    {
        this.mapCseIdConId = mapCseIdConId;
        this.mapCseIdEmailId = mapCseIdEmailId;
        this.surveyType = surveyType;
        this.channel = channel;
    }
    public void execute(QueueableContext context) {
        if(channel.equalsIgnoreCase('SMS') && surveyType.equalsIgnoreCase('General Enquiries'))
        {
            SPEN_SurveyUtility.updateSMSWithInvitation(smsVAIDs, surveyType);
        }
        else if(channel.equalsIgnoreCase('Voice Alert') && surveyType.equalsIgnoreCase('General Enquiries'))
        {
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
        else if(channel.equalsIgnoreCase('Email') && surveyType.equalsIgnoreCase('General Enquiries'))
        {
            SPEN_SurveyUtility.sendSurveyEmails(mapCseIdConId, mapCseIdEmailId, surveyType);
        }
    }
}