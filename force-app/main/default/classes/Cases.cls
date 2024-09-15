/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler for Case Trigger
AUTHOR      :   Dhara Desai
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
SEP-30-2022     Dhara Desai         Initial version 
-----------------------------------------------------------------------------*/ 
public with sharing class Cases      
{ 
    public static Boolean isRecursiveFlag = true;
    public static Boolean isIncidetSyncFlag = false; // creating new Boolean flag to avoid the Duplicate case execution Methods INC3001686(ApexCpuTime Limit)
    Public static Boolean firstcall=false; 
    Public static Boolean firstAFInsCall=false;//SOQL 101 Fix 
    Public static Id recordTypeIdReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Referral).getRecordTypeId();
    Public static Id complaintsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
    Public static Id GSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
    Public static Id NFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
    Public static Id CNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();//430 for CNT case type    
    Public static Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    Public static Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
    public static Id recordTypeIdBudgetConnection = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_BudgetConnectionEnquiry').getRecordTypeId();
    public static Id recordTypeIdFormalConnection = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_FormalConnectionEnquiry').getRecordTypeId();
    public static Id recordTypeIdConnectionReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId();
    public static Id recordTypeIdSPDBouncedEmail = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_SPDBouncedEmail').getRecordTypeId();
    public static Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
    public static Id recordTypeIdPreApplication = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CasePreApplication').getRecordTypeId();
	 Public static Id CaseUnplannedBypassRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();// formula limit
    Public static Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
    Public static Id recordTypeIdFault = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
    Public static Id recordTypeIdSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_SmartInterventions').getRecordTypeId();//CRMD-10627
    Public static Id recordTypeIdLCT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_LCT').getRecordTypeId();//CRMD-10729
    Public static String profileId = [Select Id,Name from Profile where Name = 'SPEN Integration'].Id;//check - SOQL 201
    Public static List<Group> highQueues = [select Id,name from Group where  Type = 'Queue' and name like '%high%'];//check -soql 201 
    Public static Set<String> setQueueName = new Set<String>{'NRSWA Actioned Cases', 'Streetworks Actioned Cases', 
        'NRSWA - SPM', 'NRSWA - SPD', 'Streetworks - SPD', 'Streetworks - SPM'};//check - soql 201
            Public static Map<String,Id> mapQueueName2Id = SPEN_CaseSelector.getQueueDetails(setQueueName);//check - soql 201
    Public static BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();//check - soql 201
    Public static List<Group> queueName = SPEN_CaseSelector.getQueueDetails();//check - soql 201
    Public static String qNameValues=String.valueOf(System.Label.SPEN_DesignQueueLabel); //check 201
    Public static List<String> queueValues = qNameValues.split(';');
    Public static List<Group> queueNameList = SPEN_CaseSelector.getQueueDetailList(queueValues);
    //check - soql 201 - S
    Public static Set<String> setBhNames = new Set<String>(System.label.SPEN_CJBusinessHours.split(','));
    Public static List<BusinessHours> lstBusinessHour =  SPEN_BusinessHourSelector.getBusinessHrs(setBhNames);
    
    Public static Set<String> entitlementAccount = new Set<String>{'Default Entitlement Account','GS Entitlement Account','Neutral Fault Entitlement Account','CNT Entitlement Account','NRSWA Case Entitlement Account','GE Entitlement Account'};//check - soql 201
        Public static List<Entitlement> lstEnt =  SPEN_EntitlementSelector.getEntitlementRecordsFromAccount(entitlementAccount);//check- soql 201
    
    Public static String OperatingHrsByRecordTypeName = 'SMS Blackout Window';
    Public static list<SPEN_IVROperatingHours__c> ivrlist = SPEN_IvrOperatingHoursSelector.getIVROperatingHours(OperatingHrsByRecordTypeName);
    
    Public static String UnidentifiedContactName = System.Label.SPEN_SMSUnidentifiedContact;
    Public static list<Contact> UndifinedContactRecords = [Select ID from Contact where name =:UnidentifiedContactName Limit 1];
    
    Public static map<string,SPEN_ConfigurableSettings__c> confmap = SEL_ConfigurationSettingSelector.getSMSConfig('SMS Config'); 
    
    Public static String IVRMessageTemplateExtName = System.Label.SPEN_IVRMessageTemplateCaseWeborPhoneSP;
    Public static Id IvrrecId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
    Public static List<SPEN_IVRMessage__c> ivrMsgList = [Select ID, SPEN_IVRMessage__c from SPEN_IVRMessage__c where SPEN_ExternalId__c =:IVRMessageTemplateExtName and RecordtypeId = :IvrrecId  Limit 1];
    
    Public static List<Account> accList = SPEN_AccountSelector.getPartnerAccount(CasesConstants.SPEN);
    
    Public static RecordType recType=[select id,RecordType.name from RecordType  where RecordType.name =:SPEN_ImpactedPremisesConstants.SMS_CASERECORDTYPE LIMIT 1];
    
    Public static SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
    Public static SPEN_IVRMessage__c ivrMsgSMS= ivrSel.selectByExternalId(SPEN_ImpactedPremisesConstants.SMSCOMPLAINTaCKNOLEDGMENT);
    Public static SPEN_IVRMessage__c ivrAcknowledgmentVA= ivrSel.selectByExternalId(SPEN_ImpactedPremisesConstants.VACOMPLAINTACKNOWLEDGMENT);        
    Public static SPEN_IVRMessage__c sMSMsg = ivrSel.selectByExternalId('SMS – GE Case Close – Survey');
    Public static SPEN_IVRMessage__c vAMsg = ivrSel.selectByExternalId('VA – GE Case Close – Survey');
    
    Public static AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
    
    Public static String qNameValues1=String.valueOf(System.Label.SPEN_queueName);
    Public static List<String> queueValues1 = qNameValues1.split(';');
    //CRMD-9805
    Public static String citlQueueValues1=String.valueOf(System.Label.SPEN_Connection_CITL_Team_Queues);
    Public  static List<String> citlQueueList1 = citlQueueValues1.split(';');
    public static List<String> finalQueuelist = addAllList(queueValues1,citlQueueList1);
    
    //check - soql 201 - S
    
    Public static List<Group> queueNameList1 =  SPEN_CaseSelector.getQueueDetailList(finalQueuelist);
   
    //check - soql 201 - E
    
	//Creating String to bypass Case Trigger
    Public static Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
    public static Map<Id,Incident> beforeInsertIncidentMap=new Map<Id,Incident>();
    public static Map<Id,Incident> afterInsertIncidentMap=new Map<Id,Incident>();
    public static Map<String,Id> mapBHName2BHId = new Map<String,Id>();//CRMD-7609
    //Creating String to bypass Case Trigger
    Public static Boolean bypassCaseTrigger =false;
    Public static Boolean oneTimeUpdateCall=false;
    public static Boolean isScopeChangedCase=false; //CRMD- impcted premise (case scope change) : CRMD 9236
    //Public static Boolean found=false;//CRMD - 8398
    //public static Map<Id,Integer> CaseToCountMap = new Map<Id,Integer>();//CRMD - 8398
    public static Set<Id> skipPoweronCallIds(){
        Set<Id> setRecordTypeId = new Set<Id>();
        setRecordTypeId.add(CaseUnplannedBypassRecordId);
        setRecordTypeId.add(recordTypeIdFault);
        /*setRecordTypeId.add(recordTypeIdReferral);
        setRecordTypeId.add(complaintsRecordTypeId);
        setRecordTypeId.add(GSRecordTypeId);
        setRecordTypeId.add(NFRecordTypeId);
        setRecordTypeId.add(CNTRecordTypeId);
        setRecordTypeId.add(recordTypeId3PD);
        setRecordTypeId.add(recordTypeIdQuery);
        setRecordTypeId.add(recordTypeIdSW);
        setRecordTypeId.add(recordTypeIdNRSWA);
        setRecordTypeId.add(recordTypeIdBudgetConnection);
        setRecordTypeId.add(recordTypeIdFormalConnection);
        setRecordTypeId.add(recordTypeIdConnectionReadOnly);
        setRecordTypeId.add(recordTypeIdTransmission);
        setRecordTypeId.add(recordTypeIdPreApplication);
        setRecordTypeId.add(recordTypeIdSPDBouncedEmail);*/
        return setRecordTypeId;
    }
    //201
    public static List<String> addAllList(List<String> queueValues1,List<String> citlQueueList1)
    {
        queueValues1.addAll(citlQueueList1);
        return queueValues1;
    }
	public static void checkRecordType(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap, List<Case> newCases, List<Case> oldCases) {
        List<Case> referralCases = new List<Case>();
		List<Case> gsCases = new List<Case>();
		for(Case cse : newCases){
			if(cse.RecordTypeId == recordTypeIdReferral){
				referralCases.add(cse);
			}
			else //if(cse.RecordTypeId == GSRecordTypeId)//commented for CRMD-10261 - Recordtypecheck 
            {
				gsCases.add(cse);
			}
		}
		if(Trigger.isInsert){
			if(Trigger.isBefore){
				if(!referralCases.isEmpty()){
					populateReferralFields(referralCases, null);
				}
			}
			if(Trigger.isAfter){	
				if(!referralCases.isEmpty()){
					createReferralServiceAfterInsert(referralCases); 
				}
			}
		}
       
		if(Trigger.isUpdate){
			if(Trigger.isBefore){
				if(!referralCases.isEmpty()){
					populateReferralFields(referralCases, oldCaseMap);
				}
				if(!gsCases.isEmpty()){
					populateGSFieldsMass(gsCases, oldCaseMap);
				}
			}
		}
    }
	public static void populateReferralFields(List<Case> caseNewList, Map<ID, Case> oldCaseMap){
        DateTime dt = (DateTime)Date.today().addDays(35);
        if(!dt.format('EEEE').equalsIgnoreCase('Tuesday')){
            dt = findNextTuesday(dt);
        }
        for(Case cse: caseNewList){
			if(cse.Status!=null && cse.Status.equals(CasesConstants.WITH_PARTNER) && (oldCaseMap == null || (oldCaseMap != null && cse.Status != oldCaseMap.get(cse.id).Status)))
            {
                cse.SPEN_NextCustomerContact__c = Date.valueOf(dt);
            }
		}
	}
    public static DateTime findNextTuesday(Datetime dt){
        dt = dt.addDays(1);
        String day = dt.format('EEEE');
        if(!day.equalsIgnoreCase('Tuesday'))
        {
            return findNextTuesday(dt);
        }
        else{
            return dt;
        }
    }
    
    /*************************************************************************
@Author: Rajat Verma
@Date: 09/02/24
@purpose: Check If the logged in user has transmission access or not
*************************************************************************************/
    public static Boolean checkTransmissionAccess(){
        Boolean ifTransmission = false;
        Set<String> transmissionProfileIds = new Set<String>(System.label.SPEN_TransmissionProfileIDs.trim().split(','));
        if(transmissionProfileIds.contains(UserInfo.getProfileId())){
            ifTransmission = true;
        }
        
        return ifTransmission;
    }

/*************************************************************************
@Author: Rajat Verma
@Date: 26/06/23
@purpose: Create Plot Records and ByPass Case Trigger From Flow
*************************************************************************************/
    @InvocableMethod(label='Create Plot Records' description='ByPass the Case trigger for this transaction And Create Plot Records')
    public static List<String> createPlotRecords(List<SPEN_Plot__c> plotLists){
        //Cases.bypassCaseTrigger = true;
        List<String> resultString = new List<String>();
        List<SPEN_Plot__c> plotListToCreate = new List<SPEN_Plot__c>();
        String successResult = '';
        integer firstNumber = Integer.valueOf(plotLists[0].SPEN_FirstinRange__c) ;
        integer lastNumber = Integer.valueOf(plotLists[0].SPEN_LastinRange__c) ;
        integer plotRange = (lastNumber - firstNumber) + 1;
        integer counterName = firstNumber;
        
        
        for(integer i=0; i<plotRange ; i++){
            SPEN_Plot__c sp = new SPEN_Plot__c();
            sp.SPEN_PlotNumber__c = plotLists[0].SPEN_PlotNumber__c + ' ' + counterName;
            sp.SPEN_BuildingCode__c = plotLists[0].SPEN_BuildingCode__c ; 
            sp.SPEN_PropertyType__c = plotLists[0].SPEN_PropertyType__c ;
            sp.SPEN_BusinessType__c = plotLists[0].SPEN_BusinessType__c ;
            sp.SPEN_BusinessTypeOther__c = plotLists[0].SPEN_BusinessTypeOther__c ;
            sp.SPEN_NoofBedrooms__c = plotLists[0].SPEN_NoofBedrooms__c ;
            sp.SPEN_EVChargingType__c = plotLists[0].SPEN_EVChargingType__c ;
            sp.SPEN_EVChargerQuantity__c = plotLists[0].SPEN_EVChargerQuantity__c ;
            sp.SPEN_EVtoGrid__c = plotLists[0].SPEN_EVtoGrid__c ;
            sp.SPEN_DisturbingLoadSummary__c = plotLists[0].SPEN_DisturbingLoadSummary__c ;
            sp.SPEN_DisturbinglLoadkw__c = plotLists[0].SPEN_DisturbinglLoadkw__c ;
            sp.SPEN_TechnologyType__c = plotLists[0].SPEN_TechnologyType__c ;
            sp.SPEN_EnergySource__c = plotLists[0].SPEN_EnergySource__c ;
            sp.SPEN_GenerationRatingkW__c = plotLists[0].SPEN_GenerationRatingkW__c ;
            sp.SPEN_CombinedHeatandPower__c = plotLists[0].SPEN_CombinedHeatandPower__c ;
            sp.SPEN_StreetName__c = plotLists[0].SPEN_StreetName__c ;
            sp.SPEN_TownCity__c = plotLists[0].SPEN_TownCity__c ;
            sp.SPEN_County__c = plotLists[0].SPEN_County__c ;
            sp.SPEN_PostCode__c = plotLists[0].SPEN_PostCode__c ;
            sp.SPEN_MaxPowerkVA__c = plotLists[0].SPEN_MaxPowerkVA__c ;
            sp.SPEN_MeteringPointClass__c = plotLists[0].SPEN_MeteringPointClass__c ;//Added CRMD-7195
            sp.SPEN_MeteringPointProfile__c = plotLists[0].SPEN_MeteringPointProfile__c ;//Added CRMD-7195
            sp.SPEN_Phase__c = plotLists[0].SPEN_Phase__c ;
            sp.SPEN_Earth__c = plotLists[0].SPEN_Earth__c ;
            sp.SPEN_HeatingMethod__c = plotLists[0].SPEN_HeatingMethod__c ;
            sp.SPEN_HeatingTypeDescription__c = plotLists[0].SPEN_HeatingTypeDescription__c ;
            sp.SPEN_CaseRecord__c = plotLists[0].SPEN_CaseRecord__c ;
            sp.SPEN_Country__c = plotLists[0].SPEN_Country__c ; //Added CRMD-7195
            sp.SPEN_IDREQTOBEDISCON__c = plotLists[0].SPEN_IDREQTOBEDISCON__c ;//Added CRMD-7195
            plotListToCreate.add(sp);
            counterName++;
        }
        if(!plotListToCreate.isEmpty()){
            Database.SaveResult[] results = Database.insert(plotListToCreate, false);
            for (Database.SaveResult savresult : results) {
                if (savresult.isSuccess()) {
                	successResult = 'Success';
                }else{
                    //successResult = 'Error';
					successResult = savresult.getErrors()[0].getMessage();//CRMD-10509
                }
            }
            resultString.add(successResult);
        }
        return resultString;
    }	

	
