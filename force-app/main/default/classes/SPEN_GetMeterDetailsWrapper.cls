public class SPEN_GetMeterDetailsWrapper 
{
    public Header header;
    public List<Results> results;
    
    public class Header 
    {
        public String RequestDate;
        public String RequestId;
        public String ResponseTime;
        public String VersionNumber;        
    }    
    
    public class ParameterSet 
    {
        public List<Parameters> Parameters;
    }
    
    public class Errors 
    {
        public String Code;
        public String Description;
    }
    
    public class Parameters 
    {
        public String Key;
        public String Value;
    }
    
    public class Results 
    {
        public List<Errors> Errors;
        public ParameterSet ParameterSet;
        public List<UtilityMatches> UtilityMatches;  
    }
    
    public class UtilityMatches 
    {
        public List<Parameters> UtilityDetails;
        public String UtilityKey;
        public String UtilityType;
        public List<Meters> Meters;
    }
    
    public class Meters
    {
        public List<Parameters> MeterDetails;
    }

    public static void test()
    {
        //System.debug('testing');
        Boolean isTest=true;
    }
}