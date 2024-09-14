/***************************************************************************
* @Author:      Swaathi
* @Date:        22/08/2023
* @UserStory:   CRMD-724
* @Description: Class to create Streetworks case based on the details coming from webform
*****************************************************************************/

@RestResource(urlMapping='/StreetWorksCase/*')
global with sharing class SPEN_SyncStreetworksCaseDetails {
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
    global static void createStreetWorkCaseFromWebform() {
        RestRequest restRqst = RestContext.request;
        RestResponse restResp = RestContext.response;
        Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
        Id recordTypeIdCaseInfo = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SWWebform').getRecordTypeId();
        Id recordTypeIdSiteDetails = Schema.SObjectType.SPEN_SiteDetails__c.getRecordTypeInfosByDeveloperName().get('Streetworks').getRecordTypeId();
        try{
            SPEN_SyncStreetworksCaseDetailsWrapper responseWrapper = new SPEN_SyncStreetworksCaseDetailsWrapper();
            SPEN_SyncStreetworksCaseDetailsWrapper wrapper= (SPEN_SyncStreetworksCaseDetailsWrapper)JSON.deserialize(restRqst.requestBody.toString(), 
                                                                                                                     SPEN_SyncStreetworksCaseDetailsWrapper.requestBody.class);
            Case swCase = new Case();
            swCase.SPEN_ProjectCommencementDate__c = wrapper.Cases.CommencementDate;
            swCase.SPEN_ProjectCompletionDate__c = wrapper.Cases.completionDate;
            swCase.SPEN_WorkLocation__c = wrapper.Cases.WorkLocation;
            swCase.SPEN_ExcavationRequired__c = wrapper.Cases.ExcavationRequired;
            swCase.SPEN_NoticeType__c = wrapper.Cases.NoticeType;
            swCase.SPEN_EarliestStartDate__c = wrapper.Cases.EarliestStartDate;
            swCase.SPEN_ProposedStartDate__c = wrapper.Cases.ProposedStartDate;
            swCase.SPEN_ProposedWorksCompletionDate__c = wrapper.Cases.ProposedWorksCompletionDate;
            swCase.SPEN_EarlyStartDate__c = wrapper.Cases.EarlyStartDate;
            swCase.PlannedJointingDate__c = wrapper.Cases.PlannedJointingDate;
            swCase.SPEN_ConnectionDistrict__c = wrapper.Cases.District;
            swCase.Origin = CasesConstants.originWEB; //CRMD-9451 by Sumit
            
            swCase.SPEN_Sensitivity__c = wrapper.Cases.Sensitivity;
            swCase.RecordTypeId = recordTypeIdSW;
            swCase.Status = SPEN_ConstantData.SWCaseStatus;
            swCase.SPEN_Contractor__c = wrapper.Cases.Contractor;
            swCase.SPEN_WorkRequestorName__c = wrapper.Cases.WorkRequestorName;
            swCase.SPEN_ProjectId__c = wrapper.Cases.ProjectId;
            insert swCase;
            
            SPEN_CaseInformation__c caseinfo = new SPEN_CaseInformation__c();
            caseinfo.SPEN_Contractor__c = wrapper.caseInfo.Contractor;
            caseinfo.SPEN_OtherContractorName__c = wrapper.caseInfo.OtherContractorName;
            caseinfo.SPEN_Case__c = swCase.Id;
            caseinfo.SPEN_NoticeRequestorName__c = wrapper.caseInfo.NoticeRequestorName;
            caseinfo.SPEN_NoticeRequestorEmail__c = wrapper.caseInfo.NoticeRequestorEmail;
            caseinfo.SPEN_NoticeRequestorContact__c = wrapper.caseInfo.NoticeRequestorContact;
            caseinfo.SPEN_NoticeRequestorBusinessUnit__c = wrapper.caseInfo.NoticeRequestorBusinessUnit;
            caseinfo.SPEN_SameAsNoticeRequestor__c = wrapper.caseinfo.SameAsNoticeRequestor;
            caseinfo.RecordTypeId = recordTypeIdCaseInfo;
            caseinfo.SPEN_WorkRequestorName__c = wrapper.caseInfo.WorkRequestorName;
            caseinfo.SPEN_WorkRequestorEmail__c = wrapper.caseInfo.WorkRequestorEmail;
            caseinfo.SPEN_WorkRequestorContact__c = wrapper.caseInfo.WorkRequestorContact;
            caseinfo.SPEN_WorkRequestorBusinessUnit__c = wrapper.caseInfo.WorkRequestorBusinessUnit;
            caseinfo.SPEN_RoadOpeningNoticeRequired__c = wrapper.caseInfo.RoadOpeningNoticeRequired;
            caseinfo.SPEN_ProjectId__c = wrapper.caseInfo.ProjectId;
            caseinfo.SPEN_StateDurationReqd__c = wrapper.caseInfo.StateDurationReqd;
            caseinfo.SPEN_RoadLaneClosure__c = wrapper.caseInfo.RoadLaneClosure;
            caseinfo.SPEN_EarlyStartRequired__c = wrapper.caseInfo.EarlyStartRequired;
            caseinfo.SPEN_EarlyStartReason__c = wrapper.caseInfo.EarlyStartReason;
            caseinfo.SPEN_CollaborationRequired__c = wrapper.caseInfo.CollaborationRequired;
            caseinfo.SPEN_JointingRequired__c = wrapper.caseInfo.JointingRequired;
            caseinfo.SPEN_SharepointURL__c = wrapper.caseInfo.SharePointURL;
            if(wrapper.caseInfo.CustomerImpact == 'None')
            {
                caseinfo.SPEN_CustomerImpact__c = '';
            }
            else 
            {
                caseinfo.SPEN_CustomerImpact__c = wrapper.caseInfo.CustomerImpact;
            }
            caseinfo.SPEN_NCTApproval__c = wrapper.caseInfo.NCTApproval;
            caseinfo.SPEN_ScopeofWork__c = wrapper.caseInfo.ScopeofWork;
            caseinfo.SPEN_SiteSpecificRisks__c = wrapper.caseInfo.SiteSpecificRisks;
            insert caseinfo;
            if(caseinfo.id!=null){
                //added by shubhi for CRMD:7688
                Id jobId= System.enqueueJob(new SPEN_SyncStreetWorksCaseQueueable(caseInfo));
            }
            
            SPEN_SiteDetails__c sitedetail = new SPEN_SiteDetails__c();
            List<SPEN_SiteDetails__c> siteList = new List<SPEN_SiteDetails__c>();
            for(SPEN_SyncStreetworksCaseDetailsWrapper.SiteDetailsInput stdetail : wrapper.siteDetails)
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
                
                //Case cs =  [SELECT id,ownerId from Case where Id=:swCase.Id ];
                
                SPEN_IntegrationRequest__c integrationRequestRecordCreation = new SPEN_IntegrationRequest__c();
                integrationRequestRecordCreation.SPEN_Status__c = SPEN_ConstantData.Completed;
                integrationRequestRecordCreation.SPEN_IntegrationRequestServiceClass__c = SPEN_ConstantData.SWIntegrationRequestServiceClass;
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
            integrationRequestRecordCreation.SPEN_IntegrationRequestServiceClass__c = SPEN_ConstantData.SWIntegrationRequestServiceClass;
            integrationRequestRecordCreation.SPEN_Request__c = restRqst.requestBody.toString();
            integrationRequestRecordCreation.SPEN_Response__c = restResp.responseBody.toString();
            insert integrationRequestRecordCreation;
        }
      
    }	
    
}