/*************************************************************************
@Author: Dhara Desai
@Date: 04/10/22
@purpose: When contact is populated , auto-populate caller fields on case creation
*************************************************************************************/
    public void beforeCaseInsert(List<sObject> caseNewList){
        List<Case> cseMapNewVal = (List<Case>)caseNewList;
        Map<Id, Contact> custInfoMap = new Map<Id, Contact>();
        Set<Id> conIds = new Set<Id>();
        Boolean isWithinBusinessHours;
        List<SPEN_ContactPremise__c> conPremiseInfo = new  List<SPEN_ContactPremise__c>();
        SPEN_ConfigurableSettings__c outageConfig = new SPEN_ConfigurableSettings__c();
        List<SPEN_ContactPremise__c> conPremiseDetails = new List<SPEN_ContactPremise__c>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
		Id recordTypeIdComplaints = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Complaints).getRecordTypeId();
        Id recordTypeIdGS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_GS).getRecordTypeId();
        Id recordTypeNF = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
        Id CNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();//CRMD-6151 for CNT case type
        Id CaseRecordUnplanFaultId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
        String recordTypeNRSWAName = 'SPEN_NRSWA';
        Set<Id> prmIds = new Set<Id>();
        Set<Id> complaintsPrmIds = new Set<Id>();
        Set<Id> gsPrmIds = new Set<Id>();
		Set<Id> cntPrmIds = new Set<Id>();//CRMD-6151
        Set<Id> mPANIds = new Set<Id>();//CRMD-10729
        Map<Id,ID> mPANvsPremiseMap = new Map<Id,ID>();//CRMD-10729
        //formula limit - START
        Set<Id> incIdSet = new Set<Id>(); 
        Set<Id> bypassCaseIdSet = new Set<Id>();
        Set<String> bypassPostCodeSet = new Set<String>();//CRMD-9191
        Set<Id> nonBypassCaseIdSet = new Set<Id>();
        Set<Id> queryCaseParentIDSet = new Set<ID>();
        //formula limit - END
        List<SPEN_MPAN__c> mpanLstFoPremise = new List<SPEN_MPAN__c>();
        Map<Id, Integer> premiseIdEnergisedMPANCount = new Map<Id, Integer>();							   
        String connectionRecTypeLabel=System.Label.SPEN_ConnectionsRecordType;//User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay 
        List <Case> lstConCaseUpd = new List<Case>();//User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay
        List <Id> lstConIdLst = new List<Id>();//User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay					   
        List<Case> caseConLstAddr = new List<Case>();//User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay
        Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();//amrita
        Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();//amrita
        Id recordTypeIdConnectionReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId(); //amrita
        Boolean hasDataLoadPermission = FeatureManagement.checkPermission('SPEN_BypassTriggerCase');
        //check - soql 201 - S
        Map<Id,Case> ParentCase3PD = new Map<Id,Case>();
        Map<Id,SPEN_Premise__c> PremiseMap =new Map<Id,SPEN_Premise__c>();
        List<SPEn_PostcodeMDM__c> postcodeMDMList = new List<SPEn_PostcodeMDM__c>()  ;
        //check - soql 201 - E
        try{           
            if(!cseMapNewVal.isEmpty()){
                //formula limit - START
                for(Case cse : cseMapNewVal)
                {
                    
                    if(cse.RecordTypeId == recordTypeId3PD || cse.RecordTypeId == recordTypeIdNRSWA)
                    {
                    incIdSet.add(cse.SPEN_Incident__c); //For inc ref formula
                    }
                   //if(cse.recordtypeId == CaseUnplannedBypassRecordId) //for bypassfulladdress formula
                	if(cse.RecordTypeId == recordTypeIdQuery)
                    {
                        queryCaseParentIDSet.add(cse.ParentId);
                    }
                    if(cse.SPEN_Bypass__c == false && cse.SPEN_AddressPremise__c != NULL)
                    {
                       System.debug('Inside If1: ');
                        nonBypassCaseIdSet.add(cse.SPEN_AddressPremise__c);
                    }
                    //CRMD-9191 - Start
                    if(cse.SPEN_Bypass__c == true && cse.SPEN_BYPASSPostCode__c != NULL && cse.SPEN_AddressPremise__c == NULL)
                    {
                        System.debug('Inside If*: ');
                        bypassPostCodeSet.add(cse.SPEN_BYPASSPostCode__c);
                    }
                    //CRMD-9191 END
                }
               system.debug('incIdSet >>' + incIdSet);
                if(!incIdSet.isEmpty())//check - soql 201
                {
                beforeInsertIncidentMap = new Map<Id,Incident>([Select Id,SPEN_IncidentReference__c,createddate,SPEN_SPDSPM__c,SPEN_District__c from Incident where Id IN:incIdSet]);
                }
                if(!queryCaseParentIDSet.isEmpty())//check - soql 201
                {
                    ParentCase3PD = new Map<Id,Case>([SELECT Id,SPEN_incidentrefFormula__c,SPEN_Incident__c,BusinessHoursId,SPEN_SPDSPMIndicator__c from Case where ID IN:queryCaseParentIDSet]);//CRMD 9531 BusinessHoursId,SPEN_SPDSPMIndicator__c added
                }
                if(!nonBypassCaseIdSet.isEmpty())//check - soql 201
                {
                    PremiseMap = new Map<Id,SPEN_Premise__c>([Select Id,SPEN_FullAddress__c,Local_Authority__c,SPEN_LSOA__c from SPEN_Premise__c where Id IN:nonBypassCaseIdSet]);//CRMD-9191 LA added
                }
                //CRMD-9191 - Start
                Map<String,SPEn_PostcodeMDM__c> postcodeMDMMap = new Map<String,SPEn_PostcodeMDM__c> ();
                if(!bypassPostCodeSet.isEmpty())//check - soql 201
                {
                    postcodeMDMList = [SELECT Id, SPEN_PostCode__c,SPEN_LocalAuthority__c,SPEN_LSOA__c FROM SPEN_PostCodeMDM__c where SPEN_PostCode__c IN:bypassPostCodeSet];
                    
                for(SPEn_PostcodeMDM__c postCode:postcodeMDMList)
                {
                    postcodeMDMMap.put(postCode.SPEN_PostCode__c,postCode);
                }
                }//201
                //CRMD-9191 - end
                //formula limit - END
                for(Case cse: cseMapNewVal){
                    //if(incidentMap.containsKey(cse.SPEN_Incident__c) && ParentCase3PD.containsKey(cse.ParentId))
                    //check - soql 201
                    if(!ParentCase3PD.isEmpty() && ParentCase3PD.containsKey(cse.ParentId)) // ****FOR Query Case*****
{
                           //CRMD-9531 start - Agent initiated Query
                        if(cse.SPEN_QueryType__c == 'Internal' && cse.Origin == 'Email' )
                        {
                            System.debug('>>>ParentCase3PD.get(cse.ParentId).BusinessHoursId: '+ParentCase3PD.get(cse.ParentId).BusinessHoursId);
                            System.debug('>>>ParentCase3PD.get(cse.ParentId).SPEN_SPDSPMIndicator__c: '+ParentCase3PD.get(cse.ParentId).SPEN_SPDSPMIndicator__c);
                            cse.BusinessHoursId = ParentCase3PD.get(cse.ParentId).BusinessHoursId;
                            cse.SPEN_SPDSPMIndicator__c = ParentCase3PD.get(cse.ParentId).SPEN_SPDSPMIndicator__c;
                        }
                        //CRMD-9531 end
                        else
                    {
                        Case Parent3PDCase = ParentCase3PD.get(cse.ParentId);
                        cse.SPEN_IncidentRefFormula__c =Parent3PDCase.SPEN_incidentrefFormula__c;
                    }
                }
                    //201
                    if(!beforeInsertIncidentMap.isEmpty() && beforeInsertIncidentMap.containsKey(cse.SPEN_Incident__c) && (cse.RecordTypeId == recordTypeId3PD || cse.RecordTypeId == recordTypeIdNRSWA))// ****FOR 3PD Case and NRSWA Case***** 
                    {
                       Incident inc = beforeInsertIncidentMap.get(cse.SPEN_Incident__c);
                       cse.SPEN_IncidentRefFormula__c =inc.SPEN_IncidentReference__c; 
                       cse.SPEN_IncidentDate__c = Date.valueOf(inc.createdDate);//CRMD - 8960
                       if(cse.RecordTypeId == recordTypeIdNRSWA)
                       {
                           cse.SPEN_NRSWAExternalID__c = recordTypeNRSWAName + '-'+cse.SPEN_IncidentRefFormula__c;
                       }
                    }
                    	
                    if((cse.RecordTypeId == recordTypeId || cse.RecordTypeId == recordTypeIdGE) && cse.ContactId!=NULL && cse.SPEN_AdditionalCaller__c == False){//CRMD-10129 //CRMD-10770
                        //custInfoMap.put(cse.ContactId,SPEN_CaseSelector.getCustomerInfo(cse.ContactId));
                        conIds.add(cse.ContactId);
                    }  
                    //FORMULA LIMIT - START
                     if(cse.RecordTypeId == recordTypeIdNRSWA || cse.RecordTypeId == recordTypeId3PD||cse.RecordTypeId == recordTypeIdSW || cse.RecordTypeId == recordTypeIdGE ||  cse.RecordTypeId == recordTypeIdSI || cse.RecordtypeId == recordTypeIdLCT){//CRMD-10441  //CRMD-10627-SI record type //CRMD-10752- added LCT
                        cse.SPEN_LastStatusChangeDate__c = system.now();
                        cse.SPEN_CaseAssignmentTime__c = system.now();
                    } 

                    if(cse.SPEN_Bypass__c)// if(!caseBypassList.isEMpty())//with bypass checked
                    {
                        cse.SPEN_Bypass_FullAddress__c = cse.SPEN_BYPASSFlatNumber__c +' '+cse.SPEN_BYPASSPremiseNumber__c+' '+cse.SPEN_BYPASSPremiseName__c+' '+
                            cse.SPEN_BYPASSStreet__c+' '+cse.SPEN_BYPASSArea__c+' '+cse.SPEN_Town_PowerOnFormula__c+' '+cse.SPEN_BYPASSPostCode__c+' '+cse.SPEN_BYPASSSiteNumber__c+' '+
                            cse.SPEN_OperatingZonePowerOnFormula__c;
                        //CRMD-9191 - Start
                        if(!postcodeMDMMap.isEmpty())
                        {
                            SPEn_PostcodeMDM__c pcode = postcodeMDMMap.get(cse.SPEN_BYPASSPostCode__c);
                            cse.SPEN_Local_Authority__c = pcode.SPEN_LocalAuthority__c;
                           //CRMD-9191 feedback - start
                           if(cse.RecordTypeId == recordTypeIdReferral)
                           {
                               cse.SPEN_LSOA__c = pcode.SPEN_LSOA__c;
                           }
                           //CRMD-9191 feedback - end
                        }
                        //CRMD-9191 - END
                    }
                    //201
                    if(!PremiseMap.isEmpty() && PremiseMap.containsKey(cse.SPEN_AddressPremise__c))
                    {
                        System.debug('Inside Final If');
                        SPEN_Premise__c premise = PremiseMap.get(cse.SPEN_AddressPremise__c);
                        cse.SPEN_Bypass_FullAddress__c = '<a href="/'+ String.valueOf(cse.SPEN_AddressPremise__c).substring(0, 15)+	'" target="_self"'+ '>' + premise.SPEN_FullAddress__c + '</a>';
			            cse.SPEN_Local_Authority__c = premise.Local_Authority__c; // CRMD-9191
                        //CRMD-9191 feedback - start
                        if(cse.RecordTypeId == recordTypeIdReferral)
                        {
                           cse.SPEN_LSOA__c = premise.SPEN_LSOA__c;
						}
                        //CRMD-9191 feedback - end
                    }
                    
                    
                 	//FORMULA Limit - END                  
                    //SPEN_ConfigurableSettings__c Code for populating Outage ETR ==> Change By: Bhagyashree Mandlik(14-Oct-2022)
                    cse.SPEN_ETROutage__c = SPEN_CaseService.getOutageETR(cse.SPEN_CaseCategoryOutcome__c);
                    //Code for linking found customer in case US 1940 ==> Change By: Smita Raikar(25-Oct-2022)
                    if(cse.Origin != 'Web' && cse.RecordTypeId != recordTypeIdReferral)
                    {
                        if(cse.SPEN_AddressPremise__c!= Null || cse.SPEN_AddressPremise__c!= '')
                        {
                            prmIds.add(cse.SPEN_AddressPremise__c);
                        }
                        // CRMD-5320 IVR Case to contact update
                        if('IVR'.equalsIgnoreCase(cse.Origin) && cse.SPEN_CallerMobileTelephone__c!=null  ){
                                                        cse.SPEN_CallerMobileTelephone__c=cse.SPEN_CallerMobileTelephone__c;
                                              
                                                     cse.SPEN_CallerTelephone__c = cse.SPEN_CallerMobileTelephone__c; 
                                                    }
                                                    else if('IVR'.equalsIgnoreCase(cse.Origin) && cse.SPEN_CallerTelephone__c!=null ){
                                                    cse.SPEN_CallerTelephone__c = cse.SPEN_CallerTelephone__c;
                            
                                   
                            }
                             
                    }
                    if(cse.Origin == 'Web')
                    {
                       conPremiseDetails = SPEN_ContactPremisesSelector.getPremiseContactInfo(cse);
                       for(SPEN_ContactPremise__c conPremise : conPremiseDetails){
                           if(conPremise.SPEN_Role__c == 'Customer'){
                                    conPremiseInfo.add(conPremise);
                              }
                       } 

                    }
                    if(!conPremiseInfo.isEmpty() || conPremiseInfo.size()==1)
                    {
                        cse.ContactId = conPremiseInfo[0].SPEN_RelatedContact__c;
                    }
                    //Update Reopened Date on 3PD Query Case 
                    if(cse.RecordTypeId == recordTypeIdQuery){
                        cse.SPEN_QueryReopenedDate__c = system.now();
                        cse.SPEN_CaseAssignmentTime__c = system.now();
                        cse.SPEN_LastStatusChangeDate__c = system.now();
                    }
                    if(cse.RecordTypeId == recordTypeIdNRSWA || cse.RecordTypeId == recordTypeId3PD||cse.RecordTypeId == recordTypeIdSW || cse.RecordTypeId == recordTypeIdGE ||  cse.RecordTypeId == recordTypeIdSI || cse.RecordTypeId == recordTypeIdLCT){ //CRMD-10627
                        cse.SPEN_LastStatusChangeDate__c = system.now();
                        cse.SPEN_CaseAssignmentTime__c = system.now();
                    } 

                    //Code Implementation Starts here . User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay
                    String conCaseRecTypeName=((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosById().get(cse.RecordTypeId).getDeveloperName();
                    system.debug('connectionRecType>>'+connectionRecTypeLabel+'<<cse.RecordType.DeveloperName>>'+conCaseRecTypeName);
                    if(connectionRecTypeLabel != null && connectionRecTypeLabel.containsignorecase(conCaseRecTypeName) && !FeatureManagement.checkPermission('SPEN_BypassTriggerCase'))
                    {
                        lstConCaseUpd.add(cse); 
                        if(cse.ContactId != null && !cse.isClone())
                        {
                            caseConLstAddr.add(cse);//Code Implementation . User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay 
                            lstConIdLst.add(cse.ContactId);
                        }//8234 start
                    if(!hasDataLoadPermission && (cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly)){
                        cse.SPEN_SAPReference__c = null;
                        cse.SPEN_SAPErrorDetails__c = null;
                        cse.SPEN_CaseTransferredDateTimeInSAP__c = null;
                      cse.status = CasesConstants.CASESTATUS_OPEN;//CRMD-9469
                        //CRMD-9784
                        if(cse.isClone() && System.Label.SPEN_ConnMigrationOrigin.equalsIgnoreCase(cse.Origin)){
                            cse.Origin = '';
                        }
                        //END
                    }//8234 end
		    //CRMD-918 start
                    if((cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly) && cse.Status == 'Delivery' && cse.SPEN_SubStatus__c == null)
                    {
                        cse.SPEN_SubStatus__c='Assigned';
                    }//CRMD-918 end
                    }
		}
                if(!lstConCaseUpd.isEmpty())
                {
                    SPEN_CasesConnectionService.updateBMSOMS(lstConCaseUpd);
                    SPEN_CasesConnectionService.updatePaymentDecision(lstConCaseUpd);//Code Implementation . User Story : CRMD-8296. Date : 05/10/2023. Developer : Akshay 
                }//Code Implementation Ends here . User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay 

                if(!caseConLstAddr.isEmpty())
                {
                    SPEN_CasesConnectionService.updateAddressInfo(caseConLstAddr,lstConIdLst);//Code Implementation . User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay 
                }
                   
                if(prmIds!=Null)
                {
                	premiseIdEnergisedMPANCount = SPEN_PremiseSelector.getPremiseEnergisedMPANCount(prmIds);
                }
                
                for(Case cse: cseMapNewVal)
                {
                    if (!premiseIdEnergisedMPANCount.isEmpty() && premiseIdEnergisedMPANCount.containsKey(cse.SPEN_AddressPremise__c) && premiseIdEnergisedMPANCount.get(cse.SPEN_AddressPremise__c) == 0 && cse.RecordTypeId == CaseRecordUnplanFaultId)
                    {
                        cse.addError('Case cannot be created as there are no Energised MPAN exist for the selected Premise');
                    }
                    // defect validation for send to poweron button for bypass case only
                    //if(cse.RecordTypeId == byPassRecordTypeId && cse.SPEN_SendtoPowerOn__c){
                     //   cse.addError('The send to PowerOn checkbox can only be checked after the case is created. Please save case details and then check the box.');

                   // }
                }
            }
            if(!conIds.isEmpty())
            {
                custInfoMap = SPEN_ContactSelector.contactRecord(conIds);
            }
            if(custInfoMap.size()>0){
                populateCallerInfo(custInfoMap,cseMapNewVal);
            }
            for(Case cse: cseMapNewVal){ //CRMD-10729 - GE /SI record type added
                //CRMD-10729 - S
                if((cse.RecordTypeId == recordTypeIdGE ||  cse.RecordTypeId == recordTypeIdSI ||  cse.RecordTypeId == recordTypeIdLCT) && 
                   (cse.SPEN_MPANMeter__c != NULL ))
                {
                    mPANIds.add(cse.SPEN_MPANMeter__c);
                }  //CRMD-10729 - E
                //CRMD-10729 - COndition added for GE/SI/LCt
                 if((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeNF ||  ((cse.RecordTypeId == recordTypeIdGE  || cse.RecordTypeId == recordTypeIdLCT ||  cse.RecordTypeId == recordTypeIdSI ) && cse.SPEN_MPANMeter__c == NULL )) && (cse.SPEN_AddressPremise__c!= Null //|| cse.SPEN_AddressPremise__c!= ''
                                                                                                                                                                                                                           )){
                    complaintsPrmIds.add(cse.SPEN_AddressPremise__c);
                }
                else if(cse.RecordTypeId == recordTypeIdGS && (cse.SPEN_AddressPremise__c!= Null || cse.SPEN_AddressPremise__c!= '')){
                    gsPrmIds.add(cse.SPEN_AddressPremise__c);
                }
				else if(cse.RecordTypeId == CNTRecordTypeId && (cse.SPEN_AddressPremise__c!= Null || cse.SPEN_AddressPremise__c!= '')){
                    cntPrmIds.add(cse.SPEN_AddressPremise__c);
                }	//CRMD-6151
            }
            if(!complaintsPrmIds.isEmpty())
                {
                	mpanLstFoPremise = SPEN_PremiseSelector.getPremiseForMPAN(complaintsPrmIds);
                }
            else if(!gsPrmIds.isEmpty())
                {
                  mpanLstFoPremise = SPEN_PremiseSelector.getPremiseForMPAN(gsPrmIds);
                }
			else if(!cntPrmIds.isEmpty())
                {
                  mpanLstFoPremise = SPEN_PremiseSelector.getPremiseForMPAN(cntPrmIds);
                }	//CRMD-6151
                //CRMD-10729 - S
          if(!mPANIds.isEmpty())
          {
				mPANvsPremiseMap =  SPEN_PremiseSelector.getPremiseFromMPAN(mPANIds);             
          }
              //CRMD-10729 - E
            for(Case cse: cseMapNewVal)
                {//CRMD-10729 - GE /SI/LCT record type added
                    if ((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeNF || cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == CNTRecordTypeId ||  cse.RecordTypeId == recordTypeIdGE ||  cse.RecordTypeId == recordTypeIdSI || cse.RecordTypeId == recordTypeIdLCT) && !mpanLstFoPremise.isEmpty()){    //CRMD-6151
                        cse.SPEN_MPANMeter__c = mpanLstFoPremise[0].Id;
                    }
                   else if (cse.RecordTypeId == recordTypeIdGS && !mpanLstFoPremise.isEmpty()){
                        cse.SPEN_MPANMeter__c = mpanLstFoPremise[0].Id;
                    } //CRMD-10729 - S
                   if((cse.RecordTypeId == recordTypeIdGE ||  cse.RecordTypeId == recordTypeIdSI || cse.RecordTypeId == recordTypeIdLCT) && (!mPANvsPremiseMap.isEmpty()))
                   {
                      }
                   } //CRMD-10729 - E
        }catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
/*****************************************************************************************
@Author: Ayush Mittal
@Date: 03/05/2023
@purpose: When case is created , auto-populate zone lookup on case based on town populated
******************************************************************************************/ 
public static void caseInsertZoneValue(List<sObject> caseNewList)
{
    List<Case> cseList = caseNewList;
    Map<id, id> zoneMap = new Map<id, id>();
    Map<id,SPEN_Premise__c > premiseMap = new Map<id, SPEN_Premise__c>();
    Set<Id> zoneId = new Set<Id>(); 
    Set<Id> premId = new Set<Id>(); 
   
    try
    {
        if(!cseList.isEmpty())
        {
            for(Case cse: cseList)
            {
                /*if((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS || 
                    cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || 
                    cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == recordTypeIdGE ) && cse.SPEN_Bypass__c == true && cse.SPEN_Town__c != null ) */   	//430
                if(cse.SPEN_Bypass__c == true && cse.SPEN_Town__c != null )   	//430
                {
                    zoneId.add(cse.SPEN_Town__c);
                }
                /* else if((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS 
                         || cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || 
                         cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == recordTypeIdGE ) && cse.SPEN_AddressPremise__c != null) */ //430
                else if(cse.SPEN_AddressPremise__c != null) //430
		{
                    premId.add(cse.SPEN_AddressPremise__c);
                }
            }
            if(!premId.isEmpty())
            {
                for(SPEN_Premise__c premRec : [Select Id,Name, SPEN_Zone__c from SPEN_Premise__c where ID In :premId])
                {
                    premiseMap.put(premRec.Id, premRec);
                }
            }
            else if(!zoneId.isEmpty())
            {
                for(SPEN_Zone__c zoneRecord : [Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where ID In :zoneId])
                {
                    zoneMap.put(zoneRecord.Id, zoneRecord.SPEN_Parent__c);
                }
            }
           
            for(Case cse: cseList)
            {
                /* if((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS || 
                    cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || 
                    cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == recordTypeIdGE) && cse.SPEN_AddressPremise__c != null && !premiseMap.isEmpty() && premiseMap.containsKey(cse.SPEN_AddressPremise__c)) */		//430
               if(cse.SPEN_AddressPremise__c != null && !premiseMap.isEmpty() && 
                premiseMap.containsKey(cse.SPEN_AddressPremise__c))		//430
		{
                    cse.SPEN_Zone__c = premiseMap.get(cse.SPEN_AddressPremise__c).SPEN_Zone__c;
                }
                /*else if(((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS ||
                          cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || 
                          cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == recordTypeIdGE) && cse.SPEN_Bypass__c == true && cse.SPEN_Town__c != null ) && !zoneMap.isEmpty() && zoneMap.containsKey(cse.SPEN_Town__c))*/ //430
                else if((cse.SPEN_Bypass__c == true && cse.SPEN_Town__c != null ) && 
                           !zoneMap.isEmpty() && zoneMap.containsKey(cse.SPEN_Town__c)) //430
		{
                    cse.SPEN_Zone__c = zoneMap.get(cse.SPEN_Town__c);
                }
            }   
        }   
        updateBusinessHours(cseList);
    }
    catch(exception e)
    {
        SEL_LoggingService.log(e);
    }
}

/*************************************************************************
@Author: Asmita Rajput
@Date: 27/4/2023
@purpose: When case is created , update business hours based on District
*************************************************************************************/   
    public static void updateBusinessHours(List<case> caseNewList)
    {
        Id ComplaintsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
        Id GSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
        
        Map<Id,SPEN_Zone__c> mapId2Zone = new Map<Id,SPEN_Zone__c>();
        try{   
            for(Case caseObj: caseNewList)
            { 
                mapId2Zone.put(caseObj.SPEN_Zone__c, null);
            }
            mapId2Zone.putAll(SPEN_ZoneSelector.getZoneRecordsByIds(mapId2Zone.keySet()));
           
            /*  Set<String> setBhNames = new Set<String>(System.label.SPEN_CJBusinessHours.split(','));
            //Map<String,Id> mapBHName2BHId = new Map<String,Id>();//CRMD - 7609 commented - made public
            
List<BusinessHours> lstBusinessHour =  SPEN_BusinessHourSelector.getBusinessHrs(setBhNames);*///check - soql 201
            for(BusinessHours bh: lstBusinessHour)
            {
                mapBHName2BHId.put(bh.name,bh.id);
            }
            if(!mapId2Zone.isEmpty())
            {
                for(Case caseObj: caseNewList)
                {
                    SPEN_Zone__c zone = mapId2Zone.get(caseObj.SPEN_Zone__c);
                    if(zone!=NULL)
                   {
                        if((caseObj.RecordTypeId == ComplaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId)
                        && zone.SPEN_SPD_SPM__c.equalsIgnoreCase('SPM'))
                        {
                            caseObj.BusinessHoursId = mapBHName2BHId.get('SPM Complaints Business Hours');
                        }
                        else if(caseObj.RecordTypeId == recordTypeIdGE && zone.SPEN_SPD_SPM__c.equalsIgnoreCase('SPM'))
                        {
                            caseObj.BusinessHoursId = mapBHName2BHId.get('SPEN GE SPM Business Hours');
                        }
                        else if((caseObj.RecordTypeId == ComplaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId)
                        && zone.SPEN_SPD_SPM__c.equalsIgnoreCase('SPD'))
                        {
                            caseObj.BusinessHoursId = mapBHName2BHId.get('SPD Complaints Business Hours');
                        } else if(caseObj.RecordTypeId == recordTypeIdGE && zone.SPEN_SPD_SPM__c.equalsIgnoreCase('SPD'))
                        {
                        caseObj.BusinessHoursId = mapBHName2BHId.get('SPEN GE SPD Business Hours');
                        }
                    }
                }
            }
        }catch(exception e){
            system.debug('Exception Occurred :' + e.getStackTraceString());
            SEL_LoggingService.log(e);
        }
    }  
    public static void updateBusinessHoursForNRSWA(List<case> caseNewList)
    {
        
        //Map<Id,SPEN_Zone__c> mapId2Zone = new Map<Id,SPEN_Zone__c>();
        try{   
           
            /* Set<String> setBhNames = new Set<String>(System.label.SPEN_CJBusinessHours.split(','));
List<BusinessHours> lstBusinessHour =  SPEN_BusinessHourSelector.getBusinessHrs(setBhNames);*/ //check - soql 201
            for(BusinessHours bh: lstBusinessHour)
            {
                mapBHName2BHId.put(bh.name,bh.id);
            }
              for(Case caseObj: caseNewList)
                {
                //CRMD-7609 - START
                if(caseObj.RecordTypeId == recordTypeIdNRSWA && caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL)//9376
                {
                  caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c = 'NRSWA - 2 Business Hours';
                }
                else if(caseObj.RecordTypeId == recordTypeIdNRSWA && !caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High'))//9376
                {
                  caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c = 'NRSWA - 2 Business Hours';
                }
                       //CRMD-7609 - END
                    else if(caseObj.RecordTypeId==recordTypeIdQuery && caseObj.SPEN_Type__c=='NRSWA')
		    {
			    if (String.isNotBlank(caseObj.SPEN_SPDSPMIndicator__c) && caseObj.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPD') && caseobj.Origin == 'PowerOn' && caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL)//9376
			    {
				caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c = '2 Hr SLA North';
			    }
				else if (String.isNotBlank(caseObj.SPEN_SPDSPMIndicator__c) && caseObj.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPD') && caseobj.Origin == 'PowerOn' && !caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High'))//9376
			    {
				caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c = '2 Hr SLA North';
			    }
			    else  if (String.isNotBlank(caseObj.SPEN_SPDSPMIndicator__c) && caseObj.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPM') && caseobj.Origin == 'PowerOn' && caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL)//9376
			    {
				caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c = '2 Hr SLA South';
			    }
                else  if (String.isNotBlank(caseObj.SPEN_SPDSPMIndicator__c) && caseObj.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPM') && caseobj.Origin == 'PowerOn' && !caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High'))//9376
			    {
				caseObj.SPEN_Email_WI_Queue_Routing_Outcome__c = '2 Hr SLA South';
			    }
                    }
                  
                    //CRMD-7609 - START
                    if(caseObj.RecordTypeId == recordTypeIdNRSWA || caseObj.RecordTypeId == recordTypeIdSW || (caseObj.RecordTypeId==recordTypeIdQuery && caseObj.SPEN_Type__c=='NRSWA'))
                    {
                        system.debug('caseObj.SPEN_SPDSPMIndicator__c'+ caseObj.SPEN_SPDSPMIndicator__c);
                        if (String.isNotBlank(caseObj.SPEN_SPDSPMIndicator__c) && caseObj.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPD') )
                        {
                            caseObj.BusinessHoursId = mapBHName2BHId.get('SPD SW/NRSWA Business Hours');
                        }
                        else  if (String.isNotBlank(caseObj.SPEN_SPDSPMIndicator__c) && caseObj.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPM'))
                        {
                            caseObj.BusinessHoursId = mapBHName2BHId.get('SPM SW/NRSWA Business Hours');
                        }
                    }
                    //CRMD-7609 - END
                }
            
        }catch(exception e){
            system.debug('Exception Occurred :' + e.getStackTraceString());
            SEL_LoggingService.log(e);
        }
    }
    public void caseUpdateComplaintDates(List<sObject> caseNewList, Map<Id, sObject> caseOldMap)
    {
        List<Case> cseMapNewVal = (List<Case>)caseNewList;
        Map<Id,case> cseMapOldVal = new Map<Id,case>();
        if(caseOldMap != null && !caseOldMap.isEmpty())
            cseMapOldVal = (Map<Id,case>)caseOldMap;
        

        for (Case newCase : cseMapNewVal){
            if(/*(newCase.recordTypeId == complaintRecType || newCase.recordTypeId == GSRecordTypeId || newCase.recordTypeId == gERecordTypeId) &&*/ //commented for CRMD-10261 
                //CRMD-10295 
                ((Trigger.isUpdate && 
                (newCase.SPEN_ReceivedDate__c != cseMapOldVal.get(newCase.Id).SPEN_ReceivedDate__c ||
                newCase.BusinessHoursId != cseMapOldVal.get(newCase.Id).BusinessHoursId
                )
                ) || Trigger.isInsert) &&
                newCase.SPEN_ReceivedDate__c != null)
                {
                    Datetime dueDate = SPEN_BusinessDaysCalculationUtil.addDays(newCase.SPEN_ReceivedDate__c, 1,newCase.BusinessHoursId);
                    newCase.SPEN_ComplaintDay1Date__c = Date.valueOf(String.valueof(dueDate));

                    //Update Complaints/GS Milestone Start Date
                    Date myDate = Date.valueOf(newCase.SPEN_ComplaintDay1Date__c)-1;
                    Time myTime = Time.newInstance(23, 59, 0, 0);
                    DateTime stDateTime = DateTime.newInstance(myDate, myTime);
                    newCase.SPEN_ComplaintsGSMilestoneStartDate__c = stDateTime;
		    if(newCase.recordTypeId == recordTypeIdGE)
                    {
                        newCase.SlaStartDate = stDateTime;
                    }
		    //CRMD-10897-Start
                    Datetime responsedueDate = SPEN_BusinessDaysCalculationUtil.addDays(newCase.SPEN_ReceivedDate__c, 10,newCase.BusinessHoursId);
                    newCase.SPEN_ResponseDueDate__c = Date.valueOf(String.valueof(responsedueDate));
                    //END
                } 
        }
    }
    
   
/*************************************************************************
@Author: Asmita Rajput
@Date: 05/05/2023
@purpose: Update the Entitlement on Case
*************************************************************************************/ 
    public static void  updateEntitlement(List<sObject> caseNewList) {
        
        Id ComplaintsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
        Id GSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
        Id NFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
        Id CNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();//455 Milestone update for CNT case type
        //Set<String> entitlementAccount = new Set<String>{'Default Entitlement Account','GS Entitlement Account','Neutral Fault Entitlement Account','CNT Entitlement Account','NRSWA Case Entitlement Account','GE Entitlement Account'};//check - soql 201
        List<Case> listCases = (List<Case>)caseNewList;
        Map<String,Id> mapEntitlementName2id = new Map<String,Id>();
        try{        
            // List<Entitlement> lstEnt =  SPEN_EntitlementSelector.getEntitlementRecordsFromAccount(entitlementAccount);//check- soql 201
            for(Entitlement ent: lstEnt)
            {
                mapEntitlementName2id.put(ent.account.name,ent.id);
            }
            for(Case caseObj: listCases)
            {
                if(caseObj.RecordTypeId == ComplaintsRecordTypeId && caseObj.EntitlementId == null)
                {
                    caseObj.EntitlementId = mapEntitlementName2id.get('Default Entitlement Account');
                }else if(caseObj.RecordTypeId == GSRecordTypeId && caseObj.EntitlementId == null)
                {
                    caseObj.EntitlementId = mapEntitlementName2id.get('GS Entitlement Account');
                }else if(caseObj.RecordTypeId == NFRecordTypeId && caseObj.EntitlementId == null)
                {
                    caseObj.EntitlementId = mapEntitlementName2id.get('Neutral Fault Entitlement Account');
                }else if(caseObj.RecordTypeId == CNTRecordTypeId && caseObj.EntitlementId == null)
                {
                    caseObj.EntitlementId = mapEntitlementName2id.get('CNT Entitlement Account');//455 user story
                }
                else if(caseObj.RecordTypeId == recordTypeIdNRSWA && caseObj.EntitlementId == null)
                {
                    caseObj.EntitlementId = mapEntitlementName2id.get('NRSWA Case Entitlement Account');//CRMD - 7609
                }
         	 else if(caseObj.RecordTypeId == recordTypeIdGE && caseObj.EntitlementId == null)
                {
                    caseObj.EntitlementId = mapEntitlementName2id.get('GE Entitlement Account');
                }
                
            }
        }  catch(exception e){
            system.debug('Exception Occurred in updateEntitlement:' + e.getStackTraceString());
            SEL_LoggingService.log(e);
        } 
    }
    
/*************************************************************************
@Author: Smita Raikar
@Date: 26/12/22
@purpose: When case is created , update ETR value from zone config setting
*************************************************************************************/
    public static void caseInsertETROutageValue(List<sObject> caseNewList)
	{
        List<Case> cseMapNewVal = (List<Case>)caseNewList;
        
        Boolean isWithinBusinessHours;
        
        SPEN_ConfigurableSettings__c outageConfig = new SPEN_ConfigurableSettings__c();
        
		Set<Id> zoneId = new Set<Id>(); 
        Set<Id> incidentId = new Set<Id>(); 
        Map<Id, String> zoneMap = new Map<Id, String>(); 
        Map<Id, datetime> incidentMap = new Map<Id, datetime>(); 
        try
		{
            if(!cseMapNewVal.isEmpty())
			{
                for(Case cse: cseMapNewVal)
				{
                    if(cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c==NULL){
                       
						zoneId.add(cse.SPEN_Zone__c);
                    } 
                    else if((cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c!=NULL) || (cse.SPEN_Zone__c==NULL && cse.SPEN_Incident__c!=NULL))
					{
                         
						incidentId.add(cse.SPEN_Incident__c);
                    }
                    else
					{
                        //SPEN_ConfigurableSettings__c Code for populating Outage ETR ==> Change By: Bhagyashree Mandlik(14-Oct-2022)
                        cse.SPEN_ETROutage__c = SPEN_CaseService.getOutageETR(cse.SPEN_CaseCategoryOutcome__c);
                    }  
                }
                
                //written by Ayush 08 03
                if(!zoneId.isEmpty())//check - soql 201
                {
                for(SPEN_Zone__c zone : [Select Id,Name from SPEN_Zone__c where ID In :zoneId])
                {
                    zoneMap.put(zone.Id, zone.Name);
                }
                }
                if(!incidentId.isEmpty())//check - soql 201
                {
                for(Incident incRec : [Select Id,SPEN_EstimatedRestorationTime__c,IncidentNumber from Incident where ID In :incidentId])
                {
                    incidentMap.put(incRec.Id, incRec.SPEN_EstimatedRestorationTime__c);
                }
                }
                for(Case cse: cseMapNewVal)
                {
                    if((cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c==NULL) && (!zoneMap.isEmpty() && zoneMap.containsKey(cse.SPEN_Zone__c)))//201
                    {
                        cse.SPEN_ETROutage__c = SPEN_CaseService.getOutageETRVal(Datetime.valueOfGMT(String.valueOF(cse.CreatedDate)),zoneMap.get(cse.SPEN_Zone__c));
                    }
                    
                    else if(((cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c!=NULL) || (cse.SPEN_Zone__c==NULL && cse.SPEN_Incident__c!=NULL)) && (!incidentMap.isEmpty() && incidentMap.containsKey(cse.SPEN_Incident__c)))//201
                    {
                        string outageETR = string.valueOfGmt(incidentMap.get(cse.SPEN_Incident__c)); 
                        cse.SPEN_ETROutage__c = Cases.convertToLocaleTimeZone(outageETR) ; 
                    }  
                }
                // written by Ayush 08 03   
            }
        }
		catch(exception e)
		{
            SEL_LoggingService.log(e);
        }
    }
/*************************************************************************
@Author: Ayush Mittal
@Date: 10/05/23
@purpose: To fire Assignment Rule on the click of Log complaint button via VC.
*************************************************************************************/
public static void caseInsertAssignOwner(List<sObject> caseNewList)
{
    List<Case> cseList = caseNewList;
    
    List<Case> caseList = new List<Case>();
    Set<Id> caseIdSet = new Set<Id>();

    for(Case cse : cseList) 
    {
        caseIdSet.add(cse.Id);
    }
    //Fetching the assignment rules on case
        /*AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];*/ //check - soql 201
    
    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
    
        if(!caseIdSet.isEmpty())//check - soql 201
        {
    for(Case cse : [SELECT Id FROM Case WHERE Id IN: caseIdSet]) 
    {
        cse.setOptions(dmlOpts);
        caseList.add(cse);
    }
}
if(!caseList.isEmpty())  //201
{
   /* if(!Cases.firstcall && !Test.isRunningTest()) //CRMD-10771
    {
        
        Cases.firstcall =true;*/
        update caseList;
   // }
}
}


/*************************************************************************
Inline editing .
@Author: Ayush Mittal 
@Date: 23/05/23
@purpose: To fire Assignment Rule for inline editing.
*************************************************************************************/
public static void caseUpdateAssignOwner(Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap)
{
    List<Case> cseMapNewVal = (List<Case>)caseNewMap.values();
    Map<Id,case> cseMapOldVal = (Map<Id,case>)caseOldMap;
    
    List<Case> caseList = new List<Case>();
    Set<Id> caseIdSet = new Set<Id>();

    Id recordTypeIdComplaints = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
    Id recordTypeIdGS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
    Id recordTypeIdNF = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
    Id rcordTypeIdCNT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();
    
  
    for(Case cse : cseMapNewVal) 
    {
        if(
          (cse.recordTypeId == recordTypeIdNF  &&
          		(cse.SPEN_Complaints_Queue_Responsibility__c  !=cseMapOldVal.get(cse.id).SPEN_Complaints_Queue_Responsibility__c)
          )
          || 
          (cse.recordTypeId == recordTypeIdGS && 
                (cse.SPEN_Category__c  !=cseMapOldVal.get(cse.id).SPEN_Category__c || 
                 cse.SPEN_SPD_SPM__c  !=cseMapOldVal.get(cse.id).SPEN_SPD_SPM__c
                )
          ) 
          ||
          (cse.recordTypeId == recordTypeIdComplaints && 
                (cse.SPEN_Category__c  !=cseMapOldVal.get(cse.id).SPEN_Category__c || 
                 cse.SPEN_ComplaintDay1Date__c !=cseMapOldVal.get(cse.id).SPEN_ComplaintDay1Date__c || 
                 cse.SPEN_SPD_SPM__c  !=cseMapOldVal.get(cse.id).SPEN_SPD_SPM__c || 
                 cse.SPEN_Route_directly_to_Day2__c  !=cseMapOldVal.get(cse.id).SPEN_Route_directly_to_Day2__c ||
                 cse.SPEN_Customer_is_off_supply__c  !=cseMapOldVal.get(cse.id).SPEN_Customer_is_off_supply__c ||
                 cse.SPEN_Complaints_Queue_Responsibility__c  !=cseMapOldVal.get(cse.id).SPEN_Complaints_Queue_Responsibility__c ||
                 cse.SPEN_Is_License_Complaint_Category__c  !=cseMapOldVal.get(cse.id).SPEN_Is_License_Complaint_Category__c
                )
           ) ||
           (cse.recordTypeId == rcordTypeIdCNT  &&
           		(cse.Status !=cseMapOldVal.get(cse.id).Status ||
                 cse.SPEN_SPD_SPM__c  !=cseMapOldVal.get(cse.id).SPEN_SPD_SPM__c ||
                 cse.SPEN_Complaints_Queue_Responsibility__c  !=cseMapOldVal.get(cse.id).SPEN_Complaints_Queue_Responsibility__c ||
                 cse.SPEN_CNT_IsNeedExcludedFromICRouting__c   !=cseMapOldVal.get(cse.id).SPEN_CNT_IsNeedExcludedFromICRouting__c 
                )
           ) ||
           (cse.recordTypeId == recordTypeIdSW  && cse.SPEN_ConnectionDistrict__c !=cseMapOldVal.get(cse.id).SPEN_ConnectionDistrict__c ) || 
           (cse.recordTypeId == recordTypeIdNRSWA && cse.SPEN_SPDSPMIndicator__c !=cseMapOldVal.get(cse.id).SPEN_SPDSPMIndicator__c )
           )
        {
            caseIdSet.add(cse.Id);
        }
        
    }
    //Fetching the assignment rules on case
    AssignmentRule AR = new AssignmentRule();
    AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
    
    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
    Database.DMLOptions dmlOpts = new Database.DMLOptions();
    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
    
    if(!caseIdSet.isEmpty())
    {
        for(Case cse : [SELECT Id FROM Case WHERE Id IN: caseIdSet]) 
        {
            Case cs = new Case(Id = cse.id);
            cs.setOptions(dmlOpts);
            caseList.add(cs);
        }
    }
    if(!Cases.firstcall && !Test.isRunningTest())
    {
        Cases.firstcall =true;
        update caseList;
        System.enqueueJob(new SPEN_CaseAssignmentNotificationQueueable(caseIdSet));
    } 
}
public static void processCaseSLA(Map<Id, Case> caseOldMap, Map<Id,Case> newCaseMap)
{
    Set<Id> setCaseId = new Set<Id>();
    for(Case cse : newCaseMap.values()) 
    {
        if(cse.recordtypeid == recordTypeIdSW || cse.recordtypeid == recordTypeIdNRSWA ||
           (cse.recordtypeid == recordTypeIdQuery && (cse.SPEN_Type__c == 'StreetWorks' ||cse.SPEN_Type__c == 'NRSWA'))) 
        {
            setCaseId.add(cse.Id);
        }
    }
    if(!setCaseId.isEmpty()){
        System.enqueueJob(new SPEN_JourneySLAQueueable(setCaseId));
    }
    
}
public static void sendNotificationsToQueues(Map<Id, sObject> caseOldMap, Map<Id,sObject> newCaseMap)
{
    Map<Id,Case> cseMapNewVal = (Map<Id,Case>)newCaseMap;
    Map<Id,Case> cseMapOldVal = (Map<Id,Case>)caseOldMap;
    Set<Id> setCaseId = new Set<Id>();
    Set<String> setQueueNames = new Set<String>();
   
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            for(Case cse : cseMapNewVal.values()) 
            {
                       setCaseId.add(cse.Id);
                
            }
            if(setCaseId != null && !setCaseId.isEmpty())
                System.enqueueJob(new SPEN_CaseAssignmentNotificationQueueable(setCaseId));
        }
        if(Trigger.isUpdate){
            for(Case cse : cseMapNewVal.values()) 
            {
                if(cse.OwnerId != cseMapOldVal.get(cse.Id).OwnerId ) 
                {
                    setCaseId.add(cse.Id);
                }
            }
            if(setCaseId != null && !setCaseId.isEmpty())
                System.enqueueJob(new SPEN_CaseAssignmentNotificationQueueable(setCaseId));
        }
    }
}
/**************************************************************************************
@Author: Ayush Mittal 
@Date: 24/05/23
@purpose: Change the ownership of task associated with the case on every owner update 
**************************************************************************************/    
public static void updateTaskOwnerOnCaseOwnerChange(Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap)
{
    Map<Id,Case> cseMapNewVal = (Map<Id,Case>)caseNewMap;
    Map<Id,Case> cseMapOldVal = (Map<Id,Case>)caseOldMap;

    Set<Id> caseIds = new Set<Id>();

    if(!cseMapNewVal.isEmpty()) 
    {
        for(Case cse : cseMapNewVal.values()) 
        {
            if( cse.OwnerId != cseMapOldVal.get(cse.Id).OwnerId) //record type check added- CRMD-7117
            {
                caseIds.add(cse.Id);
            }
        }
        if(!caseIds.isEmpty())
        {
            System.enqueueJob(new SPEN_TaskOwnerChangeQueueable(caseIds,cseMapNewVal));
        }
    }
}

/*************************************************************************
@Author: Smita Raikar
@Date: 26/12/22
@purpose: When case is updated , update ETR value from zone config setting or Incident ETA value
*************************************************************************************/
public static void caseUpdateETROutageValue(Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap)
{
    List<Case> cseMapNewVal = (List<Case>)caseNewMap.values();
    Map<Id,case> cseMapOldVal = (Map<Id,case>)caseOldMap;
    
    Boolean isWithinBusinessHours;
    
    SPEN_ConfigurableSettings__c outageConfig = new SPEN_ConfigurableSettings__c();
    
    Set<Id> zoneId = new Set<Id>(); //Written Ayush 08 03
    Set<Id> incidentId = new Set<Id>(); //Written Ayush 08 03
    Map<Id, String> zoneMap = new Map<Id, String>(); //Written Ayush 08 03
    Map<Id, datetime> incidentMap = new Map<Id, datetime>(); //Written Ayush 08 03
    
    try
    {           
        if(!cseMapNewVal.isEmpty())
        {
            for(Case cse: cseMapNewVal)
            {
                if((cse.Status!='Closed' || cse.Status!='Cancelled') && (cseMapOldVal.get(cse.id).SPEN_Zone__c!=cse.SPEN_Zone__c || cseMapOldVal.get(cse.id).SPEN_Incident__c!=cse.SPEN_Incident__c))
                {
                    if(cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c==NULL)
                    {
                        //system.debug('Zone-'+cse.SPEN_Zone__r.Name);
                        //SPEN_Zone__c zone=[Select Id,Name from SPEN_Zone__c where ID=: cse.SPEN_Zone__c]; //Commented Ayush 08 03
                        //cse.SPEN_ETROutage__c = SPEN_CaseService.getOutageETRVal(cse.CreatedDate,zone.Name); //Commented Ayush 08 03
                        zoneId.add(cse.SPEN_Zone__c);  //Written Ayush 08 03
                    } 
                    else if((cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c!=NULL) || (cse.SPEN_Zone__c==NULL && cse.SPEN_Incident__c!=NULL)) 
                    {
                        //Incident incRec=[Select Id,SPEN_EstimatedRestorationTime__c,IncidentNumber from Incident where ID=: cse.SPEN_Incident__c]; //Commented Ayush 08 03
                        //string outageETR = string.valueOfGmt(incRec.SPEN_EstimatedRestorationTime__c); //Commented Ayush 08 03
                        //cse.SPEN_ETROutage__c =outageETR ; //Commented Ayush 08 03
                        incidentId.add(cse.SPEN_Incident__c); //Written Ayush 08 03
                    }
                    
                    //Commented to Merge Methods  08 03 AYUSH
                    /*
                    else if(cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c!=NULL)
                    {
                        Incident incRec=[Select Id,SPEN_EstimatedRestorationTime__c,IncidentNumber from Incident where ID=: cse.SPEN_Incident__c];
                        string outageETR = string.valueOfGmt(incRec.SPEN_EstimatedRestorationTime__c);
                        cse.SPEN_ETROutage__c =outageETR ;
                    }
                    else if(cse.SPEN_Zone__c==NULL && cse.SPEN_Incident__c!=NULL)
                    {
                        Incident incRec=[Select Id,SPEN_EstimatedRestorationTime__c,IncidentNumber from Incident where ID=: cse.SPEN_Incident__c];
                        string outageETR = string.valueOfGmt(incRec.SPEN_EstimatedRestorationTime__c);
                        cse.SPEN_ETROutage__c =outageETR ;
                    }
                    */

                    
                    else 
                    {
                        //SPEN_ConfigurableSettings__c Code for populating Outage ETR ==> Change By: Bhagyashree Mandlik(14-Oct-2022)
                        cse.SPEN_ETROutage__c = SPEN_CaseService.getOutageETR(cse.SPEN_CaseCategoryOutcome__c);  
                    }  
                } 
            }
            //written by Ayush 08 03
            for(SPEN_Zone__c zone : [Select Id,Name from SPEN_Zone__c where ID In :zoneId])
            {
                zoneMap.put(zone.Id, zone.Name);
            }
            if(!Test.isRunningTest()){
                for(Incident incRec : [Select Id,SPEN_EstimatedRestorationTime__c,IncidentNumber from Incident where ID In :incidentId])
                {
                    incidentMap.put(incRec.Id, incRec.SPEN_EstimatedRestorationTime__c);
                }
            }
            for(Case cse: cseMapNewVal)
            {
                if(cse.Status!='Closed' || cse.Status!='Cancelled')
                {
                    if((cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c==NULL) && zoneMap.containsKey(cse.SPEN_Zone__c))
                    {
                        cse.SPEN_ETROutage__c = SPEN_CaseService.getOutageETRVal(Datetime.valueOfGMT(String.valueOF(cse.CreatedDate)),zoneMap.get(cse.SPEN_Zone__c)); 
                    }
                    
                    else if(((cse.SPEN_Zone__c!=NULL && cse.SPEN_Incident__c!=NULL) || (cse.SPEN_Zone__c==NULL && cse.SPEN_Incident__c!=NULL)) && incidentMap.containsKey(cse.SPEN_Incident__c))  
                    {
                        string outageETR = string.valueOfGmt(incidentMap.get(cse.SPEN_Incident__c)); 
                        cse.SPEN_ETROutage__c =outageETR ; 
                    }
                }
            }
            // written by Ayush 08 03
        }   
    }
    catch(exception e)
    {
        SEL_LoggingService.log(e);
    }
}
/*************************************************************************
@Author: Dhara Desai
@Date: 04/10/22
@purpose: When contact details changed, auto-populate caller fields on case Update
*************************************************************************************/
    public void beforeCaseUpdate(Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap){
        List<Case> cseMapNewVal = (List<Case>)caseNewMap.values();
        Map<Id,case> cseMapOldVal = (Map<Id,case>)caseOldMap;
        Map<Id, Contact> custInfoMap = new Map<Id, Contact>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> prmIds = new Set<Id>();
        //Code Implementation Starts here . User Story : CRMD-5382 & 5384. Date : 05/17/2023. Developer : Sheker
        Map<String,Id> mapDevNamevsId = new Map<String,Id>();
        /*String qNameValues=String.valueOf(System.Label.SPEN_queueName);
        List<String> queueValues = qNameValues.split(';');
        //CRMD-9805
        String citlQueueValues=String.valueOf(System.Label.SPEN_Connection_CITL_Team_Queues);
        List<String> citlQueueList = citlQueueValues.split(';');
        queueValues.addAll(citlQueueList);
        //End
        List<Group> queueNameList =  SPEN_CaseSelector.getQueueDetailList(queueValues);*///check - soql 201
        Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();
        Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
        Id CaseRecordUnplannedFltId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
        Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
        //BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();//check - soql 201
        Datetime statusChangeDate = system.now();
        //Code Implementation Ends here . User Story : CRMD-5382 & 5384. Date : 05/17/2023. Developer : Sheker
        Map<Id, Integer> premiseIdEnergisedMPANCount = new Map<Id, Integer>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
        Id NFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
	    Set<String> PostCodeSet = new Set<String>();//CRMD-9191
        String connectionRecTypeLabel=System.Label.SPEN_ConnectionsRecordType;//User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay 
        List <Case> lstConCaseUpd = new List<Case>();//User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay 
        List <Case> lstConCaseUpdPayDec = new List<Case>();//Code Implementation . User Story : CRMD-8296. Date : 05/10/2023. Developer : Akshay 
        //List<Id> lstCreateQAS = new List <Id>(); //User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay 
        List <Id> lstConIdLst = new List<Id>();
        List<Case> caseConLstAddr = new List<Case>();//User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay
        List<Case> caseConDesignQueueList = new List<Case>();//User Story : CRMD-5572. Date : 20/07. Developer : Amrita
        List<Id> lstTransferQAS = new List<Id>(); // User Story : CRMD-6888. Date : 24/07/2023. Developer : Rajat
        String transferQAS = 'TRANSFER_QAS'; // User Story : CRMD-6888. Date : 24/07/2023. Developer : Rajat
        List<Case> caseForInformationStatusList = new List<Case>();//User Story : CRMD-6828. Date : 27/07. Developer : Amrita
        List<Id> lstCancelQAS = new List<Id>(); // User Story : CRMD-6038. Date : 28/07/2023. Developer : Rajat
        String cancelQAS = 'CANCEL_QAS'; // User Story : CRMD-6038. Date : 28/07/2023. Developer : Rajat
        //formula limit - START
        Set<Id> byPassCaseIdSet = new Set<Id>();
        Set<Id> nonByPassPremiseIdSet = new Set<Id>();
        Set<Id> incidentIdSetForCaseUpdate = new Set<Id>();
        Set<Id> queryCaseIdSet = new Set<Id>();
        //formula limit - END
        List<Case> listOfCase = new List<Case>(); // User Story : CRMD-1342 Date : 18/10/2023. Developer : Amrita
        Set<Id> caseIdSet = new Set<Id>(); // User Story : CRMD-1342 Date : 18/10/2023. Developer : Amrita
        //User Story : CRMD-5368 : Rajat 
        Set<String> caseConnectionStatus = new Set<String>(System.label.SPEN_ConnCaseStatus.trim().split(','));
        //CRMD-6033 : Rajat
        Id recordTypeIdConnectionReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId();
        set<id> nGSESOAccIdSet = new Set<id>(); // 27/11/2023 .Developer - Amrita
        // String profileId = [Select Id,Name from Profile where Name = 'SPEN Integration'].Id; //check - soql 201
        //CRMD-9891
        Set<String> transmissionProfileIds = new Set<String>(System.label.SPEN_TransmissionProfileIDs.trim().split(','));
        Id recordTypeIdPreApplication = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CasePreApplication').getRecordTypeId();
String ownerOldIDStringVal = NULL;//CRMD-10128
        String ownerNewIDStringVal = NULL;//CRMD-10128
        //check - soql 201 - S
        List<Case> caseBypassList = new List<Case>();
        List<SPEN_PostCodeMDM__c> pdmList =new List<SPEN_PostCodeMDM__c>();
        Map<Id,SPEN_Premise__c> PremiseMap = new Map<Id,SPEN_Premise__c>();
        Map<Id,Case> ParentCase3PD = new Map<Id,Case>();
        List<Account> accountList = new List<Account>();
         Map<String,SPEn_PostcodeMDM__c> postcodeMDMMap = new Map<String,SPEn_PostcodeMDM__c> ();
        //check - soql 201 - E
        try{
           
            //if(!queueNameList.isEmpty())//201
             if(!queueNameList1.isEmpty())//201
            {
                for(Group queueName : queueNameList1){//201
                mapDevNamevsId.put(queueName.DeveloperName,queueName.Id);
                }
            }
            if(!cseMapNewVal.isEmpty()){
                for(Case cse: cseMapNewVal)
                {
                    //formula limit - START
                    Case csOldVal = cseMapOldVal.get(cse.Id);
//CRMD-10128 - Start
                    ownerOldIDStringVal = String.valueOf(csOldVal.ownerId);
                    ownerNewIDStringVal = String.valueOf(cse.ownerId);
                    if(cse.recordtypeId == recordTypeIdGE && cse.ownerId != csOldVal.ownerId &&
                       ownerOldIDStringVal.startswith('005') && ownerNewIDStringVal.startswith('00G') &&  csOldVal.Status == 'Created')
                    {
                        cse.Status = 'Assigned';
                    }
//CRMD-10627 - Start
                    if((cse.recordtypeId == recordTypeIdGE || cse.recordtypeId == recordTypeIdSI || cse.recordtypeId == recordTypeIdLCT) && cse.Status == 'With Partner')
                    {
                        cse.SPEN_PartnerAssignmentTime__c = System.now();
                    }
                    //CRMD-10627 - End
                    //CRMD-10128 - End
                    if(cse.recordtypeId == recordTypeIdQuery && cse.ParentId != csOldVal.ParentId)
                    {
                        queryCaseIdSet.add(cse.parentId);
                    }
                    if((cse.recordtypeID == recordTypeId3PD || cse.RecordTypeId == recordTypeIdNRSWA) && cse.SPEN_incident__c != csOldVal.SPEN_Incident__c && cse.SPEN_incident__c!=null)
                    {
                        incidentIdSetForCaseUpdate.add(cse.SPEN_Incident__c);
                    }
                    if(cse.SPEN_bypass__c && ((csOldVal.SPEN_BYPASSFlatNumber__c != cse.SPEN_BYPASSFlatNumber__c)|| 
                                              (csOldVal.SPEN_BYPASSPremiseNumber__c != cse.SPEN_BYPASSPremiseNumber__c) ||
                                              (csOldVal.SPEN_BYPASSPremiseName__c != cse.SPEN_BYPASSPremiseName__c) ||
                                               (csOldVal.SPEN_BYPASSStreet__c != cse.SPEN_BYPASSStreet__c) ||
                                               (csOldVal.SPEN_BYPASSArea__c != cse.SPEN_BYPASSArea__c) ||
                                               (csOldVal.SPEN_Town_PowerOnFormula__c != cse.SPEN_Town_PowerOnFormula__c) ||
                                               (csOldVal.SPEN_BYPASSPostCode__c != cse.SPEN_BYPASSPostCode__c) ||
                                               (csOldVal.SPEN_BYPASSSiteNumber__c != cse.SPEN_BYPASSSiteNumber__c) ||
                                              (csOldVal.SPEN_OperatingZonePowerOnFormula__c != cse.SPEN_OperatingZonePowerOnFormula__c) 
                                             ))
                    {
                        byPassCaseIdSet.add(cse.Id);
                        //CRMD-9191 - start
                        if(csOldVal.SPEN_BYPASSPostCode__c != cse.SPEN_BYPASSPostCode__c)
                        {
                            PostCodeSet.add(cse.SPEN_BYPASSPostCode__c);
                        }
                        //CRMD-9191 - end
                    }
                    else if(!cse.SPEN_Bypass__c && csOldVal.SPEN_AddressPremise__c != cse.SPEN_AddressPremise__c)
                    {
                        nonBypassPremiseIdSet.add(cse.SPEN_AddressPremise__c);
                    }
                }
                if(!incidentIdSetForCaseUpdate.isEmpty())//check - soql 201 
                {
                afterInsertIncidentMap = new Map<Id,Incident>([SELECT Id,SPEN_IncidentReference__c,SPEN_SPDSPM__c,SPEN_District__c,createddate from Incident where Id IN:incidentIdSetForCaseUpdate]);
            }
            if(!bypassCaseIdSet.isEmpty())//check - soql 201 
            {
                 caseBypassList = new List<Case>([Select Id,SPEN_Bypass__c,createddate,SPEN_BYPASSFlatNumber__c,SPEN_BYPASSPremiseNumber__c,SPEN_BYPASSPremiseName__c,
                                                            SPEN_BYPASSStreet__c,SPEN_BYPASSArea__c,SPEN_Town_PowerOnFormula__c,SPEN_BYPASSPostCode__c,SPEN_AddressPremise__c,
                                                            SPEN_BYPASSSiteNumber__c,SPEN_OperatingZonePowerOnFormula__c,SPEN_AddressPremise__r.SPEN_FullAddress__c from Case where Id IN:bypassCaseIdSet]);
            }
                //CRMD-9191 - start
                //if()
                if(!PostCodeSet.isEmpty())//check - soql 201 
                {
                    pdmList = new List<SPEN_PostCodeMDM__c>([SELECT Id, SPEN_LocalAuthority__c,SPEN_PostCode__c,SPEN_LSOA__c FROM SPEN_PostCodeMDM__c where SPEN_PostCode__c in:PostCodeSet]);
                
                for(SPEn_PostcodeMDM__c postCode:pdmList)
                {
                    postcodeMDMMap.put(postCode.SPEN_PostCode__c,postCode);
                }
                }//201 
                if(!nonBypassPremiseIdSet.isEmpty())//check - soql 201 
                {
                    PremiseMap = new Map<Id,SPEN_Premise__c>([Select Id,SPEN_FullAddress__c,Local_Authority__c,SPEN_LSOA__c from SPEN_Premise__c where Id IN:nonBypassPremiseIdSet]);//CRMD-9191 LA added
                }
                //CRMD-9191 END
                //9411- start
                //List<Group> highQueues = [select Id,name from Group where  Type = 'Queue' and name like '%high%'];//check -soql 201 
                Set<String> highQueueNameSet = new Set<String>();
                for(Group g:highQueues)
                {
                    highQueueNameSet.add(g.Id);
                }
                //9411 - end 
                if(!queryCaseIdSet.isEmpty())//check - soql 201 
                {
                    ParentCase3PD = new Map<Id,Case>([SELECT Id,SPEN_incidentrefFormula__c,SPEN_Incident__c from Case where ID IN:queryCaseIdSet]);
                }
                for(Case cse: cseMapNewVal){  
                     Case csOldValue = cseMapOldVal.get(cse.Id);
                    //201
                    if(!ParentCase3PD.isEmpty() && ParentCase3PD.containsKey(cse.ParentId)) // ****FOR Query Case*****
                    {
                        Case Parent3PDCase = ParentCase3PD.get(cse.ParentId);
                        cse.SPEN_IncidentRefFormula__c =Parent3PDCase.SPEN_incidentrefFormula__c;
                    }
                    //201
                    if(!afterInsertIncidentMap.isEmpty() && afterInsertIncidentMap.containsKey(cse.SPEN_Incident__c))
                    {
                        Incident inc = afterInsertIncidentMap.get(cse.SPEN_Incident__c);
                        cse.SPEN_IncidentRefFormula__c = inc.SPEN_IncidentReference__c;
                        cse.SPEN_IncidentDate__c = Date.valueOf(inc.createdDate);//CRMD-8960
                    }
                   else if(cse.recordtypeID == recordTypeId3PD && (csOldValue.SPEN_incident__c!=Null && cse.SPEN_incident__c == NULL))
                    {
                        cse.SPEN_IncidentRefFormula__c = null;
                        cse.SPEN_IncidentDate__c =null;//CRMD-8960
                    }
                     if(!caseBypassList.isEMpty())//with bypass checked
                    {
                         String fullAddress = cse.SPEN_BYPASSFlatNumber__c +' '+cse.SPEN_BYPASSPremiseNumber__c+' '+cse.SPEN_BYPASSPremiseName__c+' '+
                            cse.SPEN_BYPASSStreet__c+' '+cse.SPEN_BYPASSArea__c+' '+cse.SPEN_Town_PowerOnFormula__c+' '+cse.SPEN_BYPASSPostCode__c+' '+cse.SPEN_BYPASSSiteNumber__c+' '+
                            cse.SPEN_OperatingZonePowerOnFormula__c;
                        cse.SPEN_Bypass_FullAddress__c = fullAddress.replaceAll('null','');
                        //CRMD-9191 - Start
                        if(!postcodeMDMMap.isEMpty())
                        {
                            SPEN_PostCodeMDM__c pCode = postcodeMDMMap.get(cse.SPEN_BYPASSPostCode__c);
                            cse.SPEN_Local_Authority__c = pcode.SPEN_LocalAuthority__c;
                            //CRMD-9191 feedback - start
                            if(cse.RecordTypeId == recordTypeIdReferral)
                            {
                                cse.SPEN_LSOA__c = pcode.SPEN_LSOA__c;
                            }
                            //CRMD-9191 feedback - end
                        }
                        //CRMD-9191 - end
                    }
                    //201
                    if(!PremiseMap.isEMpty() && PremiseMap.containsKey(cse.SPEN_AddressPremise__c))
                    {
                        System.debug('Inside Final If');
                        SPEN_Premise__c premise = PremiseMap.get(cse.SPEN_AddressPremise__c);
                        cse.SPEN_Bypass_FullAddress__c = '<a href="/'+ String.valueOf(cse.SPEN_AddressPremise__c).substring(0, 15)+	'" target="_self"'+ '>' + premise.SPEN_FullAddress__c + '</a>';
                        cse.SPEN_Local_Authority__c = premise.Local_Authority__c;//CRMD-9191
                        //CRMD-9191 feedback - start
                        if(cse.RecordTypeId == recordTypeIdReferral)
                        {
                            cse.SPEN_LSOA__c = premise.SPEN_LSOA__c;
                        }
                        //CRMD-9191 feedback - end
                    }
                    //formula limit - END
                }
                for(Case cse: cseMapNewVal){
		
		            //CRMD-9891
                    if(transmissionProfileIds.contains(UserInfo.getProfileId()) && (recordTypeIdTransmission != cse.RecordTypeId && recordTypeIdPreApplication != cse.RecordTypeId)){
                        cse.addError('You cannot edit this case record.');
                    }
                    //END
                    if(recordTypeIdTransmission == cse.RecordTypeId && cseMapOldVal.get(cse.Id).SPEN_FinancialInformation__c != cse.SPEN_FinancialInformation__c && String.isNotBlank(cseMapOldVal.get(cse.Id).SPEN_FinancialInformation__c) && String.isBlank(cse.SPEN_FinancialInformation__c) && !FeatureManagement.checkPermission('SPEN_BypassTriggerCase')) 
                    {
                        cse.addError('Cannot Remove the Financial Record');
                    }
                    if(recordTypeIdTransmission == cse.RecordTypeId && cseMapOldVal.get(cse.Id).SPEN_PlanningDetails__c != cse.SPEN_PlanningDetails__c && String.isNotBlank(cseMapOldVal.get(cse.Id).SPEN_PlanningDetails__c) && String.isBlank(cse.SPEN_PlanningDetails__c) && !FeatureManagement.checkPermission('SPEN_BypassTriggerCase')) 
                    {
                        cse.addError('Cannot Remove the Planning Record');
                    }
                    if(((cse.RecordTypeId == recordTypeId || cse.RecordTypeId == recordTypeIdGE) && cse.ContactId!=cseMapOldVal.get(cse.id).ContactId && ((cseMapOldVal.get(cse.Id)).SPEN_AdditionalCaller__c == False) && cse.SPEN_AdditionalCaller__c == False) /*||
                    cse.RecordTypeId == recordTypeIdGE && cse.ContactId!=cseMapOldVal.get(cse.id).ContactId*/)//CRMD-10129 //CRMD-10770
                    {
                        conIds.add(cse.ContactId);
                    }
                    if(cse.SPEN_Incident__c!=cseMapOldVal.get(cse.id).SPEN_Incident__c){
                        cse.SPEN_INCChangeTime__c=System.now();
                    }
                    if(cse.Origin != 'Web' && cse.recordTypeId != recordTypeIdReferral)
                    {
                        if((cse.SPEN_AddressPremise__c!= Null || cse.SPEN_AddressPremise__c!= '') && cse.SPEN_AddressPremise__c!=cseMapOldVal.get(cse.id).SPEN_AddressPremise__c)
                        {
                            prmIds.add(cse.SPEN_AddressPremise__c);
                        }
                        // CRMD-5320 IVR Case to contact update
                           if('IVR'.equalsIgnoreCase(cse.Origin) && cse.SPEN_CallerMobileTelephone__c!=null && cseMapOldVal.get(cse.id).SPEN_CallerMobileTelephone__c!= cse.SPEN_CallerMobileTelephone__c){
                         cse.SPEN_CallerMobileTelephone__c=cse.SPEN_CallerMobileTelephone__c;
                         cse.SPEN_CallerTelephone__c = cse.SPEN_CallerMobileTelephone__c; 
                      }
             else if('IVR'.equalsIgnoreCase(cse.Origin) && cse.SPEN_CallerTelephone__c!=null  && cseMapOldVal.get(cse.id).SPEN_CallerTelephone__c!= cse.SPEN_CallerTelephone__c){
                      cse.SPEN_CallerTelephone__c = cse.SPEN_CallerTelephone__c;
                     }                        
                    }
                     //NF: logic to update Entitlement Start time = NF SLA Clock
                    if(cse.RecordTypeId == NFRecordTypeId && cse.SPEN_NeutralFaultSLAClockStart__c != null && cse.SPEN_NeutralFaultSLAClockStart__c != cseMapOldVal.get(cse.id).SPEN_NeutralFaultSLAClockStart__c)
                    {
                        cse.SlaStartDate = cse.SPEN_NeutralFaultSLAClockStart__c;
                    }
                    //CRMD-8398 bug - start
                    //Admin user bypass check - CRMD 9072
                    if(//!(cse.LastModifiedById == modifiedUser[0].Id) &&
                        !(UserInfo.getUserName() == System.label.SPEN_AdminUser) &&
                       (//cse.recordtypeid == recordTypeId3PD || //CRMD-9029
                        (cse.recordtypeid == recordTypeIdQuery && cse.SPEN_Type__c == 'Third Party Damage') || //CRMD-9029
                        cse.recordtypeid == recordTypeIdNRSWA || (cse.recordtypeid == recordTypeIdQuery && cse.SPEN_Type__c == 'NRSWA') ||
                        cse.recordtypeid == recordTypeIdSW ||(cse.recordtypeid == recordTypeIdQuery && cse.SPEN_Type__c == 'StreetWorks'))
                       && (cse.ownerId != cseMapOldVal.get(cse.id).ownerId)
                       && !(cse.status.equalsIgnoreCase('Closed'))//CRMD-9029
                    )
                    {
                        String ownerIDInString = String.valueOf(cseMapOldVal.get(cse.id).ownerId);
                        //if(found == False && caseRec.Reassignment_Reason__c == NULL)
                        if(ownerIDInString.startswith('00Q'))
                        {
                            if(cse.Reassignment_Reason__c == NULL && cse.SPEN_Transaction_Count__c> 0 )
                            {                               
                                if(!highQueueNameSet.contains(cseMapOldVal.get(cse.id).ownerId))//9411
                                {
                                cse.Reassignment_Reason__c.addError('Please provide a Reassignment Reason before changing the owner');
				}
                            }
                             cse.SPEN_Transaction_Count__c = cse.SPEN_Transaction_Count__c+1;
                        }
                        else
                        {
                            if(cse.Reassignment_Reason__c == NULL && cse.SPEN_Transaction_Count__c> 0)
                            {

                                if(!highQueueNameSet.contains(cseMapOldVal.get(cse.id).ownerId))//9411
                                {
					cse.Reassignment_Reason__c.addError('Please provide a Reassignment Reason before changing the owner');
				}
                            }
                            cse.SPEN_Transaction_Count__c = cse.SPEN_Transaction_Count__c+1;
                        }
                       
                    }
                    //CRMD-8398 bug - end
                   //Code Implementation Starts here . User Story : CRMD-5382, 5384, 5381 and 5385. Date : 05/17/2023. Developer : Sheker
                   //Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();
                   //Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                    if((cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly) && !FeatureManagement.checkPermission('SPEN_BypassTriggerCase')){
                        //CRMD-9805
                        String queueDevName = getQueueBasedOnDistrict(cse.SPEN_ConnectionDistrict__c,cse.SPEN_CompanyID__c);
                        
                        //End
                        if((cseMapOldVal.get(cse.id).Status == 'Budget Enquiry' || cseMapOldVal.get(cse.id).Status == 'Information Enquiry'|| 
                            cseMapOldVal.get(cse.id).Status == 'Formal Enquiry') && 
                           (CasesConstants.Case_Design.equals(cse.Status) || CasesConstants.CASE_BUDGETDESIGN.equals(cse.Status))){
                            cse.SPEN_InformationStatus__c = 'Pre-Check Required';
                        }else if(CasesConstants.Case_Design.equals(cse.Status) || CasesConstants.CASE_BUDGETDESIGN.equals(cse.Status)){
                            caseForInformationStatusList.add(cse);
                        }
                        if(cse.SPEN_SAPStatus__c != null && cse.SPEN_SAPStatus__c != (cseMapOldVal.get(cse.Id)).SPEN_SAPStatus__c) {
                            
                            if(CasesConstants.CASE_SAPSTATUACANA.equalsIgnoreCase(cse.SPEN_SAPStatus__c) || CasesConstants.CASE_SAPSTATUACANB.equalsIgnoreCase(cse.SPEN_SAPStatus__c)){// CRMD-920
                                cse.Status = CasesConstants.Case_Cancelled; // CRMD-920
                            }else if(CasesConstants.CASE_SAPSTATUSPECA.equalsIgnoreCase(cse.SPEN_SAPStatus__c)){// CRMD-9238
                                cse.Status = CasesConstants.CASE_QUOTEISSUEDAWAITINGACCEPTANCE; // CRMD-9238
                                cse.SPEN_SubStatus__c = CasesConstants.CASE_QUOTEVALID;
                            }else if(!mapDevNamevsId.isEmpty() && cse.SPEN_SAPStatus__c != null && System.Label.SPEN_SAPStatusDeliveryWrokPlann.contains(cse.SPEN_SAPStatus__c)){// CRMD-9238 and CRMD-9830 //201
                                cse.Status = CasesConstants.Case_DeliveryWorkPlanning; // CRMD-9238
                                cse.SPEN_SubStatus__c = CasesConstants.CASE_GSCALLREQUIREDSUBSTATUS;
                                //CRMD-9805
                                cse.OwnerId = mapDevNamevsId.get(queueDevName);
                                
                                //End
                            }else if(CasesConstants.CASE_SAPSTATUSBESE.equalsIgnoreCase(cse.SPEN_SAPStatus__c)){// CRMD-9238
                                cse.Status = CasesConstants.CASE_STATUSBUDGETISSUEDCUSTACC; // CRMD-9238
                                cse.SPEN_SubStatus__c = CasesConstants.CASE_QUOTEVALID;
                            }
                        }
                       if(cse.Status != (cseMapOldVal.get(cse.Id)).Status){
                            cse.SPEN_LastStatus__c = (cseMapOldVal.get(cse.Id)).Status;
                            //CRMD-8791
                            if(UserInfo.getProfileId() != profileId && 'Cancelled'.equals((cseMapOldVal.get(cse.Id)).Status)){
                                cse.addError('You cannot change the status once a case has been cancelled.');
                            }
                            //CRMD-6033
                            if((caseConnectionStatus.contains(cse.Status) ||
                               'Cancelled'.equals(cse.Status)) && cse.RecordTypeId != recordTypeIdBudget){ //SFAMS-662: Added the recordtype condition
                                   cse.RecordTypeId = recordTypeIdConnectionReadOnly;
                               }
                            //END
                            //CRMD-6038
                            if(UserInfo.getProfileId() != profileId && 'Cancelled'.equals(cse.Status)){
                                
                                //CRMD-5368 : Rajat
                                if(UserInfo.getProfileId() != profileId && (caseConnectionStatus.contains((cseMapOldVal.get(cse.Id)).Status) ||
                                   ((CasesConstants.Case_Design.equals((cseMapOldVal.get(cse.Id)).Status) || 
                                     CasesConstants.CASE_BUDGETDESIGN.equals((cseMapOldVal.get(cse.Id)).Status)) &&
                                    CasesConstants.CASE_COMPETENT.equals((cseMapOldVal.get(cse.Id)).SPEN_SubStatus__c)))){
                                        cse.addError('You cannot change the status to Cancelled post Design and Competent');
                                }else{
                                    lstCancelQAS.add(cse.Id);
                                }
                                //END
                            }
                            //END
                            //CRMD-8316
                            if(UserInfo.getProfileId() != profileId && String.isBlank(cse.SPEN_SAPReference__c) && (CasesConstants.Case_Design.equals(cse.Status) || CasesConstants.CASE_BUDGETDESIGN.equals(cse.Status))){
                                cse.addError('You cannot change the status to Design/Budget Design without syncing the case with SAP.');
                            }
                            //END
                            if(cse.Status == CasesConstants.Case_Design || cse.Status == CasesConstants.CASE_BUDGETDESIGN){
                               // listOfCaseId.add(cse.id); //7110
                                
                                cse.SPEN_SubStatus__c = CasesConstants.CASE_NOTCOMPETENT;
                                //Code Implementation Starts here . User Story : CRMD-1325 Date : 25/7/2023. Developer: Rohit C
                                if(!mapDevNamevsId.isEmpty())//201
                                {
                                if( cse.SPEN_DesignType__c == CasesConstants.CASE_DESIGNTYPEFIXED)
                                {
                                    cse.OwnerId = mapDevNamevsId.get(CasesConstants.CASE_CONTACTTEAMFIXEDPRICEQUOTATIONS);
                                }
                                //Code Implementation Ends here . User Story : CRMD-1325 Date : 25/7/2023. Developer: Rohit C
                                else
                                {
                                    cse.OwnerId = mapDevNamevsId.get(CasesConstants.Case_SPEN_DesignTeam);                               
                                    caseConDesignQueueList.add(cse);
                                    
                                }
                                }
                            }//CRMD-1389 : 12/09/23 : Rajat Verma//201
                            else if(!mapDevNamevsId.isEmpty() && CasesConstants.CASE_QUOTEISSUEDAWAITINGACCEPTANCE.equalsIgnoreCase(cse.Status) && 
                                    CasesConstants.CASE_DESIGNTYPEFIXED.equalsIgnoreCase(cse.SPEN_DesignType__c)){
                                        cse.OwnerId = mapDevNamevsId.get(CasesConstants.CASE_CONTACTTEAMFIXEDPRICEQUOTEISSUED); 
                                    }
                            if(CasesConstants.Case_DeliveryWorkPlanning.equalsIgnoreCase(cse.Status) && 
                               CasesConstants.CASE_GSCALLREQUIREDSUBSTATUS.equalsIgnoreCase(cse.SPEN_SubStatus__c)){
                                   listOfCase.add(cse);
                                   caseIdSet.add(cse.id);
                               }
                            
                            //END
                            //else if(cse.Status == CasesConstants.Case_Acceptance && cse.SPEN_SubStatus__c == null){
                            //    cse.OwnerId = mapDevNamevsId.get(CasesConstants.Case_SPEN_AcceptanceTeam);
                            //} 
                            //else if(cse.Status == CasesConstants.Case_DeliveryWorkPlanning && cse.SPEN_SubStatus__c == null){
                            //    cse.OwnerId = mapDevNamevsId.get(CasesConstants.Case_SPEN_CITLTeam);
                            //} 
                        }

                        //Code Implementation Starts here. User Story : CRMD-920 Date : 18/9/2023. Developer: Rohit C
                        //201
                        if(!mapDevNamevsId.isEmpty() && cse.SPEN_InformationStatus__c != (cseMapOldVal.get(cse.Id)).SPEN_InformationStatus__c  && cse.Status == CasesConstants.Case_Acceptance && cse.SPEN_SubStatus__c == CasesConstants.CASE_PAIDNOTACCEPTED && cse.SPEN_InformationStatus__c == CasesConstants.CASE_REFUNDREQUIRED){
                            cse.OwnerId = mapDevNamevsId.get(CasesConstants.CASE_ACCEPTANCECANCELLATIONINPROCESS);
                        }  
                        //Code Implementation Ends here. User Story : CRMD-920 Date : 18/9/2023. Developer: Rohit C
                       if(cse.SPEN_SubStatus__c != (cseMapOldVal.get(cse.Id)).SPEN_SubStatus__c){
                            if(!mapDevNamevsId.isEmpty())//201
                            {
                           if(cse.SPEN_SubStatus__c == CasesConstants.Case_WelcomePackSent || cse.SPEN_SubStatus__c == CasesConstants.Case_AwaitingInfo){
                               System.debug('mapDevNamevsId***'+mapDevNamevsId);
                               cse.OwnerId = mapDevNamevsId.get(CasesConstants.Case_SPEN_CTAI);
                           }
                           else if(cse.SPEN_SubStatus__c == CasesConstants.Case_InfoReceived){
                               cse.OwnerId = mapDevNamevsId.get(CasesConstants.Case_SPEN_CTEE);
                            }//CRMD-1389 : Rajat Verma
                            else if(CasesConstants.CASE_ACCEPTEDANDPAID.equalsIgnoreCase(cse.SPEN_SubStatus__c) &&
                                    CasesConstants.CASE_DESIGNTYPEFIXED.equalsIgnoreCase(cse.SPEN_DesignType__c)){
                                        cse.OwnerId = mapDevNamevsId.get(CasesConstants.CASE_ACCEPTANCEFIXEDPRICEQUOTATION);
                                    }
                            }//201
                            //END
                            //CRMD-6888 : Developer : Rajat
                            if(CasesConstants.Case_Design.equals(cse.Status) || CasesConstants.CASE_BUDGETDESIGN.equals(cse.Status)){
                                //CRMD-6699 : Developer : Rajat : Restrict Case Sub Status change as Competent
                                if(UserInfo.getProfileId() != profileId && String.isNotBlank(cse.SPEN_SubStatus__c) && !cse.SPEN_Is_Case_Competent__c &&
                                   (cse.SPEN_SubStatus__c != (cseMapOldVal.get(cse.Id)).SPEN_SubStatus__c) &&
                                   CasesConstants.CASE_NOTCOMPETENT.equals((cseMapOldVal.get(cse.Id)).SPEN_SubStatus__c) &&
                                   'Competent'.equals(cse.SPEN_SubStatus__c)){
                                       cse.addError('You cannot change the sub status to Competent, please use Confirm Competency button.');
                                   }     
                                //END
                                if(UserInfo.getProfileId() != profileId && CasesConstants.CASE_COMPETENT.equals(cse.SPEN_SubStatus__c)){
                                    lstTransferQAS.add(cse.Id);
                                }
                            }
                            //END CRMD-6888
                        }
                       if(cse.Status != (cseMapOldVal.get(cse.Id)).Status || cse.SPEN_SubStatus__c != (cseMapOldVal.get(cse.Id)).SPEN_SubStatus__c){
                        cse.SPEN_LastStatusChange__c = system.now();
                        statusChangeDate =cse.SPEN_LastStatusChange__c;
                        if(cse.SPEN_SubStatus__c =='Welcome Pack Sent'){
                            
                            cse.SPEN_CaseStatusChange7Days__c = Cases.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser7));
                            cse.SPEN_CaseStatusChange14Days__c = Cases.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser14));
                            cse.SPEN_CaseStatusChange21Days__c = Cases.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser21));
                            
                        }
                        else if(cse.SPEN_SubStatus__c =='Awaiting Info'){
                            
                            cse.SPEN_CaseSubStatusAwaitingInfo7Days__c = Cases.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser7));
                            cse.SPEN_CaseSubStatusAwaitingInfo14Days__c = Cases.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser14));
                            cse.SPEN_CaseSubStatusAwaitingInfo21Days__c = Cases.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser21));
                            //cse.SPEN_CaseStatusChange7Days__c = SPEN_CasesConnectionService.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser7));
                            //cse.SPEN_CaseStatusChange14Days__c = SPEN_CasesConnectionService.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser14));
                            //cse.SPEN_CaseStatusChange21Days__c = SPEN_CasesConnectionService.getWorkingDays(bh.Id, statusChangeDate, Long.valueOf(System.label.SPEN_StopChaser21));
                        }
                    } //Code Implementation ends here. User Story : CRMD-5762. Date : 06/14/2023. Developer : sheker
                   }//Code Implementation Ends here . User Story : CRMD-5382, 5384, 5381 and 5385. Date : 05/17/2023. Developer : Sheker
                    //Code Implementation Starts here . User Story : CRMD-6082. Date : 08/06/2023. Developer : Akshay
                    String conCaseRecTypeName=((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosById().get(cse.RecordTypeId).getDeveloperName();                    
                    /*if(connectionRecTypeLabel != null && connectionRecTypeLabel.containsignorecase(conCaseRecTypeName) && cse.status == 'Information Enquiry' && cseMapOldVal.get(cse.id).status!='Information Enquiry')
                    {
                    lstCreateQAS.add(cse.id);                        
                    }*/
                    //Code Implementation Ends here . User Story : CRMD-6082. Date : 08/06/2023. Developer : Akshay
                    //Code Implementation Starts here . User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay
                    
                    if(connectionRecTypeLabel != null && connectionRecTypeLabel.containsignorecase(conCaseRecTypeName) && !FeatureManagement.checkPermission('SPEN_BypassTriggerCase'))
                    {
                        
                        if(cse.Id != null && (cse.SPEN_JobType__c != cseMapOldVal.get(cse.Id).SPEN_JobType__c || cse.SPEN_QuotationType__c != cseMapOldVal.get(cse.Id).SPEN_QuotationType__c || cse.SPEN_CustomerClass__c != cseMapOldVal.get(cse.Id).SPEN_CustomerClass__c || cse.SPEN_RequiredPhase__c != cseMapOldVal.get(cse.Id).SPEN_RequiredPhase__c || cse.SPEN_POCVoltage__c != cseMapOldVal.get(cse.Id).SPEN_POCVoltage__c || cse.SPEN_MeteringVoltage__c != cseMapOldVal.get(cse.Id).SPEN_MeteringVoltage__c || cse.SPEN_TotalPlots__c != cseMapOldVal.get(cse.Id).SPEN_TotalPlots__c || cse.SPEN_RequiredPower__c != cseMapOldVal.get(cse.Id).SPEN_RequiredPower__c ))
                        {
                            lstConCaseUpd.add(cse);
                        }

                        if(!string.isBlank(cse.SPEN_PaymentDecision__c) && cse.SPEN_PaymentDecision__c != cseMapOldVal.get(cse.Id).SPEN_PaymentDecision__c)
                        {
                            lstConCaseUpdPayDec.add(cse);
                        }
                        
                        if(cse.ContactId != null && cse.ContactId != cseMapOldVal.get(cse.Id).ContactId)
                        {
                            caseConLstAddr.add(cse);//Code Implementation . User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay 
                            lstConIdLst.add(cse.ContactId);
                        } 
                        if(cse.SPEN_OfgemMarketSegment__c == 'LVSSA')
                        {
                            cse.SPEN_CaseNeedsActionTillDate__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_LVSSACaseNeedsActionBeforeDays));
                        }
                        else if(cse.SPEN_OfgemMarketSegment__c == 'LVSSB')
                        {
                            cse.SPEN_CaseNeedsActionTillDate__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_LVSSBCaseNeedsActionBeforeDays));
                        }
                    
                    
                    }
                    if(recordTypeIdTransmission == cse.RecordTypeId && cse.SPEN_NGESOCCMAccount__c != null && cse.SPEN_NGESOCCMAccount__c != cseMapOldVal.get(cse.Id).SPEN_NGESOCCMAccount__c && !FeatureManagement.checkPermission('SPEN_BypassTriggerCase')){
                        nGSESOAccIdSet.add(cse.SPEN_NGESOCCMAccount__c);
                    }
                   /** if(cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal){//CRMD-2625
                        if(cse.SPEN_PausedStatus__c != null && cse.SPEN_PausedStatus__c != cseMapOldVal.get(cse.Id).SPEN_PausedStatus__c
                           && cse.SPEN_PausedStatus__c == 'Yes'){
                               cse.SPEN_3DaysTaskCreationForOwner__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_FirstReminderFor3Days));
                               cse.SPEN_6DaysTaskCreationForOwner__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_SecondReminderFor6dyas));
                               cse.SPEN_9DaysTaskCreationForOwner__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_FinalReminderFor9days));
                           }
                    }**/
                    
                }
                /*if(!lstCreateQAS.isEmpty())
{
SPEN_SAPQASCallout.sendSoapCallout('CREATE_QAS',lstCreateQAS); 
}*/
                //CRMD-6888 : Developer : Rajat
                if(!lstTransferQAS.isEmpty())
                {
                    SPEN_SAPQASCallout.sendSoapCallout(transferQAS,lstTransferQAS); 
                }
                //END
                //CRMD-6038 : Developer : Rajat
                if(!lstCancelQAS.isEmpty()){
                    SPEN_SAPQASCallout.sendSoapCallout(cancelQAS,lstCancelQAS); 
                }
                //END
                if(!lstConCaseUpd.isEmpty())
                {
                    
                    SPEN_CasesConnectionService.updateBMSOMS(lstConCaseUpd);
                }//Code Implementation Ends here . User Story : CRMD-5720. Date : 06/05/2023. Developer : Akshay 
                
                if(!lstConCaseUpdPayDec.isEmpty())
                {
                    SPEN_CasesConnectionService.updatePaymentDecision(lstConCaseUpdPayDec);//Code Implementation . User Story : CRMD-8296. Date : 05/10/2023. Developer : Akshay 
                }
                if(!caseConLstAddr.isEmpty())
                {
                    SPEN_CasesConnectionService.updateAddressInfo(caseConLstAddr,lstConIdLst);//Code Implementation . User Story : CRMD-6084. Date : 26Jun23. Developer : Akshay 
                }

                if(!prmIds.isEmpty())//check - soql 201 
                {
                    premiseIdEnergisedMPANCount = SPEN_PremiseSelector.getPremiseEnergisedMPANCount(prmIds);
                }
                
                for(Case cse: cseMapNewVal)
                {
                    if (!premiseIdEnergisedMPANCount.isEmpty() && premiseIdEnergisedMPANCount.containsKey(cse.SPEN_AddressPremise__c) && premiseIdEnergisedMPANCount.get(cse.SPEN_AddressPremise__c) == 0 && cse.RecordTypeId == CaseRecordUnplannedFltId)
                    {
                        cse.addError('Case cannot be created as there are no Energised MPAN exist for the selected Premise');
                    }        
                }
            }
            
            if(!conIds.isEmpty())
            {
                custInfoMap = SPEN_ContactSelector.contactRecord(conIds);
            }
            
            if(custInfoMap.size()>0){
                populateCallerInfo(custInfoMap,cseMapNewVal);
            }         
            if(!caseForInformationStatusList.isEmpty() && caseForInformationStatusList.size() > 0 ){
                caseUpateWithInformationStatus(caseForInformationStatusList);
            }
            if(!caseConDesignQueueList.isEmpty() && caseConDesignQueueList.size() > 0){
                caseUpateWithDesignQueue(caseConDesignQueueList);
            }
            
            if(!listOfCase.isEmpty() && listOfCase.size() > 0){//CRMD-1342
               updateCaseGSDueDateForPostAccp(listOfCase,caseIdSet);
            }
            if(nGSESOAccIdSet != null && nGSESOAccIdSet.size()> 0){
                Map<Id,String> accutMap =  new MAp<Id,String>();
                if(!nGSESOAccIdSet.isEmpty())//check - soql 201
                {
                    accountList = [Select id, SPEN_PartnerEmailaddress__c from Account where id IN : nGSESOAccIdSet];
                    
              
                for(Account accntRec : accountList){
                    accutMap.put(accntRec.id,accntRec.SPEN_PartnerEmailaddress__c);
                }
                 for(Case cse: cseMapNewVal){
                     if(accutMap != null && accutMap.size()>0 && accutMap.containsKey(cse.SPEN_NGESOCCMAccount__c)){
                         cse.SPEN_AccountEmail__c = accutMap.get(cse.SPEN_NGESOCCMAccount__c);
                        }
                     }
                 }                
            }
            if(caseNewMap.get(recordTypeId) != null &&  ((Case)(caseNewMap.get(recordTypeId))).SPEN_Incident__c=='NULL'){
                caseNewMap.get(recordTypeId).addError('SPEN_CancelledStatusValidation'); 
            }
            
        }catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
    /*************************************************************************
@Author: Smita Raikar
@Date: 14/12/22
@purpose: When town lookup changes, auto-populate zone lookup on case Update
*************************************************************************************/
    public static void caseUpdateZoneValue(Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap)
    {
        List<Case> cseMapNewVal = (List<Case>)caseNewMap.values(); 
        Map<Id,case> cseMapOldVal = (Map<Id,case>)caseOldMap;
        
        Set<Id> premId = new Set<Id>();
        Map<id,SPEN_Premise__c > premiseMap = new Map<id, SPEN_Premise__c>(); 

        Set<Id> zoneId = new Set<Id>();
        Map<id, id> zoneMap = new Map<id, id>();
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedBypass).getRecordTypeId();
        Id recordTypeIdComplaints = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
        Id CNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();//430
        Id recordTypeIdGS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
       	Id recordTypeNF = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
        
        try
        {
            if(!cseMapNewVal.isEmpty())
            {
                for(Case cse: cseMapNewVal)
                {
                    if((cse.RecordTypeId == recordTypeId || ((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS || cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || cse.RecordTypeId == CNTRecordTypeId) && cse.SPEN_Bypass__c == true)) && cse.SPEN_Town__c!=cseMapOldVal.get(cse.id).SPEN_Town__c && cse.SPEN_Town__c != null ) //430
                    {
                        //SPEN_Zone__c zoneRecord=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where Id=:cse.SPEN_Town__c];
                        //cse.SPEN_Zone__c=zoneRecord.SPEN_Parent__c;
                        zoneId.add(cse.SPEN_Town__c);
                    }
                    else if((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS || cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || cse.RecordTypeId == CNTRecordTypeId) && cse.SPEN_AddressPremise__c!=cseMapOldVal.get(cse.id).SPEN_AddressPremise__c && cse.SPEN_AddressPremise__c != null)//430
                    {
                        premId.add(cse.SPEN_AddressPremise__c);
                    }
                }
                if(!premId.isEmpty())
                {
                    for(SPEN_Premise__c premRec : [Select Id,Name, SPEN_Zone__c from SPEN_Premise__c where ID In :premId])
                    {
                        premiseMap.put(premRec.Id, premRec);
                    }
                }
                else if(!zoneId.isEmpty())
                {
                    for(SPEN_Zone__c zoneRecord : [Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where ID In :zoneId])
                    {
                        zoneMap.put(zoneRecord.Id, zoneRecord.SPEN_Parent__c);
                    }
                }
                for(Case cse: cseMapNewVal)
                {
                    if((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS || cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || cse.RecordTypeId == CNTRecordTypeId) && cse.SPEN_AddressPremise__c != null && !premiseMap.isEmpty() && premiseMap.containsKey(cse.SPEN_AddressPremise__c))  //430
                    {
                        cse.SPEN_Zone__c = premiseMap.get(cse.SPEN_AddressPremise__c).SPEN_Zone__c;
                    }
                    else if((cse.RecordTypeId == recordTypeId || ((cse.RecordTypeId == recordTypeIdComplaints || cse.RecordTypeId == recordTypeIdGS || cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeNF || cse.RecordTypeId == CNTRecordTypeId) && cse.SPEN_Bypass__c == true)) && cse.SPEN_Town__c != null && !zoneMap.isEmpty() && zoneMap.containsKey(cse.SPEN_Town__c))  //430
                    {
                        cse.SPEN_Zone__c = zoneMap.get(cse.SPEN_Town__c);
                    }
                }
            }
            updateBusinessHours(cseMapNewVal);
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }
    /*************************************************************************
@Author: Dhara Desai
@Date: 04/10/22
@purpose: auto-populate caller fields Method for case insert and update
*************************************************************************************/
    public static void populateCallerInfo(Map<Id,Contact> custInfoMap,List<Case> caseList){
        try{
            if(caseList.size()>0){
                for(Case cse : caseList){
                    if(custInfoMap.containsKey(cse.contactId)){
                        if(cse.Origin == 'IVR' )
                        {
                        cse.SPEN_CallerInitials__c = !string.isEmpty(string.valueOf(custInfoMap.get(cse.ContactId).MiddleName)) ? string.valueOf(custInfoMap.get(cse.ContactId).MiddleName).Left(8) : '' ;
                        //cse.SPEN_CallerMobileTelephone__c = (cse.SPEN_CallerMobileTelephone__c == null)?custInfoMap.get(cse.ContactId).MobilePhone : cse.SPEN_CallerMobileTelephone__c;
                        cse.SPEN_CallerName__c = custInfoMap.get(cse.ContactId).Name;
                        //cse.SPEN_CallerTelephone__c = (cse.SPEN_CallerTelephone__c ==null) ? custInfoMap.get(cse.ContactId).Phone : cse.SPEN_CallerTelephone__c ;
                        cse.SPEN_CallerTitle__c = custInfoMap.get(cse.ContactId).Salutation;//custInfoMap.get(cse.ContactId).Suffix; 
                        }
                        /*-- Changes By Sumit for CRMD-7305 --*/
                        else if(cse.Origin == 'Phone')
                        {
                        cse.SPEN_CallerInitials__c = !string.isEmpty(string.valueOf(custInfoMap.get(cse.ContactId).MiddleName)) ? string.valueOf(custInfoMap.get(cse.ContactId).MiddleName).Left(8) : '' ;
                        cse.SPEN_CallerMobileTelephone__c = (cse.SPEN_CallerMobileTelephone__c == null) ? ((custInfoMap.get(cse.ContactId).MobilePhone== null) ? custInfoMap.get(cse.ContactId).Phone : custInfoMap.get(cse.ContactId).MobilePhone) : cse.SPEN_CallerMobileTelephone__c;
                            
                        cse.SPEN_CallerName__c = custInfoMap.get(cse.ContactId).Name;
                        cse.SPEN_CallerTelephone__c = (cse.SPEN_CallerTelephone__c ==null) ? ((custInfoMap.get(cse.ContactId).Phone == NULL) ? custInfoMap.get(cse.ContactId).MobilePhone : custInfoMap.get(cse.ContactId).Phone) : cse.SPEN_CallerTelephone__c ;
                        cse.SPEN_CallerTitle__c = custInfoMap.get(cse.ContactId).Salutation;//custInfoMap.get(cse.ContactId).Suffix;    
                        }
                        /*-- Changes By Sumit for CRMD-7305 --*/
                        else
                        {
                            if(cse.recordtypeId!=recordTypeIdGE || (cse.recordtypeId==recordTypeIdGE && Trigger.isInsert))//CRMD-10129
                            {
                                cse.SPEN_CallerInitials__c = !string.isEmpty(string.valueOf(custInfoMap.get(cse.ContactId).MiddleName)) ? string.valueOf(custInfoMap.get(cse.ContactId).MiddleName).Left(8) : '' ;
                                cse.SPEN_CallerMobileTelephone__c = (cse.SPEN_CallerMobileTelephone__c == null)?custInfoMap.get(cse.ContactId).MobilePhone : cse.SPEN_CallerMobileTelephone__c;
                                cse.SPEN_CallerName__c = custInfoMap.get(cse.ContactId).Name;
                                cse.SPEN_CallerTelephone__c = (cse.SPEN_CallerTelephone__c ==null) ? custInfoMap.get(cse.ContactId).Phone : cse.SPEN_CallerTelephone__c ;
                                cse.SPEN_CallerTitle__c = custInfoMap.get(cse.ContactId).Salutation;//custInfoMap.get(cse.ContactId).Suffix;    
                            }
                            else if(cse.recordtypeId==recordTypeIdGE && Trigger.isUpdate)
                            {
                                cse.SPEN_CallerInitials__c = !string.isEmpty(string.valueOf(custInfoMap.get(cse.ContactId).MiddleName)) ? string.valueOf(custInfoMap.get(cse.ContactId).MiddleName).Left(8) : '' ;
                                cse.SPEN_CallerMobileTelephone__c = (custInfoMap.get(cse.ContactId).MobilePhone!=null)?custInfoMap.get(cse.ContactId).MobilePhone : '';
                                cse.SPEN_CallerName__c = custInfoMap.get(cse.ContactId).Name;
                                cse.SPEN_CallerTelephone__c = (custInfoMap.get(cse.ContactId).Phone !=NULL)? custInfoMap.get(cse.ContactId).Phone : '';
                                cse.SPEN_CallerTitle__c = (custInfoMap.get(cse.ContactId).Salutation!= NULL)? custInfoMap.get(cse.ContactId).Salutation : '';  
                            
                            }
                        }
                    }
                }
            }
        }catch(exception e){
            SEL_LoggingService.log(e);
        }
    }

