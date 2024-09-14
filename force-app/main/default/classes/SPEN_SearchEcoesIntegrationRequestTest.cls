@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
global class SPEN_SearchEcoesIntegrationRequestTest implements HttpCalloutMock
{
    private class RestMock implements HttpCalloutMock 
    {
        protected Integer code;
        protected String body;
        
        public RestMock(Integer code, String body)
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
        if(req.getEndpoint().contains('https://uit.ecoes.co.uk/WebServices/Service/ECOESApi.svc/RESTful/JSON/SearchUtilityAddress'))
        {
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"Errors": [],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G11 1GG"},]},"UtilityAddressMatches": [{"AddressDetails": [{"Key": "installing_supplier_mpid","Value": "BGAS"}],"UtilityType": null}]}');
            Assert.areEqual('POST', req.getMethod());
        }
        res.setStatusCode(200);
        return res;
    }
    
    @isTest 
    private static void testSearchEcoes()
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
            String records = 'Postcode : G32 9AW | BuildingNumber/BuildingName : 1726 |  FlatNumber : 1/2';
            SPEN_MPAN__c sMpanRec = SPEN_TestDataFactory.createMPANRecords(1);
            sMpanRec.SPEN_LastEchoesSyncDate__c = system.today();
            Insert sMpanRec;
            List<SPEN_Premise__c> spList = SPEN_TestDataFactory.createListOfPremise(1);
            spList[0].SPEN_PostCode__c = 'G32 9AW';
            spList[0].SPEN_BuildingNameNumber__c = '1726';
            spList[0].SPEN_FlatNumber__c = '1/2';
            Insert spList;
            
            List<SPEN_IntegrationRequest__c> intreq=SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            intreq[0].SPEN_Result__c='Pass';
            insert intreq;

            intreq[0].SPEN_Status__c='Processing';
            intreq[0].SPEN_IntegrationRequestServiceClass__c = 'SPEN_SearchEcoesService';
            intreq[0].SPEN_Records__c = records;
            update intreq;

            Test.startTest();
            Integer code = 200;
            String fullJson ='{"Results" : [{"Errors": [],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G32 9AW"},{"Key": "BuildingNumber","Value": "1726"}]},"UtilityAddressMatches": [{"AddressDetails": [{"Key": "mpancore","Value": "676372"},{"Key": "meter_type","Value": "BGAS"},{"Key": "supplier_mpid","Value": "TST"},{"Key": "dcc_service_flag","Value": "A"},{"Key": "metered_indicator","Value": "K"}],"UtilityType": null}]}]}';
            Test.setMock(HttpCalloutMock.class, new RestMock(code,fullJson));
            SPEN_SearchEcoesIntegrationRequest objSPENSearchEcoesIntegrationRequest = new SPEN_SearchEcoesIntegrationRequest();
            objSPENSearchEcoesIntegrationRequest.send(intreq[0].Id,records);
            Assert.isNotNull(spList);
            Test.stopTest();
        }
    }
    
    @isTest 
    private static void testSearchEcoesMultiple()
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
            String records = 'Postcode : G32 9AW | BuildingNumber/BuildingName : 1726 |  FlatNumber : 1/2';
            SPEN_MPAN__c sMpanRec = SPEN_TestDataFactory.createMPANRecords(1);
            sMpanRec.SPEN_LastEchoesSyncDate__c = system.today();
            Insert sMpanRec;
            List<SPEN_Premise__c> spList = SPEN_TestDataFactory.createListOfPremise(1);
            spList[0].SPEN_PostCode__c = 'G32 9AW';
            spList[0].SPEN_BuildingNameNumber__c = '1726';
            spList[0].SPEN_FlatNumber__c = '1/2';
            Insert spList;
            
            List<SPEN_IntegrationRequest__c> intreq = SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            intreq[0].SPEN_Result__c='Pass';
            insert intreq;
            Test.startTest();
            Integer code = 200;
            String fullJson ='{"Results" : [{"Errors": [],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G32 9AW"},{"Key": "BuildingNumber","Value": "1726"}]},"UtilityAddressMatches": [{"AddressDetails": [{"Key": "mpan_core","Value": "676372"},{"Key": "trading_status","Value": "T"}],"UtilityType": null},{"AddressDetails": [{"Key": "mpancore","Value": "6763726"},{"Key": "trading_status","Value": "X"}],"UtilityType": null }]}]}';
            Test.setMock(HttpCalloutMock.class, new RestMock(code,fullJson));
            SPEN_SearchEcoesIntegrationRequest objSPENSearchEcoesIntegrationRequest = new SPEN_SearchEcoesIntegrationRequest();
            objSPENSearchEcoesIntegrationRequest.send(intreq[0].Id,records);
          	Assert.isNotNull(spList);
            Test.stopTest();
        }
    }
    
    @isTest 
    private static void testAddressNotFound()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps12.Id);
        
        System.runAs(user)
        {
            String records = 'Postcode : G32 9AW | BuildingNumber/BuildingName : 1726 |  FlatNumber : 1/2';
            SPEN_MPAN__c sMpanRec = SPEN_TestDataFactory.createMPANRecords(1);
            List<SPEN_IntegrationRequest__c> intreq = SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            intreq[0].SPEN_Result__c='Pass';
            insert intreq;
            Test.startTest();
            Integer code = 200;
            String fullJson ='{"Results" : [{"Errors": [{"Code" : "201","Description" : "Error"}],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G32 9AW"},{"Key": "BuildingNumber","Value": "1726"}]},"UtilityAddressMatches": []}]}';
            Test.setMock(HttpCalloutMock.class, new RestMock(code,fullJson));
            SPEN_SearchEcoesIntegrationRequest objSPENSearchEcoesIntegrationRequest = new SPEN_SearchEcoesIntegrationRequest();
            objSPENSearchEcoesIntegrationRequest.send(intreq[0].Id,records);
            Assert.areEqual(true,user.IsActive,'active user');
            Test.stopTest();
        }
    }
    @Istest
    private static void testMethodForSearchEcoesService()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        System.runAs(user)
        {
            List<SPEN_IntegrationRequest__c> intreq=SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert intreq;
            String address = 'Postcode : G32 9AW | BuildingNumber/BuildingName : 1726 |  FlatNumber : 1/2';
            Test.startTest();
            Integer code = 200;
            String fullJson ='{"Results" : [{"Errors": [{"Code" : "201","Description" : "Error"}],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G32 9AW"},{"Key": "BuildingNumber","Value": "1726"}]},"UtilityAddressMatches": []}]}';
            Test.setMock(HttpCalloutMock.class, new RestMock(code,fullJson));
            SPEN_SearchEcoesService.getResultFromMpan(intreq[0].Id,address);
             Assert.areEqual(true,user.IsActive,'active user');
            Test.stopTest();
        }
    }
}