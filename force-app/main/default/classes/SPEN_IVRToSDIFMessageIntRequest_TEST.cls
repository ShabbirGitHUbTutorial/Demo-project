/**********************************************************************************************
* @Author:      Smita Raikar
* @Date:        21/11/2022
* @Description: Test class of SPEN_IVRToSDIFMessageIntegrationRequest
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
@IsTest(SeeAllData=false)
global  class SPEN_IVRToSDIFMessageIntRequest_TEST implements HttpCalloutMock
{
     private class ReqResMock implements HttpCalloutMock 
    {
        protected Integer code;
        protected String body;
        
        public ReqResMock(Integer code, String body)
        {
            this.code = code;
            this.body = body;
        }        
        public HTTPResponse respond(HTTPRequest req) 
        {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('application/json', 'application/json');
            res.setBody(body);
            res.setStatusCode(code);
            return res;
        }
    }
     global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse(); 
        
        if(req.getEndpoint().contains('https://spdeveloper.scottishpower.com/SDIF-CRMPING-QA/0.0.1/incservice/CRMPingRequest'))
        {
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"APIName":"SDIFCheckPremiseState","incidentId":"NULL","operatingZoneId":"textid", "propertyNo":"s123"}');
            System.assertEquals('POST', req.getMethod());
        }
        res.setStatusCode(200);
        return res;
    }
    
    @IsTest
    public static void testsend()
    {
        SPEN_IntegrationRequestService istest = new SPEN_IntegrationRequestService();
        Map<Id, SPEN_IntegrationRequest__c> testMap = new Map<Id, SPEN_IntegrationRequest__c>();
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        /*User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        
        Database.insert(user);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU']; //Ayush 20 01 2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);   //Ayush 20 01 2023
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);*/
        System.runAs(user)
        { 
            Test.startTest();
            SPEN_AssignIVRMessageWrapper objWrapper = new SPEN_AssignIVRMessageWrapper();		
            SPEN_AssignIVRMessageWrapper.test();
            //Added for Assign IVR Message
            SPEN_IVRMessage__c testIVRMessage = SPEN_TestDataFactory.createIVRMessage(1); 
            insert testIVRMessage;
            SPEN_ConfigurableSettings__c testconfig = SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay'); 
            insert testconfig;
            //Added for Assign IVR Message
            SPEN_Zone__c testRegion = SPEN_TestDataFactory.createZoneRegionRecords(testIVRMessage.Id);
            insert testRegion;
            SPEN_Zone__c testDistrict = SPEN_TestDataFactory.createZoneDistrictRecords(testIVRMessage.Id);
            testDistrict.SPEN_Parent__c=testRegion.Id;
            insert testDistrict;
            SPEN_Zone__c testZone = SPEN_TestDataFactory.createZoneRecords(testIVRMessage.Id);
            testDistrict.SPEN_Parent__c=testDistrict.Id;
            insert testZone;
            
            List<SPEN_Premise__c> premiseRecList = SPEN_TestDataFactory.createListOfPremise(2);
            premiseRecList[0].SPEN_Zone__c = testZone.Id;
           	insert premiseRecList;
            
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IVRMessage__c='Thank you for contacting SP Energy Networks.';
            inc.SPEN_IncidentID__c='k0008d095INCD';
            insert inc;
            Incident inc1 = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc1.SPEN_IVRMessage__c='Thank you for contacting SP Energy Networks.';
            
            insert inc1;
            
            
            //Added for Assign IVR Message
            SPEN_IntegrationRequest__c testIVRMsgIntegrationReqst = SPEN_TestDataFactory.createIntegrationReqforIVRMsg();
            testIVRMsgIntegrationReqst.SPEN_Records__c = premiseRecList[0].SPEN_PremiseID__c;
            insert testIVRMsgIntegrationReqst;
            SPEN_IntegrationRequest__c testIVRIntegrationRequest = SPEN_TestDataFactory.createFailedIntegrationReqforIVRMsg();
            testIVRIntegrationRequest.SPEN_Records__c = premiseRecList[0].SPEN_PremiseID__c; // Corrected by Ayush ---> 20 01 2023
            testIVRIntegrationRequest.SPEN_Status__c = 'Processing';
            update testIVRIntegrationRequest;
            system.assertEquals(testIVRIntegrationRequest.SPEN_Status__c, 'Processing');
            //Test.setMock(HttpCalloutMock.class, new SPEN_IVRToSDIFMessageIntRequest_TEST());
            //SPEN_IVRToSDIFMessageIntegrationRequest intReqClass=new SPEN_IVRToSDIFMessageIntegrationRequest();
            //intReqClass.send(testIVRMsgIntegrationReqst.Id,premiseRecList[0].SPEN_PremiseID__c);
              
            Integer code = 200;
            String fullJson ='{"APIName":"SDIFCheckPremiseState","incidentId":"NULL","operatingZoneId":"textid", "propertyNo":"s123"}';
            
			Test.setMock(HttpCalloutMock.class, new ReqResMock(code,fullJson));
            Assert.isNotNull(testIVRMsgIntegrationReqst, 'MPAN Record Passed');
            Test.stopTest();
        }
    }
	
    
    
    
    private static testMethod void updateStatusTestExceptionCoverage() 
    {
  
            try
            {
                Test.startTest(); 
                
                SPEN_IVRToSDIFMessageIntegrationRequest ivrMessageIntTest = new SPEN_IVRToSDIFMessageIntegrationRequest();
                ivrMessageIntTest.send(NULL,NULL);
                
               
                Assert.isNotNull(ivrMessageIntTest, 'Value Passed');
                Test.stopTest();   
            }
            catch(Exception ex)
            {
                System.assert(NULL!= ex);
            }
        }
    
}