@isTest
public class PowerOnToCaseWrapperTest {
    
    @isTest 
    private static void powerOnToCaseTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            PowerOnToCaseWrapper objWrapper = new PowerOnToCaseWrapper();		
            PowerOnToCaseWrapper.test();
            Assert.isTrue(objWrapper.sdifLogCallReply==null);
            Test.stopTest();
       }
    }

}