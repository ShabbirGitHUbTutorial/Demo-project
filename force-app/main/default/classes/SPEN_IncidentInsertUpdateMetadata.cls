/*-------------------------------------------------------------------------------------------------------------------
DESCRIPTION: Apex CLASS SPEN_IncidentInsertUpdateMetadata.apxc for Incident Record Auto Refresh
AUTHOR                      VERSION       	 DATE       		Details
Sheker Kulkacherla            1            23/11/2022         CRMD-440 View Current Reactive Incidents
----------------------------------------------------------------------------------------------------------------*/
global with sharing class SPEN_IncidentInsertUpdateMetadata {
    @AuraEnabled
    public static String getChannel(){
        SPEN_IncidentAutomaticRefresh__mdt incidentRecord = SPEN_IncidentAutomaticRefresh__mdt.getInstance(SPEN_ConstantData.INCIDENTINSERTANDUPDATES);
        return string.valueOf(incidentRecord.SPEN_Channel__c);
    }
}