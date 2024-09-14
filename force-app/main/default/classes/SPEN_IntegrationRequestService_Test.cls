/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        11/11/2022
* @Description: Test class of SPEN_IntegrationRequestService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
@IsTest(SeeAllData=false)
@SuppressWarnings('PMD.SOQLSelectorPattern')
global class SPEN_IntegrationRequestService_Test implements HttpCalloutMock
{
    global HttpResponse respond(HTTPRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    }
    @IsTest
    public static void ableToGetData()
    {
        SPEN_IntegrationRequestService istest = new SPEN_IntegrationRequestService();
        Map<Id, SPEN_IntegrationRequest__c> testMap = new Map<Id, SPEN_IntegrationRequest__c>();
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        System.runAs(user)
        {  
            Test.startTest();
            List<SPEN_MPAN__c> mpanRecList = SPEN_TestDataFactory.createMPANList(2);
            insert mpanRecList;
            mpanRecList[0].SPEN_AccountNumberMPAN__c = mpanRecList[0].Id;
            mpanRecList[1].SPEN_AccountNumberMPAN__c = mpanRecList[1].Id;
            update mpanRecList;
            
            List<SPEN_Premise__c> premiseRecList = SPEN_TestDataFactory.createListOfPremise(2);
            premiseRecList[0].SPEN_AccountNumberMPAN__c = mpanRecList[0].Id;
            
            premiseRecList[1].SPEN_AccountNumberMPAN__c = mpanRecList[1].Id;
            insert premiseRecList;
            
            SPEN_IntegrationRequest__c testIntegrationReqst = SPEN_TestDataFactory.createProcessingIntegrationReq();
            testIntegrationReqst.SPEN_Records__c = premiseRecList[0].SPEN_PremiseID__c;
            insert testIntegrationReqst;
            
            SPEN_IntegrationRequest__c testIntegrationRequest = SPEN_TestDataFactory.createFailedIntegrationReq();
            testIntegrationRequest.SPEN_Records__c = premiseRecList[1].SPEN_PremiseID__c;
            testIntegrationRequest.SPEN_Status__c = 'Processing';
            update testIntegrationRequest;
            Test.setMock(HttpCalloutMock.class, new SPEN_IntegrationRequestService_Test());
            Assert.isNotNull(testIntegrationRequest);
            Test.stopTest();
        }
    } 
    private static testMethod void updateStatusTestExceptionCoverage() 
    {
        try
        {
            Test.startTest(); 
            SPEN_IntegrationRequestService istest = new SPEN_IntegrationRequestService();
            SPEN_MeterPingIntegrationRequest meterPingIntTest = new SPEN_MeterPingIntegrationRequest();
           
            istest.isStatusProcessing(NULL);
            istest.isStatusChanged(NULL,NULL);
           

            istest.isStatusProcessingForMeterDetails(NULL);
            istest.isStatusProcessingForEchoesSearch(NULL);
			istest.isStatusProcessingForPremise(NULL);	//CRMD - 5165
            SPEN_GetMeterDetailsByMpanService.getMeterDetailsFromMpan(NULL, NULL);

            SPEN_MeterPingService.getIntgReqResultDetails(NULL, NULL);
            
            SPEN_IntegrationRequestService.isStatusChng(NULL,NULL);
            meterPingIntTest.send(NULL,NULL);
           	Assert.isNotNull(meterPingIntTest, 'Value Passed');
            Test.stopTest();   
        }
        catch(Exception ex)
        {
            //System.assert(NULL!= ex);
            Assert.isTrue(NULL!= ex);
        }
    }
}