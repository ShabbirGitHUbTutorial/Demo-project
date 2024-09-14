/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        07/10/2022
* @Description: Selector class is on IncidentTrigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class IncidentSelector {
    
    //purpose: Method to get related case on respect of incident details
    public static List<Case> getRelatedCaseInfo(Set<Id> incdntIdSet){
        List<Case> relCaseInfo = new List<Case>();
        if(incdntIdSet != null && !incdntIdSet.IsEmpty()){
            relCaseInfo =[Select Id,
                          recordTypeId,
                          SPEN_Incident__c,
                          SPEN_Incident__r.SPEN_IncidentStatus__c, 
                          CaseNumber, 
                          OwnerId,
                          Status 
                          from Case 
                          where SPEN_Incident__c IN : incdntIdSet ];
            
        }
        return relCaseInfo; 
    }
    
    public static List<SPEN_Incident_to_case_status_mapping__mdt> getIncndtToCaseMetaDataInfo(){
        List<SPEN_Incident_to_case_status_mapping__mdt> lstIncToCseMetaData = new List<SPEN_Incident_to_case_status_mapping__mdt>();
        lstIncToCseMetaData = [SELECT id, SPEN_CaseStatus__c, SPEN_IncidentStatus__c,DeveloperName 
                               FROM SPEN_Incident_to_case_status_mapping__mdt
                               WHERE DeveloperName != null ];
        return lstIncToCseMetaData; 
    }
    
    public static List<SPEN_Incident_to_case_status_mapping__mdt> getIncndtToCaseMetaDataMapList(String incStatus){
        List<SPEN_Incident_to_case_status_mapping__mdt> inCsMapList = new List<SPEN_Incident_to_case_status_mapping__mdt>();
        if(incStatus!= Null){
            inCsMapList = [SELECT Id, SPEN_CaseStatus__c,
                           SPEN_IncidentStatus__c
                           FROM SPEN_Incident_to_case_status_mapping__mdt 
                           WHERE SPEN_IncidentStatus__c =: incStatus ];
        }
        return inCsMapList;
    }
    
    
    public static List<Incident> getRelatedIncInfoForStatusUnchecked(Set<Id> incdntIdSet){
        List<Incident> relIncInfo = new List<Incident>();
        if(incdntIdSet!= Null && !incdntIdSet.IsEmpty()){
            relIncInfo =[Select Id,
                         SPEN_StatusUpdated__c
                         from Incident 
                         where Id IN : incdntIdSet ];
        }
        return relIncInfo;   
        
    }
    //purpose: Method to get  incident record by passing incident number from custom metadata
    public static Incident getIncidentRecord(String incidentNumber){
        Incident incidentInfo = new Incident();
        if(incidentNumber!= Null){
            incidentInfo =[SELECT Id, IncidentNumber, SPEN_IVRMessage__c FROM Incident WHERE IncidentNumber =: incidentNumber ];
        }
        return incidentInfo;     
    }   
    public static Map<String,Incident> getIncidentFromRef(Set<String> setMatchingInc)
    {
        Map<String,Incident> mapIncdRef2Inc = new Map<String,Incident>();
        Set<String> incRefArray = new Set<String>();
         for(String inc: setMatchingInc)
        {
            incRefArray.add('%'+inc+'%');
        }
        if(!setMatchingInc.isEmpty())
        {//SFAMS-642: createdDate field is added into the SOQL Query
            for(Incident incd : [SELECT id, SPEN_IncidentReference__c, lastmodifiedDate, createdDate FROM Incident WHERE SPEN_IncidentReference__c
                                LIKE: incRefArray])
            {
                mapIncdRef2Inc.put(incd.SPEN_IncidentReference__c,incd);
            }
        }
        return mapIncdRef2Inc;
    }

    public static List<Incident> getIncidentFromRefWithNRSWACase(Map<String,String> incRefIncCoordMap)
    {
        Id recordtypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
        List<Incident> incWithCases = new List<Incident>();
        if(!incRefIncCoordMap.isEmpty())
        {
            incWithCases =[Select Id,SPEN_IncidentReference__c,SPEN_NumberOfNRSWACoordinates__c, SPEN_SPDSPM__c,//CRMD- 7609 SPEN_SPDSPM__c field added
                           SPEN_Actual_Time__c,//9429
                          (Select id,Status from Cases__r where RecordTypeId =:recordtypeIdNRSWA limit 1) 
                          from Incident where SPEN_IncidentReference__c=:incRefIncCoordMap.keyset() limit 1];
        }
        return incWithCases; 

    }

    //CRMD-8573
    public static Incident getIncRecord(String incReference){
        Incident incRecord = new Incident();
        if(incReference != null){
            incRecord =[SELECT Id,SPEN_IncidentReference__c,
                        SPEN_Zone__c,SPEN_Zone__r.SPEN_SPD_SPM__c 
                        FROM Incident 
                        where SPEN_IncidentReference__c =:incReference];
        }
        return incRecord;
    }

    //CRMD-7899
    public static Incident getIncRecordById(id incId){
        Incident incRecord = new Incident();
        if(incId != null){
            incRecord =[SELECT Id,SPEN_IncidentReference__c,SPEN_SPDSPM__c,
                        SPEN_Zone__c,SPEN_Zone__r.SPEN_SPD_SPM__c 
                        FROM Incident 
                        where id =:incId];
        }
        return incRecord;
    }
}