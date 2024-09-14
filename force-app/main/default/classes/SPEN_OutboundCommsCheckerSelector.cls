public with sharing class SPEN_OutboundCommsCheckerSelector {

    @AuraEnabled
    public static List<SPEN_IVROperatingHours__c> getIfInRestricedDate(Id recordId){
        try {
            Datetime currentTime = System.now();
            Id recordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByDeveloperName().get('Outbound_Contact_Hours').getRecordTypeId();
        	List<SPEN_IVROperatingHours__c> resrtictDateQuery;
            if(recordId != null)
            	resrtictDateQuery = [SELECT Id, SPEN_CommunicationType__c, SPEN_isDaily__c, SPEN_RestrictStartDate__c,RecordType.DeveloperName, SPEN_RestrictEndDate__c, SPEN_isActive__c, SPEN_StartTime__c, SPEN_EndTime__c, SPEN_IVRMessage__c, SPEN_IVR__c FROM SPEN_IVROperatingHours__c WHERE RecordTypeId =:recordTypeId  AND (SPEN_RestrictStartDate__c <= :currentTime AND SPEN_RestrictEndDate__c >= :currentTime) AND Id =:recordId];
            //System.debug(resrtictDateQuery);
            return resrtictDateQuery;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SPEN_IVROperatingHours__c> getIfInStartEndTime(Id recordId){
        try {
            List<SPEN_IVROperatingHours__c> startEndTimeQuery = new List<SPEN_IVROperatingHours__c>();
            Time currentTime = System.now().time();
            Id recordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByDeveloperName().get('Outbound_Contact_Hours').getRecordTypeId();        
            if(recordId != null)
            	startEndTimeQuery = [SELECT Id, Name, SPEN_CommunicationType__c, SPEN_isDaily__c, SPEN_RestrictStartDate__c, SPEN_RestrictEndDate__c,RecordType.DeveloperName, SPEN_isActive__c, SPEN_StartTime__c, SPEN_EndTime__c, SPEN_IVRMessage__c, SPEN_IVR__c FROM SPEN_IVROperatingHours__c WHERE RecordTypeId =:recordTypeId AND (SPEN_StartTime__c <= :currentTime AND SPEN_EndTime__c >= :currentTime) AND Id =:recordId];
            return startEndTimeQuery;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}