@IsTest
public class SPEN_ContactPSRWrapperTest {
    
    @isTest 
    private static void contactPSRResponseTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_ContactPSRWrapper objWrapper = new SPEN_ContactPSRWrapper();		
            SPEN_ContactPSRWrapper.test();
            Assert.areEqual(objWrapper.getcustomerdetailsResponse,null); 
            Test.stopTest();
       }
    }


}