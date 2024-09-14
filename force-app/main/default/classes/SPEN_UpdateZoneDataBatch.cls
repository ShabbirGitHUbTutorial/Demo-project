/**
 * @description       : This batch class is used to upsert the Zone records and called from SPEN_UpdateZoneDataController
 * 						class.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 12-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SPEN_UpdateZoneDataBatch implements Database.Batchable<sObject>,Database.Stateful
{
    
    public Map<String,String> mapZoneIdToParentId = new Map<String,String>();
    public Map<String,SPEN_Zone__c> mapExternalIdToZone = new Map<String,SPEN_Zone__c>();
    
    
    /*public SPEN_UpdateZoneDataBatch(){
        //System.debug('Default constructor');
    }*/

    public SPEN_UpdateZoneDataBatch(Map<String, String> mapZoneIdToParentId)
    {
        this.mapZoneIdToParentId = mapZoneIdToParentId;
        for(SPEN_Zone__c  objZone : [Select id, SPEN_ExternalId__c from SPEN_Zone__c where SPEN_ExternalId__c IN: mapZoneIdToParentId.values() WITH SECURITY_ENFORCED ])
        {
            mapExternalIdToZone.put(objZone.SPEN_ExternalId__c, objZone);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        //System.debug('mapZoneIdToParentId ----- >'+ mapZoneIdToParentId );
        return Database.getQueryLocator([Select id, name, SPEN_Type__c,SPEN_ExternalId__c,SPEN_Parent__c, SPEN_Parent__r.SPEN_ExternalId__c from SPEN_Zone__c where SPEN_ExternalId__c IN : mapZoneIdToParentId.keySet() WITH SECURITY_ENFORCED ]);
    }

    public void execute(Database.BatchableContext bc, List<SPEN_Zone__c> lstZone)
    {
       try{
            List<SPEN_Zone__c> lstZoneToUpsert = new List<SPEN_Zone__c>();
            for(SPEN_Zone__c objZOne : lstZone){
                if(objZOne.SPEN_ExternalId__c != null && objZOne.SPEN_Parent__r != null)
                {
                    if(mapZoneIdToParentId.get(objZOne.SPEN_ExternalId__c) != null && mapExternalIdToZone.get(mapZoneIdToParentId.get(objZOne.SPEN_ExternalId__c)) != null){
                    	objZone.SPEN_Parent__c = mapExternalIdToZone.get(mapZoneIdToParentId.get(objZOne.SPEN_ExternalId__c)).id;
                    	////System.debug('=====parentId:'+ objZone.SPEN_Parent__c);
                    	lstZoneToUpsert.add(objZone);
                    }
                }
            }
            //System.debug('lstZoneToUpsert:'+lstZoneToUpsert);
            List<Database.upsertResult> uResults = Database.upsert(lstZoneToUpsert,SPEN_Zone__c.Fields.SPEN_ExternalId__c, false);
       
            }catch(Exception ex){
                SEL_LoggingService.log(ex);    
            }            
    }
    
    public void finish(Database.BatchableContext bc) 
    {
       String s='Inside finsh'; //System.debug('finish method'); 
    }
}