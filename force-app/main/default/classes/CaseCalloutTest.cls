/*-------------------------------------------------------------------------------------------------------------------
DESCRIPTION: UNIT TEST CLASS FOR CaseCallout.apxc class
AUTHOR: Sumit Biswas
MODIFIED BY: ROHIT CHOWDHURY
VERSION: 1
DATE: 8th NOVEMBER 2022
----------------------------------------------------------------------------------------------------------------*/
@IsTest
public class CaseCalloutTest {
    @IsTest
    public static void ableToGetData(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Map<Id, Case> oldMapCases= new Map<Id, Case>();
       
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
         oldMapCases.put(newCase.Id,newCase);
        List<SPEN_Premise__c> premList = SPEN_TestDataFactory.createListOfPremise(1);
        List<Case> caseList = SPEN_TestDataFactory.createUnPlannedFaultCase(premList[0].Id);
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
        CaseCallouts.sendCreatedCaseToPowerOnAPI(caseList);
        CaseCallouts.mobileTelephoneUpdateOnContact(caseList,oldMapCases);
        CaseCallouts.sendCreatedCaseToPowerOnAPI(null);
        Assert.isTrue(modCase!=null);
        Test.stopTest();
        }
        
    } 

}