public class SPEN_VoiceCallService 
{
    public void isUpdatingPremiseOnVoiceCall(Map<Id,VoiceCall> oldVoiceCall, List<VoiceCall> newVoiceCall)
    {
        try
        {
        	Set<Id> conIds = New Set<Id>();
    		for(VoiceCall voiceSession: newVoiceCall)
    		{
                VoiceCall oldVoice = oldVoiceCall.get(voiceSession.Id);
                string contactIdPrefix = Schema.SObjectType.Contact.getKeyPrefix();
                string caseIdPrefix = Schema.SObjectType.Case.getKeyPrefix();
                if(voiceSession.RelatedRecordId !=null && String.valueOf(voiceSession.RelatedRecordId).startsWith(contactIdPrefix) && voiceSession.SPEN_ContactId__c == null && voiceSession.CallType =='Outbound'){
                    voiceSession.SPEN_ContactId__c = voiceSession.RelatedRecordId;
                    conIds.add(voiceSession.SPEN_ContactId__c);
			Map<Id,SPEN_CustomerUpdate__c> voiceCustomerUpdateMap = SPEN_CustomerUpdatesSelector.getCustomerUpdateForVoiceCall(voiceSession);
                    if(!voiceCustomerUpdateMap.isEmpty()){
                        voiceSession.SPEN_OutboundDiallerTask__c = voiceCustomerUpdateMap.get(voiceSession.Id).Id;
                        voiceSession.SPEN_RelatedIncident__c = voiceCustomerUpdateMap.get(voiceSession.Id).SPEN_IncidentId__c;
                    } 
                }
                if(voiceSession.RelatedRecordId !=null && String.valueOf(voiceSession.RelatedRecordId).startsWith(caseIdPrefix) && voiceSession.SPEN_VCCase__c == null && voiceSession.CallType =='Outbound'){
                    voiceSession.SPEN_VCCase__c = voiceSession.RelatedRecordId;
                }
        		IF(voiceSession.SPEN_ContactId__c!= null && (voiceSession.SPEN_ContactId__c!=oldVoice.SPEN_ContactId__c)) 
        		{
           			conIds.add(voiceSession.SPEN_ContactId__c);
        		}
    		}
    		Map<String,String> conMap = new Map<String, String>();
            if(!conIds.isEmpty()){
                conMap = SPEN_ContactPremisesSelector.getPremiseForContact(conIds);
            }
            
            if(!conMap.isEmpty())
            {
            	for(VoiceCall voiceSession: newVoiceCall)
                {
                    if(conMap.containsKey(voiceSession.SPEN_ContactId__c))
                    {
                      	voiceSession.SPEN_VoicecallPremise__c = conMap.get(voiceSession.SPEN_ContactId__c);
                    }
                }
            }
        }
        catch(exception ex)
        {
            SEL_LoggingService.log(ex);
        }
    }

    @InvocableMethod(label='Update Voice Call' description='Update Common Wizard Summary to Voice Call')
    public static void updateCWizardDataToVoiceCall(List<VoiceCall> inputObj){
        List<VoiceCall> wizardVoiceCall = inputObj;
		upsert wizardVoiceCall;
    }
    
}