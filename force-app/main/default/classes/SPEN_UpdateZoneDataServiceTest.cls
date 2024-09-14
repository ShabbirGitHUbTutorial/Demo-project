/**
 * @description       : This is the test class for SPEN_UpdateZoneDataService class.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 12-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
@SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials') 
public class SPEN_UpdateZoneDataServiceTest implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();       
        if(req.getEndpoint().contains('https://spdeveloper.scottishpower.com/token?grant_type=client_credentials'))
        {
        	 res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        	 res.setBody('{"access_token":"f967619c-8284-3e81-9fae-0ff9abcde3d9","scope":"am_application_scope default","token_type":"Bearer","expires_in":3600}');
             Assert.areEqual('POST', req.getMethod());
        }
        if(req.getEndpoint().contains('https://spdeveloper.scottishpower.com/SDIF-CRMREF/0.0.1/SDIFGetOperatingZoneLis'))
        {
        	 res.setHeader('Content-Type', 'application/json');
        	 res.setBody('{"APIName" : "SDIFGetTownZoneList","operatingZoneList": [{"ozId":"OZ00","ozName":"UNKNOWN","ozParentId":"ZW01","ozType":"Operating"},{"ozId":"OZ01","ozName":"LANARK NORTH","ozParentId":"ZW11","ozType":"Operating"}]}');  
             Assert.areEqual('GET', req.getMethod());
        }
        // Create a fake response
        res.setStatusCode(200);
        return res;
    }
    
    @isTest 
    private static void getZoneDataTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        {
            Test.startTest();
            SPEN_UpdateZoneDataService objSPENUpdateZoneDataService = new SPEN_UpdateZoneDataService();
            objSPENUpdateZoneDataService.send();
            SPEN_UpdateZoneDataService.getZoneData();
            Assert.areEqual(user.profileId,profileId);
            Test.stopTest();
        }
    }
    
    @isTest 
    private static void getZoneTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UpdateZoneDataServiceTest());
            SPEN_UpdateZoneDataService.getZoneData();
            Assert.areEqual(user.profileId,profileId);
            Test.stopTest();
        }
    }
}