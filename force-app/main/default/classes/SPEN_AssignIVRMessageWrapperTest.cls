@isTest
public class SPEN_AssignIVRMessageWrapperTest {
    public static testMethod void testMethod1(){
         
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_AssignIVRMessageWrapper objWrapper = new SPEN_AssignIVRMessageWrapper();		
            SPEN_AssignIVRMessageWrapper.test();
            Assert.isTrue(objWrapper.reqBody==null);
            Test.stopTest();
        }     
    }
}