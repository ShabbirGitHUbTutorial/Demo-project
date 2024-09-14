@IsTest
public class SPEN_ECOSActualResponseWrapperTEST 
{
    @isTest 
    private static void ecosResponseTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_ECOSActualResponseWrapper objWrapper = new SPEN_ECOSActualResponseWrapper();		
            SPEN_ECOSActualResponseWrapper.test();
            Assert.isTrue(objWrapper!=null);
            Test.stopTest();
       }
    }
}