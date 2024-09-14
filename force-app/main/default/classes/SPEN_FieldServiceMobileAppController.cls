/*-----------------------------------------------------------------------------
DESCRIPTION :   Controller class used to support LWC used in the FS Mobile App
AUTHOR      :   Accenture - Portugal ATC
-----------------------------------------------------------------------------*/
public with sharing class SPEN_FieldServiceMobileAppController {
    
    @TestVisible private static Double latitude;
    @TestVisible private static Double longitude;
    @TestVisible private static String premiseId;
    @TestVisible private static Id serviceResource;
    
    // DESCRIPTION
    // Return all the forms available to be invoked from the 'sPEN_MobileNonWorkRelated' LWC 
    @AuraEnabled (cacheable = true)
    public static List<SPEN_MobileFormSetting__mdt> getNonWorkRelatedForms(String userId, Double latitude, Double longitude) {
        
        SPEN_FieldServiceMobileAppController.latitude = latitude;
        SPEN_FieldServiceMobileAppController.longitude = longitude;
        SPEN_FieldServiceMobileAppController.premiseId = '';
        // GET service resource based on user Id
        SPEN_FieldServiceMobileAppController.serviceResource = getServiceResource(userId);
        // GET all the possible options that can be invoked from the 'MobileNonWorkRelatedForms' LWC
        List<SPEN_MobileFormSetting__mdt> settings = getMobileFormSettings();
        
        // Sign all the deep-links
        for(SPEN_MobileFormSetting__mdt setting : settings){
            setting.SPEN_FormDeepLink__c = deepLinkSign(setting.SPEN_FormDeepLink__c, setting.SPEN_Type__c);
        }

        return settings;
    }

    // DESCRIPTION
    // Return the signed link to be invoked from the 'sPEN_MobileNonWorkRelated' LWC
    @AuraEnabled (cacheable = true)
    public static String getDeepLink(String serviceResourceId, String target, String type, Double latitude, Double longitude, String premiseId) {
        SPEN_FieldServiceMobileAppController.serviceResource = serviceResourceId;
        SPEN_FieldServiceMobileAppController.latitude = latitude;
        SPEN_FieldServiceMobileAppController.longitude = longitude;
        SPEN_FieldServiceMobileAppController.premiseId = premiseId;
 
        return deepLinkSign(target,type);
    }
    
    // DESCRIPTION
    // Get ServiceResource record based on user's id
    // OFFline Consideration: Requires ServiceResource record to be included in Briefcase
    @TestVisible private static Id getServiceResource(Id userId) {
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId =: userId WITH SECURITY_ENFORCED LIMIT 1];
        return sr.Id;
    }

    // DESCRIPTION
    // Get ALL MobileFormSettings custom metadata records
    // OFFline Consideration: Requires SPEN_MobileFormSetting__mdt to be included in Briefcase
    @TestVisible private static List<SPEN_MobileFormSetting__mdt> getMobileFormSettings() {
        return [SELECT Id, MasterLabel, SPEN_FormDeepLink__c, SPEN_Type__c FROM SPEN_MobileFormSetting__mdt WHERE SPEN_isActive__c = true WITH SECURITY_ENFORCED];
    }

    // DESCRIPTION
    // Get The correct URL depeding on the MobileFormSettings custom metadata records types
    @TestVisible private static String getURL(String target, String type) {
        String url;

        if(type == 'LWC'){
            url = 'com.salesforce.fieldservice://v1/globalaction/SPEN_GlobalLWC?lwcName=' + target + 
                    '&latitude=' + SPEN_FieldServiceMobileAppController.latitude + 
                    '&longitude=' + SPEN_FieldServiceMobileAppController.longitude;
        } else{
            url = 'com.salesforce.fieldservice://v1/sObject/' + SPEN_FieldServiceMobileAppController.serviceResource + 
                    '/flow/' + target + 
                    '?latitude=' + SPEN_FieldServiceMobileAppController.latitude + 
                    '&longitude=' + SPEN_FieldServiceMobileAppController.longitude +
                    '&premiseId=' + SPEN_FieldServiceMobileAppController.premiseId;
        }

        return url;
    }

    // DESCRIPTION
    // Sign DeepLink to hide security dialog in the FS Mobile App
    @TestVisible private static string  deepLinkSign(String target, String type) {
        
        // Call Crypto.sign specifying the selected algorithm
        final String algorithmName = 'ECDSA-SHA256';
        // TODO - How to hide the private key
        final String privateKeyPKCS8 = 'MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgVAbfZs/reGpKE9JBzxkLImx+EyD5fhIADihDkXLh9xOhRANCAATYarZ4Po5//eNlQLWjbPe0jIO+pw+WOj/9rFdcrlRoJiH88qPcESogwSLszWVUdQFGuvDmW3Dits5iQDTTeEWC'; 
        
        String url = getURL(target, type);

        Blob privateKey = EncodingUtil.base64Decode(privateKeyPKCS8);
        Blob input = Blob.valueOf(url);
        
        String signature = EncodingUtil.base64Encode(Crypto.sign(algorithmName, input, privateKey));

        String signatureTrim = signature.replace('\n', '');
        signatureTrim = signatureTrim.replace('\r', '');
        signatureTrim = signatureTrim.replace('=', '');

        String deepLinkSigned;
        deepLinkSigned = url + '&__signature='+ signatureTrim;
       

        return deepLinkSigned;
    }
}