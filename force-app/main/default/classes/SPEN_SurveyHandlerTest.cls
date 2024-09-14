@isTest
public class SPEN_SurveyHandlerTest {
    
    @isTest 
    public static void testgetRelatedSurveyQuestionResponses() 
    {
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        if (devOpsPSGroup.Status != 'Updated')  
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);	 
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign; 
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_SurveyAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        System.runAs(user){
            Test.startTest();
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            SPEN_SurveyHandler.getRelatedSurveyQuestionResponses(new List<Id>{testCase[0].Id});
            SPEN_SurveyHandler.getSurveyResponses(testCase[0].Id);
            
            
            Test.stopTest();
        }
    }
}