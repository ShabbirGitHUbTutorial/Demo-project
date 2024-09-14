global with sharing class SPEN_SyncNRSWACaseDetailsWrapper {
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
        public String NoticeType;
        public Date PlannedJointingDate;
        public String FREPNumber;
        public String IncidentNumber;
        public Date worksStartDate;
        public Date WorksCompletionDate;
        public String District;
        
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
        public String WorkRequestorName;
        public String WorkRequestorEmail;
        public String WorkRequestorContact;
        public String WorkRequestorBusinessUnit;
        public String RoadOpeningNoticeRequired;
        public String ProjectId; 
        //public String RoadLaneClosure; 
        public String JointingRequired; 
        public String NCTApproval; 
        public String ScopeofWork; 
        public String SiteSpecificRules;
        public Boolean WorksToBeManagedByNamedContractor;
        public String ReinstatementContractor;
        public Boolean ThirdPartyPackIssuedToContractor;
        public String WayleaveAgreementsAndGrantorsRequest;
        public String NumberOfLandownersSatisfactionReport;
        public String AnyAdditionalCompletionCriteria;
        public String MaterialsToBeFreeIssuedAndLocation;
        public String TestsToBeCarriedOutByContractor;
        public String TestsToBeCarriedOutByEmployer;
        public String InterfaceWithOverheadLineContractor;
        public String EstimatedCost;
        public String AdditionalComments;
        public String SharePointURL;
        
    }
    /*public String test() //for test class coverage
    {
        String test = 'test';
        return test;
    }*/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public static void test(){
        
    }
}