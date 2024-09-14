@isTest
public class SPEN_IncidentResourceDetailsWrapperTest {
	@isTest
     private static void incidentResDetailsTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_IncidentResourceDetailsWrapper incRes = new SPEN_IncidentResourceDetailsWrapper();		
            SPEN_IncidentResourceDetailsWrapper.test();
            Assert.areEqual(true, user.IsActive, 'user is active');
            Test.stopTest();
       }
    }
}