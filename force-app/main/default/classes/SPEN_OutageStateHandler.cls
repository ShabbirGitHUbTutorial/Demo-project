public with sharing class SPEN_OutageStateHandler {
    
    
    public static Incident outageStateupdate(Incident tempIcident, String logComments, String incType){
        logComments = logComments.replaceAll('\'', '');
        String PreviousOutageValue = SPEN_OutageStateHandler.betweenData(SPEN_ConstantData.COMMENTFROM, SPEN_ConstantData.COMMENTTO, logComments);
        String lastString = logComments.substring(logComments.length()-1, logComments.length());
        String CurrentOutageValue = SPEN_OutageStateHandler.betweenData(SPEN_ConstantData.COMMENTTO, lastString, logComments);
        if(PreviousOutageValue == SPEN_ConstantData.OUTAGERESTORED && CurrentOutageValue != SPEN_ConstantData.OUTAGERESTORED && incType == 'LV'){
            tempIcident.SPEN_IncidentStatus__c = 'In Progress';
            tempIcident.SPEN_Outage_State__c = CurrentOutageValue;
            tempIcident.SPEN_Previous_Outage_State__c = PreviousOutageValue;
        }else{
			tempIcident.SPEN_Outage_State__c = CurrentOutageValue;
            tempIcident.SPEN_Previous_Outage_State__c = PreviousOutageValue;
        }
        return tempIcident;
    } 
    public static String betweenData(String startDelim , String endDelim, String logComments){
        String betweenData;
        Integer startIndex = logComments.indexOf(startDelim);
        if (startIndex != -1) {
            Integer endIndex = logComments.indexOf(endDelim, startIndex);
            if (endIndex != -1) {
                betweenData = logComments.substring(startIndex+startDelim.length(), endIndex+1).trim();
            }
        }
        return betweenData;
    }
    
}