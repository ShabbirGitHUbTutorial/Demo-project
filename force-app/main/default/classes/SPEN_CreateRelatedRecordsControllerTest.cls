@IsTest
public class SPEN_CreateRelatedRecordsControllerTest {
    @isTest
    public static void relatedProjectTest(){
        //Profile Creation
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        //User setup
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        //insert User
        Database.insert(user);
        //Permissionset assignment
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseTransmissionAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        
        System.runAs(user){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            
            Test.startTest();
            String relatedProject = '[{"parentCase":"5002600000Wh0z8AAB","relatedCaseId":"5002600000W9lZAAAZ","relatedProjectName":"00014002","relatedStage":"Stage 1","relatedType":"Wider","relatedQueue":"1","relatedRelationship":"Interactive"},{"parentCase":"5002600000Wh0z8AAB","relatedCaseId":"5002600000WBG9CAAX","relatedProjectName":"00014107","relatedStage":"Stage 2","relatedType":"Enabling","relatedQueue":"","relatedRelationship":"Related"},{"parentCase":"5002600000Wh0z8AAB","relatedCaseId":"5002600000WfGOEAA3","relatedProjectName":"00014133","relatedStage":"Stage 4","relatedType":"Wider","relatedQueue":"3","relatedRelationship":"Interactive"}]';
            SPEN_CaseSelector.findRecords('test');
            SPEN_CreateRelatedRecordsController.insertRelatedProject(relatedProject);
            Test.stopTest();     
            
            // List<SPEN_RelatedProject__c> relList = [Select Id,SPEN_Case__c,SPEN_RelatedCase__c From SPEN_RelatedProject__c where SPEN_Case__c = '5002600000Wh0z8AAB'];
            // Assert.areEqual(relList[0].SPEN_RelatedCase__c,'5002600000W9lZAAAZ' );
        }
    }
}