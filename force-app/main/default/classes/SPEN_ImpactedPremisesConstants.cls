public class SPEN_ImpactedPremisesConstants {
    
	public static List<String> ConfigValueList = new List<String>{'OutageChangeDelay'};
    public static String OUTAGECHANGEDELAY = 'OutageChangeDelay';
    public static String SPENINCIDENT = 'SPEN Incident';
    public static String SPENINCIDENTOUTAGECHANGED = 'SDIFIncidentOutageChanged';
    public static String SPENINCIDENTOUTAGECHANGEDSTC = 'IncidentOutageChangedStc';
    public static String INCIDENTID = 'IncidentID';
    public static String INCIDENTREFERENCE = 'IncidentReference';
    public static String INCIDENTNAME = 'Incident';
    public static String CALL = 'CALL';
    public static String THIRDCALL = '3rd Call Received';
    public static Set<String> SETCASEINCTYPE = new Set<String> {'HV_N','HV_S','LV'};
    public static String SPENSP = 'SP';
    public static String SMSSINGLEPREMISENETWORKFAULT = 'SMS – Single Premise – Network Fault';
    public static String VASINGLEPREMISENETWORKFAULT = 'Single Premise Network Fault VA';
    public static String INSTANT = 'Instant';
    public static String MERGEDFROMSPTONETWORK = 'Merged from SP to Network';
    public static String OUTBOUND = 'Outbound';
    public static String SMSBLACKOUTWINDOW = 'SMS Blackout Window';
    public static String VABLACKOUTWINDOW = 'VA Blackout Window';
    public static String MERGED = 'Merged';
    public static String INCOMINGCASEVOLUMECOUNT = 'SPEN_IncomingCaseVolumeCount';
    public static final String SMSREADYSTATUS='Ready';
    public static final String H_PREFEREDMETHODOFCONTACT='H';
    public static final String T_PREFEREDMETHODOFCONTACT='T';
    public static final String SMS_CASERECORDTYPE='Case';
    public static final String CONTACTROLE='Customer';
    public static final Integer TIMEOUT=120000;
    public static final Integer VA_TIMEOUT = 120000;
    public static String SMSCOMPLAINTaCKNOLEDGMENT = 'SMS - Complaint - Acknowledgment';//CRMD-5392
    public static String VACOMPLAINTACKNOWLEDGMENT = 'Complaint Acknowledgment VA';//CRMD-5392
}