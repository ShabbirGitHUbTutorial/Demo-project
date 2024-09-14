@IsTest
public class SPEN_CallbackServiceWrapperTest {
    
    @isTest 
    private static void callbackServiceResponseTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_CallbackServiceWrapper objWrapper = new SPEN_CallbackServiceWrapper();		
            SPEN_CallbackServiceWrapper.test();
            Assert.isTrue(objWrapper.SDIFReceiveEndDevicePingStatus==null);
            Test.stopTest();
       }
    }

}