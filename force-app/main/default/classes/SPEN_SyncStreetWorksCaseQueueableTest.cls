/***************************************************************************
* @Author:      Shubhi
* @Date:        30/08/2023
* @UserStory:   CRMD-7688
* @Description: Test class for SPEN_SyncStreetWorksCaseQueueable
*****************************************************************************/
@isTest
@suppresswarnings('PMD.SOQLSelectorPattern,PMD.CodeBestPracticesAvoidEmptyQueries')
public with sharing class SPEN_SyncStreetWorksCaseQueueableTest {
    
    private static SPEN_SyncStreetworksCaseDetailsWrapper setupTestData()
    {
        SPEN_SyncStreetworksCaseDetailsWrapper wrapper = new SPEN_SyncStreetworksCaseDetailsWrapper();
        
        SPEN_SyncStreetworksCaseDetailsWrapper.CaseInput caseWrapper = new SPEN_SyncStreetworksCaseDetailsWrapper.CaseInput();
        caseWrapper.CommencementDate = Date.today();
        caseWrapper.completionDate = Date.today();
        caseWrapper.WorkLocation = 'England';
        casewrapper.ExcavationRequired = 'Yes';
        casewrapper.NoticeType = 'Emergency';
        casewrapper.District = 'North Wales';
        casewrapper.Sensitivity = 'T/S';
        casewrapper.EarliestStartDate = Date.Today();
        casewrapper.ProposedStartDate = Date.Today();
        casewrapper.ProposedWorksCompletionDate = Date.Today();
        casewrapper.EarlyStartDate = Date.Today();
        casewrapper.PlannedJointingDate = Date.Today();
        wrapper.Cases = caseWrapper;
        
        SPEN_SyncStreetworksCaseDetailsWrapper.CaseInformationInput  caseInfoWrapper = new SPEN_SyncStreetworksCaseDetailsWrapper.CaseInformationInput();
        caseInfoWrapper.Contractor = 'Aggreko UK Limited';
        caseInfoWrapper.OtherContractorName ='';
        caseInfoWrapper.NoticeRequestorName = 'John Smith';
        caseInfoWrapper.NoticeRequestorEmail = 'test1gmail.com';
        caseInfoWrapper.NoticeRequestorContact = '"+447404885091';
        caseInfoWrapper.NoticeRequestorBusinessUnit = 'Transmission';
        caseInfoWrapper.SameAsNoticeRequestor = false;
        caseInfoWrapper.WorkRequestorName = 'Test Name';
        caseInfoWrapper.WorkRequestorEmail = 'test1@gmail.com';
        caseInfoWrapper.WorkRequestorContact = '+447404885092';
        caseInfoWrapper.WorkRequestorBusinessUnit = 'Transmission';
        caseInfoWrapper.RoadOpeningNoticeRequired = 'Yes';
        caseInfoWrapper.ProjectId = '1235465'; 
        caseInfoWrapper.StateDurationReqd = 1; 
        caseInfoWrapper.RoadLaneClosure = 'No'; 
        caseInfoWrapper.EarlyStartRequired = 'No'; 
        caseInfoWrapper.EarlyStartReason = 'Test Reason'; 
        caseInfoWrapper.CollaborationRequired = 'Yes'; 
        caseInfoWrapper.JointingRequired = 'Yes'; 
        caseInfoWrapper.CustomerImpact = 'None'; 
        caseInfoWrapper.NCTApproval = 'Yes'; 
        caseInfoWrapper.ScopeofWork = 'Test Scope'; 
        caseInfoWrapper.SiteSpecificRisks = 'Test Risk'; 
        wrapper.caseInfo = caseInfoWrapper;
        
        List<SPEN_SyncStreetworksCaseDetailsWrapper.SiteDetailsInput> siteDetailsList = new List<SPEN_SyncStreetworksCaseDetailsWrapper.SiteDetailsInput>();
        SPEN_SyncStreetworksCaseDetailsWrapper.SiteDetailsInput sitewrapper = new SPEN_SyncStreetworksCaseDetailsWrapper.SiteDetailsInput();
        sitewrapper.LocationofWorks = '23 Merseyside AB1 1AB';
        sitewrapper.Coordinates = '0001234,0007890';
        sitewrapper.Surfacetype = 'Footpath';
        sitewrapper.TrafficManagement = 'Contraflow';
        sitewrapper.TrafficLights = '2-Way';
        sitewrapper.ApplicationDate = Date.today();
        siteDetailsList.add(sitewrapper);
        wrapper.siteDetails = siteDetailsList;
        return wrapper;
    }
    private static SPEN_SyncNRSWACaseDetailsWrapper setupNRSWAData(){
        SPEN_SyncNRSWACaseDetailsWrapper wrapper = new SPEN_SyncNRSWACaseDetailsWrapper();
        SPEN_SyncNRSWACaseDetailsWrapper.CaseInput caseWrapper = new SPEN_SyncNRSWACaseDetailsWrapper.CaseInput();
        casewrapper.Contractor = 'Aggreko UK Limited';
        casewrapper.WorkRequestorName = 'Test Name';
        casewrapper.ProjectId = '1235465'; 
        caseWrapper.CommencementDate = Date.today();
        caseWrapper.completionDate = Date.today();
        caseWrapper.WorkLocation = 'England';
        casewrapper.NoticeType = 'Emergency';
        casewrapper.District = 'North Wales';
        casewrapper.PlannedJointingDate = Date.Today();
        casewrapper.FREPNumber = '1235465'; 
        casewrapper.IncidentNumber = '1235465'; 
        casewrapper.worksStartDate = Date.Today();
        casewrapper.WorksCompletionDate = Date.Today();
       
        wrapper.Cases = caseWrapper;
        
        SPEN_SyncNRSWACaseDetailsWrapper.CaseInformationInput  caseInfoWrapper = new SPEN_SyncNRSWACaseDetailsWrapper.CaseInformationInput();
        caseInfoWrapper.Contractor = 'Aggreko UK Limited';
        casewrapper.WorkRequestorName = 'Test Name';
        caseInfoWrapper.WorkRequestorEmail = 'test@gmail.com';
        caseInfoWrapper.WorkRequestorContact = '+447404885092';
        caseInfoWrapper.WorkRequestorBusinessUnit = 'Transmission';
        caseInfoWrapper.RoadOpeningNoticeRequired = 'Yes';
        caseInfoWrapper.ProjectId = '1235465'; 
        caseInfoWrapper.JointingRequired = 'Yes'; 
        caseInfoWrapper.NCTApproval = 'Yes'; 
        caseInfoWrapper.ScopeofWork = 'Test Scope'; 
        caseInfoWrapper.SiteSpecificRules = 'Test Rule';
        caseInfoWrapper.WorksToBeManagedByNamedContractor = false;
        caseInfoWrapper.ReinstatementContractor = 'Test Reinstatement';
        caseInfoWrapper.ThirdPartyPackIssuedToContractor = false;
        caseInfoWrapper.WayleaveAgreementsAndGrantorsRequest = 'Test';
        caseInfoWrapper.NumberOfLandownersSatisfactionReport = 'Test';
        caseInfoWrapper.AnyAdditionalCompletionCriteria = 'Test';
        caseInfoWrapper.MaterialsToBeFreeIssuedAndLocation = 'Test';
        caseInfoWrapper.TestsToBeCarriedOutByContractor = 'Test';
        caseInfoWrapper.TestsToBeCarriedOutByEmployer = 'Test';
        caseInfoWrapper.InterfaceWithOverheadLineContractor = 'Test';
        caseInfoWrapper.EstimatedCost = 'Test';
        caseInfoWrapper.AdditionalComments = 'Test';
        wrapper.caseInfo = caseInfoWrapper;
        
        List<SPEN_SyncNRSWACaseDetailsWrapper.SiteDetailsInput> siteDetailsList = new List<SPEN_SyncNRSWACaseDetailsWrapper.SiteDetailsInput>();
        SPEN_SyncNRSWACaseDetailsWrapper.SiteDetailsInput sitewrapper = new SPEN_SyncNRSWACaseDetailsWrapper.SiteDetailsInput();
        sitewrapper.LocationofWorks = '23 Merseyside AB1 1AB';
        sitewrapper.Coordinates = '0001234,0007890';
        sitewrapper.Surfacetype = 'Footpath';
        sitewrapper.TrafficManagement = 'Contraflow';
        sitewrapper.TrafficLights = '2-Way';
        sitewrapper.ApplicationDate = Date.today();
        siteDetailsList.add(sitewrapper);
        wrapper.siteDetails = siteDetailsList;
        return wrapper; 
    }
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_AccountCRU');//[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_AccountCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user){
            test.startTest();
            List<SPEN_Employee__c> empList=SPEN_TestDataFactory.createEmployeeRecords(3);
            insert empList;
            List<Account> accountList = SPEN_TestDataFactory.createSpenAccount();
            accountList[0].SPEN_Streetworks_Contractor__c=true;
            accountList[0].name='Aggreko UK Limited';
            update accountList;
            Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
            Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
            Id recordTypeIdCaseInfo = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SWWebform').getRecordTypeId();
            Id recordTypeIdCaseInfoNRSWA = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_NSRWA_Webform').getRecordTypeId();
            List<case> cases=SPEN_TestDataFactory.createCaseRecords(1,recordTypeIdSW);
            insert cases;
            List<SPEN_CaseInformation__c> ciList=new List<SPEN_CaseInformation__c>();
            SPEN_CaseInformation__c caseinfo=SPEN_TestDataFactory.createCaseInformationRecords(cases[0].id,recordTypeIdCaseInfo);
            ciList.add(caseinfo);
            SPEN_CaseInformation__c caseinfoNRSWA=SPEN_TestDataFactory.createCaseInformationRecords(cases[0].id,recordTypeIdCaseInfoNRSWA);
            insert ciList;
            test.stopTest();
    	}        
    }    
    
    @isTest
    public static void testcreateStreetWorkQueueableOnSuccess(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){
            SPEN_SyncStreetworksCaseDetailsWrapper wrapper = setupTestData();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/StreetWorksCase/*';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
            RestContext.request = req;
            RestResponse resp = new RestResponse();
            resp.responseBody=Blob.valueOf('{"success":true,"casenumber":"00036645"}');
            RestContext.response = resp;
            test.startTest();
            SPEN_SyncStreetworksCaseDetails.createStreetWorkCaseFromWebform();
            test.stopTest();
            List<SPEN_CaseEmployee__c> csEmpList1=[SELECT id from SPEN_CaseEmployee__c where spen_case__c!=null];
            Assert.isNotNull(csEmpList1);
            List<SPEN_ResponsibleParty__c> responsiblePartyList=[SELECT id from SPEN_ResponsibleParty__c where spen_case__c!=null];
            Assert.isNotNull(responsiblePartyList);
        }

    }
    
    @isTest
    public static void testcreateCaseEmployee(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){
            Test.starttest();
            Id recordTypeIdCaseInfo = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SWWebform').getRecordTypeId();
            SPEN_CaseInformation__c caseinfo=[Select id,SPEN_Case__c,SPEN_Contractor__c,SPEN_WorkRequestorEmail__c,SPEN_NoticeRequestorEmail__c from SPEN_CaseInformation__c where recordTypeId=:recordTypeIdCaseInfo limit 1];
            caseinfo.SPEN_WorkRequestorEmail__c='';
            caseinfo.SPEN_NoticeRequestorEmail__c='';
            update caseinfo;
            //negative
            SPEN_SyncStreetWorksCaseQueueable swq=new SPEN_SyncStreetWorksCaseQueueable(caseinfo);
            swq.createCaseEmployee(caseinfo);
            List<SPEN_CaseEmployee__c> csEmpList1=[SELECT id from SPEN_CaseEmployee__c where spen_case__c!=null];
            Assert.isNotNull(csEmpList1);
            //positive
            caseinfo.SPEN_WorkRequestorEmail__c='test1@test.com';
            caseinfo.SPEN_NoticeRequestorEmail__c='test1@test.com';
            update caseinfo;
            swq.createCaseEmployee(caseinfo);
            List<SPEN_CaseEmployee__c> csEmpList11=new List<SPEN_CaseEmployee__c>();
            csEmpList11=[SELECT id from SPEN_CaseEmployee__c where spen_case__c!=null];
            Assert.isNotNull(csEmpList11);
            //posititive with diff email
            caseinfo.SPEN_WorkRequestorEmail__c='test1@test.com';
            caseinfo.SPEN_NoticeRequestorEmail__c='test2@test.com';
            update caseinfo;
            System.enqueueJob(new SPEN_SyncStreetWorksCaseQueueable(caseInfo));
            Test.stopTest();
        }
    }
    @isTest
    public static void createResponsibleParty(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){
            Id recordTypeIdCaseInfo = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SWWebform').getRecordTypeId();
            //negative
            SPEN_CaseInformation__c caseinfo=[Select id,recordTypeId,SPEN_Case__c,SPEN_Contractor__c,SPEN_WorkRequestorEmail__c,SPEN_NoticeRequestorEmail__c from SPEN_CaseInformation__c where recordTypeId=:recordTypeIdCaseInfo limit 1];
            caseinfo.SPEN_Contractor__c='';
            update caseinfo;
            SPEN_SyncStreetWorksCaseQueueable swq=new SPEN_SyncStreetWorksCaseQueueable(caseinfo);
            //swq.createResponsibleParty(caseinfo);
            System.enqueueJob(new SPEN_SyncStreetWorksCaseQueueable(caseInfo));
			List<SPEN_ResponsibleParty__c> responsiblePartyList=[SELECT id from SPEN_ResponsibleParty__c where spen_case__c!=null];
            Assert.isNotNull(responsiblePartyList);
            caseinfo.SPEN_Contractor__c='Aggreko UK Limited';
            update caseinfo;
            System.enqueueJob(new SPEN_SyncStreetWorksCaseQueueable(caseInfo));
            //positive

        }
        
    }
    @isTest
    public static void testcreateNRSWAQueueableOnSuccess(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){
            SPEN_SyncNRSWACaseDetailsWrapper wrapper = setupNRSWAData();
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/NRSWACase/*';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
            RestContext.request = req;
            RestResponse resp = new RestResponse();
            resp.responseBody=Blob.valueOf('{"success":true,"casenumber":"00036645"}');
            RestContext.response = resp;
            test.startTest();
            SPEN_SyncNRSWACaseDetails.createNRSWACaseFromWebform();
            test.stopTest();            
            List<SPEN_CaseEmployee__c> csEmpList1=[SELECT id from SPEN_CaseEmployee__c where spen_case__c!=null];
            Assert.isNotNull(csEmpList1);
            List<SPEN_ResponsibleParty__c> responsiblePartyList=[SELECT id from SPEN_ResponsibleParty__c where spen_case__c!=null];
            Assert.isNotNull(responsiblePartyList);
        }

    }
}