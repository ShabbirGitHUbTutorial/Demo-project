public with sharing class SPEN_CallbackServiceWrapper {

	public List<SDIFReceiveEndDevicePingStatus> SDIFReceiveEndDevicePingStatus;	
 
 public class SDIFReceiveEndDevicePingStatus {
	 public List<StatusReading> StatusReading; 
	 public List<EndDeviceStatusCallbackContext> EndDeviceStatusCallbackContext;	
 }
 
 public class StatusReading {
	 public String status;
	 public List<EndDeviceAsset> EndDeviceAsset; 
	 
 }
 public class EndDeviceAsset {
	 public String mRID; 	
 }
 
 
 public class EndDeviceStatusCallbackContext {
	 public String correlationID;	 
 }
 public static void test(){
       //System.debug('testing');
	   Boolean istest=true;
 }
 
}