/*************************************************************************
@Author: Debapriya Saha
@Date: 04/10/22
@purpose: auto-populate caller fields Method for case insert and update
*************************************************************************************/
public static void afterCaseInsert(List<Case> newCreatedCaseList){
    Set<Id> setSkipRecordType = skipPoweronCallIds();
    for(Case cse : newCreatedCaseList)
    {
        if(setSkipRecordType.contains(cse.recordTypeId )){
            CaseCallouts.sendCreatedCaseToPowerOnAPI(newCreatedCaseList);
            CaseCallouts.mobileTelephoneUpdateOnContact(newCreatedCaseList, new Map<Id, Case>()); // By Rahul Kumar : CRMD-5320
        }
    }
    Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
    //Id recordTypeIdSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_SmartInterventions').getRecordTypeId();
    String caseEventType = null;
    List<Id> caseTransmissionIds = new List<Id>();
    List<Id> caseEnergizationIds = new List<Id>();//CRMD-1236
    List<Id> caseITTIssuedDateNotification = new List<Id>();//CRMD-1211
    Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();
    Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
    List<Id> listOfCaseId = new List<Id>(); // User Story : CRMD-7110. Date : 28/08/2023. Developer : Amrita
    Map<String,Id> conRefNumVsCaseMap = new Map<String,Id> (); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
    Map<String,Id> conRefNumVsCaseConReqMap = new Map<String,Id> (); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
    List<Case> lstCaseUpd = new List<Case>(); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
    List<SPEN_RelatedProject__c> relProjDel = new List<SPEN_RelatedProject__c>(); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
    List<SPEN_RelatedProject__c> relProjCloCont = new List<SPEN_RelatedProject__c>(); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
    Id recordTypeIdConnectionReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId(); //amrita for 9838
    //SFAMS-998 - By Sumit - Start
    Set<Id> caseInformationIds = new Set<Id>();
    List<SPEN_CaseInformation__c> relatedCaseInfos = new List<SPEN_CaseInformation__c>();
	//SFAMS-998 - By Sumit - End
    
    for(Case cse : newCreatedCaseList)
    {
            if(!FeatureManagement.checkPermission('SPEN_BypassTriggerCase'))
            {
                if(recordTypeIdTransmission == cse.RecordTypeId && cse.SPEN_CustomerEngagementNotes__c != null && (cse.SPEN_Stage__c == 'MTM3'||cse.SPEN_Stage__c == 'MTM4'))
                {
                    caseTransmissionIds.add(cse.id);
                }
                else if(recordTypeIdTransmission == cse.RecordTypeId  && cse.SPEN_FinalEnergisationDate__c !=NULL)
                {
                    caseEnergizationIds.add(cse.Id);
                }
                else if(recordTypeIdTransmission == cse.RecordTypeId  && cse.SPEN_ITTIssuedDate__c != NULL)
                {
                    
                    caseITTIssuedDateNotification.add(cse.Id);
                }
                else if(recordTypeIdSI == cse.RecordTypeId || recordTypeIdGE == cse.RecordTypeId ||
                    recordTypeIdBudget == cse.RecordTypeId || recordTypeIdFormal == cse.RecordTypeId || recordTypeIdConnectionReadOnly == cse.RecordTypeId)
                {
                    listOfCaseId.add(cse.Id);
                    
                }    

                if(recordTypeIdTransmission == cse.RecordTypeId && !string.isBlank(cse.SPEN_ContractReferenceNumberFormula__c) && cse.status.equalsIgnoreCase('Contracted'))// User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
                {
                    conRefNumVsCaseMap.put(cse.SPEN_ContractReferenceNumberFormula__c,cse.id);
                }

                if(recordTypeIdTransmission == cse.RecordTypeId && !string.isBlank(cse.SPEN_ContractReferenceNumberFormula__c) && ((cse.status.equalsIgnoreCase('Contract Required') && cse.SPEN_ContractReferenceNumberFormula__c.containsIgnoreCase('SPT-RI')) || cse.SPEN_ContractReferenceNumberFormula__c.containsIgnoreCase('SPT-TOCO') || cse.SPEN_ContractReferenceNumberFormula__c.containsIgnoreCase('SPT-ATOCO')))// User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
                {
                    conRefNumVsCaseConReqMap.put(cse.SPEN_ContractReferenceNumberFormula__c,cse.id);
                }
                //SFAMS-998 - By Sumit
                if (recordTypeIdSI == cse.RecordTypeId && cse.SPEN_Primary_Case_Information__c != null) 
                {
                    caseInformationIds.add(cse.SPEN_Primary_Case_Information__c);
                }
            }
    }
    //SFAMS-998 - By Sumit
    if(!caseInformationIds.isEmpty())
    {
        List<SPEN_CaseInformation__c> caseInformationList = SPEN_CaseSelector.getCaseInformationList(caseInformationIds);
        SPEN_CaseInformationTriggerHandler.calculateAndSetDates(caseInformationList);
    }

    if(!conRefNumVsCaseConReqMap.keyset().isEmpty())
    {
        for(SPEN_RelatedProject__c relProj : [Select id,SPEN_Case__c,SPEN_RelatedCase__c,SPEN_Case__r.status,SPEN_RelatedCase__r.status,SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c,SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c,SPEN_QueuePosition__c,SPEN_Relationship__c,SPEN_Stage__c,SPEN_Type__c from SPEN_RelatedProject__c where (SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseConReqMap.keyset() and SPEN_Case__r.status = 'Contracted' and SPEN_Case__c not in:conRefNumVsCaseConReqMap.values()) or (SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseConReqMap.keyset() and SPEN_RelatedCase__r.status = 'Contracted' and SPEN_RelatedCase__c not in:conRefNumVsCaseConReqMap.values())]) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        {
            if(conRefNumVsCaseConReqMap.keyset().contains(relProj.SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c) && relProj.SPEN_Case__r.status.equalsIgnoreCase('Contracted'))
            {
                SPEN_RelatedProject__c rPro = new SPEN_RelatedProject__c();
                rPro.SPEN_Case__c = conRefNumVsCaseConReqMap.get(relProj.SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c);
                rPro.SPEN_QueuePosition__c = relProj.SPEN_QueuePosition__c;
                rPro.SPEN_RelatedCase__c = relProj.SPEN_RelatedCase__c;
                rPro.SPEN_Relationship__c = relProj.SPEN_Relationship__c;
                rPro.SPEN_Stage__c = relProj.SPEN_Stage__c;
                rPro.SPEN_Type__c = relProj.SPEN_Type__c;
                relProjCloCont.add(rPro);
            }
                
            else if(conRefNumVsCaseConReqMap.keyset().contains(relProj.SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c) && relProj.SPEN_RelatedCase__r.status.equalsIgnoreCase('Contracted'))
            {
                SPEN_RelatedProject__c rPro = new SPEN_RelatedProject__c();
                rPro.SPEN_Case__c = relProj.SPEN_Case__c;
                rPro.SPEN_QueuePosition__c = relProj.SPEN_QueuePosition__c;
                rPro.SPEN_RelatedCase__c = conRefNumVsCaseConReqMap.get(relProj.SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c);
                rPro.SPEN_Relationship__c = relProj.SPEN_Relationship__c;
                rPro.SPEN_Stage__c = relProj.SPEN_Stage__c;
                rPro.SPEN_Type__c = relProj.SPEN_Type__c;
                relProjCloCont.add(rPro);
            }
        }
    }
        
    if(!conRefNumVsCaseMap.keyset().isEmpty())
    {
        for(Case cs: [Select Id,SPEN_ContractReferenceNumberFormula__c,Status from Case where SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseMap.keyset() and RecordTypeId =: recordTypeIdTransmission and id not in:conRefNumVsCaseMap.values() and status != 'Previous Contract']) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        {
            cs.Status = 'Previous Contract';   
            lstCaseUpd.add(cs);      
        }

        if(!lstCaseUpd.isEmpty()) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        {
            Update lstCaseUpd;
        }

        if(!conRefNumVsCaseMap.isEmpty())//check - soql 201
        {
        for(SPEN_RelatedProject__c relProj : [Select id,SPEN_Case__c,SPEN_RelatedCase__c,SPEN_Case__r.status,SPEN_RelatedCase__r.status from SPEN_RelatedProject__c where (SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseMap.keyset() and SPEN_Case__r.status = 'Previous Contract' and SPEN_Case__c not in:conRefNumVsCaseMap.values() and SPEN_RelatedCase__c not in:conRefNumVsCaseMap.values()) or (SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseMap.keyset() and SPEN_RelatedCase__r.status = 'Previous Contract' and SPEN_RelatedCase__c not in:conRefNumVsCaseMap.values() and SPEN_Case__c not in:conRefNumVsCaseMap.values())]) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        {
            relProjDel.add(relProj);
        }
        }
        if(!relProjDel.isEmpty())
        {
            Delete relProjDel;
        }
    }    

    if(!relProjCloCont.isEmpty())
    {
        Insert relProjCloCont;
    }

    if(!caseTransmissionIds.isEmpty())
    {
        caseEventType = 'Customer Engagement';
        updateCommunicationSchedulerRecrd(caseTransmissionIds,caseEventType);
    }
    else if(!caseEnergizationIds.isEmpty())
    {
        caseEventType = 'Energization Date';
        updateCommunicationSchedulerRecrd(caseEnergizationIds,caseEventType);
    }
    //CRMD-1211 starts here
    else if(!caseITTIssuedDateNotification.isEmpty())
    {
        caseEventType = 'ITTIssued Notification';
        updateCommunicationSchedulerRecrd(caseITTIssuedDateNotification,caseEventType);
    }          
    if(!listOfCaseId.isEmpty() && listOfCaseId.size() > 0){
        SPEN_FileUploaderConnClass.uploadFile(listOfCaseId);//CRMD-7110 Sharepoint US
    }

}
    
    public static void afterCaseUpdate(Map<Id,Case> oldUpdatedCaseMap, List<Case> newUpdatedCaseList){
        Set<Id> setSkipRecordType = skipPoweronCallIds();
        for(Case cse : newUpdatedCaseList)
        {
            if(setSkipRecordType.contains(cse.recordTypeId ) && !Cases.isScopeChangedCase) // By Shubhi V : CRMD 9236
            {
                CaseCallouts.sendUpdatedCaseToPowerOnAPI(oldUpdatedCaseMap, newUpdatedCaseList);
                CaseCallouts.sendCancelledCaseToPowerOnAPI(oldUpdatedCaseMap, newUpdatedCaseList);
                CaseCallouts.mobileTelephoneUpdateOnContact(newUpdatedCaseList,oldUpdatedCaseMap);  // By Rahul Kumar : CRMD-5320
            }
        }
        List<Case> listOfFixedCaseId = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        List<Id> caseTransmissionIds = new List<Id>();
        List<Id> caseEnergizationIds = new List<Id>();
        List<Id> caseStage1Ids = new List<Id>();
        List<Id> chaserCaseIdList = new List<Id>();
        List<Id> caseITTIssuedDateNotification = new List<Id>();
        List<Case> caseList = new List<Case>();
        Set<Id> gsDueDateCaseList = new Set<Id>();
        List<Id> finalUpdateCaseList = new List<Id>();
        Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();
        Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
        Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
        Id recordTypeIdConnectionReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId(); //amrita
        String caseEventType = null;
        //BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();  //check - soql 201
        //CRMD-9334
        Set<Id> setOwnerId = new Set<Id>();
        Map<Id,Id> caseVSDeliveryMap = new Map<Id,Id>();
        // Code for CRMD - 7748 starts here
        Map<String,Id> finacialCaseMap =  new Map<String,Id>();
        Map<String,Id> conRefNumVsCaseMap = new Map<String,Id> (); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        Map<String,Id> conRefNumVsCaseConReqMap = new Map<String,Id> (); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        List <Case> lstCaseUpd = new List<Case>(); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay   
        List<SPEN_RelatedProject__c> relProjDel = new List<SPEN_RelatedProject__c>(); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay     
        List<SPEN_RelatedProject__c> relProjCloCont = new List<SPEN_RelatedProject__c>(); // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
        Id recTypeIdGE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
        Set<Id> setCsIdSurvey = new Set<Id>();
        for(Case cse: newUpdatedCaseList){ 
            if(!FeatureManagement.checkPermission('SPEN_BypassTriggerCase'))
            {
                if(cse.Application_fee_Type__c != NULL && cse.Application_fee_Type__c == 'Fixed'  &&  recordTypeIdTransmission == cse.RecordTypeId &&
                (cse.SPEN_LocationType__c != oldUpdatedCaseMap.get(cse.Id).SPEN_LocationType__c ||
                    cse.SPEN_ContractArea__c != oldUpdatedCaseMap.get(cse.Id).SPEN_ContractArea__c ||
                    cse.Application_Stage__c != oldUpdatedCaseMap.get(cse.Id).Application_Stage__c ||
                    cse.SPEN_ApplicationType__c != oldUpdatedCaseMap.get(cse.Id).SPEN_ApplicationType__c ||
                    cse.SPEN_PrimaryTransmissionTechnologyType__c != oldUpdatedCaseMap.get(cse.Id).SPEN_PrimaryTransmissionTechnologyType__c ||
                    cse.SPEN_DemandCapacityMWs__c != oldUpdatedCaseMap.get(cse.Id).SPEN_DemandCapacityMWs__c ||
                    cse.SPEN_SizeMWsExportCEC__c != oldUpdatedCaseMap.get(cse.Id).SPEN_SizeMWsExportCEC__c))
                    
                {
                    
                    listOfFixedCaseId.add(cse); 
                }
                // 7748 ends here
                
                
                if((cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal) &&
                (cse.SPEN_PausedStatus__c != null && cse.SPEN_PausedStatus__c != oldUpdatedCaseMap.get(cse.Id).SPEN_PausedStatus__c
                    && cse.SPEN_PausedStatus__c == 'Yes' && (CasesConstants.Case_Design.equals(cse.Status) || CasesConstants.CASE_BUDGETDESIGN.equals(cse.Status)))){
                        caseIds.add(cse.id);
                        
                    }
                
                if(recordTypeIdTransmission == cse.RecordTypeId && (cse.SPEN_Stage__c == 'MTM3'||cse.SPEN_Stage__c == 'MTM4') && cse.SPEN_CustomerEngagementNotes__c != oldUpdatedCaseMap.get(cse.Id).SPEN_CustomerEngagementNotes__c)
                {
                    caseTransmissionIds.add(cse.id);
                }
                system.debug('stage4EnergisationDate>>>>>>>'+cse.SPEN_Stage4__c);
                //CRMD - 1236 starts here
                //condition to check if the Stage 4 field is updated for a transmission case
                if(recordTypeIdTransmission == cse.RecordTypeId  && cse.SPEN_FinalEnergisationDate__c != oldUpdatedCaseMap.get(cse.Id).SPEN_FinalEnergisationDate__c)
                {
                    caseEnergizationIds.add(cse.Id);
                }
                system.debug('caseEnergizationIds>>>>>>>'+caseEnergizationIds);
                
                //CRMD-1211 starts here
                //system.debug('recordTypeIdTransmission>>>>>>>>>>>>>>>>>'+recordTypeIdTransmission+'STAGE>>>>>'+cse.SPEN_Stage__c+'SPEN_Stage3__c>>>>>>>'+cse.SPEN_Stage3__c);
                if(recordTypeIdTransmission == cse.RecordTypeId && cse.SPEN_ITTIssuedDate__c != NULL && cse.SPEN_ITTIssuedDate__c != oldUpdatedCaseMap.get(cse.Id).SPEN_ITTIssuedDate__c)
                {
                    
                    caseITTIssuedDateNotification.add(cse.Id);
                }    
                system.debug('caseITTIssuedDateNotification>>>>>>'+caseITTIssuedDateNotification);
                //CRMD-1211 ends here
                //
            if((cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly) &&
             (cse.Status == 'Delivery Work Planning' || cse.Status == 'Delivery') && cse.SPEN_GSDueDate__c != null && cse.SPEN_GSDueDate__c !=  oldUpdatedCaseMap.get(cse.Id).SPEN_GSDueDate__c){
                gsDueDateCaseList.add(cse.id);
            }
            system.debug('gsDueDateCaseList**' + gsDueDateCaseList);
            //CRMD-9934
            if((cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly) &&
               cse.Status == 'Quote Issued Awaiting Cust Acceptance' && cse.SPEN_Delivery__c != null){
                   setOwnerId.add(oldUpdatedCaseMap.get(cse.Id).OwnerId);
                   caseVSDeliveryMap.put(cse.SPEN_Delivery__c,cse.Id); //Map of Delivery and Case Id 
               }
            //END
                if(recordTypeIdTransmission == cse.RecordTypeId && !string.isBlank(cse.SPEN_ContractReferenceNumberFormula__c) && cse.status != oldUpdatedCaseMap.get(cse.Id).status  && cse.status.equalsIgnoreCase('Contracted'))// User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
                {
                    conRefNumVsCaseMap.put(cse.SPEN_ContractReferenceNumberFormula__c,cse.id);
                }

                if(recordTypeIdTransmission == cse.RecordTypeId && !string.isBlank(cse.SPEN_ContractReferenceNumberFormula__c) && cse.status != oldUpdatedCaseMap.get(cse.Id).status  && (cse.status.equalsIgnoreCase('Contract Required') && cse.SPEN_ContractReferenceNumberFormula__c.containsIgnoreCase('SPT-RI')))// User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
                {
                    conRefNumVsCaseConReqMap.put(cse.SPEN_ContractReferenceNumberFormula__c,cse.id);
                }

                if(recTypeIdGE == cse.RecordTypeId && cse.status != oldUpdatedCaseMap.get(cse.Id).status && cse.status.equalsIgnoreCase('Closed') && cse.SPEN_EnquiryGroup__c != 'Information Only' && cse.SPEN_Exemption__c == false)
                {
                    //setCsIdSurvey.add(cse.Id);
                    system.debug(setCsIdSurvey);
                }
            }
        }

        if(!conRefNumVsCaseConReqMap.keyset().isEmpty())
        {
            for(SPEN_RelatedProject__c relProj : [Select id,SPEN_Case__c,SPEN_RelatedCase__c,SPEN_Case__r.status,SPEN_RelatedCase__r.status,SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c,SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c,SPEN_QueuePosition__c,SPEN_Relationship__c,SPEN_Stage__c,SPEN_Type__c from SPEN_RelatedProject__c where (SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseConReqMap.keyset() and SPEN_Case__r.status = 'Contracted' and SPEN_Case__c not in:conRefNumVsCaseConReqMap.values()) or (SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseConReqMap.keyset() and SPEN_RelatedCase__r.status = 'Contracted' and SPEN_RelatedCase__c not in:conRefNumVsCaseConReqMap.values())]) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
            {
                if(conRefNumVsCaseConReqMap.keyset().contains(relProj.SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c) && relProj.SPEN_Case__r.status.equalsIgnoreCase('Contracted'))
                {
                    SPEN_RelatedProject__c rPro = new SPEN_RelatedProject__c();
                    rPro.SPEN_Case__c = conRefNumVsCaseConReqMap.get(relProj.SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c);
                    rPro.SPEN_QueuePosition__c = relProj.SPEN_QueuePosition__c;
                    rPro.SPEN_RelatedCase__c = relProj.SPEN_RelatedCase__c;
                    rPro.SPEN_Relationship__c = relProj.SPEN_Relationship__c;
                    rPro.SPEN_Stage__c = relProj.SPEN_Stage__c;
                    rPro.SPEN_Type__c = relProj.SPEN_Type__c;

                    relProjCloCont.add(rPro);
                }
                
                else if(conRefNumVsCaseConReqMap.keyset().contains(relProj.SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c) && relProj.SPEN_RelatedCase__r.status.equalsIgnoreCase('Contracted'))
                {
                    SPEN_RelatedProject__c rPro = new SPEN_RelatedProject__c();
                    rPro.SPEN_Case__c = relProj.SPEN_Case__c;
                    rPro.SPEN_QueuePosition__c = relProj.SPEN_QueuePosition__c;
                    rPro.SPEN_RelatedCase__c = conRefNumVsCaseConReqMap.get(relProj.SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c);
                    rPro.SPEN_Relationship__c = relProj.SPEN_Relationship__c;
                    rPro.SPEN_Stage__c = relProj.SPEN_Stage__c;
                    rPro.SPEN_Type__c = relProj.SPEN_Type__c;

                    relProjCloCont.add(rPro);
                }
            }
        }
        
        if(!conRefNumVsCaseMap.keyset().isEmpty())
        {
            for(Case cs: [Select Id,SPEN_ContractReferenceNumberFormula__c,Status from Case where SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseMap.keyset() and RecordTypeId =: recordTypeIdTransmission and id not in:conRefNumVsCaseMap.values() and status != 'Previous Contract']) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
            {
                cs.Status = 'Previous Contract';   
                lstCaseUpd.add(cs);      
            }

            if(!lstCaseUpd.isEmpty()) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
            {
                Update lstCaseUpd;
            }

            for(SPEN_RelatedProject__c relProj : [Select id,SPEN_Case__c,SPEN_RelatedCase__c,SPEN_Case__r.status,SPEN_RelatedCase__r.status from SPEN_RelatedProject__c where (SPEN_Case__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseMap.keyset() and SPEN_Case__r.status = 'Previous Contract' and SPEN_Case__c not in:conRefNumVsCaseMap.values() and SPEN_RelatedCase__c not in:conRefNumVsCaseMap.values()) or (SPEN_RelatedCase__r.SPEN_ContractReferenceNumberFormula__c in:conRefNumVsCaseMap.keyset() and SPEN_RelatedCase__r.status = 'Previous Contract' and SPEN_RelatedCase__c not in:conRefNumVsCaseMap.values() and SPEN_Case__c not in:conRefNumVsCaseMap.values())]) // User Story : CRMD-9829. Date : 07/02/2024. Developer : Akshay
            {
                relProjDel.add(relProj);
            }

            if(!relProjDel.isEmpty())
            {
                Delete relProjDel;
            }
        }    

        if(!relProjCloCont.isEmpty())
        {
            Insert relProjCloCont;
        }

        if(!listOfFixedCaseId.isEmpty()){
            cases.calculateFixedCumulativeApplicationFee(listOfFixedCaseId,finacialCaseMap);
        }
        if(!setOwnerId.isEmpty() && !caseVSDeliveryMap.isEmpty()){
            updateDeliveryFieldFromCase(setOwnerId,caseVSDeliveryMap,oldUpdatedCaseMap,newUpdatedCaseList);
        }
         if(gsDueDateCaseList!= null && gsDueDateCaseList.size()>0){
             for(SPEN_Delivery__c del : [Select id,SPEN_Case__c,SPEN_GSCallStatus__c from SPEN_Delivery__c where SPEN_Case__c IN : gsDueDateCaseList and 
                                         (SPEN_GSCallStatus__c = 'None' OR 	SPEN_GSCallStatus__c = 'Unsuccessful')]){
                                         finalUpdateCaseList.add(del.SPEN_Case__c);    
                                         }
             system.debug('finalUpdateCaseList**' + finalUpdateCaseList);
        }
        if(!caseIds.isEmpty() && caseIds.size() > 0){
            system.debug('caseEventType>>>>>>>>'+caseEventType);
            for(Case cseRec : [Select id,SPEN_PausedStatus__c,SPEN_3DaysTaskCreationForOwner__c,SPEN_6DaysTaskCreationForOwner__c,SPEN_9DaysTaskCreationForOwner__c,
                               SPEN_OfgemMarketSegment__c,SPEN_DeactivateAutoChasers__c from Case where ID IN : caseIds]){
                                   if(cseRec.SPEN_OfgemMarketSegment__c == 'LVSSA' || cseRec.SPEN_OfgemMarketSegment__c == 'LVSSB'){//CRMD-2625
                                       cseRec.SPEN_3DaysTaskCreationForOwner__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_FirstReminderFor3Days));
                                       cseRec.SPEN_6DaysTaskCreationForOwner__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_SecondReminderFor6dyas));
                                       cseRec.SPEN_9DaysTaskCreationForOwner__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_FinalReminderFor9days));
                                       caseList.add(cseRec);
                                   }
                                   else if(!cseRec.SPEN_DeactivateAutoChasers__c && (cseRec.SPEN_OfgemMarketSegment__c == 'N/A'|| cseRec.SPEN_OfgemMarketSegment__c == 'LVHV'|| cseRec.SPEN_OfgemMarketSegment__c == 'LVAL') ||
                                           (cseRec.SPEN_OfgemMarketSegment__c != 'N/A' && cseRec.SPEN_OfgemMarketSegment__c != 'LVHV' && cseRec.SPEN_OfgemMarketSegment__c != 'LVAL'
                                            && cseRec.SPEN_OfgemMarketSegment__c != 'LVSSA' && cseRec.SPEN_OfgemMarketSegment__c != 'LVSSB')){//CRMD-1333
                                                chaserCaseIdList.add(cseRec.id);
                                                caseEventType = 'IsPaused';
                                            }
                               }
            
            if(!oneTimeUpdateCall && caseList!= null && caseList.size()>0){//CRMD-2625
                oneTimeUpdateCall = true;
                update caseList;
            }
            if(chaserCaseIdList != null && chaserCaseIdList.size() > 0){//CRMD-1333
                updateCommunicationSchedulerRecrd(chaserCaseIdList,caseEventType);
            }
        }
        
        if(!caseTransmissionIds.isEmpty())
        {
            caseEventType = 'Customer Engagement';
            updateCommunicationSchedulerRecrd(caseTransmissionIds,caseEventType);
        }
        //CRMD - 1236
        if(!caseEnergizationIds.isEmpty())
        {
            caseEventType = 'Energization Date';
            updateCommunicationSchedulerRecrd(caseEnergizationIds,caseEventType);
        }
        //CRMD-1211 starts here
        if(!caseITTIssuedDateNotification.isEmpty())
        {
            caseEventType = 'ITTIssued Notification';
            updateCommunicationSchedulerRecrd(caseITTIssuedDateNotification,caseEventType);
        }
        //CRMD-1211 ends here
        if(finalUpdateCaseList!= null && finalUpdateCaseList.size() > 0){
            caseEventType = '2daysPriorTask';
            system.debug('caseEventType**' + caseEventType);
        updateCommunicationSchedulerRecrd(finalUpdateCaseList,caseEventType);
        }

        if(!setCsIdSurvey.isEmpty())
        {
            SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
            SPEN_IVRMessage__c sMSMsg = ivrSel.selectByExternalId('SMS – GE Case Close – Survey');
            SPEN_IVRMessage__c vAMsg = ivrSel.selectByExternalId('VA – GE Case Close – Survey');
            Id caseRecType = Schema.SObjectType.SPEN_Sms__c.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            Id instantVARecTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
            List<SPEN_SMS__c> lstSmsSP=new List<SPEN_SMS__c>();
            List<SPEN_VoiceAlert__c> lstVASP = new List<SPEN_VoiceAlert__c>();
            Map<Id,Id> mapCseIdConId = new Map<Id,Id>();
            Map<Id,String> mapCseIdEmailId = new Map<Id,String>();

            for(Case cse : [select id,ContactId,contact.MobilePhone,contact.SPEN_PSR__c, Contact.SPEN_PreferredMethodofContact__c,SPEN_AddressPremise__c,SPEN_Incident__c, Contact.Phone,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c,SPEN_PreferredMethodofContact__c,RecordType.Name,RecordType.DeveloperName,Status,ContactMobile,ContactPhone,contact.OtherPhone,Origin,SuppliedEmail,SPEN_ApplicantEmail__c,ContactEmail,SPEN_AdditionalCaller__c from Case where Id IN :setCsIdSurvey AND ContactId != null])
            {
                if(cse.SPEN_PreferredMethodofContact__c == 'E' && cse.Origin == 'Email' && !String.isBlank(cse.contactId) && !String.isBlank(cse.SuppliedEmail))
                {
                    system.debug('2296>>>>');
                    mapCseIdConId.put(cse.id,cse.contactId);
                    mapCseIdEmailId.put(cse.id,cse.SuppliedEmail);
                }
                else if(cse.SPEN_PreferredMethodofContact__c == 'E' && cse.Origin == 'Webform' && !String.isBlank(cse.contactId) && !String.isBlank(cse.SPEN_ApplicantEmail__c))
                {
                    system.debug('2302>>>>');
                    mapCseIdConId.put(cse.id,cse.contactId);
                    mapCseIdEmailId.put(cse.id,cse.SPEN_ApplicantEmail__c);
                }
                else if(cse.SPEN_PreferredMethodofContact__c == 'E' && !String.isBlank(cse.contactId) && !String.isBlank(cse.ContactEmail))
                {
                    system.debug('2308>>>>');
                    mapCseIdConId.put(cse.id,cse.contactId);
                    mapCseIdEmailId.put(cse.id,cse.ContactEmail);
                }
                else if((cse.SPEN_AdditionalCaller__c && !String.isBlank(cse.SPEN_CallerMobileTelephone__c)) || !String.isBlank(cse.ContactMobile) || (!String.isBlank(cse.contact.OtherPhone) && cse.contact.OtherPhone.startsWith('07')))
                {
                    system.debug('2314>>>>');
                    //Create SMS through Case Details for GE
                    String mobNo;
                    if(cse.SPEN_AdditionalCaller__c && !String.isBlank(cse.SPEN_CallerMobileTelephone__c))
                    {
                        mobNo= (cse.SPEN_CallerMobileTelephone__c != null && cse.SPEN_CallerMobileTelephone__c.startsWith('0')) ? '+44'+cse.SPEN_CallerMobileTelephone__c.removeStart('0'):cse.SPEN_CallerMobileTelephone__c;
                    }
                    else if(!String.isBlank(cse.ContactMobile))
                    {
                        mobNo= (cse.ContactMobile != null && cse.ContactMobile.startsWith('0')) ? '+44'+cse.ContactMobile.removeStart('0'):cse.ContactMobile;
                    }
                    else if(!String.isBlank(cse.contact.OtherPhone) && cse.contact.OtherPhone.startsWith('07'))
                    {
                        mobNo= (cse.contact.OtherPhone != null && cse.contact.OtherPhone.startsWith('0')) ? '+44'+cse.contact.OtherPhone.removeStart('0'):cse.contact.OtherPhone;
                    }
                    
                    SPEN_SMS__c sms= new SPEN_SMS__c();
                    sms.SPEN_ContactId__c = cse.ContactId;
                    sms.SPEN_IvrMessageId__c = sMSMsg.id;
                    sms.SPEN_Message__c = sMSMsg.SPEN_IVRMessage__c;
                    sms.SPEN_Status__c = 'Created';
                    sms.SPEN_Event__c = 'GE Closure Survey';
                    sms.SPEN_Mobile__c = mobNo;
                    sms.RecordTypeId = caseRecType;
                    sms.SPEN_CaseId__c = cse.id;
                    sms.SPEN_IncidentId__c = cse.SPEN_Incident__c;
                    sms.SPEN_MessageType__c = 'Outbound';
                    lstSmsSP.add(sms);
                }
                else if(!String.isBlank(cse.contactId) && !String.isBlank(cse.ContactEmail))
                {
                    system.debug('2344>>>>');
                    //Create Email through Case Details for GE
                    mapCseIdConId.put(cse.id,cse.contactId);
                    mapCseIdEmailId.put(cse.id,cse.ContactEmail);
                }
                else if((cse.SPEN_AdditionalCaller__c && !String.isBlank(cse.SPEN_CallerTelephone__c)) || (!String.isBlank(cse.contactId) && !String.isBlank(cse.ContactPhone)))
                {
                    system.debug('2351>>>>');
                    //Create VA through Case Details for GE
                    SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                    objVoiceAlert.SPEN_ContactId__c = cse.contactId;
                    objVoiceAlert.SPEN_IncidentId__c = cse.SPEN_Incident__c;
                    objVoiceAlert.SPEN_Event__c = 'GE Closure Survey'; 
                    objVoiceAlert.SPEN_BroadcastMessage__c = vAMsg.SPEN_IVRMessage__c;
                    objVoiceAlert.SPEN_Case__c = cse.id;
                    objVoiceAlert.RecordTypeId = instantVARecTypeId;
                    objVoiceAlert.SPEN_Status__c = 'Ready';
                    objVoiceALert.SPEN_CalledInTelephone__c = (cse.SPEN_AdditionalCaller__c && !String.isBlank(cse.SPEN_CallerTelephone__c)) ? cse.SPEN_CallerTelephone__c : null;
                    lstVASP.add(objVoiceAlert);
                }
            }

            if(!lstSmsSP.isEmpty())
            {
                try
                {
                    system.debug('2370>>>>'+lstSmsSP);
                    insert lstSmsSP;
                    Map<Id,SPEN_SMS__c> mapIdSMS = new Map<Id,SPEN_SMS__c>(lstSmsSP);
                    Id jobId = System.enqueueJob(new SPEN_GESurveyQueueable(mapIdSMS.keySet(),'General Enquiries','SMS')); 
                }
                catch(exception e)
                {
                    SEL_LoggingService.log(e);
                }
            }
            if(!lstVASP.isEmpty())
            {
                try
                {
                    system.debug('2384>>>>'+lstVASP);
                    insert lstVASP;
                    Set<Id> voiceAlertIds = new Set<Id>();
                    for(SPEN_VoiceAlert__c va : lstVASP)
                    {
                        voiceAlertIds.add(va.id);
                    }
                    //SPEN_SurveyUtility.updateVoiceAlertWithInvitation(voiceAlertIds);
                    Id jobId = System.enqueueJob(new SPEN_GESurveyQueueable(voiceAlertIds,'General Enquiries','Voice Alert')); 
                }
                catch(exception e)
                {
                    SEL_LoggingService.log(e);
                }
            }
            if(!mapCseIdConId.isEmpty() && !mapCseIdEmailId.isEmpty())
            {
                try
                {
                    system.debug('2403>>>>'+mapCseIdConId+'>>>>>'+mapCseIdEmailId);
                    Id jobId = System.enqueueJob(new SPEN_GESurveyQueueable(mapCseIdConId,mapCseIdEmailId,'General Enquiries','Email')); 
                }
                catch(exception e)
                {
                    SEL_LoggingService.log(e);
                }
            }
        }

        
    }
    /*************************************************************************
@Author: Rajat Verma
@Date: 29/11/23
@purpose: Update the time fields on case
*************************************************************************************/
    public static void updateDeliveryFieldFromCase(Set<Id> setOwnerId,Map<Id,Id> caseVSDeliveryMap,Map<Id,Case> oldUpdatedCaseMap, List<Case> newUpdatedCaseList){
        map<Id,User>mapUserIdVSUser = new map<Id,User>();
        List<SPEN_Delivery__c> deliveryList = new List<SPEN_Delivery__c>();
        
        if(!setOwnerId.isEmpty()){
            for(User oUser:[Select Id,Name,SPEN_SAPId__c From User Where Id In:setOwnerId]){
                mapUserIdVSUser.put(oUser.Id,oUser);
            }
            if(!mapUserIdVSUser.isEmpty()){
                for(Case cse: newUpdatedCaseList){
                    if(mapUserIdVSUser.containsKey(oldUpdatedCaseMap.get(cse.Id).OwnerId) && cse.SPEN_Delivery__c != null && caseVSDeliveryMap.containsKey(cse.SPEN_Delivery__c)){
                        SPEN_Delivery__c delObj = new SPEN_Delivery__c();
                        delObj.Id = cse.SPEN_Delivery__c;
                        delObj.SPEN_Case_Owner_On_Quote_Status__c = mapUserIdVSUser.get(oldUpdatedCaseMap.get(cse.Id).OwnerId).Name  + ' - ' + mapUserIdVSUser.get(oldUpdatedCaseMap.get(cse.Id).OwnerId).SPEN_SAPId__c;
                        deliveryList.add(delObj); 
                    }
                }
            }
        }
        if(!deliveryList.isEmpty() && deliveryList.size() > 0){
            update deliveryList;
        }
    }
    
    /*************************************************************************
@Author: Rajat Verma
@Date: 02/02/24
@purpose: Get the Queue based on District
*************************************************************************************/
public static String getQueueBasedOnDistrict(String connectionDistrict,String companyId){
    connectionDistrict = !String.isBlank(connectionDistrict)? connectionDistrict.toLowerCase() : null; // INC3542302 : added the Conditional operator to change the string into Lower case and changed all the when values into lowercase
    String queueDevName = '';
    switch on connectionDistrict {
        when 'ayrshire & clyde' {
            queueDevName =  'SPEN_SPDCITLAyrshire';
        }when 'central & fife' {
            queueDevName =  'SPEN_SPDCITLCentralFife';
        }when 'dee valley & mid wales' {
            queueDevName = 'SPEN_SPMCITLDeeValleyMidWales';
        }when 'dumfries' {
            queueDevName =  'SPEN_SPDCITLDumfries';
        }when 'edinburgh & borders' {
            queueDevName =  'SPEN_SPDCITLEdinburghBorders';
        }when 'glasgow & clyde' {
            queueDevName =  'SPEN_SPDCITLGlasgowClyde';
        }when 'lanarkshire' {
            queueDevName =  'SPEN_SPDCITLLanarkshire';
        }when 'merseyside' {
            queueDevName =  'SPEN_SPMCITLMerseyside';
        }when 'mid cheshire' {
            queueDevName =  'SPEN_SPMCITLCheshire';
        }when 'north wales' {
            queueDevName =  'SPEN_SPMCITLNorthWales';
        }when 'wirral' {
            queueDevName =  'SPEN_SPMCITLWirral';
        }when null {
            if('SPD'.equalsIgnoreCase(companyId)){
               queueDevName =  'SPEN_SPDCITLExceptionsNorth'; 
            }else if('SPM'.equalsIgnoreCase(companyId)){
               queueDevName =  'SPEN_SPMCITLExceptionsSouth';
            }
        }
    }
    return queueDevName;
}
    
    /*************************************************************************
@Author: Dhara Desai
@Date: 15/11/22
@purpose: Update the time fields on case
*************************************************************************************/
public static void caseUpdateTimeFields(Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap){
    List<Case> cseMapNewVal = (List<Case>)caseNewMap.values();
    Map<Id,case> cseMapOldVal = (Map<Id,case>)caseOldMap;
    List<Case> updateCase = new List<Case>();
        //List<Group> queueName = new List<Group>();
        //queueName = SPEN_CaseSelector.getQueueDetails(); check 201
    try{
        if(!cseMapNewVal.isEmpty()){
            for(Case cse: cseMapNewVal){
                    if(cse.OwnerId != null && cse.OwnerId != cseMapOldVal.get(cse.id).OwnerId && cse.OwnerId.getsobjecttype() == User.sobjecttype){
                    cse.SPEN_CaseAssignmentTime__c = System.now();
                    updateCase.add(cse);
                }
                if((cse.RecordtypeId == recordTypeIdQuery || cse.RecordTypeId == recordTypeIdNRSWA || cse.Recordtypeid == recordTypeId3PD || cse.recordtypeid == recordTypeIdLCT
                || cse.RecordtypeId == recordTypeIdGE || cse.RecordtypeId == recordTypeIdSI) 
                && cse.OwnerId != cseMapOldVal.get(cse.id).OwnerId && cse.OwnerId.getsobjecttype() == Group.sobjecttype){
                    cse.SPEN_CaseAssignmentTime__c = System.now();
                    updateCase.add(cse);
                }
                if(cse.SPEN_SendtoPowerOn__c != cseMapOldVal.get(cse.id).SPEN_SendtoPowerOn__c && cse.SPEN_SendtoPowerOn__c == true){
                    cse.SPEN_PowerOnSentTime__c = System.now();
                    cse.OwnerId = queueName[0].Id;
                    updateCase.add(cse);
                }
            }
        }
            /*if(!updateCase.isEmpty()){
                upsert updateCase;
            }*/
    }catch(exception e){
        SEL_LoggingService.log(e);
    }
}
/*************************************************************************
@purpose: SMS Record Creation
*************************************************************************************/
    
