public with sharing class SPEN_ConstantData {
    public static Map<String, String> typeMapping = new Map<String, String>{'MessagingSession' => 'SMS', 'VoiceCall' => 'Call', 'Email Message' => 'EMail'};
	public static String MESSAGINGSESSION= 'MessagingSession';
    public static String VOICECALL = 'VoiceCall';
    public static String EMAILMESSAGE = 'Email Message';
    public static String INCIDENTINSERTANDUPDATES = 'SPEN_IncidentInsertAndUpdates';
    public static String IncidentMessage = 'HV Incident Message';
    public static String HVESOIncidentMessage = 'HVN ESO Demand Disconnection Message';
    //Start for CRMD-3156 and CRMD-3097
    public static String PREPOSTASKRECRDTYPE = 'SPEN_PreQuoteContactTask';
    public static String PREQUOTETASKTYPE = 'Pre-Quote Contact';
    public static String POSTENRUIRYTASKTYPE = 'Post Enquiry Contact';
    public static String POSTENRUIRYDUPERRORMSG = 'User cannot create more than one Post-Quote Contact task in the same case';
    public static String PREQUOTEDUPERRORMSG = 'User cannot create more than one Pre-Quote Contact task in the same case';
    //End for CRMD-3156 and CRMD-3097
    
    //CRMD-724 Start 
    public static String SWCaseStatus = 'Streetworks Review'; 
    public static String Completed = 'Completed';
    public static String Failed = 'Failed';
    public static String SWIntegrationRequestServiceClass = 'SPEN_SyncStreetworksCaseDetails';
    //CRMD-724 END 
    //CRMD-707 START
    public static String NRSWACaseStatus = 'NRSWA Review';
    public static String NRSWAIntegrationRequestServiceClass = 'SPEN_SyncNRSWACaseDetails';
    //CRMD-707 END
    //Start for CRMD-6968
    public static String ONDEMAND = 'On Demand';
    public static String MESSAGINGTASKERRORMESSAGE = 'You can not change the status from Higher to Lower Satus';
    //End for CRMD-6968
    public static String COMMENTFROM = 'from';
    public static String COMMENTTO = ' to';
    public static String OUTAGERESTORED = 'Restored';
    //End for CRMD-6362

    public static List<String> CAMPAIGN_LIST=new List<String>{'Stage 2','Stage 3','Stage 4','Stage 2 Reply','Stage 1 Reply','Stage 3 Reply','Stage 4 Reply'};
    public static List<String>  MLIESTONETYPE_LIST=new List<String>{'Planning','Land Interest','Standard'};
    public static List<String>  TASKSTATUS_LIST=new List<String>{'Open','Not Started','In progress','Callback Required','Contact Successful','Contact Not Successful','Phone call','Successful – Email','Case Accepted - With Delivery','Designer Escalation Addressed','Team Leader Escalation Addressed','Attempted','System Design Notes Required','Engineering Design Notes Required','Development Notes Required','Preparation Completed'};
    public static List<String>  INVOICE_OUTCOME_LIST=new List<String>{'Issued','Written Off','Redirected','Re-issued','Paid in Full','Withdrawn','Negotiated Settlement'};
}