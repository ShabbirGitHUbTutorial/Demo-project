/**
 * @description       : This is the test class for SPEN_UpdateZoneDataController class.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 12-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SPEN_UpdateZoneDataControllerTest {

    @isTest 
    private static void updateZoneRecordsTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UpdateZoneDataServiceTest());
            Boolean isSuccess = SPEN_UpdateZoneDataController.updateZoneRecords();
            Assert.isNotNull(isSuccess,'Assertion Passed');
            Test.stopTest();
        }
    }
    
}