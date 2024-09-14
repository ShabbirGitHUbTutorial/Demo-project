@IsTest
public with sharing class SPEN_PhysicalInformationSelectorTEST 
{
    
    @IsTest
    private static void testPhysicalInformationFromCase()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessConnectionCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PhysicalInformationAccessCRUD'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        
        System.runAs(user)
        {   
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(1);
            insert testCase;
            List<Id> phyInfoIds = new List<Id>();
            List<SPEN_PhysicalInformation__c> physInfoLst=SPEN_TestDataFactory.createPhysInfoRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            physInfoLst[0].SPEN_Case__c=testCase[0].Id;
            insert physInfoLst;
            String phyInfoId = physInfoLst[0].Id;
            phyInfoIds.add(physInfoLst[0].Id);
            SPEN_PhysicalInformationSelector.getPhysicalInfoFromCase(testCase[0].Id);
            SPEN_PhysicalInformationSelector.getPhysicalInfoFromPhyInfoIds(phyInfoIds);
            SPEN_PhysicalInformationSelector.getPhysicalInfoFromPhyInfoStrId(phyInfoId);
            Assert.isNotNull(physInfoLst[0].SPEN_ItemClass__c, 'IT-UITEM');
            Test.stopTest();            
        }
    }   
}