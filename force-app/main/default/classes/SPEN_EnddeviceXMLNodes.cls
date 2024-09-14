public class SPEN_EnddeviceXMLNodes {
    
    @SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')
    //private final static String NAMESPACE = 'ENMAC/TCS';
    //private final static String NAMESPACE = 'http://ssi.energy.ge.com/smartgrid/datamodel/EndDeviceOperation/enddevicestatuscallbackservice';
    private final static String NAMESPACE = 'http://ge.com/dsp/bf/service/commonfault';
    private final static String PREFIX = '';
    
    public class SoapBodyNode extends XmlNode.XmlRootNode{
        public List<SDIFReceiveEndDevicePingStatusNode> SDIFReceiveEndDevicePingStatus = new List<SDIFReceiveEndDevicePingStatusNode>();
        
        protected override void registerXML() 
        {
            //system.debug('ReceiveEndDevicePingStatus' +SDIFReceiveEndDevicePingStatus);
            registerChildren(SDIFReceiveEndDevicePingStatus, 'SDIFReceiveEndDevicePingStatus', NAMESPACE, PREFIX);
        }
        
    }
    
   /* public class SoapEnvelopeNode extends XmlNode.XmlRootNode {
        public List<SoapHeaderNode> header = new List<SoapHeaderNode>();
        public List<SoapBodyNode> body = new List<SoapBodyNode>();
        protected override void registerXML() 	
        {
            registerChildren(header,'Header', NAMESPACE, PREFIX);
            registerChildren(body, 'Body', NAMESPACE, PREFIX);
        }
    }
    public class SoapHeaderNode extends XmlNode {
        
        public String headerTime;
        public String id;
        public Integer age;
        public Integer txnSource;
        public String entityId;
        public String endPoint;
        public Integer sequence;
        public String transport;
        public String funtion;
        
        protected override void registerXML() 
        {
            this.age = (Integer) registerTextNode(Integer.class, 'Age', NAMESPACE, PREFIX, age);
            this.headerTime = (String) registerTextNode(String.class, 'Time', NAMESPACE, PREFIX, headerTime);
            this.id = (String) registerTextNode(String.class, 'Id', NAMESPACE, PREFIX, id);
            this.txnSource = (Integer) registerTextNode(Integer.class, 'TxnSource', NAMESPACE, PREFIX, txnSource);
            this.entityId = (String) registerTextNode(String.class, 'EntityID', NAMESPACE, PREFIX, entityId);
            this.endPoint = (String) registerTextNode(String.class, 'Endpoint', NAMESPACE, PREFIX, endPoint);
            this.sequence = (Integer) registerTextNode(Integer.class, 'Sequence', NAMESPACE, PREFIX, sequence);
            this.transport = (String) registerTextNode(String.class, 'Transport', NAMESPACE, PREFIX, transport);
            this.funtion = (String) registerTextNode(String.class, 'Funtion', NAMESPACE, PREFIX, funtion);
        }  
    }*/
    
    public class SDIFReceiveEndDevicePingStatusNode extends XmlNode{
        
        public list<StatusReadingNode> StatusReading = new list<StatusReadingNode>();
        public list<EndDeviceStatusCallbackContextNode> EndDeviceStatusCallbackContext = new list<EndDeviceStatusCallbackContextNode>();
        
        protected override void registerXML() 
        {
            registerChildren(StatusReading, 'StatusReading', NAMESPACE, PREFIX);	
            registerChildren(EndDeviceStatusCallbackContext, 'EndDeviceStatusCallbackContext', NAMESPACE, PREFIX);
        }
    }
    
    public class EndDeviceStatusCallbackContextNode extends XmlNode {        
        public String correlationID;
        
        
        protected override void registerXML() 
        {			            
            this.correlationID = (String) registerTextNode(String.class, 'correlationID', NAMESPACE, PREFIX, correlationID);
        }
    }
    public class StatusReadingNode extends XmlNode {        
        public String status;
        public list<EndDeviceAssetNode> EndDeviceAsset = new list<EndDeviceAssetNode>();
        
        
        protected override void registerXML() 
        {			            
            this.status = (String) registerTextNode(String.class, 'status', NAMESPACE, PREFIX, status);
            registerChildren(EndDeviceAsset, 'EndDeviceAsset', NAMESPACE, PREFIX);	
        }
    }
    
    public class EndDeviceAssetNode extends XmlNode{
        public string mRID;
        protected override void registerXML() {
            this.mRID = (String) registerTextNode(String.class, 'mRID', NAMESPACE, PREFIX, mRID);
        }
    }
    
}