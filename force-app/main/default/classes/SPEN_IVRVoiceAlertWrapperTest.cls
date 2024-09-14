@IsTest
public class SPEN_IVRVoiceAlertWrapperTest {
	@isTest 
    private static void updateZoneRecordsTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_IVRVoiceAlertWrapper.Attributes objAtt = new SPEN_IVRVoiceAlertWrapper.Attributes();
            objAtt.PhoneNumber = '8789434587';
            objAtt.IVRMessage = 'hello';
            String json = JSON.serialize(objAtt);
            SPEN_IVRVoiceAlertWrapper objWrapper = SPEN_IVRVoiceAlertWrapper.parse(json);
            Assert.isTrue(objWrapper!=null);
            Test.stopTest();
        }
    }
}