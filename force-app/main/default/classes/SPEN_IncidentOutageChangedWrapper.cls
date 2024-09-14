public with sharing class SPEN_IncidentOutageChangedWrapper {
   
    public List<RequestBody> reqBody;

    public class RequestBody{
        public List<SDIFIncidentOutageChanged>  sDIFIncidentOutageChanged;
    }
    public class SDIFIncidentOutageChanged{
        public List<IncidentOutageChangedStc> incidentOutageChangedStc;
    }

    public class IncidentOutageChangedStc{
        public String incidentID;
		public String incidentReference;
		
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public static void test(){
        
    }
}