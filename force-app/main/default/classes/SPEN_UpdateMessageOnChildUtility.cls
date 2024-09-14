/*-----------------------------------------------------------------------------
DESCRIPTION :   Utility class for Zone Trigger (updating IVR message details from parent to child)
AUTHOR      :   Shubhi Vijayvergia
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0
TEST CLASS	:	SPEN_UpdateMessageOnChildUtilityTest
HISTORY     :
Date            Author              Comment
Jun-27-2023     Shubhi Vijayvergia         Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_UpdateMessageOnChildUtility {
    static final String ZONE_TYPE_DISTRICT='District';
    static final String ZONE_TYPE_ZONE='Zone';
    static final String ZONE_TYPE_REGION='Region';
    static List<Id> ivrMsgIdList=new List<Id>();
    static List<Id> districtParentIdList=new List<Id>();
    static List<Id> zoneParentIdList=new List<Id>();
    static Map<Id,List<SPEN_Zone__c>>childDistrictMap=new Map<Id,List<SPEN_Zone__c>>();
    static Map<Id,List<SPEN_Zone__c>>childZoneMap=new Map<Id,List<SPEN_Zone__c>>();
    static Map<Id,SPEN_IVRMessage__c> zoneIVRMesgMap=new Map<Id,SPEN_IVRMessage__c>();
    public static void updateChildMessageFromParent(Map<Id, SPEN_Zone__c> zoneOldMap,List<SPEN_Zone__c> zoneNewList){
        SPEN_UpdateMessageOnChildUtility.getParentIdsForMessageUpdate(zoneNewList,zoneOldMap);
        SPEN_UpdateMessageOnChildUtility.zoneIVRMesgMap=SPEN_IVRMessageSelector.getIVRMessageMap(ivrMsgIdList);
        SPEN_UpdateMessageOnChildUtility.childDistrictMap=SPEN_UpdateMessageOnChildUtility.getChildDistricts(districtParentIdList);
        SPEN_UpdateMessageOnChildUtility.childZoneMap=SPEN_UpdateMessageOnChildUtility.getChildZones(zoneParentIdList);
        SPEN_UpdateMessageOnChildUtility.updateChildMessages(zoneNewList);  
    }
    //method to fetch children and grandchildren if zone type=region
    private static Map<Id,List<SPEN_Zone__c>> getChildDistricts(List<Id> parentIdList) {
        Map<Id,List<SPEN_Zone__c>> parentMap=new Map<Id,List<SPEN_Zone__c>>();
        if(!parentIdList.isEmpty()){
            for(SPEN_Zone__c z:SPEN_ZoneSelector.getChildrenZone(parentIdList,ZONE_TYPE_DISTRICT)){
                List<SPEN_Zone__c> zoneList=new List<SPEN_Zone__c>();
                if(parentMap.containskey(z.SPEN_Parent__c) && !parentMap.get(z.SPEN_Parent__c).isEmpty()){
                    zoneList=parentMap.get(z.SPEN_Parent__c);
                }else if(parentMap.containskey(z.SPEN_Parent__r.SPEN_Parent__c) && !parentMap.get(z.SPEN_Parent__r.SPEN_Parent__c).isEmpty()){
                    zoneList=parentMap.get(z.SPEN_Parent__r.SPEN_Parent__c);
                }
                zoneList.add(z);
                if(SPEN_UpdateMessageOnChildUtility.zoneIVRMesgMap!=null && SPEN_UpdateMessageOnChildUtility.zoneIVRMesgMap.containskey(z.SPEN_Parent__r.SPEN_Parent__c)){
                   parentMap.put(z.SPEN_Parent__r.SPEN_Parent__c,zoneList);
                }else{
                    parentMap.put(z.SPEN_Parent__c,zoneList);
                }
                //ZoneParentIdList.add(z.id); 
            }
        }
        return parentMap;
    }
    //method to fetch children if zone type=district
    private static Map<Id,List<SPEN_Zone__c>> getChildZones(List<Id> parentIdList) {
        Map<Id,List<SPEN_Zone__c>> parentMap=new Map<Id,List<SPEN_Zone__c>>();
        if(!parentIdList.isEmpty()){
            for(SPEN_Zone__c z:SPEN_ZoneSelector.getChildrenZone(parentIdList,ZONE_TYPE_Zone)){
                List<SPEN_Zone__c> zoneList=new List<SPEN_Zone__c>();
                if(z.SPEN_Parent__c!=null && parentMap.containskey(z.SPEN_Parent__c) && !parentMap.get(z.SPEN_Parent__c).isEmpty()){
                     zoneList=parentMap.get(z.SPEN_Parent__c);
                }
                zoneList.add(z);
                parentMap.put(z.SPEN_Parent__c,zoneList);
                zoneParentIdList.add(z.id);
            }
        }
        return parentMap;
    }
    private static void getParentIdsForMessageUpdate(List<SPEN_Zone__c> zoneNewList,Map<Id, SPEN_Zone__c> zoneOldMap){
        for(SPEN_Zone__c z: zoneNewList){
            SPEN_UpdateMessageOnChildUtility.getParentIdsForMessageUpdate(z);
        }
    }
    private static void getParentIdsForMessageUpdate(SPEN_Zone__c parentZone){
        if(parentZone!=null && parentZone.SPEN_Type__c== ZONE_TYPE_REGION){
            SPEN_UpdateMessageOnChildUtility.districtParentIdList.add(parentZone.id);
        }else if(parentZone!=null && parentZone.SPEN_Type__c==ZONE_TYPE_DISTRICT){
                SPEN_UpdateMessageOnChildUtility.zoneParentIdList.add(parentZone.id);
        }
    }

    // method to update child zones with parent message if overwriteToChild =true
    private static void updateChildMessages(List<SPEN_Zone__c> parentZoneList){
        List<SPEN_Zone__c> zoneDisListVal = new List<SPEN_Zone__c>();
        for(SPEN_Zone__c z: parentZoneList){
            SPEN_IVRMessage__c msg=new SPEN_IVRMessage__c();
            if(z.SPEN_IVRMessageTemplate__c!=null && SPEN_UpdateMessageOnChildUtility.zoneIVRMesgMap!=null && SPEN_UpdateMessageOnChildUtility.zoneIVRMesgMap.containsKey(z.SPEN_IVRMessageTemplate__c)){
                msg=SPEN_UpdateMessageOnChildUtility.zoneIVRMesgMap.get(z.SPEN_IVRMessageTemplate__c);
                //z.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c; //CRMD-5177
            }
            if(msg!=null && z.SPEN_OverwriteToChild__c ==true ){
                zoneDisListVal=SPEN_UpdateMessageOnChildUtility.getChildZonesToUpdateList(z,msg);
            }
            //Change based on CRMD-5177
        }
        if(!zoneDisListVal.isEmpty() && Schema.sObjectType.SPEN_Zone__c.isUpdateable()){
            update zoneDisListVal;
        }
    }
    // methid to  get list to update message
    private static List<SPEN_Zone__c> getChildZonesToUpdateList(SPEN_Zone__c parentZone,SPEN_IVRMessage__c msg){

            List<SPEN_Zone__c> zoneDisListVal = new List<SPEN_Zone__c>();
            if(parentZone.SPEN_Type__c=='Region' && SPEN_UpdateMessageOnChildUtility.childDistrictMap!=null && SPEN_UpdateMessageOnChildUtility.childDistrictMap.containsKey(parentZone.id)){
                zoneDisListVal.addAll(SPEN_UpdateMessageOnChildUtility.updateChildMessageFromParent(msg,parentZone,SPEN_UpdateMessageOnChildUtility.childDistrictMap.get(parentZone.id)));
            }else if(parentZone.SPEN_Type__c=='District' && SPEN_UpdateMessageOnChildUtility.childZoneMap!=null && SPEN_UpdateMessageOnChildUtility.childZoneMap.containsKey(parentZone.id)){
                zoneDisListVal.addAll(SPEN_UpdateMessageOnChildUtility.updateChildMessageFromParent(msg,parentZone,SPEN_UpdateMessageOnChildUtility.childZoneMap.get(parentZone.id)));
            }
            return zoneDisListVal;
    }
    //method to update message fields on children
    private static List<SPEN_Zone__c> updateChildMessageFromParent(SPEN_IVRMessage__c msg,SPEN_Zone__c parentZone, List<SPEN_Zone__c> childZoneList ){
        List<SPEN_Zone__c> zoneDisListVal = new List<SPEN_Zone__c>();
        if(msg!=null && parentZone!=null){
            for(SPEN_Zone__c zone1: childZoneList){
                zone1.SPEN_IVRMessageTemplate__c=parentZone.SPEN_IVRMessageTemplate__c;
                //Change based on CRMD-5177
                //zone1.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                zone1.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;
                zone1.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c;
                zoneDisListVal.add(zone1);
            }
        }
        return zoneDisListVal;
    }
    
}