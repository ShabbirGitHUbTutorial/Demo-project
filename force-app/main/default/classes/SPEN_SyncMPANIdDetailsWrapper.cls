//wrapper class for SPEN_SyncMPANIdDetails
public with sharing class SPEN_SyncMPANIdDetailsWrapper {
    
    public List<RequestBody> reqBody;

	public class RequestBody {
		public List<SDIFEndDevicePowerDownEvent> sdifEndDevicePowerDownEvent;	
	}
    
    public class SDIFEndDevicePowerDownEvent {
		//public String crtdDateTime;
		public String createdDateTime;
		public String mRID;
		public String category;
		public String severity;
		public String reason;
        
	}
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public static void test(){
        //System.debug('testing');
    }
}