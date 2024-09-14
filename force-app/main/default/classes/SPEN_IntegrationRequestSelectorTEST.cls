@IsTest
public class SPEN_IntegrationRequestSelectorTEST 
{
    @Istest
    private static void testGetIntReqZoneRecord()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        PermissionSet conSettings = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = conSettings.Id);
        PermissionSet contactps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = contactps.Id);
        System.runAs(user){
            Test.startTest();
            List<SPEN_IntegrationRequest__c> intreq = SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert intreq;
            List<SPEN_IntegrationRequest__c> intreq1 = SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert intreq1;
            intreq[0].SPEN_RelatedRecord__c = intreq[0].Id;
            update intreq;
            
            Set<Id> relatedRecords = new Set<Id>();
            relatedRecords.add(intreq[0].Id);
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            intreq1[0].SPEN_RelatedRecord__c = con.Id;
            update intreq1;
            SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(intreq[0].Id);
            SPEN_IntegrationRequestSelector.geIntegrationRequestMapRecord(system.now());
            // SPEN_IntegrationRequestSelector.geIntegrationRequestZoneRecord(relatedRecords, system.now());
            SPEN_IntegrationRequestSelector.getIntegrationRequestRecordByContact(con.Id);
            Assert.isNotNull(intreq[0].Id, 'Id Passed');
            Test.stopTest();
        }
    }
}