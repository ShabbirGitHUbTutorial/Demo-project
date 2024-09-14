public with sharing class SPEN_OutboundCommsCheckerService {

    @AuraEnabled
    public static Boolean getCommHoursIfDaily(SPEN_IVROperatingHours__c recordIVR){
        try {
            Boolean sendVoiceAlert = false;
            if(recordIVR.SPEN_isDaily__c){
                List<SPEN_IVROperatingHours__c> sendDateAlert = SPEN_OutboundCommsCheckerSelector.getIfInRestricedDate(recordIVR.Id);
                if(sendDateAlert.size() > 0){
                    sendVoiceAlert = true;
                } else {
                    sendVoiceAlert = false;
                }
            } else{
                List<SPEN_IVROperatingHours__c> sendTimeAlert = SPEN_OutboundCommsCheckerSelector.getIfInStartEndTime(recordIVR.Id);
                if(sendTimeAlert.size() > 0){
                    sendVoiceAlert = true;
                } else {
                    sendVoiceAlert = false;
                }
            }
            return sendVoiceAlert;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}