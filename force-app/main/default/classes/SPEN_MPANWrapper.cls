public class SPEN_MPANWrapper {

	public class ParameterSet {
		public List<Parameters> Parameters;
	}

	public class Meters {
		public List<Parameters> MeterDetails;
	}

	public class Errors {
		public String Code;
		public String Description;
	}

	public class Parameters {
		public String Key;
		public String Value;
	}

	public List<Errors> Errors;
	public ParameterSet ParameterSet;
	public List<UtilityMatches> UtilityMatches;

	public class UtilityMatches {
		public List<Parameters> UtilityDetails;
		public String UtilityKey;
		public String UtilityType;
		public List<Meters> Meters;
	}

	public static void test(){
		System.debug('testing');
	}
}