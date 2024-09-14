/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        07/10/2022
* @Description: Selector class is on IncidentTrigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_IncidentSelector {
    
    //purpose: Method to get related case on respect of incident details
    public static List<Case> getRelatedCaseInfo(Set<Id> incdntIdSet){
        List<Case> relCaseInfo = new List<Case>();
        if(incdntIdSet!= Null && !incdntIdSet.IsEmpty()){
            relCaseInfo =[Select Id,
                          SPEN_Incident__c, 
                          CaseNumber, 
                          OwnerId 
                          from Case 
                          where SPEN_Incident__c IN : incdntIdSet];
        }
        return relCaseInfo;     
    }
    
    public static List<SPEN_Incident_to_case_status_mapping__mdt> getIncndtToCaseMetaDataInfo(){
        List<SPEN_Incident_to_case_status_mapping__mdt> lstIncToCseMetaData = [SELECT id, 
                                                                               SPEN_CaseStatus__c, 
                                                                               SPEN_IncidentStatus__c 
                                                                               FROM SPEN_Incident_to_case_status_mapping__mdt];
        return lstIncToCseMetaData; 
    }
    
    public static List<SPEN_Incident_to_case_status_mapping__mdt> getIncndtToCaseMetaDataMapList(String incStatus){
        List<SPEN_Incident_to_case_status_mapping__mdt> inCsMapList = new List<SPEN_Incident_to_case_status_mapping__mdt>();
        if(incStatus!= Null){
            inCsMapList = [SELECT Id, SPEN_CaseStatus__c,
                           SPEN_IncidentStatus__c
                           FROM SPEN_Incident_to_case_status_mapping__mdt 
                           WHERE SPEN_IncidentStatus__c =: incStatus
                          ];
        }
        return inCsMapList;
    }
    
    
    public static List<Incident> getRelatedIncInfoForStatusUnchecked(Set<Id> incdntIdSet){
        List<Incident> relIncInfo = new List<Incident>();
        if(incdntIdSet!= Null && !incdntIdSet.IsEmpty()){
            relIncInfo =[Select Id,
                         SPEN_StatusUpdated__c
                         from Incident 
                         where Id IN : incdntIdSet];
        }
        return relIncInfo;     
    }
    //purpose: Method to get  incident record by passing incident number from custom metadata
    public static Incident getIncidentRecord(String incidentId){
        Incident incidentInfo = new Incident();
        if(incidentId!= Null){
            incidentInfo =[SELECT Id, IncidentNumber,SPEN_IncidentID__c, SPEN_IVRMessage__c FROM Incident WHERE SPEN_IncidentID__c =: incidentId];

        }
        return incidentInfo;     
    }
    public static Incident getIncidentRecordWithoutClosedStatus(String incidentId){
        Incident incidentInfo = new Incident();
        if(incidentId!= Null){
            incidentInfo =[SELECT Id, IncidentNumber,SPEN_IncidentID__c, SPEN_IVRMessage__c,SPEN_IncidentStatus__c 
                           FROM Incident 
                           WHERE 
                           SPEN_IncidentID__c =: incidentId];
        }
        if(incidentInfo.SPEN_IncidentStatus__c == 'Awaiting' ){
            
            return incidentInfo;
        }
        else if( incidentInfo.SPEN_IncidentStatus__c =='In Progress'){
            return incidentInfo;
        }
        else if(incidentInfo.SPEN_IncidentStatus__c =='On Site'){
            return incidentInfo;
        }
        else if(incidentInfo.SPEN_IncidentStatus__c =='Merged'){
            return incidentInfo;
        }else if(incidentInfo.SPEN_IncidentStatus__c =='Delog'){
            return incidentInfo;
        }else if(incidentInfo.SPEN_IncidentStatus__c =='Complete'){
            return incidentInfo;
        }else if(incidentInfo.SPEN_IncidentStatus__c =='Cancelled'){
            return incidentInfo;
        }
        return null;    
    }
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method for SPEN_ImpactedPremise
    ***************************************************************/ 
    public static List<Incident> getIncidentInformationfromIncidentids(Set<String> incidentIds){
    List<Incident> incidentList = new List<Incident>();
    if(!incidentIds.isEmpty())
    {
        incidentList = [Select Id,SPEN_ResourceID__c,SPEN_ResourceArrivalDate__c,
                              SPEN_EstimatedRestorationTime__c,SPEN_IncidentType__c,SPEN_DispatchedDate__c,
                              SPEN_isUpgrade__c,SPEN_IncidentID__c,SPEN_ActiveNumberofCustomers__c,SPEN_RestoredNumberofCustomer__c
                              FROM Incident
                              WHERE SPEN_IncidentID__c IN: incidentIds];
    }
    return incidentList;
}
    
}