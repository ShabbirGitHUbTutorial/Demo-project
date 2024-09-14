public with sharing class SPEN_IncidentResourceDetailsXMLNodes {

    @SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')

    private final static String NAMESPACE = 'SDIF';
    //private final static String NAMESPACE = 'ENMAC/TCS';
    //private final static String NAMESPACE = '';

	private final static String PREFIX = '';
    
    public class SoapBodyNode extends XmlNode.XmlRootNode{
	
		public List<SDIFIncidentLabourLogCreatedNode> SDIFIncidentLabourLogCreated = new List<SDIFIncidentLabourLogCreatedNode>();
		//public List<IncidentLabourLogCreatedStcNode> incidentLabourLogCreatedStc = new List<IncidentLabourLogCreatedStcNode>();
				
		protected override void registerXML() 
		{	
			System.debug('IN SoapBodyNode');
			registerChildren(SDIFIncidentLabourLogCreated, 'SDIFIncidentLabourLogCreated', NAMESPACE, PREFIX);
			//registerChildren(incidentLabourLogCreatedStc, 'incidentLabourLogCreatedStc', NAMESPACE, PREFIX);
		}
	}

    public class SDIFIncidentLabourLogCreatedNode extends XmlNode {
		public List<IncidentLabourLogCreatedStcNode> incidentLabourLogCreatedStc = new List<IncidentLabourLogCreatedStcNode>();
		protected override void registerXML() 
		{
            System.debug('IN SDIFIncidentLabourLogCreatedNode');
			registerChildren(incidentLabourLogCreatedStc, 'IncidentLabourLogCreatedStc', NAMESPACE, PREFIX);
		}
	}

    public class IncidentLabourLogCreatedStcNode extends XmlNode {
	
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
	
		protected override void registerXML() 
		{
            System.debug('IN IncidentLabourLogCreatedStcNode');
			this.IncidentID = (String) registerTextNode(String.class, 'IncidentID', NAMESPACE, PREFIX, IncidentID);
			this.IncidentReference = (String) registerTextNode(String.class, 'IncidentReference', NAMESPACE, PREFIX, IncidentReference);
            this.LogCategoryID = (Integer) registerTextNode(Integer.class, 'LogCategoryID', NAMESPACE, PREFIX, LogCategoryID);
            this.LogSubCategoryID = (Integer) registerTextNode(Integer.class, 'LogSubCategoryID', NAMESPACE, PREFIX, LogSubCategoryID);
            this.LoggedTime = (String) registerTextNode(String.class, 'LoggedTime', NAMESPACE, PREFIX, LoggedTime);
            this.Company = (String) registerTextNode(String.class, 'Company', NAMESPACE, PREFIX, Company);
            this.EventDate = (String) registerTextNode(String.class, 'EventDate', NAMESPACE, PREFIX, EventDate);
            this.DispatchedDate = (String) registerTextNode(String.class, 'DispatchedDate', NAMESPACE, PREFIX, DispatchedDate);
            this.CompletionDate = (String) registerTextNode(String.class, 'CompletionDate', NAMESPACE, PREFIX, CompletionDate);
            this.ResourceName = (String) registerTextNode(String.class, 'ResourceName', NAMESPACE, PREFIX, ResourceName);
            this.LogComment = (String) registerTextNode(String.class, 'LogComment', NAMESPACE, PREFIX, LogComment);
            this.Operator = (String) registerTextNode(String.class, 'Operator', NAMESPACE, PREFIX, Operator);
		}    
	}
}