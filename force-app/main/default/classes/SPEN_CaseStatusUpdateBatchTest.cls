/**
* @description       : Test class for SPEN_CaseStatusUpdateBatch
* @author            :Rahul Kumar
* @group             : 
* @last modified on  : 14-08-2023
* @last modified by  : rahul.dd.kumar@accenture.com
**/
@IsTest(SeeAllData=false)
public with sharing class SPEN_CaseStatusUpdateBatchTest {
    @testSetup 
    static void dataSetup() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user){
        List<Case> modCase = new List<Case>();
        Case newCase = SPEN_TestDataFactory.createFaultCase()[0];
        newCase.SPEN_CriticalInformation__c = 'Test Critical Information Modified';
        Test.startTest();
        update newCase;
        modCase.add(newCase);
       
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        CaseCallouts.sendUpdatedCaseToPowerOnAPI(SPEN_TestDataFactory.createWebCase(), SPEN_TestDataFactory.createFaultCase());
        CaseCallouts.sendUpdatedCaseToPowerOnAPI(null, null);
        CaseCallouts.sendUpdatedCaseToPowerOnAPI(SPEN_TestDataFactory.createWebCase(), modCase);
        CaseCallouts.sendCancelledCaseToPowerOnAPI(SPEN_TestDataFactory.createWebCase(), SPEN_TestDataFactory.cancelCallCase());
        CaseCallouts.sendCancelledCaseToPowerOnAPI(null, null);
        CaseCallouts.sendCreatedCaseToPowerOnAPI(null);
        Test.stopTest();
        }
       
    }
    @isTest
    public static void testCaseStatusUpdateBatch(){
        User u= [Select id FROM User WHERE isActive = true LIMIT 1];
        System.runAs(u){
            Test.startTest();
                List<Case> lstOfCases = [select id, ownerId, status, SPEN_ETROutage__c from case LIMIT 10];
                Map<Id, Case> mapOfIdVsCases = new Map<Id, Case>(lstOfCases);
                Database.executeBatch(new SPEN_CaseStatusUpdateBatch(mapOfIdVsCases),100);
            System.assert(true, 'Batch processed successfully!');
            Test.stopTest();

        }
    }
    
}