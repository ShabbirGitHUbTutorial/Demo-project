public with sharing class SPEN_IncidentOutageChangedXMLNodes {

    @SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')

    private final static String NAMESPACE = 'SDIF';
    
	private final static String PREFIX = '';
    
    public class SoapBodyNode extends XmlNode.XmlRootNode{
	
		public List<SDIFIncidentOutageChangedNode> sDIFIncidentOutageChanged = new List<SDIFIncidentOutageChangedNode>();
				
		protected override void registerXML() 
		{	
			registerChildren(sDIFIncidentOutageChanged, SPEN_ImpactedPremisesConstants.SPENINCIDENTOUTAGECHANGED, NAMESPACE, PREFIX);
		}
	}

    public class SDIFIncidentOutageChangedNode extends XmlNode {
		public List<IncidentOutageChangedStcNode> incidentOutageChangedStc = new List<IncidentOutageChangedStcNode>();
		protected override void registerXML() 
		{
            registerChildren(incidentOutageChangedStc, SPEN_ImpactedPremisesConstants.SPENINCIDENTOUTAGECHANGEDSTC, NAMESPACE, PREFIX);
		}
	}

    public class IncidentOutageChangedStcNode extends XmlNode {
	
		public String incidentID;
		public String incidentReference;
		
	
		protected override void registerXML() 
		{
            this.incidentID = (String) registerTextNode(String.class, SPEN_ImpactedPremisesConstants.INCIDENTID, NAMESPACE, PREFIX, IncidentID);
			this.incidentReference = (String) registerTextNode(String.class, SPEN_ImpactedPremisesConstants.INCIDENTREFERENCE, NAMESPACE, PREFIX, IncidentReference);
            
		}    
	}
}