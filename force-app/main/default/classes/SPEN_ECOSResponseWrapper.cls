public with sharing class SPEN_ECOSResponseWrapper{
    
  public List<RequestBody> reqBody;
    
    public class ParameterSet {
    public List<Parameters> Parameters;
  }

	public class Errors {
    public String Code;
    public String Description;
  }
    
    public class Parameters {
    public String Key;
    public String Value;
  }

  	public class RequestBody {
        public List<Errors> Errors;
  		public ParameterSet ParameterSet;
    	public List<UtilityAddressMatches> UtilityAddressMatches;  
  	}

	public class UtilityAddressMatches {
		public List<Parameters> AddressDetails;
		public String UtilityType;
	}
  public static void test(){
      //System.debug('testing');
      Boolean insidetest=true;
  }  
    /*public class AddressDetails {
		public List<Parameters> postcode;
        public List<Parameters> dcc_service_flag;
        public List<Parameters> dcc_service_flag_efd;
	}*/

}