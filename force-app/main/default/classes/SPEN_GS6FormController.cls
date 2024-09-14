/*-----------------------------------------------------------------------------
DESCRIPTION :   Controller class used to support GS6 LWC used in the FS Mobile App
AUTHOR      :   Accenture - PATC
-----------------------------------------------------------------------------*/
public with sharing class SPEN_GS6FormController {

    @AuraEnabled (cacheable = true)
    public static ServiceTerritoryMember getDistrict(String userId) {
        
        return [
            SELECT Id, ServiceTerritory.Name, TerritoryType                          
            FROM ServiceTerritoryMember                     
            WHERE ServiceResource.RelatedRecordId =: userId and TerritoryType = 'P'                        
            AND EffectiveStartDate <= :DateTime.now()                         
            AND (EffectiveEndDate >= :DateTime.now() OR EffectiveEndDate = NULL)                        
            WITH SECURITY_ENFORCED                        
            LIMIT 1];
        
       
    }
}