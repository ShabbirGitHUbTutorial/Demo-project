/*-----------------------------------------------------------------------------
DESCRIPTION :   Test for the controller class used to support LWC used in the FS Mobile App
AUTHOR      :   Accenture - Portugal ATC
-----------------------------------------------------------------------------*/
@isTest
private class SPEN_FieldServiceMobileAppControllerTest {
    @TestSetup
    static void setup() {

        //creating User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User user = new user(
        LastName = 'Billy Bain',
        Alias = 'Bill',
        Email = 'test@test.com',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey='en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'standarduser@test.com.test');

        insert user;

        //creating Service Resources
        ServiceResource serviceResource = new ServiceResource( 
        Name = 'Billy Bain', 
        RelatedRecordId = user.Id);
        
        insert serviceResource;

        //creating SPEN_MobileFormSetting__mdt
        SPEN_MobileFormSetting__mdt formSet = [SELECT MasterLabel, SPEN_FormDeepLink__c, SPEN_Type__c FROM SPEN_MobileFormSetting__mdt WHERE SPEN_Type__c = 'Flow' LIMIT 1];


    }

    @isTest
    static void testGetNonWorkRelatedForms() {
        // Arrange
        Test.startTest();
        Id userId = [SELECT id FROM user WHERE Username = 'standarduser@test.com.test'].Id;
        Double latitude = 15;
        Double longitude= -3;
        // Act
        List<SPEN_MobileFormSetting__mdt> result = SPEN_FieldServiceMobileAppController.getNonWorkRelatedForms(userId, latitude, longitude);
        // Assert
        System.assertNotEquals(0, result.size(), 'No records returned');
        for (SPEN_MobileFormSetting__mdt setting : result) {
            System.assertNotEquals(null, setting.SPEN_FormDeepLink__c, 'Deep link is null');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetDeepLink() {
        // Arrange
        Test.startTest();
        String target = 'my_Flow';
        String type = 'Flow';
        ServiceResource sr = [SELECT Id FROM ServiceResource];
        Id srId = sr.Id;
        Double latitude = 15;
        Double longitude= -3;
        String premisedId = 'testId';
        // Act
        String result = SPEN_FieldServiceMobileAppController.getDeepLink(srId,target,type, latitude, longitude, premisedId);
        // Assert
        System.assert(result.contains('&__signature='), 'Unexpected URL');
        Test.stopTest();
    }

    @isTest
    static void testGetServiceResource() {
        // Arrange
        Test.startTest();
        Id userId = [SELECT id FROM user WHERE Username = 'standarduser@test.com.test'].Id;
        // Act
        Id result = SPEN_FieldServiceMobileAppController.getServiceResource(userId);
        // Assert
        System.assertNotEquals(null, result, 'No record returned');
        Test.stopTest();
    }

    @isTest
    static void testGetMobileFormSettings() {
        // Arrange
        Test.startTest();
        // Act
        List<SPEN_MobileFormSetting__mdt> result = SPEN_FieldServiceMobileAppController.getMobileFormSettings();
        // Assert
        System.assertNotEquals(0, result.size(), 'No records returned');
        Test.stopTest();
    }

    @isTest
    static void testDeepLinkSign() {
        // Arrange
        Test.startTest();
        String target = 'my_LWC';
        String type = 'LWC';
        // Act
        String result = SPEN_FieldServiceMobileAppController.deepLinkSign(target, type);
        // Assert
        System.assert(result.contains('&__signature='), 'Unexpected URL');
        Test.stopTest();
    } 

    @isTest static void testGetURL_LWC() {
        // Arrange
        Test.startTest();
        String target = 'TestFlow';
        SPEN_FieldServiceMobileAppController.latitude = 37.7749;
        SPEN_FieldServiceMobileAppController.longitude = -122.4194;
        String expectedUrl = 'com.salesforce.fieldservice://v1/globalaction/SPEN_GlobalLWC?lwcName=TestFlow&latitude=37.7749&longitude=-122.4194';
        // Act
        String actualUrl = SPEN_FieldServiceMobileAppController.getURL(target, 'LWC');
        // Assert
        System.assertEquals(expectedUrl, actualUrl);
        Test.stopTest();
    }

    @isTest static void testGetURL_Flow() {
        // Arrenge
        Test.startTest();
        String target = 'TestFlow';
        SPEN_FieldServiceMobileAppController.latitude = 37.7749;
        SPEN_FieldServiceMobileAppController.longitude = -122.4194;
        ServiceResource sr = [SELECT Id FROM ServiceResource LIMIT 1];
        SPEN_FieldServiceMobileAppController.serviceResource = sr.Id;
        // Act
        String result = SPEN_FieldServiceMobileAppController.getURL(target, 'Flow');
        // Assert
        System.assert(result.contains('flow'), 'Unexpected URL');
        Test.stopTest();
    }

}