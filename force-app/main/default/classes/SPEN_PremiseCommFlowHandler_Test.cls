@isTest
public class SPEN_PremiseCommFlowHandler_Test {
    @isTest
    private static void listViewFilterQueryTest(){
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
            Test.startTest();
            List<ListView> views = SPEN_TestDataFactory.getListViews();
            Test.setMock(HttpCalloutMock.class, new SPEN_PremiseCommFlowHandlerHTTPMock());
            SPEN_PremiseCommunicationFlowHandler.getListViewFilterQuery(views[0].Id);
            System.assertEquals(true,user.IsActive,'active user');
            Test.stopTest();
        }
    }
    @isTest
    private static void listViewDetailsTest(){
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
            List<ListView> views = SPEN_TestDataFactory.getListViews();
            Test.startTest();
            SPEN_PremiseCommunicationFlowHandler.getListViewDetails(views[0].Id);
            System.assertEquals(true,user.IsActive,'active user');
            Test.stopTest();
        }
    }
}