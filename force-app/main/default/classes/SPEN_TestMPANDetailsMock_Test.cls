@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
global class SPEN_TestMPANDetailsMock_Test implements HttpCalloutMock
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
            res.setBody(body);
            res.setStatusCode(code);
            return res;
        }
    }
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        return res;
    }
    
    @IsTest 
    public static void testPostCallout() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user)
        {
        	SPEN_MPAN__c mpan = SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert mpan;
            Id recordId = mpan.Id;
            Test.startTest();
            Integer code = 200;
            String json = '{"Errors": [],"ParameterSet":{"Parameters":[]},"UtilityMatches": [{"UtilityDetails": [],"Meters":[{"MeterDetails":[{"Key":"distributor_mpid","Value":"1800017037796"}]}]}]}';
            Test.setMock(HttpCalloutMock.class, new RestMock(code,json));
            SPEN_TestMPANDetailsMock testmock = new SPEN_TestMPANDetailsMock();
            testmock.send(recordId);
            SEL_IntegrationsOutboundMessageBase outBase;
            Assert.isNotNull(mpan);
            Test.stopTest();
        }
    }
    @IsTest 
    public static void testMockException()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user)
        {
            SPEN_MPAN__c mpan = SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert mpan;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_TestMPANDetailsMock testmock = new SPEN_TestMPANDetailsMock();
            testmock.mockException();
            Assert.isNotNull(mpan);
            Test.stopTest();
        }
    }
}