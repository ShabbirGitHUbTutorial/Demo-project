@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_ReceiveEndDevicePingStatus_Test {
    @testSetup static void setup() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps8 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps8.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        System.runAs(user){
            SPEN_MPAN__c mpan = new SPEN_MPAN__c();
            mpan.ExternalId__c = '123';
            insert mpan;
            Assert.isNotNull(mpan);
        }
    }
    @IsTest
    public static void testGetMpan() {
        Test.startTest();
        User usr= [Select id FROM User where firstName!=null and isActive=true LIMIT 1];
        System.runAs(usr){
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/SPEN_MPAN/123';  //Request URL
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ReceiveEndDevicePingStatus.doGet();
            Assert.areEqual('GET',req.httpMethod);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testPatchMpan() {
        Test.startTest();
        User usr= [Select id FROM User where firstName!=null and isActive=true LIMIT 1];
        System.runAs(usr){
            SPEN_MPAN__c mpan = [SELECT id FROM SPEN_MPAN__c Where id!=null LIMIT 1]; 
            Map<String,String> strBody = new Map<String,String>();
            strBody.put('SPEN_MeterType__c', 'MeterType');
            strBody.put('SPEN_PremiseRetailer__c', 'PremiseRetailer');
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/SPEN_MPAN/'+mpan.Id;  //Request URL
            req.requestBody= Blob.valueOf(JSON.serialize(strBody));
            req.httpMethod = 'PATCH';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ReceiveEndDevicePingStatus.doPatch();
            Assert.areEqual('PATCH',req.httpMethod);
            Test.stopTest();
        }
    }
}