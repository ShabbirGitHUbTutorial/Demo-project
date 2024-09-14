public class SPEN_EcoesSmartMeterWrapper {
    
    public List<ParameterSets> ParameterSets;
    public Authentication Authentication;
  		
    public class ParameterSets
    {
        public List<Parameters> Parameters;
    }
    
    public class Parameters {
        public String Key;
        public String Value;
    }
    
    public class Authentication 
    {
        public String Key;
    }


    public static SPEN_EcoesSmartMeterWrapper parse(String json) {
        return (SPEN_EcoesSmartMeterWrapper) System.JSON.deserialize(json, SPEN_EcoesSmartMeterWrapper.class);
    }

}