Public static void smsCreationOnOperHours(List<case> Caselist){
        /*String OperatingHrsByRecordTypeName = 'SMS Blackout Window';
    list<SPEN_IVROperatingHours__c> ivrlist = new list<SPEN_IVROperatingHours__c>();
ivrlist = SPEN_IvrOperatingHoursSelector.getIVROperatingHours(OperatingHrsByRecordTypeName);*/
//check - soql 201
    if(ivrlist.size()>0){
            SPEN_IVROperatingHours__c ivr = ivrlist[0];
            
            if(ivr.SPEN_StartTime__c == null && ivr.SPEN_EndTime__c == null ){
                CaseSMSCreation(caseList); 
            }
            else if((ivr.SPEN_StartTime__c < ivr.SPEN_EndTime__c) && ((system.now().time() < ivr.SPEN_StartTime__c && system.now().time() < ivr.SPEN_EndTime__c) || (system.now().time() > ivr.SPEN_StartTime__c && system.now().time() > ivr.SPEN_EndTime__c))){
                CaseSMSCreation(caseList);
            } 
            else if(( ivr.SPEN_StartTime__c > ivr.SPEN_EndTime__c) && (system.now().time() < ivr.SPEN_StartTime__c && system.now().time() > ivr.SPEN_EndTime__c)){
            CaseSMSCreation(caseList);   
        }
        
        }
}

