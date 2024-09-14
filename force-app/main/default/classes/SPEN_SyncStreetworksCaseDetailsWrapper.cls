/***************************************************************************
* @Author:      Swaathi
* @Date:        22/08/2023
* @UserStory:   CRMD-724
* @Description: Wrapper Class for SPEN_SyncStreetworksCaseDetails
*****************************************************************************/
global with sharing class SPEN_SyncStreetworksCaseDetailsWrapper {
    global CaseInput Cases;
   global List<SiteDetailsInput> siteDetails;
   global CaseInformationInput caseInfo;
    global class CaseInput {
        public String Contractor;
        public String WorkRequestorName;
        public String ProjectId; 
        public Date CommencementDate;
		public Date completionDate;
        public String WorkLocation;
        public String District;
		public String Sensitivity;
        public String ExcavationRequired;
        public String NoticeType;
        public Date EarliestStartDate;
        public Date ProposedStartDate;
        public Date ProposedWorksCompletionDate;
        public Date EarlyStartDate;
        public Date PlannedJointingDate;
    }
   public class SiteDetailsInput {
        public String LocationofWorks;
        public String Coordinates;
        public String Surfacetype;
        public String TrafficManagement;
        public String TrafficLights;
        public Date ApplicationDate;
    }
    global class CaseInformationInput {
        public String Contractor;
        public String OtherContractorName;
        public String NoticeRequestorName;
        public String NoticeRequestorEmail;
        public String NoticeRequestorContact;
        public String NoticeRequestorBusinessUnit;
        public Boolean SameAsNoticeRequestor;
        public String WorkRequestorName;
        public String WorkRequestorEmail;
        public String WorkRequestorContact;
        public String WorkRequestorBusinessUnit;
        public String RoadOpeningNoticeRequired;
        public String ProjectId; 
        public Integer StateDurationReqd; 
        public String RoadLaneClosure; 
        public String EarlyStartRequired; 
        public String EarlyStartReason; 
        public String CollaborationRequired; 
        public String JointingRequired; 
        public String CustomerImpact; 
        public String NCTApproval; 
        public String ScopeofWork; 
        public String SiteSpecificRisks; 
        public String SharePointURL;
    }
    
    public String test() //for test class coverage
    {
        String test = 'test';
        return test;
    }
}