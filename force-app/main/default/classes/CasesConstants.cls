/*-----------------------------------------------------------------------------
DESCRIPTION	:	Constants class for CaseTriggerHandler
AUTHOR		:	Dhara Desai
LIBRARY		:	Salesforce Enterprise Library (SEL) - Case Trigger Handler
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
OCT-07-2022		Dhara Desai	        Initial version	
-----------------------------------------------------------------------------*/
public without sharing class CasesConstants {
    // Case Record Types
    public static final String Case_UnplannedFault = 'SPEN_UnplannedFault';
    public static final String Case_Complaints = 'SPEN_Complaints';
    public static final String Case_GS = 'SPEN_GSCS';
    public static final String Case_UnplannedBypass = 'SPEN_UnplannedBypass';
    public static final String Case_Referral = 'SPEN_Referral';
    //Code Implementation Starts here . User Story : CRMD-5382, 5384, 5381 and 5385 Date : 05/17/2023. Developer : Sheker
    public static final String Case_ThirdPartyDamage = 'SPEN_ThirdPartyDamage';
    public static final String Case_Query = 'SPEN_Query';
    public static final String loiIssuedStatus = 'LOI Issued';
    public static final String closedStatus = 'Closed';
    public static final String readyForBillingStatus = 'Ready For Billing';
    public static final String createdStatus = 'Created';
    public static final String missingFormStatus = 'Missing Form';
    public static final String openStatus = 'OPEN';
    public static final String nrswaReviewStatus = 'NRSWA Review';
    public static final String poweronOrigin = 'PowerOn';
    public static final String nrswaType = 'NRSWA';
    public static final String queryReason = 'Additional Coordinates';
    
    public static final String Case_BudgetConnectionEnquiry = 'SPEN_BudgetConnectionEnquiry';
    public static final String Case_FormalConnectionEnquiry = 'SPEN_FormalConnectionEnquiry';
    public static final String Case_Design = 'Design';
    public static final String Case_Acceptance = 'Acceptance';
    public static final String Case_DeliveryWorkPlanning = 'Delivery Work Planning';
    public static final String CASE_NOTCOMPETENT = 'Not Competent';
    public static final String Case_SPEN_DesignTeam = 'SPEN_DesignTeam';
    //Code Implementation Starts here . User Story : CRMD-1325 Date : 25/7/2023. Developer: Rohit C
    public static final String CASE_DESIGNTYPEFIXED='FXP';
    public static final String CASE_DESIGNTYPEQUOTATION='MSI';
    public static final String CASE_CONTACTTEAMFIXEDPRICEQUOTATIONS = 'SPEN_ContactTeamFixedPriceQuotations';
    //Code Implementation Ends here . User Story : CRMD-1325 Date : 25/7/2023. Developer: Rohit C
    public static final String Case_SPEN_AcceptanceTeam = 'SPEN_AcceptanceTeam';
    //Code Implementation Starts here . User Story : CRMD-920 Date : 13/9/2023. Developer: Rohit C
    public static final String CASE_ACCEPTANCECANCELLATIONINPROCESS ='SPEN_Acceptancecancellationinprocess';
    public static final String CASE_ACCEPTANCEANDPAYMENTRECEIVED ='Acceptance and Payment received';
    public static final String CASE_REFUNDREQUIRED ='Refund Required';
    public static final String CASE_PAIDNOTACCEPTED = 'Paid Not Accepted';
    //Code Implementation Ends here . User Story : CRMD-920 Date : 13/9/2023. Developer: Rohit C
    public static final String Case_SPEN_CITLTeam = 'SPEN_CustomerInterfaceTeamLeadersTeam';
    public static final String Case_InfoReceived = 'Info received';
    public static final String Case_SPEN_CTEE = 'SPEN_ContactTeamExistingEnquiry';
    public static final String Case_WelcomePackSent = 'Welcome Pack Sent';
    public static final String Case_AwaitingInfo = 'Awaiting Info';
    public static final String Case_SPEN_CTAI = 'SPEN_ContactTeamAwaitingInformation';
    public static final String CASE_BUDGETDESIGN = 'Budget Design';// added Amrita Sarkar 05/07/2023
    //Code Implementation Ends here . User Story : CRMD-5382, 5384, 5381 and 5385. Date : 05/17/2023. Developer : Sheker
    public static final String Case_NoSupplySinglePremise = 'ENS1';
    public static final String Case_NoSupplyNetwork = 'NOS';
    public static final String NoSupplyNetworkWithinBusinessHours = 'NS-SP within Business Hours';
    public static final String NoSupplyNetworkOutsideBusinessHours = 'NS-SP outside Business Hours';
    public static final String NoSupplyNetwork = 'NS-Network';
    public static final String OtherCategory = 'Other Cases';
    public static final String Case_NoSupplyIVR = 'NOS2';
    public static final String NoSupplyIVRWithinBusinessHours = 'No Supply (IVR) SP within Business Hours';
    public static final String NoSupplyIVROutsideBusinessHours = 'No Supply (IVR) SP outside Business Hours';
    public static final Integer startTime = 7;
    public static final Integer endTime = 22;//13;
   	public static final Integer outsideBusinesshoursstart = 1;
    public static final Integer outsideBusinesshoursend = 6;//13;
    public static final String CRITICALINFORMATION = '<sdif:CriticalInformation*?>(.*?)</sdif:CriticalInformation>'; 
    //Referral Statuses
    public static final String WITH_PARTNER = 'With Partner';
    public static final String CREATED = 'CREATED';
    public static final String POWERCUT = 'Help in a Power Cut';
    public static final String STATUSCREATED = 'Created';
    public static final String SPEN = 'SPEN';
    public static final String READYFORPAYMENT ='Ready for Payment';
    public static final String STATUSCLOSED = 'Closed';
    public static final String CUSTOMERSATISFACTION = 'Not Applicable';
    public static final String DELIVEREDCOMPLETED= 'Delivered - Completed';
   
    //Business Hours
    public static final String REFERRALS_BUSINESS_HOURS = 'Referrals Business Hours';
    //Days of the Week
    public static final String SATURDAY = 'Saturday';
    public static final String SUNDAY = 'Sunday';
    public static final String CASE_INFOENQUIRY = 'Information Enquiry';//CRMD-6699
    public static final String CASE_FORMALENQUIRY = 'Formal Enquiry';//CRMD-6699
    public static final String CASE_COMPETENT = 'Competent';//CRMD-6828
    public static final String CASE_ADDINFOSTATUS = 'Additional Information Required';//CRMD-6828
    public static final String CASE_AWAITINGMININFOSTATUS = 'Awaiting Minimum information';//CRMD-6828
    public static final String CASE_PHYINFORECSTATUS = 'Physical Information Received';//CRMD-6828
    public static final String CASE_ABLETOQUOTEINFOSTATUS = 'Able to Quote';//CRMD-6828
    
    //CRMD-1389 : Rajat Verma
    public static final String CASE_CONTACTTEAMFIXEDPRICEQUOTEISSUED = 'SPEN_ContactTeamFixedPriceQuoteIssued';
    public static final String CASE_ACCEPTANCEFIXEDPRICEQUOTATION = 'SPEN_AcceptanceFixedPriceQuotationQueue';
    public static final String CASE_QUOTEISSUEDAWAITINGACCEPTANCE = 'Quote Issued Awaiting Cust Acceptance';
    public static final String CASE_ACCEPTEDANDPAID = 'Accepted and Paid';
    //END
    //CRMD-1333 : Amrita Sarkar
    public static final String CASE_15DAYSTASKEVENTNAME = '15days Task Creation non LVHV';
    public static final String CASE_10DAYSTASKEVENTNAME = '10 Days Task Creation LVHV';
    public static final String CASE_20DAYSTASKEVENTNAME = '20 Days Task Creation LVHV';
    public static final String CASE_60DAYSTASKEVENTNAME = '60 Days task Create Non LVHV';
    public static final String CASE_5DAYSEMAILEVENTNAME = '5 Days System Email LVHV';
    public static final String CASE_10DAYSEMAILEVENTNAME = '10 Days System Email Non LVHV';
    public static final String CASE_15DAYSEMAILEVENTNAME = '15 Days System Email LVHV';
    public static final String CASE_45DAYSEMAILEVENTNAME = '45 Days System email Non LVHV';
    public static final String COMMSCHDULER_STATUSSCHEDULED = 'Scheduled';
    public static final String COMMSCHDULER_STATUSABORTED = 'Cancelled';
    //end

    //CRMD-1209, CRMD-1210 : Akshay Pandit
    public static final String CASE_CUSTENGPUMPDMTASKEVENTNAME = 'Customer Engagement Task PUM/PDM';
    public static final String CASE_CUSTENGHODTASKEVENTNAME = 'Customer Engagement Task HOD';
    public static final String CASE_CUSTENGPMTASKEVENTNAME = 'Customer Engagement Task PM';//1208 AC4
    //end

    public static final String cntRecordType = 'SPEN_CNT';

    public static final String CASE_ITTISSUEDTASKEVENTNAME = 'ITT Issued Due Date Prior 1 day'; //CRMD1211 AC1
    public static final String CASE_ENERGISATIONTASKEVENTNAME = 'Energisation Date Prior 14 days'; //CRMD 1236
    public static final String CASE_STAGE1ENERGDATE = 'Stage 1 Energisation Date to PM'; //CRMD 7959
    public static final string CASE_GSCALLREQUIREDSUBSTATUS = 'GS Call Required'; //CRMD 1342
    public static final string CASE_GSCALLCOMPLETESUBSTATUS = 'GS Call Complete'; //CRMD 1342
    public static final string CASE_SAPSTATUACANA = 'CANA'; //CRMD 920
    public static final string CASE_SAPSTATUACANB = 'CANB'; //CRMD 920
    public static final String Case_Cancelled = 'Cancelled'; // CRMD 920
    public static final string CASE_SAPSTATUSPECA = 'PECA'; //CRMD-9238
    public static final string CASE_SAPSTATUASCAREPECA = 'CARE PECA'; //CRMD-9238
    public static final string CASE_SAPSTATUSCPREPECA = 'CPRE PECA'; //CRMD-9238
    public static final string CASE_SAPSTATUSACPC = 'ACPC'; //CRMD-9238
    public static final string CASE_SAPSTATUSJOBR = 'JOBR'; //CRMD-9238
	public static final String CASE_ACCEPTEDNOTPAID = 'Accepted Not Paid';//CRMD-9238
    public static final String CASE_QUOTEVALID = 'Quote Valid';//CRMD-9238
    public static final String CASESTATUS_OPEN = 'Open';//CRMD-9469
public static final String CASE_STATUSBUDGETISSUEDCUSTACC = 'Budget Quote Issued Awaiting Cust Acceptance';//CRMD-9238
    public static final String CASE_SAPSTATUSBESE = 'BESE';//CRMD-9238
    //CRMD-9451 by Sumit
    public static final String originWEB = 'Web';
    public static final String location_England = 'England';
    public static final String location_Wales = 'Wales';
    public static final String location_Scotland = 'Scotland';
    @AuraEnabled
    public String WIZNOSUPPLYSP = 'ENS1';    
    @AuraEnabled
    public String WIZNOSUPPLYNETW = 'NOS';
    
    @TestVisible
	private static String getUnitTest()
	{
		return CasesConstants.OtherCategory;
	}
    @TestVisible
    private static String getConnectionUnitTest()
    {
        return CasesConstants.Case_Design;
    }
}