public static void CaseSMSCreation (List<case> caseList) {
        //String IVRMessageTemplateExtName = System.Label.SPEN_IVRMessageTemplateCaseWeborPhoneSP; ////check - soql 201
    List<Case> CaseIdToCreateSMS = New List<Case>();
    List<Case> CaseIDTOCreateSMSWithOutCon = New List<Case>();
    set<id> conidset = new set<id>();
    List<SPEN_SMS__c> SMSCreation = New List<SPEN_SMS__c>();
    map<id,contact> custInfoMap = new map<id,contact>();
    Id SMSCaseRecordTypeId = Schema.SObjectType.SPEN_SMS__c.getRecordTypeInfosByName().get('Case').getRecordTypeId();
    Id CaseRecordUnplannedBypassId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();
    Id CaseRecordUnplannedFaultId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
    list<Contact> UndifinedContactRec = new list<Contact>();
        /* String UnidentifiedContactName = System.Label.SPEN_SMSUnidentifiedContact;
list<Contact> UndifinedContactRec = new list<Contact>();
for(Contact Con: [Select ID from Contact where name =:UnidentifiedContactName Limit 1]){*///check - soql 201
        for(Contact Con: UndifinedContactRecords){
        UndifinedContactRec.add(Con);
    }
    
    for(case cs : caseList ){
        if(cs.contactid != null){
            conidset.add(cs.ContactId);
        }
    }
    if(!conidset.isempty()){
        custInfoMap = SPEN_ContactSelector.contactRecord(conidset);
    }
        /*map<string,SPEN_ConfigurableSettings__c> confmap = new map<string,SPEN_ConfigurableSettings__c>();
confmap = SEL_ConfigurationSettingSelector.getSMSConfig('SMS Config');*/ //check - soql 201
    
        //Id IvrrecId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();//check - soql 201
    list<SPEN_IVRMessage__c> IVRMessageRec = new list<SPEN_IVRMessage__c>();
        for(SPEN_IVRMessage__c ivr: ivrMsgList){
        IVRMessageRec.add(ivr);
    }
    
    for(case CaseRecord : caseList){
        if(CaseRecord.SPEN_CaseCategoryOutcome__c != NULL &&
           (CaseRecord.RecordTypeId == CaseRecordUnplannedFaultId || CaseRecord.RecordTypeId == CaseRecordUnplannedBypassId)){
               
               if((confmap.containskey(CaseRecord.SPEN_CaseCategoryOutcome__c)) &&
                  (CaseRecord.Origin == confmap.get(CaseRecord.SPEN_CaseCategoryOutcome__c).SPEN_Value__c) && (CaseRecord.ContactId != NULL)){
                      CaseIdToCreateSMS.add(CaseRecord);
                  } else if ((confmap.containskey(CaseRecord.SPEN_CaseCategoryOutcome__c)) &&
                    (CaseRecord.Origin == confmap.get(CaseRecord.SPEN_CaseCategoryOutcome__c).SPEN_Value__c) && (CaseRecord.ContactId == NULL)){
                       CaseIDTOCreateSMSWithOutCon.add(CaseRecord);
                    }
           }
    }
    If(CaseIdToCreateSMS.size()>0){
    for(case CaseIDList :CaseIdToCreateSMS){
        SPEN_SMS__c SMSRec = New SPEN_SMS__c();
        SMSRec.SPEN_CaseId__c = CaseIDList.id;
        SMSRec.SPEN_ContactId__c = CaseIDList.ContactId;
        SMSRec.RecordTypeId = SMSCaseRecordTypeId;
        SMSRec.SPEN_IvrMessageId__c = IVRMessageRec.size() > 0 ? IVRMessageRec[0].id : null;
        SMSRec.SPEN_Status__c = 'Ready';
        string Mobilenumber = custInfoMap != null ? custInfoMap.containskey(CaseIDList.ContactId)? 
            custInfoMap.get(CaseIDList.ContactId).MobilePhone != null? custInfoMap.get(CaseIDList.ContactId).MobilePhone  :null :null  :null;
        if(!String.IsEmpty(Mobilenumber)){
        Mobilenumber = Mobilenumber.startsWith('0') ? '+44'+Mobilenumber.removeStart('0'):Mobilenumber ;
        }
        SMSRec.SPEN_Mobile__c = Mobilenumber != null ? Mobilenumber : null;
        SMSRec.SPEN_MessageType__c = 'Outbound';
        SMSRec.SPEN_IncidentId__c = CaseIDList.SPEN_Incident__c!=NULL?CaseIDList.SPEN_Incident__c:NULL;
        SMSRec.SPEN_Event__c = 'Case Creation';
        SMSRec.SPEN_Message__c = IVRMessageRec.size() > 0 ? IVRMessageRec[0].SPEN_IVRMessage__c : null;
        SMSCreation.add(SMSRec);
    }
    }
    
    If(CaseIDTOCreateSMSWithOutCon.size()>0){
    for(case CaseIDList :CaseIDTOCreateSMSWithOutCon){
        SPEN_SMS__c SMSRec = New SPEN_SMS__c();
        SMSRec.SPEN_CaseId__c = CaseIDList.id;
        SMSRec.SPEN_ContactId__c = UndifinedContactRec.size() > 0 ? UndifinedContactRec[0].id : null;
        SMSRec.RecordTypeId = SMSCaseRecordTypeId;
        SMSRec.SPEN_IvrMessageId__c = IVRMessageRec.size() > 0 ? IVRMessageRec[0].id : null;
        SMSRec.SPEN_Status__c = 'Ready';
        string Mobilenumber = CaseIDList.SPEN_CustomerMobilePhone__c!=NULL?CaseIDList.SPEN_CustomerMobilePhone__c:NULL;
        if(!String.IsEmpty(Mobilenumber)){
        Mobilenumber = Mobilenumber.startsWith('0') ? '+44'+Mobilenumber.removeStart('0'):Mobilenumber ;
        }
        SMSRec.SPEN_Mobile__c = Mobilenumber != null ? Mobilenumber : null;
        SMSRec.SPEN_MessageType__c = 'Outbound';
        SMSRec.SPEN_IncidentId__c = CaseIDList.SPEN_Incident__c!=NULL?CaseIDList.SPEN_Incident__c:NULL;
        SMSRec.SPEN_Event__c = 'Case Creation';
        SMSRec.SPEN_Message__c = IVRMessageRec.size() > 0 ? IVRMessageRec[0].SPEN_IVRMessage__c : null;
        SMSCreation.add(SMSRec);
        
    }
    }
    
    If(SMSCreation.size()>0){
        Try{
            Insert SMSCreation;  
        }
        Catch(exception e) {
            SEL_LoggingService.log(e);
            }
        }
    }
	// Method to convert the datetime into locale time.
    public static String convertToLocaleTimeZone(String dateTimeVal){
		Datetime dateTimeValue = Datetime.valueOfGMT(dateTimeVal);
        String result = (dateTimeValue!=null) ? dateTimeValue.format('yyyy-MM-dd HH:mm:ss'):String.valueOf(dateTimeValue);
        return result;
    }
    //Code Implementation starts here. User Story : CRMD-5762. Date : 06/14/2023. Developer : sheker
    public static DateTime getWorkingDays(Id businessHrId, DateTime baseDate, Long days)
    {
        Long addNDays = 86400000 *days;
        return BusinessHours.add(businessHrId, baseDate, addNDays);
    }
    //Code Implementation ends here. User Story : CRMD-5762. Date : 06/14/2023. Developer : sheker
