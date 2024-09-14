public with sharing class CaseXmlNodes{
    
    @SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')
	private final static String NAMESPACE = 'SDIF';
	private final static String PREFIX = '';

    public class SoapBodyNode extends XmlNode.XmlRootNode{

        public List<SDIFLogCallReplyNode> sdifLogCallReply = new List<SDIFLogCallReplyNode>();

		protected override void registerXML() 
		{
			registerChildren(sdifLogCallReply, 'SDIFLogCallReply', NAMESPACE, PREFIX);
		}
    }
    
    public class SDIFLogCallReplyNode extends XmlNode {
		public List<LogCallReplyStcNode> logCallReplyStc = new List<LogCallReplyStcNode>();

		protected override void registerXML() 
		{			
			registerChildren(logCallReplyStc, 'LogCallReplyStc', NAMESPACE, PREFIX);
		}
    }
    
    public class LogCallReplyStcNode extends XmlNode { 

		public String callReference;
		public String errorMsg;
		public String eventTime;
        public String status;
        public String correlationID;

		protected override void registerXML() 
		{
			this.callReference = (String) registerTextNode(String.class, 'CallReference', NAMESPACE, PREFIX, callReference);
            this.errorMsg = (String) registerTextNode(String.class, 'ErrorMsg', NAMESPACE, PREFIX, errorMsg);
            this.eventTime = (String) registerTextNode(String.class, 'EventTime', NAMESPACE, PREFIX, eventTime);
            this.status = (String) registerTextNode(String.class, 'Status', NAMESPACE, PREFIX, status);
            this.correlationID = (String) registerTextNode(String.class, 'CorrelationID', NAMESPACE, PREFIX, correlationID);
		}
    }
}