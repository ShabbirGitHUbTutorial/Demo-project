/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the Plot Queries.
LIBRARY     :   Salesforce Enterprise Library - Plot Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
21-Jul-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_PlotSelector {
    /**************************************************
    @Author: Rohit Sharma
    @Date: 21-Jul-2023 
    @purpose: Method to get Plot details from case.
    ***************************************************/
    public static List<SPEN_Plot__c> getPlotsFromCase(Id caseId){
        List<SPEN_Plot__c>	plotList = new List<SPEN_Plot__c>();
        if(caseId != null)
        {
            plotList = 	[Select Id,
                         SPEN_SupplyPointCode__c,SPEN_PlotNumber__c,SPEN_MeteringPointClass__c,SPEN_MeteringPointProfile__c,
                         SPEN_MaxPowerkVA__c,SPEN_UNIT__c,SPEN_Phase__c,SPEN_FutureEarthType__c,SPEN_PropertyType__c,
                         SPEN_PropertyID__c,SPEN_HeatingMethod__c,SPEN_HeatingTypeDescription__c,SPEN_IDREQTOBEDISCON__c,
                         SPEN_DISCONNECT__c,SPEN_NOUSED__c,SPEN_MPAN1__c,SPEN_MPAN2__c,SPEN_Supplier__c,SPEN_CableHeadLive__c,
                         SPEN_CableheadLiveScheduled__c,SPEN_BuildingCode__c,SPEN_FlatNumber__c,SPEN_HouseNumber__c,
                         SPEN_BuildingName__c,SPEN_StreetName__c,SPEN_Locality__c,SPEN_TownCity__c,SPEN_Country__c,
                         SPEN_County__c,SPEN_PostCode__c,SPEN_NoofBedrooms__c,SPEN_EVChargingType__c,SPEN_EVChargerQuantity__c,
                         SPEN_EVtoGrid__c,SPEN_DisturbinglLoadkw__c,SPEN_DisturbingLoadSummary__c,SPEN_PropertyID_Formula__c,SPEN_Status__c,	
                         SPEN_CaseRecord__r.SPEN_CompanyID__c,SPEN_CaseRecord__r.SPEN_CustomerClass__c FROM SPEN_Plot__c //CRMD-7375//Added 2 fields
                         where SPEN_CaseRecord__c=: caseId ORDER BY createdDate DESC];
        }  	                       
        return plotList;     
    }

    /**************************************************
@Author: Rohit Sharma
@Date: 21-Jul-2023 
@purpose: Method to get Plot details based on Supply Point Code.
***************************************************/
public static List<SPEN_Plot__c> getPlotsFromSupplyPointCode(List<String> supplyPointCodes){
        List<SPEN_Plot__c>	plotList = new List<SPEN_Plot__c>();
        if(!supplyPointCodes.isEmpty())
        {
            plotList = 	[Select Id,SPEN_SupplyPointCode__c,SPEN_MPAN1__c,SPEN_MPAN2__c FROM SPEN_Plot__c 
                         where SPEN_SupplyPointCode__c=: supplyPointCodes  ORDER BY createdDate DESC];
        }  	                       
        return plotList;     
    }
    
    
    /**************************************************
    @Author: Rohit Sharma
    @Date: 21-Jul-2023 
    @purpose: Method to get Plot count from case.
    ***************************************************/
    @AuraEnabled
    public static Integer getActivePlotsCountFromCase(Id caseId){
        List<AggregateResult> plotCountAgg;
        Integer plotCount;
        if(caseId != null)
        {
            plotCountAgg = [Select count(Id)	
                         FROM SPEN_Plot__c
                         where SPEN_CaseRecord__c=: caseId and SPEN_Status__c='Active' ];
        }
        if (!plotCountAgg.isEmpty()) 
        {
            plotCount=(Integer)plotCountAgg[0].get('expr0');
        }
        Else
        {
            plotCount=0;
        }  	                       
        return plotCount;     
    }   
}