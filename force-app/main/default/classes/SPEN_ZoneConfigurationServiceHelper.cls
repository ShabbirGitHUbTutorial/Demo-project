/*-----------------------------------------------------------------------------
DESCRIPTION :   Helper for Zone Trigger
AUTHOR      :   Shubhi Vijayvergia
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0
TEST CLASS	:	SPEN_ZoneConfigurationServiceHelperTest
HISTORY     :
Date            Author              Comment
Jun-27-2023     Shubhi Vijayvergia         Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_ZoneConfigurationServiceHelper {
    static final String ZONE_TYPE_DISTRICT='District';
    static final String ZONE_TYPE_ZONE='Zone';
    static final String ZONE_TYPE_REGION='Region';
    public static final String ZONE_CONFIGSETTING = 'Zone broadcast message updated last one hour';
    static List<Id> ivrMsgIdList=new List<Id>();
    static Map<Id,SPEN_IVRMessage__c> zoneIVRMesgMap=new Map<Id,SPEN_IVRMessage__c>();
      
    //method invoking from before insert to update message fields from template message
    public static void updateMessageOnInsert(List<SPEN_Zone__c> newZoneList){
        SPEN_ZoneConfigurationServiceHelper.getTemplateIdsForMessageUpdate(newZoneList);
        if(ivrMsgIdList!=null && !ivrMsgIdList.isEmpty()){
            SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap=SPEN_IVRMessageSelector.getIVRMessageMap(ivrMsgIdList);
        }
        for(SPEN_Zone__c z: newZoneList){
            if(z.SPEN_IVRMessageTemplate__c!=null && SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap!=null && SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap.containsKey(z.SPEN_IVRMessageTemplate__c)){
                z.SPEN_IVRTemplateBody__c=SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap.get(z.SPEN_IVRMessageTemplate__c).SPEN_IVRMessage__c; //CRMD-5177
            }
        }
    }
    public static void updateMessageOnUpdate(Map<Id, SPEN_Zone__c> zoneOldMap,List<SPEN_Zone__c> newZoneList){
        SPEN_ZoneConfigurationServiceHelper.getTemplateIdsForMessageUpdate(newZoneList);
        if(ivrMsgIdList!=null && !ivrMsgIdList.isEmpty()){
            SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap=SPEN_IVRMessageSelector.getIVRMessageMap(ivrMsgIdList);
            for(SPEN_Zone__c z: newZoneList){
                if(z.SPEN_IVRMessageTemplate__c!=null && zoneOldMap.containsKey(z.id) && zoneOldMap.get(z.id).SPEN_IVRMessageTemplate__c!=z.SPEN_IVRMessageTemplate__c && SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap!=null && SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap.containsKey(z.SPEN_IVRMessageTemplate__c)){
                    z.SPEN_IVRTemplateBody__c=SPEN_ZoneConfigurationServiceHelper.zoneIVRMesgMap.get(z.SPEN_IVRMessageTemplate__c).SPEN_IVRMessage__c; //CRMD-5177
                }
            }
        }
        
    }
    private static void getTemplateIdsForMessageUpdate(List<SPEN_Zone__c> zoneNewList){
        for(SPEN_Zone__c z: zoneNewList){
            ivrMsgIdList.add(z.SPEN_IVRMessageTemplate__c);
        }
    }
    /// method invoking from after update to update IR on change of broadcast message
    public static void updateIROnUpdate(Map<Id, SPEN_Zone__c> zoneOldMap,List<SPEN_Zone__c> zoneNewList){
        Map<Id,SPEN_Zone__c> zoneMap = new Map<Id,SPEN_Zone__c>();
        if(!zoneOldMap.isEmpty() && !zoneNewList.isEmpty()){
            for(SPEN_Zone__c zoneValue: zoneNewList){
                if(zoneOldMap.containsKey(zoneValue.Id) && zoneOldMap.get(zoneValue.Id) != Null && zoneValue.SPEN_BroadcastMessage__c !=null && zoneOldMap.get(zoneValue.Id).SPEN_BroadcastMessage__c !=zoneValue.SPEN_BroadcastMessage__c)
                {
                    zoneMap.put(zoneValue.Id,zoneValue);
                }
            }
            if(!zoneMap.isEmpty()){
                SPEN_ZoneConfigurationServiceHelper.updateIRO(zoneMap);
            }
            
        }
    }
    public static void updateIRO(Map<Id,SPEN_Zone__c> zoneMap){
        if(zoneMap!=null && !zoneMap.isEmpty()){
            Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>();
            configSetMap = SPEN_CaseSelector.configSettingsMap;//map to hold COnfig settings value
            Integer threshold = Integer.valueOf(configSetMap.get(ZONE_CONFIGSETTING).SPEN_Value__c);
            Datetime dateThreshold = system.now().addHours(-threshold);
            SPEN_IntegrationRequestSelector.geIntegrationRequestZoneRecord(zoneMap,dateThreshold);
        }
    }
}