/*************************************************************************
@Author: Sumit Biswas
@Date: 29/05/23
@purpose: CRMD-5451-Creation of referral service record after case insert
*************************************************************************************/
public static void createReferralServiceAfterInsert(List<sObject> caseNewList)
{
    List<Case> caseList = (List<Case>)caseNewList;
    List<SPEN_ReferralService__c> referralServiceList = new List<SPEN_ReferralService__c>();
    Id accId;
        //List<Account> accList = SPEN_AccountSelector.getPartnerAccount(CasesConstants.SPEN); //check - soql 201
    List<String> referralServices;
    if(!accList.isEmpty())
    {
        accId = accList[0].Id;
    }
    
    for(Case cse : caseList){
        if(cse.SPEN_ReferralServicesRequested__c != null )
        {
            referralServices = cse.SPEN_ReferralServicesRequested__c.split(';');
            for(String service : referralServices){
                if(service.equalsIgnoreCase(CasesConstants.POWERCUT))
                {
                    SPEN_ReferralService__c refService = new SPEN_ReferralService__c();
                    refService.SPEN_ServiceStatus__c = CasesConstants.STATUSCLOSED;
                    refService.SPEN_Service__c = service;
                    refService.SPEN_ClosureCode__c = CasesConstants.DELIVEREDCOMPLETED;
                    refService.SPEN_Case__c = cse.Id;
                    refService.SPEN_ClosureDate__c = system.today();
                    refService.SPEN_CustomerSatisfaction__c = CasesConstants.CUSTOMERSATISFACTION;
                    refService.SPEN_CustomerSatisfactionLevel__c = CasesConstants.CUSTOMERSATISFACTION;
                    if(accId != Null)
                    { 
                        refService.SPEN_PartnerName__c = accId;
                    }
                    referralServiceList.add(refService);
                }else{
                    SPEN_ReferralService__c refService = new SPEN_ReferralService__c();
                    refService.SPEN_ServiceStatus__c = CasesConstants.STATUSCREATED;
                    refService.SPEN_Service__c = service;
                    refService.SPEN_Case__c = cse.Id;
                    referralServiceList.add(refService);
                }
                
            }
            
        }
    }
    if(!referralServiceList.isEmpty())
    {
        try
        {
            insert referralServiceList;  
        }
        catch(Exception e) 
        {
            SEL_LoggingService.log(e);
        }
    }
}
        /*************************************************************************
@Author: Swaathi KR
@Date: 02/08/23
@User Story: CRMD-7071
@purpose: Before Insert - Populate Date/time based on every status change of case
*************************************************************************************/
public static void populateStatusChangeDate(List<Case> caseNewList, Map<ID, Case> oldCaseMap)
{
    //Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    List<Case> caseList= (List<Case>)caseNewList;
    Set<String> setSWOpenStatus = new Set<String>(System.label.SPEN_SWOpenStatus.split(';'));
    Set<String> setNRSWAOpenStatus = new Set<String>(System.label.SPEN_NRSWAOpenStatus.split(';'));
   
        /*Set<String> setQueueName = new Set<String>{'NRSWA Actioned Cases', 'Streetworks Actioned Cases', 
                               'NRSWA - SPM', 'NRSWA - SPD', 'Streetworks - SPD', 'Streetworks - SPM'};
Map<String,Id> mapQueueName2Id = SPEN_CaseSelector.getQueueDetails(setQueueName);*/ //check - soql 201
    for(Case cse : caseNewList)
    {   
        //Commented for CRMD-10261 - S - Recordtypecheck
       /* if((cse.RecordTypeId == recordTypeIdNRSWA || cse.RecordTypeId == recordTypeId3PD || cse.RecordTypeId == recordTypeIdSW
            || cse.RecordTypeId == recordTypeIdQuery)) // SW record type added - CRMD -8235
        {*/ //Commented for CRMD-10261 - E
            if(cse.Status != null && cse.Status != oldCaseMap.get(cse.Id).Status /*&& cse.Status != 'Created' && cse.Status != 'Closed'*/)
            {
                cse.SPEN_LastStatusChangeDate__c = System.now();
                if(cse.status == 'Closed' && cse.SPEN_WorksComplete__c == null && cse.RecordTypeId == recordTypeIdQuery && (cse.SPEN_Type__c == 'StreetWorks' || cse.SPEN_Type__c == 'NRSWA'))
                {
                    cse.SPEN_WorksComplete__c = System.now();
                }
                //CRMD-7413 - START
                if( cse.SPEN_AwaitingJointingCompletionDateTime__c == null && cse.Status == 'Awaiting Jointing Complete/Works Completion' &&
                (cse.RecordTypeId == recordTypeIdSW || cse.RecordTypeId == recordTypeIdNRSWA))
                {
                    cse.SPEN_AwaitingJointingCompletionDateTime__c = System.now();
                }
                //CRMD-7413 - END
                //CRMD-9065 S
                if((cse.RecordTypeId == recordTypeIdSW && setSWOpenStatus.contains(cse.status)) ||
                (cse.RecordTypeId == recordTypeIdQuery && cse.SPEN_Type__c == 'StreetWorks' && cse.status== 'Closed')){
                    cse.ownerId = mapQueueName2Id.get('Streetworks Actioned Cases');
                    cse.Reassignment_Reason__c = 'Automation';//9411
                }else if((cse.RecordTypeId == recordTypeIdNRSWA && setNRSWAOpenStatus.contains(cse.status)) ||
                (cse.RecordTypeId == recordTypeIdQuery && cse.SPEN_Type__c == 'NRSWA' && cse.status== 'Closed')){
                    cse.ownerId = mapQueueName2Id.get('NRSWA Actioned Cases');
                    cse.Reassignment_Reason__c = 'Automation';//9411
                }
                if(cse.RecordTypeId == recordTypeIdSW && cse.status.equalsIgnoreCase('Streetworks Review')){
                    cse.ownerId = cse.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPD') ? mapQueueName2Id.get('Streetworks - SPD') : mapQueueName2Id.get('Streetworks - SPM');
                    cse.Reassignment_Reason__c = 'Automation';//9411
                }else if(cse.RecordTypeId == recordTypeIdNRSWA && cse.status.equalsIgnoreCase('NRSWA Review')){
                    cse.ownerId = cse.SPEN_SPDSPMIndicator__c.equalsIgnoreCase('SPD') ? mapQueueName2Id.get('NRSWA - SPD') : mapQueueName2Id.get('NRSWA - SPM');
                    cse.Reassignment_Reason__c = 'Automation';//9411
                }
                //CRMD-9065 E
            }
        // }//Commented for CRMD-10261
    }
}
  
