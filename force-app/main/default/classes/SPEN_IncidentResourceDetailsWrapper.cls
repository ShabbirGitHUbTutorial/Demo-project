public with sharing class SPEN_IncidentResourceDetailsWrapper {
   
    public List<RequestBody> reqBody;

    public class RequestBody{
        public List<SDIFIncidentLabourLogCreated>  SDIFIncidentLabourLogCreated;
    }
    public class SDIFIncidentLabourLogCreated{
        public List<IncidentLabourLogCreatedStc> incidentLabourLogCreatedStc;
    }

    public class IncidentLabourLogCreatedStc{
        public String IncidentID;
		public String IncidentReference;
		public Integer LogCategoryID;
        public Integer LogSubCategoryID;
        public String LoggedTime;
        public String Company;
        public String EventDate;
        public String DispatchedDate;
        public String CompletionDate;
        public String ResourceName;
        public String LogComment; 
        public String Operator;
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public static void test(){
        
    }
}