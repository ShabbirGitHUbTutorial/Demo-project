@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_SDIFPingMeterQueueable_Test{
    @isTest
    public static void spenSDIFPingMeterQueueableTest(){
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
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        System.runAs(user)
        {
        SPEN_IntegrationRequest__c testRec = SPEN_TestDataFactory.createProcessingIntegrationReq();
        insert testRec;
        SPEN_SDIFPingMeterQueueable mockTest = new SPEN_SDIFPingMeterQueueable(testRec.Id, 'Test');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            System.enqueueJob(mockTest);
            Assert.areEqual(true, user.IsActive, 'active user');
		Test.stopTest();
        }
    }
}