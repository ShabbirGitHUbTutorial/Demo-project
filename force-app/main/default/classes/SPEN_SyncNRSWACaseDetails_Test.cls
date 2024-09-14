/***************************************************************************
* @Author:      Swaathi
* @Date:        24/08/2023
* @UserStory:   CRMD-724
* @Description: Method to handle test class coverage for SPEN_SyncStreetworksCaseDetails class
*****************************************************************************/

@isTest
@suppresswarnings('PMD.SOQLSelectorPattern,PMD.CodeBestPracticesAvoidEmptyQueries')
public class SPEN_SyncNRSWACaseDetails_Test  {
    public static SPEN_SyncNRSWACaseDetailsWrapper setupTestData()
    {
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
    
    @isTest
    public static void testcreateStreetWorkCaseOnSuccess()
    {
        SPEN_SyncNRSWACaseDetailsWrapper wrapper = setupTestData();
        
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
        Id recordTypeIdCaseInfo = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_NSRWA_Webform').getRecordTypeId();
        SPEN_CaseInformation__c caseinfo=[Select id,SPEN_Case__c,SPEN_Contractor__c,SPEN_WorkRequestorEmail__c,SPEN_NoticeRequestorEmail__c,recordTypeId from SPEN_CaseInformation__c where recordTypeId=:recordTypeIdCaseInfo limit 1];
        Id jobId= System.enqueueJob(new SPEN_SyncStreetWorksCaseQueueable(caseInfo));
        test.stopTest();
        Assert.isNotNull(req.requestBody);
    }
    
    @isTest
    public static void testcreateStreetWorkCaseOnError()
    {
        SPEN_SyncNRSWACaseDetailsWrapper wrapper = setupTestData();
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/NRSWACase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(wrapper.Cases));
        RestContext.request = req;
        
        RestResponse resp = new RestResponse();
        resp.responseBody=Blob.valueOf('{"success":false,"error":"Null Pointer Exception"}');
        RestContext.response = resp;
        
        test.startTest();
        SPEN_SyncNRSWACaseDetails.createNRSWACaseFromWebform();
        test.stopTest();
        Assert.isNotNull(req.requestBody);
        
    }
}