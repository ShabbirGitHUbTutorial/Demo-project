@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
global class SPEN_IVRToECOSIntegrationReqResTEST implements HttpCalloutMock
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
            res.setBody('{"Header":{"RequestDate":"20230203 08:06:26.AM","RequestId":17267658,"ResponseTime":"343.8054","VersionNumber":"1.0.0.0;Instance=UIT"},"Results":[{"Errors":[],"ParameterSet":{"Parameters":[{"Key":"MPAN","Value":"1800051691439"}]},"UtilityMatches":[{"UtilityDetails":[{"Key":"mpan_core","Value":"1800051691439"},{"Key":"dcc_service_flag","Value":"N"},{"Key":"supplier_mpid","Value":"BGAS"}],"UtilityKey":"1800051691439","UtilityType":"electricity","Meters":[{"MeterDetails":[{"Key":"mpancore","Value":"1800051691439"},{"Key":"meter_type","Value":"S"}]}]}]}]}');
            Assert.areEqual('POST', req.getMethod());
        }
        res.setStatusCode(200);
        return res;
    }
	
    @isTest 
    private static void testMeterForActive()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps12.Id);
        
        System.runAs(user)
        {
            SPEN_MPAN__c sMpanRec = SPEN_TestDataFactory.createMPANRecords(1);
            sMpanRec.SPEN_LastEchoesSyncDate__c = system.today();
            sMpanRec.SPEN_AccountNumberMPAN__c = '1800051691439';
            sMpanRec.SPEN_DCCServiceFlag__c = 'A';
            Insert sMpanRec;
            
            List<SPEN_IntegrationRequest__c> intreq=SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            intreq[0].SPEN_Result__c='Pass';
            intreq[0].SPEN_IntegrationRequestServiceClass__c = 'SPEN_MeterPingService';
            insert intreq;
            
            Test.startTest();
            Integer code = 200;
            String fullJson ='{"Header":{"RequestDate":"20230203 08:06:26.AM","RequestId":17267658,"ResponseTime":"343.8054","VersionNumber":"1.0.0.0;Instance=UIT"},"Results":[{"Errors":[],"ParameterSet":{"Parameters":[{"Key":"MPAN","Value":"1800051691439"}]},"UtilityMatches":[{"UtilityDetails":[{"Key":"mpan_core","Value":"1800051691439"},{"Key":"dcc_service_flag","Value":"A"},{"Key":"supplier_mpid","Value":"BGAS"}],"UtilityKey":"1800051691439","UtilityType":"electricity","Meters":[{"MeterDetails":[{"Key":"mpancore","Value":"1800051691439"},{"Key":"meter_type","Value":"S"}]}]}]}]}';
            Test.setMock(HttpCalloutMock.class, new ReqResMock(code,fullJson));
            SPEN_IVRToECOSIntegrationReqRes ivrToEcoesIntegrationRequest = new SPEN_IVRToECOSIntegrationReqRes();
            ivrToEcoesIntegrationRequest.send(intreq[0].Id,sMpanRec.SPEN_AccountNumberMPAN__c);
            Assert.isNotNull(sMpanRec);
            Test.stopTest();
        }
    }
}