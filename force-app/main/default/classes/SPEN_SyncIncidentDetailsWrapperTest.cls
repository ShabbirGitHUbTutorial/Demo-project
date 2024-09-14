@isTest
public class SPEN_SyncIncidentDetailsWrapperTest {
    
    @isTest 
    private static void syncIncidentDetailsTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_SyncIncidentDetailsWrapper objWrapper = new SPEN_SyncIncidentDetailsWrapper();		
            SPEN_SyncIncidentDetailsWrapper.test();
            Assert.areEqual(true, user.IsActive, 'user is active');
            Test.stopTest();
       }
    }
}