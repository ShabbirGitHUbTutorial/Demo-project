@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_GetAffectedPremiseResponse_Test 
{
    @testSetup static void setup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps8 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps8.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_OutboundContactHoursCRU']; //Riccha Mohanty-24-01-2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];//Riccha Mohanty-24-01-2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessR'];//Riccha Mohanty-24-01-2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps12.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);
        System.runAs(user)
        {
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            List<SPEN_Premise__c> premiselist=SPEN_TestDataFactory.createPremiseRecord('Premise','OX123',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiselist;
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_Role__c='Customer';
            insert conpremise;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='SP';
            inc.SPEN_IncidentID__c = '12345';
            insert inc;
            SPEN_IntegrationRequest__c inteReqRecord = SPEN_TestDataFactory.createProcessingIntegrationReq();
            inteReqRecord.SPEN_Records__c = inc.SPEN_IncidentID__c;
            inteReqRecord.SPEN_RelatedRecord__c = inc.SPEN_IncidentID__c;
            inteReqRecord.SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetAffectedPremiseService';
            insert inteReqRecord;
            
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'Incident broadcast message updated last one hour');
            insert cs;
            SPEN_ConfigurableSettings__c cs1 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'MessagingTaskType');
            insert cs1;
        }
    }
    @IsTest
    public static void testPatchPremise() 
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            SPEN_Premise__c premiseList = [SELECT id FROM SPEN_Premise__c where id!=null LIMIT 1]; 
            Incident inc = [select id from Incident where id!=null];            
            Map<String,String> strBody = new Map<String,String>();
            SPEN_AffectedPremisesResponseWrapper.premiseEnergisationState premise1 = new SPEN_AffectedPremisesResponseWrapper.premiseEnergisationState();
            premise1.pn='123';
            premise1.es='premiseState';
            List<SPEN_AffectedPremisesResponseWrapper.premiseEnergisationState> prList = new List<SPEN_AffectedPremisesResponseWrapper.premiseEnergisationState>();
            prList.add(premise1);
            
            SPEN_AffectedPremisesResponseWrapper.RequestBody affectedPremises = new SPEN_AffectedPremisesResponseWrapper.RequestBody();
            affectedPremises.incidentId = '12345';
            affectedPremises.estimateRestorationDate = String.valueOf(system.now());
            affectedPremises.premiseEnergisationState = prList;
            affectedPremises.APIName = 'APIName';
            affectedPremises.chunkCount='1';
            affectedPremises.currentChunk = '1';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/GetAffectedPremise/'+premiseList.Id;  //Request URL
            req.requestBody= Blob.valueOf(JSON.serialize(affectedPremises));
            req.httpMethod = 'PATCH';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_GetAffectedPremiseResponseDetails.affectedPremiseDetails();
            Assert.isTrue(premiseList!=null);
            Test.stopTest();
        }
    }
}