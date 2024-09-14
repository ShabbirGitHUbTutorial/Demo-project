/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the TransmissionApplicationFee Queries.
LIBRARY     :   Salesforce Enterprise Library - TransmissionApplicationFee Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
22-Sep-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_TransmissionApplicationFeeSelector {
    /**************************************************
    @Author: Rohit Sharma
    @Date: 22-Sep-2023
    @purpose: Method to get TransmissionApplicationFee details.
    ***************************************************/
        public static List<SPEN_TransmissionApplicationFeeRules__c> getTransmissionApplicationFeeDetails(String feeType){
            List<SPEN_TransmissionApplicationFeeRules__c>	transmissionApplicationFeeList = new List<SPEN_TransmissionApplicationFeeRules__c>();
            if(feeType != null)
            {
                transmissionApplicationFeeList = 	[Select Id,SPEN_isActive__c,SPEN_FeeType__c,SPEN_DailyRate__c,SPEN_Team__c,SPEN_Role__c,SPEN_DailyHours__c             	
                             FROM SPEN_TransmissionApplicationFeeRules__c
                             where SPEN_FeeType__c=: feeType and SPEN_isActive__c=true ORDER BY createdDate DESC];
            }  	                       
            return transmissionApplicationFeeList;     
        }
        public static List<SPEN_TransmissionApplicationFeeRules__c> getTransmissionApplicationFeeDetailsByApplicationType(String feeType,set<String> appType){
            List<SPEN_TransmissionApplicationFeeRules__c>	transmissionApplicationFeeList = new List<SPEN_TransmissionApplicationFeeRules__c>();
            if(feeType != null)
            {
                transmissionApplicationFeeList = 	[select id, SPEN_ApplicationStage__c, SPEN_ApplicationType__c, SPEN_ContractArea__c,SPEN_LocationType__c,
                                                               SPEN_MAXDemandCapacityMWs__c,SPEN_MAXSizeMWsCECExport__c,SPEN_MINDemandCapacityMWs__c,SPEN_MINSizeMWsCECExport__c,
                                                           SPEN_PrimaryTransmissionTechnology__c,SPEN_FixedCumulativeApplicationFee__c
                                                               FROM SPEN_TransmissionApplicationFeeRules__c 
                                                               WHERE SPEN_ApplicationType__c IN: apptype and SPEN_FeeType__c=: feeType and SPEN_isActive__c=true ORDER BY createdDate DESC];
            }  	                       
            return transmissionApplicationFeeList;     
        }
    }