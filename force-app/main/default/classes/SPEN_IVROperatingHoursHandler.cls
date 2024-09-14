public class SPEN_IVROperatingHoursHandler {
    final static Id IVRSMS = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
    final static Id IVRVA = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
    static map<id,string> recMap = new map<id,string>();
    public static void activeRecordValidation(List<SPEN_IVROperatingHours__c> iVROperHrsMap,map<id,SPEN_IVROperatingHours__c> oldmap){
        boolean isinsert = (oldmap == null);
        map<id,string> recMap = new map<id,string>();
        set<id> recidset = new set<id>();
        set<id> currentidset = new set<id>();
        if(!isinsert){
            currentidset = oldmap.keyset();
        }
        for(SPEN_IVROperatingHours__c ivr :iVROperHrsMap){
            recidset.add(ivr.RecordTypeId);
        }
        recMap.put(IVRSMS,'SMS Blackout Window');
        recMap.put(IVRVA,'VA Blackout Window');
        Map<id,list<SPEN_IVROperatingHours__c>> oprMap = new  map<id,list<SPEN_IVROperatingHours__c>>();
        oprMap=SPEN_IVROperatingHoursHandler.getIVRohMap(SPEN_IvrOperatingHoursSelector.getIVROperatingHours(recidset,currentidset));
        if(!oprMap.isEmpty()){
            SPEN_IVROperatingHoursHandler.verifyActive(iVROperHrsMap,oprMap);
        }
    }
    private static Map<id,list<SPEN_IVROperatingHours__c>> getIVRohMap(List<SPEN_IVROperatingHours__c> listIVRoh){
        Map<id,list<SPEN_IVROperatingHours__c>> oprMap = new  map<id,list<SPEN_IVROperatingHours__c>>();
        for(SPEN_IVROperatingHours__c opr :listIVRoh){
            if(oprMap.containskey(opr.recordtypeid)){
                oprMap.get(opr.recordtypeid).add(opr);    
            }
            else {
                oprMap.put(opr.recordtypeid,new list<SPEN_IVROperatingHours__c>{opr});
            }
        }
        return oprMap;
    }
    //added by shubhi for pmd violation resolution
    private static void verifyActive(List<SPEN_IVROperatingHours__c> iVROperHrsMap,Map<id,list<SPEN_IVROperatingHours__c>> oprMap){
        for(SPEN_IVROperatingHours__c opr :iVROperHrsMap){
            if((opr.RecordTypeId == IVRSMS || opr.RecordTypeId == IVRVA) && opr.SPEN_isActive__c && oprMap.containskey(opr.RecordTypeId) && oprMap.get(opr.RecordTypeId).size()>0){
                opr.adderror('Only One Active Blackout Window should be available for ' +recMap.get(opr.RecordTypeId));
            }
        }
    }
    
}