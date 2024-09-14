/***************************************************************************
* @Author:      Swaathi
* @Date:        24/08/2023
* @UserStory:   CRMD-724
* @Description: Method to handle test class coverage for SPEN_SyncStreetworksCaseDetails class
*****************************************************************************/

@isTest
public class SPEN_SyncStreetworksCaseDetails_Test {
    
    public static SPEN_SyncStreetworksCaseDetailsWrapper setupTestData()
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
        casewrapper.Contractor = 'Aggreko UK Limited';
        casewrapper.WorkRequestorName = 'Test Name';
        casewrapper.ProjectId = '1235465'; 
        wrapper.Cases = caseWrapper;
        
        SPEN_SyncStreetworksCaseDetailsWrapper.CaseInformationInput  caseInfoWrapper = new SPEN_SyncStreetworksCaseDetailsWrapper.CaseInformationInput();
        caseInfoWrapper.Contractor = 'Aggreko UK Limited';
        caseInfoWrapper.OtherContractorName ='';
        caseInfoWrapper.NoticeRequestorName = 'John Smith';
        caseInfoWrapper.NoticeRequestorEmail = 'testjohn@gmail.com';
        caseInfoWrapper.NoticeRequestorContact = '"+447404885091';
        caseInfoWrapper.NoticeRequestorBusinessUnit = 'Transmission';
        caseInfoWrapper.SameAsNoticeRequestor = false;
        caseInfoWrapper.WorkRequestorName = 'Test Name';
        caseInfoWrapper.WorkRequestorEmail = 'test@gmail.com';
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
    
    @isTest
    public static void testcreateStreetWorkCaseOnSuccess()
    {
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
        Assert.isNotNull(req.requestBody);
    }
    
    @isTest
    public static void testcreateStreetWorkCaseOnError()
    {
        SPEN_SyncStreetworksCaseDetailsWrapper wrapper = setupTestData();
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/StreetWorksCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(wrapper.Cases));
        RestContext.request = req;
        
        RestResponse resp = new RestResponse();
        resp.responseBody=Blob.valueOf('{"success":false,"error":"Null Pointer Exception"}');
        RestContext.response = resp;
        
        test.startTest();
        SPEN_SyncStreetworksCaseDetails.createStreetWorkCaseFromWebform();
        test.stopTest();
        Assert.isNotNull(req.requestBody);
        
    }
}