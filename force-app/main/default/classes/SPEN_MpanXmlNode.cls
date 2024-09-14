//xml nodes for SPEN_SyncMPANIdDetails class
public with sharing class SPEN_MpanXmlNode {
    private final static String NAMESPACE = 'http://ge.com/dsp/bf/service/commonfault';
    private final static String PREFIX = '';
    
    public class SoapBodyNode extends XmlNode.XmlRootNode{
        public List<SDIFEndDevicePowerDownEventNode> sdifEndDevicePowerDownEvent = new List<SDIFEndDevicePowerDownEventNode>();
        protected override void registerXML(){
            //System.debug('In SoapBodyNode');
            registerChildren(sdifEndDevicePowerDownEvent, 'sdifEndDevicePowerDownEvent', NAMESPACE, PREFIX);
        }
    }
    
    /*public class SoapHeaderNode extends XmlNode {
        public String headerTime;
		public Id id;
		public Integer age;
		public Integer txnSource;
		public Id entityId;
		public String endPoint;
		public Integer sequence;
		public String transport;
		public String funtion;

        protected override void registerXML() 
		{
			System.debug('IN SoapHeaderNode');
			this.age = (Integer) registerTextNode(Integer.class, 'Age', NAMESPACE, PREFIX, age);
			this.headerTime = (String) registerTextNode(String.class, 'Time', NAMESPACE, PREFIX, headerTime);
			this.id = (Id) registerTextNode(Id.class, 'Id', NAMESPACE, PREFIX, id);
			this.txnSource = (Integer) registerTextNode(Integer.class, 'TxnSource', NAMESPACE, PREFIX, txnSource);
			this.entityId = (Id) registerTextNode(Id.class, 'EntityID', NAMESPACE, PREFIX, entityId);
			this.endPoint = (String) registerTextNode(String.class, 'Endpoint', NAMESPACE, PREFIX, endPoint);
			this.sequence = (Integer) registerTextNode(Integer.class, 'Sequence', NAMESPACE, PREFIX, sequence);
			this.transport = (String) registerTextNode(String.class, 'Transport', NAMESPACE, PREFIX, transport);
			this.funtion = (String) registerTextNode(String.class, 'Funtion', NAMESPACE, PREFIX, funtion);
        }
    }
    
    public class SoapEnvelopeNode extends XmlNode{
        public List<SoapHeaderNode> header = new List<SoapHeaderNode>();
        public List<SoapBodyNode> body = new List<SoapBodyNode>();
        protected override void registerXML(){
            System.debug('In SoapEnvelopeNode');
            registerChildren(header,'Header', NAMESPACE, PREFIX);
			registerChildren(body, 'Body', NAMESPACE, PREFIX);
        }
    }*/
    
    public class SDIFEndDevicePowerDownEventNode extends XmlNode{
        //public String crtdDateTime;
		public String createdDateTime;
		public String mRID;
		public String category;
		public String severity;
		public String reason;
		//public List<Status> statusList;
        //public List<AssetsNode> assets = new List<AssetsNode>();
        
        protected override void registerXML(){			
			//System.debug('In SDIFEndDevicePowerDownEventNode');
            //this.crtdDateTime = (String) registerTextNode(String.class, 'crtdDateTime', NAMESPACE, PREFIX, crtdDateTime);
			this.createdDateTime = (String) registerTextNode(String.class, 'createdDateTime', NAMESPACE, PREFIX, createdDateTime);
			this.mRID = (String) registerTextNode(String.class, 'mRID', NAMESPACE, PREFIX, mRID);
			this.category = (String) registerTextNode(String.class, 'category', NAMESPACE, PREFIX, category);
			this.severity = (String) registerTextNode(String.class, 'severity', NAMESPACE, PREFIX, severity);
			this.reason = (String) registerTextNode(String.class, 'reason', NAMESPACE, PREFIX, reason);
			//registerChildren(statusList, 'Status', NAMESPACE, PREFIX);
		}
    }
    
}