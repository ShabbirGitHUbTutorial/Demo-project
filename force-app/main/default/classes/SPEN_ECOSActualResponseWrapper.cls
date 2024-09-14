public with sharing class SPEN_ECOSActualResponseWrapper
{
    public Header header;
    public List<Results> results;
    
    public class Header {
        public String RequestDate;
        public String RequestId;
        public String ResponseTime;
        public String VersionNumber;        
    }    
    
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
    
    public class Results {
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
}