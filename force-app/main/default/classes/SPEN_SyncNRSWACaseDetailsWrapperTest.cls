@isTest
public class SPEN_SyncNRSWACaseDetailsWrapperTest {
    @isTest
    private static void syncNRSWACaseDetailsWrapperTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_SyncNRSWACaseDetailsWrapper syncCase = new SPEN_SyncNRSWACaseDetailsWrapper();		
            SPEN_SyncNRSWACaseDetailsWrapper.test();
            Assert.areEqual(true, user.IsActive, 'user is active');
            Test.stopTest();
       }
    }
}