/***************************************************************************
* @Author:      Swaathi
* @Date:        07/09/2023
* @UserStory:   CRMD-707
* @Description: Class to create NRSWA case based on the details coming from webform
*****************************************************************************/

@RestResource(urlMapping='/NRSWACase/*')
global with sharing class SPEN_SyncNRSWACaseDetails{
    global with sharing class SuccessResponseWrapper
    {
        public Boolean success;
        public String casenumber;
        public SuccessResponseWrapper(Boolean success,Case cases)
        {
            this.success = success;
            Case cs = [SELECT Id,casenumber from Case where ID=:cases.Id];
            this.casenumber = cs.CaseNumber;
        }
    }
    global with sharing class ErrorResponseWrapper
    { 
        public Boolean success;
        public String error;
        public ErrorResponseWrapper(Boolean success,String error)
        {
            this.success = success;
            this.error = error;
            
        }
    }
    @HttpPost
    global static void createNRSWACaseFromWebform() {
        RestRequest restRqst = RestContext.request;
        RestResponse restResp = RestContext.response;
        Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
        Id recordTypeIdCaseInfo = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_NSRWA_Webform').getRecordTypeId();
        Id recordTypeIdSiteDetails = Schema.SObjectType.SPEN_SiteDetails__c.getRecordTypeInfosByDeveloperName().get('NRSWA').getRecordTypeId();
        String recordTypeNameNRSWA = 'SPEN_NRSWA';
        try{
            SPEN_SyncNRSWACaseDetailsWrapper responseWrapper = new SPEN_SyncNRSWACaseDetailsWrapper();
            SPEN_SyncNRSWACaseDetailsWrapper wrapper= (SPEN_SyncNRSWACaseDetailsWrapper)JSON.deserialize(restRqst.requestBody.toString(), 
                                                                                                                     SPEN_SyncNRSWACaseDetailsWrapper.requestBody.class);
            String incidentReference;
            if(wrapper.Cases.IncidentNumber.contains('INCD-'))
            {
                incidentReference = wrapper.Cases.IncidentNumber;
            }
            else
            {
                incidentReference = 'INCD-'+ wrapper.Cases.IncidentNumber;
            }
            Case swCase = new Case();
            swCase.SPEN_NRSWAExternalID__c = recordTypeNameNRSWA+'-'+incidentReference;
            swCase.SPEN_ProjectCommencementDate__c = wrapper.Cases.CommencementDate;
            swCase.SPEN_ProjectCompletionDate__c = wrapper.Cases.completionDate;
            swCase.SPEN_Contractor__c = wrapper.Cases.Contractor;
            swCase.SPEN_WorkLocation__c = wrapper.Cases.WorkLocation;
            swCase.SPEN_NoticeType__c = wrapper.Cases.NoticeType;
            swCase.PlannedJointingDate__c = wrapper.Cases.PlannedJointingDate;
            swCase.RecordTypeId = recordTypeIdNRSWA;
            swCase.Status = SPEN_ConstantData.NRSWACaseStatus;
            swCase.SPEN_Contractor__c = wrapper.Cases.Contractor;
            swCase.SPEN_WorkRequestorName__c = wrapper.Cases.WorkRequestorName;
            swCase.SPEN_ProjectId__c = wrapper.Cases.ProjectId;
            swCase.SPEN_FREPNo__c = wrapper.Cases.FREPNumber;
            swCase.Origin = CasesConstants.originWEB; //CRMD-9451 by Sumit
            if(SPEN_CaseSelector.getIncidentFromIncidentReference(incidentReference) != NULL)
            {
                swCase.SPEN_Incident__c = SPEN_CaseSelector.getIncidentFromIncidentReference(incidentReference).Id;
            }
            swCase.SPEN_Works_Start_Date__c = wrapper.Cases.worksStartDate;
            swCase.SPEN_Works_Completion_Date__c = wrapper.Cases.WorksCompletionDate;
            swCase.SPEN_ConnectionDistrict__c = wrapper.Cases.District;
            insert swCase;
            
            SPEN_CaseInformation__c caseinfo = new SPEN_CaseInformation__c();
            caseinfo.SPEN_Contractor__c = wrapper.caseInfo.Contractor;
            caseinfo.SPEN_Case__c = swCase.Id;
            caseinfo.RecordTypeId = recordTypeIdCaseInfo;  
            caseinfo.SPEN_WorkRequestorName__c = wrapper.caseInfo.WorkRequestorName;
            caseinfo.SPEN_WorkRequestorEmail__c = wrapper.caseInfo.WorkRequestorEmail;
            caseinfo.SPEN_WorkRequestorContact__c = wrapper.caseInfo.WorkRequestorContact;
            caseinfo.SPEN_WorkRequestorBusinessUnit__c = wrapper.caseInfo.WorkRequestorBusinessUnit;
            caseinfo.SPEN_RoadOpeningNoticeRequired__c = wrapper.caseInfo.RoadOpeningNoticeRequired;
            caseinfo.SPEN_ProjectId__c = wrapper.caseInfo.ProjectId;
            caseinfo.SPEN_JointingRequired__c = wrapper.caseInfo.JointingRequired;
            caseinfo.SPEN_NCTApproval__c = wrapper.caseInfo.NCTApproval;
            caseinfo.SPEN_ScopeofWork__c = wrapper.caseInfo.ScopeofWork;
            caseinfo.SPEN_Site_Specific_Rules__c = wrapper.caseInfo.SiteSpecificRules;
            caseinfo.Works_to_be_managed_by_named_Contractor__c = wrapper.caseInfo.WorksToBeManagedByNamedContractor;
            caseinfo.Reinstatement_Contractor__c = wrapper.caseInfo.ReinstatementContractor;
            caseinfo.SPEN_3rd_Party_Pack_issued_to_Contractor__c = wrapper.caseInfo.ThirdPartyPackIssuedToContractor;
            caseinfo.Wayleave_Agreements_and_Grantors_Request__c = wrapper.caseInfo.WayleaveAgreementsAndGrantorsRequest;
            caseinfo.Number_of_landowners_satisfaction_report__c = wrapper.caseInfo.NumberOfLandownersSatisfactionReport;
            caseinfo.Any_additional_completion_criteria__c = wrapper.caseInfo.AnyAdditionalCompletionCriteria;
            caseinfo.Materials_to_be_free_issued_and_Location__c = wrapper.caseInfo.MaterialsToBeFreeIssuedAndLocation;
            caseinfo.Tests_to_be_carried_out_by_Contractor__c = wrapper.caseInfo.TestsToBeCarriedOutByContractor;
            caseinfo.Tests_to_be_carried_out_by_employer__c = wrapper.caseInfo.TestsToBeCarriedOutByEmployer;
            caseinfo.Interface_with_overhead_line_contractor__c = wrapper.caseInfo.InterfaceWithOverheadLineContractor;
            caseinfo.SPEN_Estimated_Cost__c = wrapper.caseInfo.EstimatedCost;
            caseinfo.SPEN_AdditionalComments__c = wrapper.caseInfo.AdditionalComments;
            caseinfo.SPEN_SharepointURL__c = wrapper.caseInfo.SharePointURL;
            insert caseinfo;
            if(caseinfo.id!=null){
                //added by shubhi for CRMD:7898
                Id jobId= System.enqueueJob(new SPEN_SyncStreetWorksCaseQueueable(caseInfo));
            }
            SPEN_SiteDetails__c sitedetail = new SPEN_SiteDetails__c();
            List<SPEN_SiteDetails__c> siteList = new List<SPEN_SiteDetails__c>();
            for(SPEN_SyncNRSWACaseDetailsWrapper.SiteDetailsInput stdetail : wrapper.siteDetails)
            {
                SPEN_SiteDetails__c sd = new SPEN_SiteDetails__c();
                sd.SPEN_Case__c = swCase.Id;
                sd.SPEN_LocationOfWorks__c = stdetail.LocationofWorks;
                sd.SPEN_Coords__c = stdetail.Coordinates;
                sd.RecordTypeId = recordTypeIdSiteDetails;
                sd.SPEN_SurfaceType__c = stdetail.Surfacetype;
                if(stdetail.TrafficLights == 'None')
                {
                    sd.SPEN_TrafficLights__c = '';
                }
                else
                {
                    sd.SPEN_TrafficLights__c = stdetail.TrafficLights;  
                }
                sd.SPEN_TrafficManagement__c = stdetail.TrafficManagement;
                sd.SPEN_ApplicationDate__c = stdetail.ApplicationDate;
                siteList.add(sd);
            }
            insert siteList;
            if(swCase != NULL)
            {
                restResp.addHeader('Content-Type', 'application/json');
                restResp.responseBody = Blob.valueOf(JSON.serialize(new SuccessResponseWrapper(true,swCase))); 
                
                SPEN_IntegrationRequest__c integrationRequestRecordCreation = new SPEN_IntegrationRequest__c();
                integrationRequestRecordCreation.SPEN_Status__c = SPEN_ConstantData.Completed;
                integrationRequestRecordCreation.SPEN_IntegrationRequestServiceClass__c = SPEN_ConstantData.NRSWAIntegrationRequestServiceClass;
                integrationRequestRecordCreation.SPEN_Records__c = swCase.Id;
                integrationRequestRecordCreation.SPEN_Response__c = restResp.responseBody.toString();
                integrationRequestRecordCreation.SPEN_Request__c = restRqst.requestBody.toString();
                insert integrationRequestRecordCreation;
            }
        }
        catch(Exception e)
        {
            restResp.addHeader('Content-Type', 'application/json');
            restResp.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseWrapper(false,e.getMessage())));
            
            SPEN_IntegrationRequest__c integrationRequestRecordCreation = new SPEN_IntegrationRequest__c();
            integrationRequestRecordCreation.SPEN_Status__c = SPEN_ConstantData.Failed;
            integrationRequestRecordCreation.SPEN_IntegrationRequestServiceClass__c = SPEN_ConstantData.NRSWAIntegrationRequestServiceClass;
            integrationRequestRecordCreation.SPEN_Request__c = restRqst.requestBody.toString();
            integrationRequestRecordCreation.SPEN_Response__c = restResp.responseBody.toString();
            insert integrationRequestRecordCreation;
        }
      
    }	
    
}