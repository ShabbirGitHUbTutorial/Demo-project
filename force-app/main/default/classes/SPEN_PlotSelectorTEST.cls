@IsTest
public with sharing class SPEN_PlotSelectorTEST 
{
    
    @IsTest
    private static void testPlotsFromCase()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PlotAccessCRUD'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        
        System.runAs(user)
        {   
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(1);
            insert testCase;
            List<SPEN_Plot__c> plot=SPEN_TestDataFactory.createPlotRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            plot[0].SPEN_CaseRecord__c=testCase[0].Id;
            insert plot;
            SPEN_PlotSelector.getPlotsFromCase(testCase[0].Id);
            SPEN_PlotSelector.getActivePlotsCountFromCase(testCase[0].Id);
            Assert.isNotNull(plot[0].SPEN_TechnologyType__c, 'Photovoltaic');
            Test.stopTest();            
        }
    }   
}