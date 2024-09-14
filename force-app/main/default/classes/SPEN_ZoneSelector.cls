/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the SPEN_Zone__c Queries.
LIBRARY     :   Salesforce Enterprise Library - SPEN_Zone__c Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
NOV-23-2022     Smita Raikar        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_ZoneSelector {
    /**************************************************
       @Author: Smita Raikar
       @Date: 23/11/22
       @purpose: Method to get zone details.
       ***************************************************/
       public static List<SPEN_Zone__c> getZoneRecords(SPEN_Premise__c premiseRcrd){
           List<SPEN_Zone__c> zoneList = new List<SPEN_Zone__c>();
           if(premiseRcrd!=null && premiseRcrd.Id!=null){
                zoneList = [SELECT Id, Name,SPEN_IVRMessage__c,SPEN_BroadcastMessage__c,SPEN_Type__c 
                                FROM SPEN_Zone__c 
                                WHERE Id IN (Select SPEN_Zone__c from SPEN_Premise__c where Id=:premiseRcrd.Id) 
                                AND SPEN_Type__c='Zone' WITH SECURITY_ENFORCED];
           }
           return zoneList;     
       }
       
       /**************************************************
       @Author: Smita Raikar
       @Date: 24/11/22
       @purpose: Method to district details.
       ***************************************************/
       public static List<SPEN_Zone__c> getDistrictRecords(SPEN_Premise__c premiseRcrd){
           List<SPEN_Zone__c> districtList = new List<SPEN_Zone__c>();
           if(premiseRcrd!= null && premiseRcrd.Id!=null){
                districtList = [SELECT Id, Name,SPEN_IVRMessage__c,SPEN_BroadcastMessage__c,SPEN_Type__c 
                                    FROM SPEN_Zone__c 
                                    WHERE Id IN (Select SPEN_PremiseDistrict__c from SPEN_Premise__c where Id=:premiseRcrd.Id)
                                    AND SPEN_Type__c='District' WITH SECURITY_ENFORCED];
                }
           return districtList;     
       }
       /**************************************************
       @Author: Smita Raikar
       @Date: 24/11/22
       @purpose: Method to region details.
       ***************************************************/
       public static List<SPEN_Zone__c> getRegionRecords(SPEN_Premise__c premiseRcrd){
           List<SPEN_Zone__c> regionList = new List<SPEN_Zone__c>();
           if(premiseRcrd!= null && premiseRcrd.Id!=null){
                regionList = [SELECT Id, Name,SPEN_IVRMessage__c,SPEN_BroadcastMessage__c,SPEN_Type__c 
                                FROM SPEN_Zone__c 
                                WHERE Id in (Select SPEN_Zone__c from SPEN_Premise__c where Id=:premiseRcrd.Id) 
                                and SPEN_Type__c='Region' WITH SECURITY_ENFORCED];      
           }
           return regionList;     
       }
       /**************************************************
       @Author: Smita Raikar
       @Date: 24/11/22
       @purpose: Method to region details.
       ***************************************************/
       public static SPEN_Zone__c getRegionRecord(){
           SPEN_Zone__c region = new SPEN_Zone__c();
              region = [Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='Region' WITH SECURITY_ENFORCED LIMIT 1];      
           return region;     
       }
       /**************************************************
       @Author: Smita Raikar
       @Date: 30/11/22
       @purpose: Method to district details.
       ***************************************************/
       public static List<SPEN_Zone__c> getDistrictDetails(Id regionId){
           List<SPEN_Zone__c> districtList = new List<SPEN_Zone__c>();
           if(regionId!= null ){
           districtList = [Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='District'  AND SPEN_Parent__c=:regionId WITH SECURITY_ENFORCED];
           }
           return districtList;     
       }
       /**************************************************
       @Author: Smita Raikar
       @Date: 30/11/22
       @purpose: Method to get zone details.
       ***************************************************/
       public static List<SPEN_Zone__c> getZoneDetails(Id districtId){
           List<SPEN_Zone__c> zoneList = new List<SPEN_Zone__c>();
           if(districtId!= null ){
           zoneList = [Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='Zone' AND SPEN_Parent__c=:districtId WITH SECURITY_ENFORCED];
           }
           return zoneList;     
       }
       /**************************************************
       @Author: Smita Raikar
       @Date: 31/01/23
       @purpose: Method to get zone details.
       @ModifiedBy: Debapriya Saha
       @ModifiedDate: 02.01.2023 (MM.DD.YYYY)
       ***************************************************/
       public static List<SPEN_Zone__c> getZoneRecordsByIds(Set<Id> zoneIds){
            List<SPEN_Zone__c> zoneLis=new List<SPEN_Zone__c>();
            if(zoneIds!=null && !zoneIds.isEmpty()){
                zoneLis= [Select Id,Name,SPEN_SPD_SPM__c from SPEN_Zone__c where ID IN :zoneIds WITH SECURITY_ENFORCED];
            } 
            return zoneLis;   
       }
           
       /**************************************************
       @Author: Bhagyashree Mandlik
       @Date: 31/01/23
       @purpose: Method to get ZoneTown details.
       ***************************************************/
       public static SPEN_Zone__c getZoneTownRecord(Id caseTownId){
           SPEN_Zone__c zoneList = new SPEN_Zone__c();
           
           if(caseTownId != null){
               zoneList =  [ SELECT  Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_Parent__c,SPEN_Type__c FROM SPEN_Zone__c WHERE Id=:caseTownId WITH SECURITY_ENFORCED];      
           }
           return zoneList;     
       }
       public static List<SPEN_Zone__c> getZoneRecordforInc (Set<String> incOperatingZone){
        List<SPEN_Zone__c> zoneList = new List<SPEN_Zone__c>();
        
        if(incOperatingZone != null && !incOperatingZone.isEmpty()){
            zoneList =  [SELECT Id,Name,SPEN_ExternalId__c,SPEN_Type__c FROM SPEN_Zone__c WHERE SPEN_ExternalId__c=:incOperatingZone WITH SECURITY_ENFORCED];      
        }
        return zoneList;     
    }
    //code below  to be moved in respective selector classes
    /**************************************************
     @Author: shubhi vijayvergia
     @Date: Jun-20-2023
     @purpose: Method to get child Zone
    ***************************************************/
    public static List<SPEN_Zone__c> getChildrenZone (List<Id> parentIdList, String type){
        List<SPEN_Zone__c> zoneList = new List<SPEN_Zone__c>();
        if(String.isNotBlank(type) && !parentIdList.isEmpty()){
            switch on type{
                when 'District'{
                    zoneList = [SELECT Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c,SPEN_Parent__r.SPEN_Parent__c 
                                    FROM SPEN_Zone__c 
                                    WHERE (SPEN_Type__c=:type AND SPEN_Parent__c IN:parentIdList) OR (SPEN_Type__c='Zone' AND SPEN_Parent__r.SPEN_Parent__c IN:parentIdList)
                                    WITH SECURITY_ENFORCED];
                }
                when 'Zone'{
                    zoneList = [SELECT Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c 
                                    FROM SPEN_Zone__c 
                                    WHERE SPEN_Type__c=:type AND SPEN_Parent__c IN:parentIdList
                                    WITH SECURITY_ENFORCED];
                }
            }
        }
        return zoneList;     
    }
   }