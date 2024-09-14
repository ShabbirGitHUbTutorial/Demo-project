/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  Unit test class for Last Gasp Mock API apex class SPEN_GetAffectedPremiseService.
AUTHOR    :  Sumit Biswas
MODIFIED BY: Rohit Chowdhury
LIBRARY    :  Salesforce Enterprise Library 
VERSION    :  1.0

HISTORY    :
Date      		Author      	Comment
JAN-03-2023    Sumit Biswas     Initial version
-----------------------------------------------------------------------------------------*/
@IsTest(seeAllData=False)
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_GetAffectedPremiseServiceTEST implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
    	HttpResponse res = new HttpResponse();
    	res.setStatus('OK');
    	res.setStatusCode(200);
        res.setBody('{"animal":{"id":1,"name":"chicken","eats":"chicken food","says":"cluck cluck"}}');
    	return res;
  	}
    @IsTest
    private static void createRecordTEST(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet premiseAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = premiseAccess.Id);
        PermissionSet intAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = intAccess.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);
        System.runAs(user)
        {
            Integer chunkSize =5;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_GetAffectedPremiseServiceTEST());
            SPEN_ConfigurableSettings__c cSetting= SPEN_TestDataFactory.createConfigSetting(1,'GetAffectedPremiseINCType');
            cSetting.SPEN_Value__c='LV';
            insert cSetting;
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            List<String> lstintRequest=new List<String>();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_PSR__c=true;
            insert con;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
        	testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
        	insert testCase;
            List<String> incList=new List<String>();
        	Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='LV';
        	insert inc;
            incList.add(inc.Id);
            Incident inc1 = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc1.SPEN_IncidentType__c='LV';
            inc1.SPEN_IncidentID__c=incList[0];
        	insert inc1;
            
            List<SPEN_IntegrationRequest__c> intRequest = SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            //intRequest[0].SPEN_Records__c ='343435r4';
            intRequest[0].SPEN_RelatedRecord__c =incList[0];
            intRequest[0].SPEN_Records__c =incList[0];
            insert intRequest;
            intRequest[0].SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetAffectedPremiseService' ;
            update intRequest;
            lstintRequest.add(intRequest[0].SPEN_Records__c);
            //SPEN_GetAffectedPremiseService.createRecord(lstintRequest);
            SPEN_GetAffectedPremiseService.createRecord(incList);
            //Assert.isNotNull(intRequest[0].Id);
            Assert.isNotNull(incList);
            Test.stopTest();
        }
    }

}