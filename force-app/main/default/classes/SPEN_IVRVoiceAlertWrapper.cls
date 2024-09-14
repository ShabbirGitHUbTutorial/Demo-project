public class SPEN_IVRVoiceAlertWrapper {
    	
    public List<Attributes> attributes;
    
public class Attributes {
    public String phoneNumber;
    public String ivrMessage;
    public String voiceId;
    public String contactId;
    public String surveyQuestionsIds;
    public String surveyInvitationId;
    public String surveyId;
    public String Event;
}
    public static SPEN_IVRVoiceAlertWrapper parse(String json) {
        return (SPEN_IVRVoiceAlertWrapper) System.JSON.deserialize(json, SPEN_IVRVoiceAlertWrapper.class);
    }

}