/*************************************************************************
@Author: Sumit Biswas
@Date: 14/06/23
@purpose: Update Ready For Payment Date based on Status
*************************************************************************************/
    public static void populateGSFieldsMass(List<Case> caseNewList, Map<ID, Case> oldCaseMap)
    {       
        for(Case cse : caseNewList)
        {
            if(cse.Status != null && cse.Status != oldCaseMap.get(cse.Id).Status && cse.Status == CasesConstants.READYFORPAYMENT)
            {
                cse.SPEN_ReadyforPaymentDateTime__c = Datetime.now();
            }
        }
    }
    /*************************************************************************
@Author: Amrita Sarkar
@Date: 13/07/23
@purpose: CRMD-6725 When postCode lookup changes, auto-populate Districts lookup on case Update
*************************************************************************************/
     public static void caseUpdateDitrictFromPostCode(List<Case> newCreatedCaseList,Map<Id, sObject> caseNewMap, Map<Id, sObject> caseOldMap){
        Map<Id,case> cseMapOldVal = new Map<Id,case>();
        Map<String,String> postcadeVsDistMap = new Map<String,String>();
        /*Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();
        Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();*/ //Commented for CRMD-10261
        Set<String> postCodeSet = new Set<String>();
        Map<id,String> caseIdVsPostCodeMap = new  Map<id,String>();
        try{
            if(!newCreatedCaseList.isEmpty()){
                if(trigger.isUpdate){
                    cseMapOldVal = (Map<Id,case>)caseOldMap;
                }
                for(Case cse: newCreatedCaseList){
                    if(
                        //(cse.RecordTypeId == recordTypeIdBudget ||  cse.RecordTypeId == recordTypeIdFormal) && //commented for CRMD-10261
                        cse.SPEN_SiteContactPostCode__c != null && 
                       (caseOldMap == null || (cseMapOldVal != null && cse.SPEN_SiteContactPostCode__c !=cseMapOldVal.get(cse.id).SPEN_SiteContactPostCode__c))){
                               
                           List<String> filterLogicSplittedbySpace = cse.SPEN_SiteContactPostCode__c.split(' ');
                           if(filterLogicSplittedbySpace.size()> 0 && filterLogicSplittedbySpace.size()<2){
                               postCodeSet.add(filterLogicSplittedbySpace[0].toUpperCase());
                               caseIdVsPostCodeMap.put(cse.id,filterLogicSplittedbySpace[0].toUpperCase());
                           }else{
                               postCodeSet.add(cse.SPEN_SiteContactPostCode__c.toUpperCase());
                               caseIdVsPostCodeMap.put(cse.id,cse.SPEN_SiteContactPostCode__c.toUpperCase());
                           }
                           
                    }
                }
            
                if(!postCodeSet.isEmpty()){
                    for(SPEN_PostCodeDistrictMap__c postCodeDis : SPEN_CaseSelector.getPostCodeDisDetails(postCodeSet)){
                        postcadeVsDistMap.put((postCodeDis.SPEN_PostCode__c).toUpperCase(),postCodeDis.SPEN_DistrictName__c);
                    }
                    for(Case cse: newCreatedCaseList){
                        if(caseIdVsPostCodeMap.containsKey(cse.id)){
                            cse.SPEN_ConnectionDistrict__c = postcadeVsDistMap.get(caseIdVsPostCodeMap.get(cse.id));
                        }    
                        
                    }
                }
            }   
        }catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
    
    /*************************************************************************
@Author: Rajat Verma
@Date: 13/07/23
@purpose: CRMD-6699: Populate TTQ and Contact Received Dates on Case
*************************************************************************************/
    public static void populateDatesOnCase(List<Case> caseList,Map<Id,Case> caseNewMap, Map<Id,Case> caseOldMap){
        Set<String> connectionRecordTypes = new Set<String>(System.label.SPEN_ConnectionsRecordType.trim().split(','));
        
        try{
            if(!caseList.isEmpty()){
                if(trigger.isInsert){
                    for(Case caseObj : caseList){
                        String conCaseRecTypeName=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseObj.RecordTypeId).getDeveloperName();
                        if(connectionRecordTypes.contains(conCaseRecTypeName)){
                            caseObj.SPEN_ContactReceivedDate__c = System.now();
                            caseObj.SPEN_TTQStartDate__c = System.today();
                            caseObj.SPEN_CompetentDate__c = System.today(); 
                            DateTime currentDateTime = System.now();
                            Integer currentHours = currentDateTime.hour(), currentMinutes = currentDateTime.minute(), currentSeconds = currentDateTime.second();
                            Time newTimeValue = Time.newInstance(currentHours, currentMinutes, currentSeconds, 0);
                            caseObj.SPEN_TTQ_Start_Time__c = newTimeValue;//CRMD-9440
                            caseObj.SPEN_Competent_Time__c = newTimeValue;//CRMD-9440
                        }
                    } 
                }else if(trigger.isUpdate){
                    for(Case caseObj : caseList){
                        //String conCaseRecTypeName=Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseObj.RecordTypeId).getDeveloperName();
                        String conCaseRecTypeName=((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosById().get(caseObj.RecordTypeId).getDeveloperName();
                        if(connectionRecordTypes.contains(conCaseRecTypeName)){
                             
                            if(caseObj.Status != null && caseObj.SPEN_SubStatus__c != null && 
                               caseOldMap.get(caseObj.Id).SPEN_SubStatus__c != caseNewMap.get(caseObj.Id).SPEN_SubStatus__c &&
                               CasesConstants.Case_InfoReceived.equals(caseObj.SPEN_SubStatus__c) && caseOldMap.get(caseObj.Id).SPEN_PausedStatus__c == 'Yes'){
                                   if(CasesConstants.CASE_INFOENQUIRY.equals(caseObj.Status)){
                                       caseObj.SPEN_ContactReceivedDate__c = System.now();
                                       caseObj.SPEN_TTQStartDate__c = System.today();
                                       caseObj.SPEN_CompetentDate__c = System.today();  //CRMD-7290
                                       DateTime currentDateTime = System.now();
                                       Integer currentHours = currentDateTime.hour(), currentMinutes = currentDateTime.minute(), currentSeconds = currentDateTime.second();
                                       Time newTimeValue = Time.newInstance(currentHours, currentMinutes, currentSeconds, 0);
                                       caseObj.SPEN_TTQ_Start_Time__c = newTimeValue;
                            		   caseObj.SPEN_Competent_Time__c = newTimeValue;
                                   }
                                   if(CasesConstants.CASE_FORMALENQUIRY.equals(caseObj.Status)){
                                       caseObj.SPEN_ContactReceivedDate__c = System.now();
                                       caseObj.SPEN_CompetentDate__c = System.today();  //CRMD-7290
                                       DateTime currentDateTime = System.now();
                                       Integer currentHours = currentDateTime.hour(), currentMinutes = currentDateTime.minute(), currentSeconds = currentDateTime.second();
                                       Time newTimeValue = Time.newInstance(currentHours, currentMinutes, currentSeconds, 0);
                                       caseObj.SPEN_Competent_Time__c = newTimeValue;
                                   }
                               }
                            //CRMD-7290
                            if(caseObj.SPEN_ContactReceivedDate__c != null && caseOldMap.get(caseObj.Id).SPEN_ContactReceivedDate__c != caseNewMap.get(caseObj.Id).SPEN_ContactReceivedDate__c){
                                //In Case when new map contains past value than oldmap
                                if(caseOldMap.get(caseObj.Id).SPEN_ContactReceivedDate__c > caseNewMap.get(caseObj.Id).SPEN_ContactReceivedDate__c){
                                    caseObj.SPEN_TTQStartDate__c = caseObj.SPEN_ContactReceivedDate__c.date();
                                    caseObj.SPEN_CompetentDate__c = caseObj.SPEN_ContactReceivedDate__c.date();
                                    caseObj.SPEN_TTQ_Start_Time__c = caseObj.SPEN_ContactReceivedDate__c.time();//CRMD-9440
                                    caseObj.SPEN_Competent_Time__c = caseObj.SPEN_ContactReceivedDate__c.time();//CRMD-9440
                                }
                                //In Case when contact received date is greater than competent date
                                if(caseObj.SPEN_CompetentDate__c != null && (caseNewMap.get(caseObj.Id).SPEN_ContactReceivedDate__c.date() > caseOldMap.get(caseObj.Id).SPEN_CompetentDate__c)){
                                    caseObj.SPEN_CompetentDate__c = caseObj.SPEN_ContactReceivedDate__c.date();
                                    caseObj.SPEN_Competent_Time__c = caseObj.SPEN_ContactReceivedDate__c.time();//CRMD-9440
                                }
                            }
                            //CRMD-7290 END
                        }
                    }
                }
            }
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
    }
    
    /*************************************************************************
@Author: Rajat Verma
@Date: 19/02/24
@purpose: CRMD-9978: Populate Case Contract Reference Number
*************************************************************************************/
    public static void populateCaseContractNumber(List<Case> caseList,Map<Id,Case> caseNewMap, Map<Id,Case> caseOldMap){
        Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
        Set<Id> parentCaseIds = new Set<Id>();
        Map<Id,Case> mapOfParentCase = new Map<Id,Case>();//check - soql 201
        
        try{
            if(!caseList.isEmpty()){
                for(Case caseObj : caseList){
                    parentCaseIds.add(caseObj.ParentId);
                }
                if(!parentCaseIds.isEmpty())//check - soql 201
                {
                    mapOfParentCase = new Map<Id,Case>([Select Id, CaseNumber,SPEN_ContractArea__c From Case where Id =: parentCaseIds]);
                
                if(trigger.isInsert){
                    for(Case caseObj : caseList){
                        // if(caseObj.RecordTypeId == recordTypeIdTransmission){//Commented for CRMD-10261
                            if(!mapOfParentCase.isEmpty() && mapOfParentCase.get(caseObj.ParentId) != null && mapOfParentCase.get(caseObj.ParentId).CaseNumber != null && String.isNotBlank(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                if('In Area'.equalsIgnoreCase(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                    caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-TOCO-' + mapOfParentCase.get(caseObj.ParentId).CaseNumber;
                                }else if('Affected'.equalsIgnoreCase(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                    caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-ATOCO-' + mapOfParentCase.get(caseObj.ParentId).CaseNumber;
                                }else if('TORI'.equalsIgnoreCase(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                    caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-RI-' + mapOfParentCase.get(caseObj.ParentId).CaseNumber;
                                }
                            }
                        // }//Commented for CRMD-10261
                    }
                }else if(trigger.isUpdate){
                    for(Case caseObj : caseList){
                        //  if(caseObj.RecordTypeId == recordTypeIdTransmission){ //Commented for CRMD-10261
                            if(!mapOfParentCase.isEmpty() && mapOfParentCase.get(caseObj.ParentId) != null && mapOfParentCase.get(caseObj.ParentId).CaseNumber != null && String.isNotBlank(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                if('In Area'.equalsIgnoreCase(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                    caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-TOCO-' + mapOfParentCase.get(caseObj.ParentId).CaseNumber;
                                }else if('Affected'.equalsIgnoreCase(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                    caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-ATOCO-' + mapOfParentCase.get(caseObj.ParentId).CaseNumber;
                                }else if('TORI'.equalsIgnoreCase(mapOfParentCase.get(caseObj.ParentId).SPEN_ContractArea__c)){
                                    caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-RI-' + mapOfParentCase.get(caseObj.ParentId).CaseNumber;
                                }
                            }else if(String.isNotBlank(caseObj.SPEN_ContractArea__c) && ((caseObj.SPEN_ContractArea__c != caseOldMap.get(caseObj.Id).SPEN_ContractArea__c) 
                                                                                         || (String.isBlank(caseOldMap.get(caseObj.Id).SPEN_CaseContractReferenceNumber__c)))){
                                                                                             
                                                                                             if('In Area'.equalsIgnoreCase(caseObj.SPEN_ContractArea__c)){
                                                                                                 caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-TOCO-' + caseObj.CaseNumber;
                                                                                             }else if('Affected'.equalsIgnoreCase(caseObj.SPEN_ContractArea__c)){
                                                                                                 caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-ATOCO-' + caseObj.CaseNumber;
                                                                                             }else if('TORI'.equalsIgnoreCase(caseObj.SPEN_ContractArea__c)){
                                                                                                 caseObj.SPEN_CaseContractReferenceNumber__c = 'SPT-RI-' + caseObj.CaseNumber;
                                                                                             }
                                                                                         }
                        //  } //Commented for CRMD-10261
                    }
                }
                }//201
            }
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
    }
    
        /*************************************************************************
@Author: Swaathi KR
@Date: 28/07/23
@User Story: CRMD-7071
@purpose: Before Insert - Link the Parent 3PD case to Query Case(Origin - Email)
*************************************************************************************/
public static List<Case> populate3PDCaseOnQueryCase(List<sObject> caseNewList)
{
    List<Case> caseList= (List<Case>)caseNewList;
    Case c = caseList[0];
    List<String> incidentFinalList= new List<String>();
    List<String> fuzzyIncidentFinalList= new List<String>();
    List<String> FinalInvoiceList= new List<String>();
    List<String> CaseFinalList= new List<String>();
    //Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    //Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    String caseId;
    String incidentRefId;
    String incidentRef;
    String invoicenumber;
    Pattern regexPattern;
    Matcher matcher;
    //Boolean found;
    //Custom Labels
    String CaseRegex=System.Label.SPEN_CaseNumberRegex;
    String InvoiceNumberRegex = System.Label.SPEN_InvoiceNumberRegex;
    String IncidentExactRegex = System.Label.SPEN_IncidentReferenceNumberExactRegex;
    String IncidentFuzzyRegex = System.Label.SPEN_IncidentReferenceNumberFuzzyRegex;
    
    List<Case> CaseIdList = new List<Case>();
    Map<String,Id> InvoiceTo3PDCaseMap = new Map<String,Id>();
    Map<String,Id> QueryCaseTo3PDCaseMap = new Map<String,Id>();
    Map<String,Id> IncRefTo3PDCaseMap = new Map<String,Id>();
    Map<String,Id> IncFuzzyRefTo3PDCaseMap = new Map<String,Id>();
    
    List<String> invoiceRegexList=new List<String>();
    List<String> caseRegexList=new List<String>();
    List<String> incidentRefRegexList=new List<String>();
    List<String> fuzzyIncidentRefRegexList=new List<String>();
    
    try{
        if(!caseList.isEmpty())
        {
            for(Case cs:caseList)
            {
                if(cs.RecordTypeId == recordTypeIdQuery && cs.Origin == 'Email' && cs.SPEN_Type__c=='Third Party Damage')
                {
                    if(invoiceRegexList.isEmpty() && caseRegexList.isEmpty() && incidentRefRegexList.isEmpty() && fuzzyIncidentRefRegexList.isEmpty())
                    {
                        //Invoice Check
                        if(cs.Subject != null)
                        {
                            invoiceRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(InvoiceNumberRegex,cs.Subject);
                            System.debug('invoiceRegexList+++'+invoiceRegexList);
                            if(!invoiceRegexList.isEmpty())
                            {   
                                FinalInvoiceList.addAll(invoiceRegexList);
                            }
                        }
                        //if(invoiceRegexList.isEmpty() && cs.Description != null)
                        if(cs.Description != null)
                        {
                            invoiceRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(InvoiceNumberRegex,cs.Description);
                            if(!invoiceRegexList.isEmpty())
                            {   
                                FinalInvoiceList.addAll(invoiceRegexList);
                            }
                        }
                        
                        //Fetching the cases based on Invoice Num
                        if(!FinalInvoiceList.isEmpty())
                        {
                            //IncRefToNRSWACaseMap = SPEN_CaseSelector.get3PDCaseFromIncidentReference(incidentFinalList);
                            InvoiceTo3PDCaseMap = SPEN_CaseSelector.get3PDCaseFromInvoiceNumber(FinalInvoiceList);//swaathi
                            System.debug('### InvoiceTo3PDCaseMap: '+InvoiceTo3PDCaseMap);
                        }
                        
                        /***************************************************************************************************************************/
                        if(InvoiceTo3PDCaseMap.isEmpty()){
                            //case number search
                            if(cs.Subject != null)
                            {
                                caseRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(CaseRegex,cs.Subject);
                                system.debug('Cases+++'+caseRegexList);
                                if(!caseRegexList.isEmpty())
                                {   
                                    CaseFinalList.addAll(caseRegexList);
                                }
                                //if(caseRegexList.isEmpty() && cs.Description != null ) 
                                if(cs.Description != null)
                                {
                                    caseRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(CaseRegex,cs.Description);
                                    if(!caseRegexList.isEmpty())
                                    {   
                                        CaseFinalList.addAll(caseRegexList);
                                    }
                                }
                            }
                        }
                        //Fetching the cases based on Case Num
                        if(!CaseFinalList.isEmpty())
                        {
                            //QueryToCaseMap = SPEN_CaseSelector.get3PDCaseFromCaseId(CaseFinalList);
                            QueryCaseTo3PDCaseMap = SPEN_CaseSelector.get3PDCaseFromCaseIdNew(CaseFinalList,'SPEN_ThirdPartyDamage');//swaathi
                            System.debug('### QueryCaseTo3PDCaseMap: '+QueryCaseTo3PDCaseMap);
                            
                        }
                        /**************************************************************************************************/
                        if(InvoiceTo3PDCaseMap.isEmpty() && QueryCaseTo3PDCaseMap.isEmpty()){
                            //NORMAL Incident Check
                            if(cs.Subject != null)
                            {
                                incidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentExactRegex,cs.Subject);
                                System.debug('incidentRefRegexList+++'+incidentRefRegexList);
                                if(!incidentRefRegexList.isEmpty())
                                {   
                                    incidentFinalList.addAll(incidentRefRegexList);
                                }
                            }
                            //if(incidentRefRegexList.isEmpty() && cs.Description != null)
                            if(cs.Description != null)
                            {
                                incidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentExactRegex,cs.Description);
                                if(!incidentRefRegexList.isEmpty())
                                {   
                                    incidentFinalList.addAll(incidentRefRegexList);
                                }
                            }
                        }
                        //Fetching the cases based on Incident Ref
                        if(!incidentFinalList.isEmpty())
                        {
                            //IncRefToNRSWACaseMap = SPEN_CaseSelector.get3PDCaseFromIncidentReference(incidentFinalList);
                            IncRefTo3PDCaseMap = SPEN_CaseSelector.get3PDCaseFromIncidentReferenceNew(incidentFinalList,'SPEN_ThirdPartyDamage');//swaathi
                            System.debug('### IncRefTo3PDCaseMap: '+IncRefTo3PDCaseMap);
                        }
                        /********************************************************************************************************/
                        
                        //Fuzzy Logic
                        if(InvoiceTo3PDCaseMap.isEmpty() && QueryCaseTo3PDCaseMap.isEmpty() && IncRefTo3PDCaseMap.isEmpty())   //between hyphen
                        {
                            System.debug('Inside+++');
                            if(cs.subject != null)
                            {
                                fuzzyIncidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentFuzzyRegex,cs.Subject);
                                if(!fuzzyIncidentRefRegexList.isEmpty())
                                {
                                    fuzzyIncidentFinalList.addAll(fuzzyIncidentRefRegexList);
                                }
                            }
                            //if(fuzzyIncidentRefRegexList.isEmpty() && cs.Description != null)
                            if(cs.Description != null)
                            {
                                fuzzyIncidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentFuzzyRegex,cs.Description);
                                if(!fuzzyIncidentRefRegexList.isEmpty())
                                {
                                    fuzzyIncidentFinalList.addAll(fuzzyIncidentRefRegexList);
                                }
                            }
                        }
                        
                        //Getting valid cases based on fuzzy check list
                        if(!fuzzyIncidentFinalList.isEmpty())
                        {
                            //IncFuzzyRefToNRSWACaseMap = SPEN_CaseSelector.get3PDCaseFromFuzzyIncidentReference(fuzzyIncidentFinalList);
                            IncFuzzyRefTo3PDCaseMap = SPEN_CaseSelector.get3PDCaseFromFuzzyIncidentReferenceNew(fuzzyIncidentFinalList,'SPEN_ThirdPartyDamage');//swaathi
                            System.debug('### IncFuzzyRefTo3PDCaseMap: '+IncFuzzyRefTo3PDCaseMap);
                            
                        }
                        /********************************************************************************************************/
                    }
                    /********************************************************************************************************/
                    
                    
                }
            }
            
            
            System.debug('### Final List Map: ' + incidentFinalList);
            
            
        }
        /*****************************************************************************/
        //Parent ID populate
        if(!InvoiceTo3PDCaseMap.isEmpty())
        {
            c.ParentId = SPEN_CasesUtil.populateParentID(FinalInvoiceList,InvoiceTo3PDCaseMap);
           
        }
        if(!QueryCaseTo3PDCaseMap.isEmpty())
        {
            c.ParentId = SPEN_CasesUtil.populateParentID(CaseFinalList,QueryCaseTo3PDCaseMap);
           
        }
        if(!IncRefTo3PDCaseMap.isEmpty())
        {
            c.ParentId = SPEN_CasesUtil.populateParentID(incidentFinalList,IncRefTo3PDCaseMap);
            
        }
        //Fuzzy Incident Ref - Parent ID
        if(!IncFuzzyRefTo3PDCaseMap.isEmpty())
        {
            system.debug('Inside1+++'+fuzzyIncidentFinalList);
            system.debug('IncFuzzyRefTo3PDCaseMap+++'+IncFuzzyRefTo3PDCaseMap);
            c.ParentId = SPEN_CasesUtil.populateParentID(fuzzyIncidentFinalList,IncFuzzyRefTo3PDCaseMap);
            
        }
        /*****************************************************************************/
        return caseList;
    }
    catch(Exception e)
    {
        SEL_LoggingService.log(e);
        return NULL;
    }
}

/*************************************************************************
@Author: Govind Kumar Rawani
@Date: 15/05/24
@User Story: CRMD-10877
@purpose: Before Insert - update district field in case object 
*************************************************************************************/
public static void populateCaseDistrict(List<Case> caseNewList){
    Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
    Set<Id> parentCaseIds = new Set<Id>();
    Set<Id> incidentIdsSet = new Set<Id>();
    for(Case newCase:caseNewList){
     if(newCase.SPEN_Category__c=='General Enquiries' && newCase.ParentId!=NULL){
           System.debug('inside General Enquiries condtion==>');
    	   parentCaseIds.add(newCase.ParentId);  
			system.debug('parentCaseIds>>'+ parentCaseIds);
        }
      if(newCase.SPEN_Category__c=='Faults' && newCase.SPEN_Incident__c!=NULL){
           System.debug('inside Faults condtion==>');
   		  incidentIdsSet.add(newCase.SPEN_Incident__c);
      }
    }
    // Query parent cases to get their district field value
    Map<Id, Case> parentCasesMap = new Map<Id, Case>([SELECT Id, SPEN_District__c,RecordTypeId FROM Case WHERE Id IN :parentCaseIds]);
    System.debug('incidentIdsSet==>'+incidentIdsSet);
system.debug('parentCasesMap>>'+ parentCasesMap);
     Map<id,Incident> spendistrcictMap =new  Map<id,Incident>([select id , SPEN_Distrcits__r.Name  from Incident WHERE ID IN :incidentIdsSet]);
    // Update child cases with parent case district value
    for (Case newCase : caseNewList) {
        if (newCase.ParentId != null && parentCasesMap.containsKey(newCase.ParentId)
             && recordTypeIdGE==parentCasesMap.get(newCase.ParentId).RecordTypeId) {
            System.debug('Update record forloop');
            newCase.SPEN_ConnectionDistrict__c = parentCasesMap.get(newCase.ParentId).SPEN_District__c;
        }
        if(newCase.SPEN_Incident__c!=NULL && spendistrcictMap.containsKey(newCase.SPEN_Incident__c)){
             System.debug('updating ConnectionDistrict');
            newCase.SPEN_ConnectionDistrict__c =spendistrcictMap.get(newCase.SPEN_Incident__c).SPEN_Distrcits__r.Name;
        }
    }
}



/*public static String find3PDCaseFromSubjectOrDescription(String exp,String field)
{
    Pattern regexPattern;
    Matcher matcher;
    String ID;
    if(exp != NULL)
    {
        regexPattern = Pattern.compile(exp);
        matcher = regexPattern.matcher(field);
        if(matcher.find())
        {
            ID = matcher.group();
        }
    }
    return ID;
}*/

public static List<String> find3PDCaseFromSubjectOrDescriptionList(String exp,String field)
{
    Pattern regexPattern;
    Matcher matcher;
    String ID;
    List<String> matchedStrings = new List<String>();
    if(exp != NULL)
    {
        regexPattern = Pattern.compile(exp);
        matcher = regexPattern.matcher(field);
        while(matcher.find())
        {
            matchedStrings.add(matcher.group());
        }
        
    }
    system.debug('ID+++++++'+ID);
    return matchedStrings;
}
     /*************************************************************************
@Author: Amrita Sarkar
@Date: 13/07/23
@purpose: CRMD-5572 When Case status updated with Design, case owner updated with Queue respective of Distrct
*************************************************************************************/
    public static void caseUpateWithDesignQueue(List<Case> caseNewList){
        //List<Case> cseMapNewVal = (List<Case>)caseNewMap.values();
        //Map<Id,case> cseMapOldVal = (Map<Id,case>)caseOldMap;
        Map<String,String> postcadeVsDistMap = new Map<String,String>();
        Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();
        Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
        List<String> jobTypeList = new List<String>();
        Map<String, Map<Integer, SPEN_DesignQueueRules__c>> mapOfDescription = new Map<String, Map<Integer, SPEN_DesignQueueRules__c>>();
        Map<String, List<SPEN_DesignQueueRules__c>> mapofDesignQueue = new Map<String, List<SPEN_DesignQueueRules__c>>();
        String districtSet = '';
        String jobTypeString = '';
        Set<String> jobTypeSet = new Set<String>();
        Map<String,Id> mapDevNamevsId = new Map<String,Id>();
        try{  
            if(!caseNewList.isEmpty()){
                for(Case cse: caseNewList){
                    if((cse.RecordTypeId == recordTypeIdBudget ||  cse.RecordTypeId == recordTypeIdFormal) && 
                       (cse.Status == CasesConstants.Case_Design || cse.Status == CasesConstants.CASE_BUDGETDESIGN)){
                           districtSet = districtSet != '' ? districtSet + ',\''+ cse.SPEN_ConnectionDistrict__c+'\'' : '\'' + cse.SPEN_ConnectionDistrict__c + '\'';
                           jobTypeString = jobTypeString != '' ? jobTypeString + ',\''+ cse.SPEN_JobType__c+'\'' : '\'' + cse.SPEN_JobType__c + '\'';
                       }
                }
                districtSet = districtSet + ',\'All' + '\'';
                if(districtSet != '' && jobTypeString!= ''){
                    for(SPEN_DesignQueueRules__c designRule : SPEN_CaseSelector.getDesignQueueRuleSet(districtSet,jobTypeString)){
                        if(mapofDesignQueue.containsKey(designRule.SPEN_JobTypeDescription__c)) {
                            mapofDesignQueue.get(designRule.SPEN_JobTypeDescription__c).add(designRule);
                        } else {
                            List<SPEN_DesignQueueRules__c> newList = new List<SPEN_DesignQueueRules__c>();
                            newList.add(designRule);
                            mapofDesignQueue.put(designRule.SPEN_JobTypeDescription__c, newList);
                        }
                        
                    }
                    //String qNameValues=String.valueOf(System.Label.SPEN_DesignQueueLabel); check 201
                    //List<String> queueValues = qNameValues.split(';');

                    //List<Group> queueNameList = SPEN_CaseSelector.getQueueDetailList(queueValues);
                    for(Group queueName : queueNameList){
                        mapDevNamevsId.put(queueName.DeveloperName,queueName.Id);
                    } 
                    
                    for(Case cse: caseNewList){
                        if(!mapofDesignQueue.isEmpty() && (cse.RecordTypeId == recordTypeIdBudget ||  cse.RecordTypeId == recordTypeIdFormal)){
                            
                            List<SPEN_DesignQueueRules__c> listOfMasterData = mapofDesignQueue.get(cse.SPEN_JobType__c);                        
                            for(SPEN_DesignQueueRules__c masterData : listOfMasterData) {
                                if (cse.SPEN_CustomerClass__c == masterData.SPEN_CustomerClass__c 
                                    && cse.SPEN_TotalPlots__c >= masterData.SPEN_MinimumPlot__c
                                    && cse.SPEN_TotalPlots__c <= masterData.SPEN_MaximumPlot__c
                                    && cse.SPEN_RequiredPower__c >= masterData.SPEN_MinimumLoad__c 
                                    && cse.SPEN_RequiredPower__c <= masterData.SPEN_MaximumLoad__c){
                                        List<String> selections = masterData.SPEN_District__c.split(';');
                                        
                                        if(selections.contains(cse.SPEN_ConnectionDistrict__c) || masterData.SPEN_District__c == 'All'){
                                            
                                            cse.OwnerId = mapDevNamevsId.get(masterData.SPEN_QueueNameAPIFormula__c);
                                            break;
                                        }                                     
                                    }
                            }
                        }
                    }
                }
            }
        }catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
	public static void  restrictCaseClouserforOpenQuery(List<sObject> caseNewList){
        List<Case> caseList= (List<Case>)caseNewList;
        List<Case> queryList;//check - soql 201
        Set<Id> caseIdSet=new Set<Id>();
        boolean flag=false;
        for(Case cs :caseList){
            if(/*cs.RecordTypeId ==recordTypeId3PD && */cs.Status =='Closed')  {
                caseIdSet.add(cs.Id);
            }
        }
        if(!caseIdSet.isEmpty())//check - soql 201
        {
            queryList=SPEN_CaseSelector.getQueryCase(caseIdSet);
            
        for(Case cse:queryList){
            if(cse.Status =='Open'){
               flag=true; 
            }
        }
        }//201
         for(Case cs :caseList){
            if(/*cs.RecordTypeId ==recordTypeId3PD &&*/ flag)  {
                cs.addError('Case cannot be closed if Query is open');
            }
        }
    }
    /*************************************************************************
@Author: Kiranmayi
@Date: 13/09/23
@purpose: CRMD-7748 Calculate fixed cumulative application fee
*************************************************************************************/
public static void calculateFixedCumulativeApplicationFee(List<Case> newCasesList,Map<String,Id> finacialCaseMap){
        
    Map <String,List<String>> mapSPT = new Map <String,List<String>>();
    String mapSPTKey;
    String mapSPTValue;
    set<String> apptype = new set<String>();
    list<SPEN_FinancialInformation__c> financialList = new list<SPEN_FinancialInformation__c>();
    String transmissionRecTypeLabel=System.Label.SPEN_TransmissionsRecordType;
    //Get records that have Application fee type is Fixed
    for(case cse : newCasesList){
        
        if(cse.Application_fee_Type__c == 'Fixed'){
            apptype.add(cse.SPEN_ApplicationType__c);
        }
    }
   // List<SPEN_TransmissionApplicationFeeRules__c> transmissionApplicationVarFeeList=SPEN_TransmissionApplicationFeeSelector.getTransmissionApplicationFeeDetails('Fixed');
        if(!apptype.isEmpty())//check - soql 201
        {
    for(SPEN_TransmissionApplicationFeeRules__c spt : SPEN_TransmissionApplicationFeeSelector.getTransmissionApplicationFeeDetailsByApplicationType('Fixed',apptype))
    {
        //Keystring to concatenate the Rule field values
            String keyString = spt.SPEN_ApplicationStage__c+'_1_'+spt.SPEN_ContractArea__c+'_2_'+spt.SPEN_LocationType__c+'_3_'
                +spt.SPEN_PrimaryTransmissionTechnology__c+'_4_'+'_6_'+spt.SPEN_MAXDemandCapacityMWs__c+'_MaxDemand_'
                +spt.SPEN_MAXSizeMWsCECExport__c+'_MaxSize_'+spt.SPEN_MINDemandCapacityMWs__c+'_MinDemand_'
                +spt.SPEN_MINSizeMWsCECExport__c+'_MinSize_';
        //  system.debug(keyString+'keystring');
        
            mapSPTKey = spt.SPEN_ApplicationStage__c+'_1_'+spt.SPEN_ContractArea__c+'_2_'+spt.SPEN_LocationType__c+'_3_'
                +spt.SPEN_PrimaryTransmissionTechnology__c+'_4_';
            
        system.debug(mapSPTValue+'mapSPTKey');
        
        mapSPTValue = '_cumulativeValue_'+spt.SPEN_FixedCumulativeApplicationFee__c+'_demand_'+spt.SPEN_MAXDemandCapacityMWs__c+'_MaxDemand_'
            +spt.SPEN_MAXSizeMWsCECExport__c+'_MaxSize_'+spt.SPEN_MINDemandCapacityMWs__c+'_MinDemand_'
            +spt.SPEN_MINSizeMWsCECExport__c+'_MinSize_'+spt.SPEN_FixedCumulativeApplicationFee__c;
        system.debug(mapSPTValue+'mapSPTValue');
        if(mapSPT.containsKey(mapSPTKey))
        {
            mapSPT.get(mapSPTKey).add(mapSPTValue);
        }
        else
        {
            List<String> mapSPTValueTemp = new List<String>{mapSPTValue};
                mapSPT.put(mapSPTKey,mapSPTValueTemp);
        }
        system.debug(mapSPT+'mapSPT');
            }
    }
    for(Case cse : newCasesList)
    {
            String keyCase = cse.Application_Stage__c+'_1_'+cse.SPEN_ContractArea__c+'_2_'+cse.SPEN_LocationType__c+'_3_'
                +cse.SPEN_PrimaryTransmissionTechnologyType__c+'_4_';
            
        //system.debug(keyCase+'keyCase');
        if(keyCase != null && mapSPT.containsKey(keyCase))
        {                //  Integer cnt = mapSPT.get(keyCase).size();
            for(String strMapSPTVal : mapSPT.get(keyCase))
            {
                //  system.debug(strMapSPTVal+'strMapSPTVal');
                //  system.debug('SPEN_DemandCapacityMWs__c'+cse.SPEN_DemandCapacityMWs__c);
                //  system.debug('SPEN_SizeMWsExportCEC__c'+cse.SPEN_SizeMWsExportCEC__c);                
                //Compare case values with the Range values from the Rules object
                if(strMapSPTVal!= NULL && cse.SPEN_SizeMWsExportCEC__c <=decimal.valueOf(strMapSPTVal.substringBetween('_MaxDemand_','_MaxSize_' ))
                   && cse.SPEN_SizeMWsExportCEC__c >=decimal.valueOf(strMapSPTVal.substringBetween('_MinDemand_','_MinSize_' )) &&
                   cse.SPEN_DemandCapacityMWs__c <=decimal.valueOf(strMapSPTVal.substringBetween('_demand_','_MaxDemand_' )) &&
                   cse.SPEN_DemandCapacityMWs__c >=decimal.valueOf(strMapSPTVal.substringBetween('_MaxSize_','_MinDemand_' )))
                    //    system.debug('SPEN_DemandCapacityMWs__c'+cse.SPEN_DemandCapacityMWs__c);
                    
                {       
                    // Fetch the substring from the key string and assign it to the SPEN_FixedCummulativeApplicationFee__c
                    if(String.isNotBlank(cse.SPEN_FinancialInformation__c)){
                        SPEN_FinancialInformation__c fiInf = new SPEN_FinancialInformation__c();
                        fiInf.Id = cse.SPEN_FinancialInformation__c; 
                        fiInf.SPEN_FixedCummulativeApplicationFee__c = decimal.valueOf(strMapSPTVal.substringBetween('_cumulativeValue_', '_demand_'));
                        financialList.add(fiInf);

                    }else if(!finacialCaseMap.isEmpty() && finacialCaseMap.get(cse.CaseNumber) != null){
                        SPEN_FinancialInformation__c fiInf = new SPEN_FinancialInformation__c();
                        fiInf.Id = finacialCaseMap.get(cse.CaseNumber);
                        fiInf.SPEN_FixedCummulativeApplicationFee__c = decimal.valueOf(strMapSPTVal.substringBetween('_cumulativeValue_', '_demand_'));
                        financialList.add(fiInf);
                    }
                    break;
                }
                // String combineKey = keyCase+strMapSPTVal;
            }
            
        }
    }
    if(!financialList.isEmpty() && financialList.size() > 0){
        update financialList;
    }
    
    
}
 /*************************************************************************
@Author: Amrita Sarkar
@Date: 27/07/23
@purpose: CRMD-6828 Physical Information Worklist - Pause/Resume GS clock and auto status change
*************************************************************************************/
    public static void caseUpateWithInformationStatus(List<Case> caseList)
    {
        try{
            if(!caseList.isEmpty()){
                for(Case cse: caseList){
                    if(CasesConstants.Case_Design.equals(cse.Status) || CasesConstants.CASE_BUDGETDESIGN.equals(cse.Status)){
                        if( cse.SPEN_SubStatus__c == CasesConstants.CASE_COMPETENT &&  cse.SPEN_NumberofPhysicalInformation__c > 0){
                            cse.SPEN_InformationStatus__c = CasesConstants.CASE_ADDINFOSTATUS;
                        }else if(cse.SPEN_SubStatus__c == CasesConstants.CASE_NOTCOMPETENT &&  cse.SPEN_NumberofPhysicalInformation__c > 0){
                            cse.SPEN_InformationStatus__c = CasesConstants.CASE_AWAITINGMININFOSTATUS;
                        }else if(cse.SPEN_SubStatus__c == CasesConstants.CASE_NOTCOMPETENT  && 
                                 cse.SPEN_NumberofPhysicalInformation__c == 0){
                                     cse.SPEN_InformationStatus__c = CasesConstants.CASE_PHYINFORECSTATUS;
                                 }
                        else if(cse.SPEN_SubStatus__c == CasesConstants.CASE_COMPETENT && 
                                cse.SPEN_NumberofPhysicalInformation__c == 0){
                                    cse.SPEN_InformationStatus__c = CasesConstants.CASE_ABLETOQUOTEINFOSTATUS;
                                }
                    }
                }
            }
            
        }catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }
    public static void  updateQueryEmailThread(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Case> caseList= newCaseMap.values();
        List<SPEN_Case_Tracker__c> listTracker= new List<SPEN_Case_Tracker__c>();
        Set<Id> setQueryCaseId = new Set<Id>();
        Set<ID> setOldOwnerID = new Set<Id>();
        Set<ID> setOldQueueID = new Set<Id>();
//CRMD-10627 - Start
        Set<Id> newParentAccountCaseIDSet = new Set<Id>();
        Set<Id> oldParentAccountCaseIDSet = new Set<Id>();
        Map<ID, String> mapNewAccountIDAndName = new Map<Id,String>();
        Map<ID, String> mapOldAccountIDAndName = new Map<Id,String>();
        
        //CRMD-10627 - End
        Map<ID, String> mapQueueId2Name = new Map<Id,String>();
        Map<ID, String> mapUserId2Name = new Map<Id,String>();
        List<EmailMessage> lstEmailMessage = new List<EmailMessage>();//check - soql 201
        
        for(Case newCase: newCaseMap.values())
        {
            Case oldCase = oldCaseMap.get(newCase.id);
//CRMD-10627 - Start
            system.debug('newCase.SPEN_PartnerAccount__c: '+newCase.SPEN_PartnerAccount__c);
            if((newCase.recordtypeid == recordTypeIdGE || newCase.recordtypeId == recordTypeIdSI || newCase.recordtypeId == recordTypeIdLCT) 
            && newCase.SPEN_PartnerAccount__c != NULL && oldCaseMap.get(newCase.id).SPEN_PartnerAccount__c != newCase.SPEN_PartnerAccount__c)
            {
                newParentAccountCaseIDSet.add(newCase.SPEN_PartnerAccount__c);
                oldParentAccountCaseIDSet.add(oldCase.SPEN_PartnerAccount__c);
            }
            //CRMD-10627 - END
            if(newCase.OwnerId.getsobjecttype() == User.sobjecttype){
                setOldOwnerID.add(newCase.ownerId);
            }
            else{
                setOldQueueID.add(newCase.ownerId);
            }
            if(oldCase.OwnerId.getsobjecttype() == User.sobjecttype){
                setOldOwnerID.add(oldCase.ownerId);
            }
            else{
                setOldQueueID.add(oldCase.ownerId);
            }
        }
        if(!setOldQueueID.isEmpty())//check - soql 201
        {
        mapQueueId2Name = SPEN_CaseSelector.getQueueName(setOldQueueID);
        }
        if(!setOldOwnerID.isEmpty())//check - soql 201
        {
        mapUserId2Name = SPEN_CaseSelector.getUserName(setOldOwnerID);
        }
//CRMD-10627 - Start\
        system.debug('newParentAccountCaseIDSet: '+newParentAccountCaseIDSet);
        system.debug('oldParentAccountCaseIDSet: '+oldParentAccountCaseIDSet);
        if(!newParentAccountCaseIDSet.isEmpty())
        {
            mapNewAccountIDAndName = SPEN_CaseSelector.getNewParentAccountName(newParentAccountCaseIDSet);
        }
        if(!oldParentAccountCaseIDSet.isEmpty())
        {
            mapOldAccountIDAndName = SPEN_CaseSelector.getOldParentAccountName(oldParentAccountCaseIDSet);
        }
        //CRMD-10627 - End
        for(Case caseRec : caseList)
        {
//CRMD-10627 - Start
            if(!mapNewAccountIDAndName.isEmpty())
            {
                SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
                ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
                ctRec.SPEN_ParentCase__c = caseRec.id;
                ctRec.SPEN_PreviousValue__c = mapOldAccountIDAndName.get(oldCaseMap.get(caseRec.id).SPEN_PartnerAccount__c);
                ctRec.SPEN_NewValue__c = mapNewAccountIDAndName.get(caseRec.SPEN_PartnerAccount__c);
                ctRec.Case_Tracker_Type__c = 'Partner Account Update';
                listTracker.add(ctRec);
            }
            //CRMD-10627 - END
            //3PDQuery
            if(caseRec.recordtypeid == recordTypeIdQuery && caseRec.SPEN_Type__c== 'Third Party Damage' &&
            caseRec.status != oldCaseMap.get(caseRec.id).status
            && caseRec.status.equalsIgnoreCase('Closed'))
            {
                setQueryCaseId.add(caseRec.Id);
                if(caseRec.SPEN_CaseAssignmentTime__c != null && caseRec.OwnerId.getsobjecttype() == User.sobjecttype)
                {
                    SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
                    ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
                    ctRec.SPEN_StartTime__c = caseRec.SPEN_CaseAssignmentTime__c;
                    ctRec.SPEN_EndTime__c = caseRec.closedDate;
                    ctRec.SPEN_ParentCase__c = caseRec.id;
                    ctRec.Case_Tracker_Type__c = '3PD Accepted > Closed';
                    if(ctRec.SPEN_StartTime__c != null && ctRec.SPEN_EndTime__c != null)
                    {
                        ctRec.SPEN_AgentHandlingTimeInMinutes__c = SPEN_BusinessDaysCalculationUtil.getAgentHandlingTimeinMinutes(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                        ctRec.SPEN_AgentHandlingTime__c = SPEN_BusinessDaysCalculationUtil.calculateTimeDiffinString(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                    }
                    listTracker.add(ctRec);
                }
            }
            System.debug('recordTypeId3PD:'+recordTypeId3PD);
            //Status Update - NRSWA + 3PD Parent Case //CRMD-10441 - GE Added  //CRMD-10627 - SI Added
            if((caseRec.recordtypeid == recordTypeId3PD || caseRec.recordtypeid == recordTypeIdGE ||caseRec.recordtypeid == recordTypeIdSI || caseRec.recordtypeid == recordTypeIdLCT
            || caseRec.recordtypeid == recordTypeIdNRSWA 
            || (caseRec.recordtypeid == recordTypeIdQuery && caseRec.SPEN_Type__c == 'NRSWA')|| 
                caseRec.recordtypeid == recordTypeIdSW ||(caseRec.recordtypeid == recordTypeIdQuery && caseRec.SPEN_Type__c == 'StreetWorks')) 
            && caseRec.status != oldCaseMap.get(caseRec.id).status
            && caseRec.status != 'Reopened' && caseRec.status != 'Open')
            {
                SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
//CRMD-10627 - Start
                if(caseRec.status == 'With Partner' && caseRec.SPEN_PartnerAssignmentTime__c != NUll)
                {
                   ctRec.SPEN_PartnerAssignmentTime__c = caseRec.SPEN_PartnerAssignmentTime__c; 
                }
                 //CRMD-10627 - End
                ctRec.SPEN_StartTime__c = oldCaseMap.get(caseRec.id).SPEN_LastStatusChangeDate__c;
                ctRec.SPEN_EndTime__c = system.now();
                ctRec.SPEN_ParentCase__c = caseRec.id;
                ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
                //ctRec.SPEN_CaseOwnerName__c = mapQueueId2Name.containsKey(caseRec.ownerId) ? mapQueueId2Name.get(caseRec.ownerId) : mapUserId2Name.get(caseRec.ownerId);
                ctRec.SPEN_PreviousValue__c = oldCaseMap.get(caseRec.id).status;
                ctRec.SPEN_NewValue__c = caseRec.status;
                if(ctRec.SPEN_StartTime__c != null && ctRec.SPEN_EndTime__c != null)
                {
                    ctRec.SPEN_AgentHandlingTimeInMinutes__c = SPEN_BusinessDaysCalculationUtil.getAgentHandlingTimeinMinutes(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                    ctRec.SPEN_AgentHandlingTime__c = SPEN_BusinessDaysCalculationUtil.calculateTimeDiffinString(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                }
//CRMD-10627 - Start
                 if(caseRec.status == 'Job Completed' && caseRec.SPEN_PartnerAssignmentTime__c != null && ctRec.SPEN_EndTime__c != null)
                {
                    ctRec.SPEN_PartnerAssignmentTime__c = caseRec.SPEN_PartnerAssignmentTime__c; 
                    ctRec.SPEN_PartnerHandlingTimeInMinutes__c = SPEN_BusinessDaysCalculationUtil.getAgentHandlingTimeinMinutes(ctRec.SPEN_PartnerAssignmentTime__c, ctRec.SPEN_EndTime__c);
                    ctRec.SPEN_PartnerHandlingTime__c = SPEN_BusinessDaysCalculationUtil.calculateTimeDiffinString(ctRec.SPEN_PartnerAssignmentTime__c, ctRec.SPEN_EndTime__c);
                }
                  //CRMD-10627 - End
                ctRec.Case_Tracker_Type__c = 'Case Status Update';
                listTracker.add(ctRec);
            }
            //Owner Update - NRSWA + Query //CRMD-10441 - GE Added, CRMD-10752- LCT added  //201
            if((caseRec.recordtypeid == recordTypeId3PD || caseRec.recordtypeid == recordTypeIdGE || caseRec.recordtypeId == recordTypeIdLCT || caseRec.recordtypeid == recordTypeIdNRSWA || (caseRec.recordtypeid == recordTypeIdQuery && caseRec.SPEN_Type__c == 'NRSWA') ||
               caseRec.recordtypeid == recordTypeIdSW ||(caseRec.recordtypeid == recordTypeIdQuery && caseRec.SPEN_Type__c == 'StreetWorks'))
            && caseRec.ownerId != oldCaseMap.get(caseRec.id).ownerId && (!mapQueueId2Name.isEmpty() || !mapUserId2Name.isEmpty())
            )
            {
                SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
                ctRec.SPEN_PreviousValue__c =  mapQueueId2Name.containsKey(oldCaseMap.get(oldCaseMap.get(caseRec.id).id).ownerId) ? mapQueueId2Name.get(oldCaseMap.get(caseRec.id).ownerId) : mapUserId2Name.get(oldCaseMap.get(caseRec.id).ownerId);
                ctRec.SPEN_NewValue__c =  mapQueueId2Name.containsKey(caseRec.ownerId) ? mapQueueId2Name.get(caseRec.ownerId) : mapUserId2Name.get(caseRec.ownerId);
                ctRec.SPEN_StartTime__c = oldCaseMap.get(caseRec.id).SPEN_CaseAssignmentTime__c;
                ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
                ctRec.SPEN_EndTime__c = system.now();
                ctRec.SPEN_ParentCase__c = caseRec.id;
				ctRec.SPEN_OwnerAssignmentType__c = 'Manual';//CRMD-10516
                if(!(caseRec.recordtypeid == recordTypeId3PD ))//CRMD-9029
                {
                ctRec.SPEN_Reassignment_Reason__c = caseRec.Reassignment_Reason__c;//CRMD-8398
                }
                if(ctRec.SPEN_StartTime__c != null && ctRec.SPEN_EndTime__c != null)
                {
                    ctRec.SPEN_AgentHandlingTimeInMinutes__c = SPEN_BusinessDaysCalculationUtil.getAgentHandlingTimeinMinutes(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                	ctRec.SPEN_AgentHandlingTime__c = SPEN_BusinessDaysCalculationUtil.calculateTimeDiffinString(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                }
                ctRec.Case_Tracker_Type__c = 'Case Owner Update';
                listTracker.add(ctRec);
            }
           //CRMD-9643 S
            //NRSWA SW Query SLA Date Update
            if(caseRec.recordtypeid == recordTypeIdQuery && (caseRec.SPEN_Type__c == 'NRSWA' 
               || caseRec.SPEN_Type__c == 'StreetWorks') 
               &&((caseRec.SPEN_SLADueDate__c != null && oldCaseMap.get(caseRec.id).SPEN_SLADueDate__c != null && 
				caseRec.SPEN_SLADueDate__c.format('dd/MM/yyyy kk:mm') != oldCaseMap.get(caseRec.id).SPEN_SLADueDate__c.format('dd/MM/yyyy kk:mm')
     			) || ((caseRec.SPEN_SLADueDate__c == null || oldCaseMap.get(caseRec.id).SPEN_SLADueDate__c == null) && caseRec.SPEN_SLADueDate__c != oldCaseMap.get(caseRec.id).SPEN_SLADueDate__c)
               ))
            { 
                SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
                ctRec.SPEN_PreviousValue__c =oldCaseMap.get(caseRec.id).SPEN_SLADueDate__c != null ? oldCaseMap.get(caseRec.id).SPEN_SLADueDate__c.format('dd/MM/yyyy kk:mm'): null;
                ctRec.SPEN_NewValue__c = caseRec.SPEN_SLADueDate__c != null ? caseRec.SPEN_SLADueDate__c.format('dd/MM/yyyy kk:mm') : null;
                ctRec.SPEN_StartTime__c = system.now();
                ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
                ctRec.Case_Tracker_Type__c = 'Case SLA Update';
                ctRec.SPEN_ParentCase__c = caseRec.id;
                listTracker.add(ctRec);
            }

            //NRSWA SW Query Routing Outcome Update
            if(caseRec.recordtypeid == recordTypeIdQuery && (caseRec.SPEN_Type__c == 'NRSWA' 
            || caseRec.SPEN_Type__c == 'StreetWorks') 
            && caseRec.SPEN_Email_WI_Queue_Routing_Outcome__c != oldCaseMap.get(caseRec.id).SPEN_Email_WI_Queue_Routing_Outcome__c
            )
            { 
                SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
                ctRec.SPEN_PreviousValue__c =  oldCaseMap.get(caseRec.id).SPEN_Email_WI_Queue_Routing_Outcome__c != null ? oldCaseMap.get(caseRec.id).SPEN_Email_WI_Queue_Routing_Outcome__c:null;
                ctRec.SPEN_NewValue__c =  caseRec.SPEN_Email_WI_Queue_Routing_Outcome__c; 
                ctRec.SPEN_StartTime__c = system.now();
                ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
                ctRec.Case_Tracker_Type__c = 'Case Routing Outcome Update';
                ctRec.SPEN_ParentCase__c = caseRec.id;
                listTracker.add(ctRec);
            }
            //CRMD-9643 E
        }
        if(!setQueryCaseId.isEmpty())//check - soql 201 - S
        {
            lstEmailMessage = SPEN_EmailMessageSelector.getIncomingEmailMsg(setQueryCaseId);
            
        for(EmailMessage eml: lstEmailMessage)
        {
            Date closedDate = Date.valueOf(newCaseMap.get(eml.parentId).ClosedDate);
            Date createdDate = Date.valueOf(eml.createdDate);
            eml.SPEN_AgentResponseTime__c = createdDate.daysBetween(closedDate);
        }
        if(!lstEmailMessage.isEmpty())
        {
            update lstEmailMessage;
        }
        }//check - soql 201 - E
        if(!listTracker.isEmpty())
        {
            try{
                 insert listTracker;
            }catch(exception exp){
                
            }
        }
    }
    public static void  chkDistrictForSW(List<sObject> caseNewList){
        List<Case> caseList= (List<Case>)caseNewList; 
        String district;
         Set<String> zoneSet=new Set<String>();
         Map<String,SPEN_Zone__c> zoneMap = new Map<String,SPEN_Zone__c>();
         for(Case cs :caseList)
         {
             if((cs.RecordTypeId ==recordTypeIdSW || cs.RecordTypeId ==recordTypeId3PD || cs.RecordTypeId == recordTypeIdNRSWA) && cs.SPEN_ConnectionDistrict__c!=null)  
             {
                 zoneSet.add(cs.SPEN_ConnectionDistrict__c);
                 district=cs.SPEN_ConnectionDistrict__c;
             }
         }
        /* if(zoneSet!=null && zoneSet.size()>0) //Added for 101 test class fixed
{*/ //check - soql 201
        if(!zoneSet.isEmpty())//check - soql 201
         {
             for(SPEN_Zone__c zoneRecord : [Select Id,Name,SPEN_SPD_SPM__c,SPEN_Zone_District_Formula__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where Name In :zoneSet])
             {
                 zoneMap.put(zoneRecord.Name,zoneRecord);
             }
         }
        for(Case cse: caseList)
        {  
            if((cse.RecordTypeId ==recordTypeId3PD || cse.RecordTypeId == recordTypeIdNRSWA) && cse.SPEN_Incident__c!=null && userInfo.getUserName() !=System.Label.SPEN_WebFormModifiedUsername){
            //before Insert //201
                if(!beforeInsertIncidentMap.isEmpty() && beforeInsertIncidentMap!=null && beforeInsertIncidentMap.containsKey(cse.SPEN_Incident__c)){
                    cse.SPEN_SPDSPMIndicator__c=beforeInsertIncidentMap.get(cse.SPEN_Incident__c).SPEN_SPDSPM__c;
                    If(beforeInsertIncidentMap.get(cse.SPEN_Incident__c).SPEN_District__c!=null){
                    cse.SPEN_ConnectionDistrict__c=beforeInsertIncidentMap.get(cse.SPEN_Incident__c).SPEN_District__c;
                    }
                }
                //before update
                else if(afterInsertIncidentMap!=null && afterInsertIncidentMap.containsKey(cse.SPEN_Incident__c)){
                    cse.SPEN_SPDSPMIndicator__c=afterInsertIncidentMap.get(cse.SPEN_Incident__c).SPEN_SPDSPM__c;
                    If(afterInsertIncidentMap.get(cse.SPEN_Incident__c).SPEN_District__c!=null){
                    cse.SPEN_ConnectionDistrict__c=afterInsertIncidentMap.get(cse.SPEN_Incident__c).SPEN_District__c;
                    }
                }
            }
            //201
            else if((cse.RecordTypeId ==recordTypeIdSW || cse.RecordTypeId ==recordTypeId3PD || cse.RecordTypeId == recordTypeIdNRSWA) // && zoneMap!=null
                     && !zoneMap.isEmpty() && zoneMap.containsKey(district) && userInfo.getUserName() !=System.Label.SPEN_WebFormModifiedUsername)
                {
                    cse.SPEN_DistrictZone__c = zoneMap.get(district).id;
                    cse.SPEN_SPDSPMIndicator__c = zoneMap.get(district).SPEN_SPD_SPM__c;
                }
            //CRMD-9451 by Sumit
            else if((cse.RecordTypeId == recordTypeIdNRSWA || cse.RecordTypeId == recordTypeIdSW) && cse.Origin == CasesConstants.originWEB)
            {
                if(cse.SPEN_WorkLocation__c == CasesConstants.location_England || cse.SPEN_WorkLocation__c == CasesConstants.location_Wales)
                {
                    cse.SPEN_SPDSPMIndicator__c = 'SPM';
                }
                else if(cse.SPEN_WorkLocation__c == CasesConstants.location_Scotland)
                {
                    cse.SPEN_SPDSPMIndicator__c = 'SPD';
                }
            }
        }
        
         updateBusinessHoursForNRSWA(caseNewList); //CRMD-7609
     }
/*************************************************************************
@Author: Amrita Sarkar
@Date: 22/09/23
@purpose: Update old Communication Scheduler Records to Aborted and Create new Communication Scheduler records according to event type
*************************************************************************************/
@future(callout=false)
public static void updateCommunicationSchedulerRecrd(List<Id> caseList,String caseEventType)
{
    Id emailCommSchrecordTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByDeveloperName().get('SPEN_EmailNotification').getRecordTypeId();
    Id taskCommSchrecordTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByDeveloperName().get('SPEN_TaskNotification').getRecordTypeId();
    List<String> recordtypeList = new List<String>();
    List<SPEN_CommunicationScheduler__c> commSchList = new List<SPEN_CommunicationScheduler__c>();
    Set<String> eventTypeSet = new Set<String>();
    
        //BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs(); //check - soql 201
    List<SPEN_CommunicationScheduler__c> schCommList = new List<SPEN_CommunicationScheduler__c>();
    
    try{
        Map<id, String> mapOfDetails = new Map<id, String>();
	Map<id, Date> mapOfEvetDet = new Map<id, Date>();
	Map<id, DateTime> mapOfDtTime = new Map<id, DateTime>();
        if(caseEventType!= null && caseEventType == 'IsPaused')
            {
                if(!caseList.isEmpty())//check - soql 201
        {
            for(Case cseRec : [Select id,SPEN_PausedStatus__c, SPEN_OfgemMarketSegment__c from Case where ID IN : caseList]){
                if(cseRec.SPEN_OfgemMarketSegment__c == 'N/A'|| cseRec.SPEN_OfgemMarketSegment__c == 'LVHV'|| cseRec.SPEN_OfgemMarketSegment__c == 'LVAL'){
                    mapOfDetails.put(cseRec.Id, 'isLVHV');
                } else if(cseRec.SPEN_OfgemMarketSegment__c != 'N/A' && cseRec.SPEN_OfgemMarketSegment__c != 'LVHV' && cseRec.SPEN_OfgemMarketSegment__c != 'LVAL'
                        && cseRec.SPEN_OfgemMarketSegment__c != 'LVSSA' && cseRec.SPEN_OfgemMarketSegment__c != 'LVSSB'){
                            mapOfDetails.put(cseRec.Id, 'isNonLVHV');
                                  }
                        }
            }
            if(caseEventType!= null && caseEventType == 'IsPaused'){
                eventTypeSet.add(CasesConstants.CASE_5DAYSEMAILEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_15DAYSEMAILEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_10DAYSTASKEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_20DAYSTASKEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_10DAYSEMAILEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_45DAYSEMAILEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_15DAYSTASKEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_60DAYSTASKEVENTNAME);
                recordtypeList.add(emailCommSchrecordTypeId);
                recordtypeList.add(taskCommSchrecordTypeId);
            }
        }//customer engagement note logic for 8,10 & 12 week
        else if(caseEventType!= null && caseEventType == 'Customer Engagement')
            {
                if(!caseList.isEmpty())//check - soql 201
        {
            for(Case cseRec : [Select id from Case where ID IN : caseList])
            {
                mapOfDetails.put(cseRec.Id, 'CustEng');
                    }
            }
            if(caseEventType!= null && caseEventType == 'Customer Engagement'){
                eventTypeSet.add(CasesConstants.CASE_CUSTENGPUMPDMTASKEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_CUSTENGHODTASKEVENTNAME);
                eventTypeSet.add(CasesConstants.CASE_CUSTENGPMTASKEVENTNAME);
                recordtypeList.add(emailCommSchrecordTypeId);
                recordtypeList.add(taskCommSchrecordTypeId);
            }

        }
	//CRMD-1236 Logic to trigger task notification 
        else if(caseEventType!= null && caseEventType == 'Energization Date'){
                if(!caseList.isEmpty())//check - soql 201
                {
            for(Case cseRec : [Select id,SPEN_FinalEnergisationDate__c from Case where ID IN : caseList])
            {
                mapOfDetails.put(cseRec.Id, 'EnergizationDate');
		mapOfEvetDet.put(cseRec.Id,cseRec.SPEN_FinalEnergisationDate__c);
                    }
            }
            if(caseEventType!= null && caseEventType == 'Energization Date')
            {
                eventTypeSet.add(CasesConstants.CASE_ENERGISATIONTASKEVENTNAME);
                recordtypeList.add(taskCommSchrecordTypeId);
            }
        }
        
        //CRMD-1211 Starts here           
        else if(caseEventType!= null && caseEventType == 'ITTIssued Notification')
        {
                if(!caseList.isEmpty())//check - soql 201
                {
             for(Case cseRec : [Select id,SPEN_ITTIssuedDate__c from Case where ID IN : caseList])
            {
                mapOfDetails.put(cseRec.Id, 'ITTNotification');
		mapOfEvetDet.put(cseRec.Id,cseRec.SPEN_ITTIssuedDate__c);
                system.debug('mapOfDetails>>>>>>>>>>'+mapOfDetails);
                    }
            }
            if(caseEventType!= null && caseEventType == 'ITTIssued Notification')
            {
                eventTypeSet.add(CasesConstants.CASE_ITTISSUEDTASKEVENTNAME);
                recordtypeList.add(emailCommSchrecordTypeId);
                recordtypeList.add(taskCommSchrecordTypeId);
            }
        }else if(caseEventType!= null && caseEventType == '2daysPriorTask'){
                	eventTypeSet.add('2 days Prior Post Acceptance task');
                    recordtypeList.add(taskCommSchrecordTypeId);
                if(!caseList.isEmpty())//check - soql 201
                {
                for(Case cseRec : [Select id,SPEN_GSDueDate__c from Case where ID IN : caseList]){
                    mapOfDetails.put(cseRec.Id, '2daysPriorTask');
                    mapOfDtTime.put(cseRec.Id,cseRec.SPEN_GSDueDate__c);
                    }
            }
        }
         //CRMD-1211 Ends here
            if(!recordtypeList.isEmpty() && !eventTypeSet.isEmpty() && !caseList.isEmpty())//check - soql 201
            {
        for(SPEN_CommunicationScheduler__c prevSch : [Select id, SPEN_Status__c from SPEN_CommunicationScheduler__c where RecordTypeId IN : recordtypeList 
                                                      AND SPEN_Event__c IN : eventTypeSet AND SPEN_Case__c =: caseList AND SPEN_Status__c =: CasesConstants.COMMSCHDULER_STATUSSCHEDULED]){
                   prevSch.SPEN_Status__c = CasesConstants.COMMSCHDULER_STATUSABORTED; 
                   commSchList.add(prevSch);
                                                              }
            }
        if(commSchList != null && commSchList.size() > 0){
            update commSchList;
        }
        if(mapOfDetails != null && !mapOfDetails.isEmpty()){
        for(String caseId : mapOfDetails.keySet()){
            if(mapOfDetails.get(caseId) == 'isLVHV'){
                SPEN_CommunicationScheduler__c emailCommSchRec1 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_5DaysSystemEmail),CasesConstants.CASE_5DAYSEMAILEVENTNAME,emailCommSchrecordTypeId,caseId,'case',null,null);
                        SPEN_CommunicationScheduler__c emailCommSchRec2 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_15DaysSystemEmail),CasesConstants.CASE_15DAYSEMAILEVENTNAME,emailCommSchrecordTypeId,caseId,'case',null,null);
                        SPEN_CommunicationScheduler__c taskCommSchRec1 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_10DaysTask),CasesConstants.CASE_10DAYSTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','First Reminder: Customer contact needed',null);
                        SPEN_CommunicationScheduler__c taskCommSchRec2 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_20DaysTask),CasesConstants.CASE_20DAYSTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Final Reminder: Customer contact needed',null);                  
                schCommList.add(emailCommSchRec1);
                schCommList.add(emailCommSchRec2);
                schCommList.add(taskCommSchRec1);
                schCommList.add(taskCommSchRec2);
            }else if(mapOfDetails.get(caseId) == 'isNonLVHV'){
                        SPEN_CommunicationScheduler__c emailCommSchRec1 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_10DaysSystemEmail),CasesConstants.CASE_10DAYSEMAILEVENTNAME,emailCommSchrecordTypeId,caseId,'case',null,null);
                        SPEN_CommunicationScheduler__c emailCommSchRec2 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_45DaysSystemEmail),CasesConstants.CASE_45DAYSEMAILEVENTNAME,emailCommSchrecordTypeId,caseId,'case',null,null);
                        SPEN_CommunicationScheduler__c taskCommSchRec1 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_15DaysTask),CasesConstants.CASE_15DAYSTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','First Reminder: Customer contact needed',null);
                        SPEN_CommunicationScheduler__c taskCommSchRec2 = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_60DaysTask),CasesConstants.CASE_60DAYSTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Final Reminder: Customer contact needed',null);
                schCommList.add(emailCommSchRec1);
                schCommList.add(emailCommSchRec2);
                schCommList.add(taskCommSchRec1);
                schCommList.add(taskCommSchRec2);                   
            }

            else if(mapOfDetails.get(caseId) == 'CustEng')
            {
                        SPEN_CommunicationScheduler__c taskCommSchRecPUMPDM = createCommSchdlerRecordWithoutBusinessDays( Integer.valueOf(System.label.SPEN_CustomerEngagementTaskPUMPDM),CasesConstants.CASE_CUSTENGPUMPDMTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Action needed - Customer Engagement Required',null);
                        SPEN_CommunicationScheduler__c taskCommSchRecHOD = createCommSchdlerRecordWithoutBusinessDays( Integer.valueOf(System.label.SPEN_CustomerEngagementTaskHOD),CasesConstants.CASE_CUSTENGHODTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Action needed - Customer Engagement Required',null);
                        SPEN_CommunicationScheduler__c taskCommSchRecPM = createCommSchdlerRecordWithoutBusinessDays( Integer.valueOf(System.label.SPEN_CustomerEngagementTaskPM),CasesConstants.CASE_CUSTENGPMTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Action needed - Customer Engagement Required',null);
                schCommList.add(taskCommSchRecPUMPDM);
                schCommList.add(taskCommSchRecHOD);
                schCommList.add(taskCommSchRecPM);
            }
	    //CRMD-1236 Starts here
            else if(mapOfDetails.get(caseId) == 'EnergizationDate')
                    {
                        SPEN_CommunicationScheduler__c energisationtaskCommSchRecPM = createCommSchdlerRecordWithoutBusinessDays( Integer.valueOf(System.label.SPEN_EnergisationDateTaskPM),CasesConstants.CASE_ENERGISATIONTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Reminder - To Perform Hand Over Meeting',mapOfEvetDet.get(caseId));
                       // SPEN_CommunicationScheduler__c energisationtask2CommSchRecPM = createCommSchdlerRecordWithoutBusinessDays( Integer.valueOf(System.label.SPEN_EnergisationDateTaskPM),CasesConstants.CASE_ENERGISATIONTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Reminder - To Perform Pre Survey Close Down Call ',mapOfEvetDet.get(caseId));
                        schCommList.add(energisationtaskCommSchRecPM);
                        
                    }
		        else if(mapOfDetails.get(caseId) == 'ITTNotification')
                   {
                       SPEN_CommunicationScheduler__c taskCommSchRecITTISSUED = createCommSchdlerRecordWithoutBusinessDays( Integer.valueOf(System.label.SPEN_ITTISSUED),CasesConstants.CASE_ITTISSUEDTASKEVENTNAME,taskCommSchrecordTypeId,caseId,'case','Reminder - ITTIssued Date is due in 24 hours',mapOfEvetDet.get(caseId));
                       schCommList.add(taskCommSchRecITTISSUED);
                   }
                    //CRMD-1211 Ends here
                    else if(mapOfDetails.get(caseId) == '2daysPriorTask'){
                        SPEN_CommunicationScheduler__c priorTaskCommSchRec = createCommSchdlerRecord( Long.valueOf(System.label.SPEN_2DaysPriorAcceptance_Task),'2 days Prior Post Acceptance task',taskCommSchrecordTypeId,caseId,'case','Outstanding Post Acceptance Contact',mapOfDtTime.get(caseId));
                    	system.debug('priorTaskCommSchRec**' + priorTaskCommSchRec);
                        schCommList.add(priorTaskCommSchRec);
                    }
                }
                system.debug('commScheduler***' + schCommList.size());
                if(schCommList != null && schCommList.size() > 0){
                    insert schCommList;
                }                  
            }                             
        }catch(exception ex)
        {
            system.debug('exceptio** ' + ex);
            SEL_LoggingService.log(ex);
        }
    }
    /*************************************************************************
@Author: Amrita Sarkar
@Date: 22/09/23
@purpose: Create new Communication Scheduler records according to event type
*************************************************************************************/
    public static SPEN_CommunicationScheduler__c createCommSchdlerRecord(Long reminderDate,String eventName,String recordTypeId,String Id,String sobj,String message,DateTime eventDate)
    {
        //BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();  //check - soql 201
        SPEN_CommunicationScheduler__c commSchRec =  New SPEN_CommunicationScheduler__c();
        if(eventDate != null){
            commSchRec.SPEN_ScheduledDateTime__c = Cases.getWorkingDays(bh.Id, eventDate, reminderDate);
        }else{
           commSchRec.SPEN_ScheduledDateTime__c =  Cases.getWorkingDays(bh.Id, system.now(), reminderDate); 
        }
    if(sobj == 'case')
    {
        commSchRec.SPEN_Case__c = Id;
    }
    else if(sobj == 'account')
    {
        commSchRec.SPEN_Account__c = Id;
    }
    commSchRec.RecordTypeId = recordTypeId;
    commSchRec.SPEN_Event__c = eventName;
    commSchRec.SPEN_Status__c = CasesConstants.COMMSCHDULER_STATUSSCHEDULED;
    commSchRec.SPEN_Message__c = message;
    return commSchRec;
}

public static SPEN_CommunicationScheduler__c createCommSchdlerRecordWithoutBusinessDays(Integer reminderDate,String eventName,String recordTypeId,String Id,String sobj,String message,Date eventDate)
{
    //BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs(); 
    SPEN_CommunicationScheduler__c commSchRec =  New SPEN_CommunicationScheduler__c();
    commSchRec.SPEN_ScheduledDateTime__c =  (eventDate == null ? system.now() : eventDate).addDays(reminderDate);
    if(sobj == 'case')
    {
        commSchRec.SPEN_Case__c = Id;
    }
    else if(sobj == 'account')
    {
        commSchRec.SPEN_Account__c = Id;
    }
    commSchRec.RecordTypeId = recordTypeId;
    commSchRec.SPEN_Event__c = eventName;
    commSchRec.SPEN_Status__c = CasesConstants.COMMSCHDULER_STATUSSCHEDULED;
    commSchRec.SPEN_Message__c = message;
    return commSchRec;
}
    /*************************************************************************
@Author: Amrita Sarkar
@Date: 18/10/23
@purpose: CRMD-1342 case field GS Due Date
*************************************************************************************/
    public static void updateCaseGSDueDateForPostAccp(List<Case> listOfCase,Set<Id> caseIdSet){
        try{
            Map<id,SPEN_SAPSLACreation__c> caseIdVsSLADetMap = new Map<id,SPEN_SAPSLACreation__c>();
            for (SPEN_SAPSLACreation__c sapSLARec : [select id,SPEN_Status__c,SPEN_RelatedCase__c,SPEN_Plannedfinishdate__c,SPEN_SLADescription__c,SPEN_PlannedFinishTime__c from SPEN_SAPSLACreation__c where 
                                                     SPEN_RelatedCase__c IN : caseIdSet and SPEN_SLADescription__c = 'Post Acceptance Contact Time']){
                                                         caseIdVsSLADetMap.put(sapSLARec.SPEN_RelatedCase__c,sapSLARec);
                                                     }
            for(Case cse: listOfCase){
                if(caseIdVsSLADetMap != null && !caseIdVsSLADetMap.isEmpty() && caseIdVsSLADetMap.containsKey(cse.id)){
                    if(caseIdVsSLADetMap.get(cse.id).SPEN_PlannedFinishTime__c != null  && caseIdVsSLADetMap.get(cse.id).SPEN_Plannedfinishdate__c != null){ //CRMD-9455 Start
                        String plannedFinisedTime = caseIdVsSLADetMap.get(cse.id).SPEN_PlannedFinishTime__c;
                        List<String> splitTime = plannedFinisedTime.split(':');
                        cse.SPEN_GSDueDate__c = Datetime.newInstance((caseIdVsSLADetMap.get(cse.id).SPEN_Plannedfinishdate__c), Time.newInstance(Integer.valueOf(splitTime[0]),Integer.valueOf(splitTime[1]),Integer.valueOf(splitTime[2]),0));
                    }else{
                        cse.SPEN_GSDueDate__c = caseIdVsSLADetMap.get(cse.id).SPEN_Plannedfinishdate__c;
                    }//CRMD-9455 End
                }
            }
        }catch(Exception ex){
             SEL_LoggingService.log(ex);
        }
    }
    public static void updateRoutingOutcomeSW(List<Case> caseNewList)
    {
		 //String SWRecordTypeName=  Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(recordTypeIdSW).getDeveloperName();
         String SWRecordTypeName=  ((SObject)Type.forName('Case').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosById().get(recordTypeIdSW).getDeveloperName();
         Map<String,SPEN_Case_SLA__mdt> caseSLAMetadataMap = new Map<String,SPEN_Case_SLA__mdt>();
         String newKey;
         for(SPEN_Case_SLA__mdt caseSLARec:SPEN_Case_SLA__mdt.getAll().values())
        {
           
            String key = '';
            if(caseSLARec.SPEN_RecordType__c == 'SPEN_Streetworks')
            {
                key = caseSLARec.SPEN_RecordType__c + + '|'+caseSLARec.SPEN_SPD_SPM__c + '|' + caseSLARec.SPEN_Notice_Type__c + '|'+ caseSLARec.SPEN_Excavation_Required__c + '|' + caseSLARec.SPEN_Sensitivity__c; 
            }
            caseSLAMetadataMap.put(key,caseSLARec);
        }
        for(Case caseRec: caseNewList)
        {
             String key = '';
            if(caseRec.RecordTypeId == recordTypeIdSW)
            {
                key = SWRecordTypeName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+caseRec.SPEN_ExcavationRequired__c+'|'+caseRec.SPEN_Sensitivity__c;
                SPEN_Case_SLA__mdt slaMetadataEntry = new SPEN_Case_SLA__mdt();
                slaMetadataEntry = caseSLAMetadataMap.get(key);
                if(slaMetadataEntry == NULL)//if no exact match with Case and Metadata
                {
                    //check 1
                    newkey = SWRecordTypeName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+caseRec.SPEN_ExcavationRequired__c+'|'+null;
                    slaMetadataEntry = caseSLAMetadataMap.get(newkey); 
                    if(slaMetadataEntry == NULL)
                    {
                        //check 2
                        newkey = SWRecordTypeName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+null+'|'+caseRec.SPEN_Sensitivity__c;
                        slaMetadataEntry = caseSLAMetadataMap.get(newkey); 
                        if(slaMetadataEntry == NULL)
                        {
                            //check 3
                            newkey = SWRecordTypeName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+null+'|'+null;
                            slaMetadataEntry = caseSLAMetadataMap.get(newkey); 
                        }
                    }
                }
                if(slaMetadataEntry != null)
                {
                    caseRec.SPEN_Email_WI_Queue_Routing_Outcome__c = slaMetadataEntry.SPEN_WorkItemRouting__c;
                }
            }
        }
    }
/**************************************************
    @Author: Sai Shyam
    @Date: 09/05/2024
    @purpose: SFAMS-628
***************************************************/
public static void updateConnectionTaskDetails(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap) {
    List<Task> taskConnectionList = new List<Task>();
    List<Task> taskConnectionListToBeUpdated = new List<Task>();
    Map<Id,case> caseConnectionMap = new Map<Id,Case>();
    Set<Id> taskIdSet = new Set<Id>();

    //SF-AMS628 Changes
    Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_BudgetConnectionEnquiry').getRecordTypeId();
    Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_FormalConnectionEnquiry').getRecordTypeId();
    Id recordTypeIdConnReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId();

    Set<Id> connectionsSetRecordTypeId = new Set<Id>();
    connectionsSetRecordTypeId.add(recordTypeIdBudget);
    connectionsSetRecordTypeId.add(recordTypeIdFormal);
    connectionsSetRecordTypeId.add(recordTypeIdConnReadOnly);
    try {
        for(Case cse: newCaseMap.values()) {
            if(oldCaseMap != null) {
                if(connectionsSetRecordTypeId.contains(cse.RecordTypeId)) {
                    caseConnectionMap.put(cse.Id,cse);
                }
            }
        }
            if(caseConnectionMap.size()>0){
                taskConnectionList= SPEN_CaseSelector.getTaskConnectionList(caseConnectionMap.keySet());
                if(taskConnectionList.size()>0){
                    for(Task tsk: taskConnectionList){
                        if((oldCaseMap.get(tsk.WhatId).ownerId != null) && (oldCaseMap.get(tsk.WhatId).ownerId != caseConnectionMap.get(tsk.WhatId).ownerId) && (caseConnectionMap.get(tsk.WhatId).ownerId.getsobjecttype() == User.SobjectType)) {
                            tsk.SPEN_CaseOwnerDetails__c = caseConnectionMap.get(tsk.WhatId).ownerId;
                            taskConnectionListToBeUpdated.add(tsk);
                        }
                        if((oldCaseMap.get(tsk.WhatId).SPEN_CompanyID__c != null) && (oldCaseMap.get(tsk.WhatId).SPEN_CompanyID__c != caseConnectionMap.get(tsk.WhatId).SPEN_CompanyID__c)) {
                            tsk.SPEN_SPD_SPM__c = caseConnectionMap.get(tsk.WhatId).SPEN_CompanyID__c;
                            taskConnectionListToBeUpdated.add(tsk);
                        }
                        if((oldCaseMap.get(tsk.WhatId).SPEN_ConnectionDistrict__c != null) && (oldCaseMap.get(tsk.WhatId).SPEN_ConnectionDistrict__c != caseConnectionMap.get(tsk.WhatId).SPEN_ConnectionDistrict__c)) {
                            tsk.SPEN_CaseConnectionDistrict__c = caseConnectionMap.get(tsk.WhatId).SPEN_ConnectionDistrict__c;
                            taskConnectionListToBeUpdated.add(tsk);
                        }
                    }

                    if(!taskConnectionListToBeUpdated.isEmpty()){
                        Database.update(taskConnectionListToBeUpdated,false);
                    }
                }
            }
    }
    catch(exception ex){
        SEL_LoggingService.log(ex);
    }
}       
}