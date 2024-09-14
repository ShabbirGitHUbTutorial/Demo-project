@isTest(seeAllData = false)
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class CaseAsyncCalloutResponseTest 
{
   @testSetup static void setup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {
            SPEN_ConfigurableSettings__c config = new SPEN_ConfigurableSettings__c();
            config.Name = 'Incident broadcast message updated last one hour';
            config.SPEN_Value__c = '1';
            config.SPEN_Description__c = 'the broadcast message of the Incident object is updated in the last hour';
            insert config;
            
            SPEN_ConfigurableSettings__c config1 = new SPEN_ConfigurableSettings__c();
            config1.Name = 'Other Cases';
            config1.SPEN_Value__c = 'As soon as possible';
            //config.SPEN_Description__c = 'the broadcast message of the Incident object is updated in the last hour';
            insert config1;
            
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
            testCase[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            insert testCase;
        }
    }
    @isTest
    public static void testMethod1()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        Test.startTest();
        System.runAs(user)
        {
            Case caseObj = [Select id,caseNumber,SPEN_PowerOnCallReference__c,RecordType.DeveloperName,CreatedById FROM Case where id!=null Limit 1];
            String reqStr='<soap:Body><SDIFLogCallReply xmlns="SDIF"><LogCallReplyStc><CallReference>'+caseObj.SPEN_PowerOnCallReference__c+'</CallReference><errorMsg></errorMsg><eventTime></eventTime><Status></Status><CorrelationID>'+caseObj.caseNumber+'</CorrelationID></LogCallReplyStc></SDIFLogCallReply></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/SDIFLogCallReply/*'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass ());
            SPEN_IntegrationRequest__c intReq = new SPEN_IntegrationRequest__c();
            intReq.SPEN_Status__c = 'Failed';
            intReq.SPEN_RequestedBy__c = caseObj.CreatedById;
            intReq.SPEN_IntegrationRequestServiceClass__c = 'SDIFLogCallReply';
            intReq.SPEN_RelatedRecord__c = caseObj.Id;
            intReq.SPEN_Response__c = reqStr;
            intReq.SPEN_ErrorMessage__c = 'log a call failed';
            insert intReq;
            CaseAsyncCalloutResponse.updateCase();
            Test.stopTest();
            Assert.areEqual(req.httpMethod, 'POST');
        }
    }
    @isTest
    public static void testMethod2()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        Test.startTest();
        System.runAs(user)
        {
            Case caseObj = [Select id,caseNumber,SPEN_PowerOnCallReference__c,RecordType.DeveloperName,CreatedById FROM Case where id!=null Limit 1];
            String reqStr='<soap:Body><SDIFLogCallReply xmlns="SDIF"><LogCallReplyStc><CallReference></CallReference><errorMsg></errorMsg><eventTime></eventTime><Status></Status><CorrelationID>'+caseObj.caseNumber+'</CorrelationID></LogCallReplyStc></SDIFLogCallReply></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/SDIFLogCallReply/*'; 
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass ());
            SPEN_IntegrationRequest__c intReq = new SPEN_IntegrationRequest__c();
            intReq.SPEN_Status__c = 'Failed';
            intReq.SPEN_RequestedBy__c = caseObj.CreatedById;
            intReq.SPEN_IntegrationRequestServiceClass__c = 'SDIFLogCallReply';
            intReq.SPEN_RelatedRecord__c = caseObj.Id;
            intReq.SPEN_Response__c = reqStr;
            intReq.SPEN_ErrorMessage__c = 'log a call failed';
            insert intReq;
            CaseAsyncCalloutResponse.updateCase();
            Set<Id> caseList = new Set<Id> ();
            caseList.add(caseObj.Id);
            Id jobId= System.enqueueJob(new SPEN_CaseCalloutQueueable(caseList));
            Assert.isTrue(caseList!=null);
            Test.stopTest();
        }
    }
}