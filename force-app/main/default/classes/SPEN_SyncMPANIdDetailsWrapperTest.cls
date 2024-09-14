@isTest 
public class SPEN_SyncMPANIdDetailsWrapperTest {
    
    @isTest 
    private static void syncMPANIdDetailsTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_SyncMPANIdDetailsWrapper objWrapper = new SPEN_SyncMPANIdDetailsWrapper();		
            SPEN_SyncMPANIdDetailsWrapper.test();
            Assert.areEqual(true, user.IsActive, 'Active user');
            Test.stopTest();
       }
    }
}