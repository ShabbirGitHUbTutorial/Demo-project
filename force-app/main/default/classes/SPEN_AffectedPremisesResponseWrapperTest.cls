@isTest
public class SPEN_AffectedPremisesResponseWrapperTest {
    
    public static testMethod void TestMethod1(){
         
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_AffectedPremisesResponseWrapper objWrapper = new SPEN_AffectedPremisesResponseWrapper();		
            SPEN_AffectedPremisesResponseWrapper.test();
            Assert.isTrue(objWrapper.reqBody==null);
            Test.stopTest();
        }     
    }

}