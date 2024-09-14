public with sharing class PowerOnToCaseWrapper {
    
    public List<SDIFLogCallReply> sdifLogCallReply;

	public class LogCallReplyStc {
		public String callReference;
		public String errorMsg;
		public String eventTime;
        public String status;
        public String correlationID;
	}

	public class SDIFLogCallReply {
		public List<LogCallReplyStc> logCallReplyStc;
	}

	public static void test(){
		//System.debug('testing');
		Boolean isTest=true;
	}
}