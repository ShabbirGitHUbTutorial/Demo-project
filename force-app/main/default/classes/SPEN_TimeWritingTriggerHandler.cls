/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler class of the SPEN_TimeWriting__c Object Trigger.
LIBRARY     :   Salesforce Enterprise Library - Handler class of the SPEN_TimeWriting__c Object Trigger
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
22-Sep-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_TimeWritingTriggerHandler {
    
    public static void calculateTimeWritingFee(List<SPEN_TimeWriting__c> timeWritingList){
        try
        {
            List<SPEN_TransmissionApplicationFeeRules__c> transmissionApplicationVarFeeList=SPEN_TransmissionApplicationFeeSelector.getTransmissionApplicationFeeDetails('Variable');
            Decimal hourlyRate=0;
            for(SPEN_TimeWriting__c timeWritingInstance:timeWritingList)
            {
                hourlyRate=getDailyRatesByTeamAndRole(timeWritingInstance.SPEN_Team__c,timeWritingInstance.SPEN_Role__c,transmissionApplicationVarFeeList);
              //  system.debug('value of dailyRateis : '+hourlyRate);
                timeWritingInstance.SPEN_TotalCost__c=hourlyRate * timeWritingInstance.SPEN_HoursSpent__c;                
            }
        }catch(Exception ex){
            //System.debug('In class SPEN_TimeWritingTriggerHandler method calculateTimeWritingFee: exception block='+ex.getMessage());
            SEL_LoggingService.log(ex);
        }
		
	}
    public static Decimal getDailyRatesByTeamAndRole(String team, String role,List<SPEN_TransmissionApplicationFeeRules__c> transmissionApplicationVarFeeList)
    {
        Decimal rate=0;
        for(SPEN_TransmissionApplicationFeeRules__c transmissionApplicationFeeInstance : transmissionApplicationVarFeeList)
        {
            if((transmissionApplicationFeeInstance.SPEN_Team__c).equalsIgnoreCase(team) && (transmissionApplicationFeeInstance.SPEN_Role__c).equalsIgnoreCase(role))
            {
                rate=transmissionApplicationFeeInstance.SPEN_DailyRate__c/transmissionApplicationFeeInstance.SPEN_DailyHours__c;
                
            }
        }
        return rate;
    }
}