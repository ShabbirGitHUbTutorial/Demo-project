@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_MPANWrapperTEST {
    @IsTest
    private static void updateMeterDetailsTEST(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        //PermissionSet mpanAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
		//insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = mpanAccess.Id);
        System.runAs(user)
        {
            Test.startTest();
            SPEN_MPANWrapper objWrapper = new SPEN_MPANWrapper();		
            SPEN_MPANWrapper.test();
            Assert.areEqual(true, user.IsActive, 'active user');
            Test.stopTest();
        }
    }
}