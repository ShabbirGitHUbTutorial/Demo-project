public with sharing class SPEN_ContactTriggerHandler {
    public static void sPEN_ContactPreviousValue(List<Contact> ConLst, Map<id,Contact> oldMap){
        
        list<SPEN_ContactSnapshot__c> conSnapList = new list<SPEN_ContactSnapshot__c>();
        
        for(Contact con :ConLst){
            if((con.MobilePhone != oldMap.get(con.id).MobilePhone && con.Phone != oldMap.get(con.id).Phone && 
                con.Email != oldMap.get(con.id).Email && con.OtherPhone != oldMap.get(con.id).OtherPhone) &&
               (con.FirstName != oldMap.get(con.id).FirstName || con.LastName != oldMap.get(con.id).LastName)){
                   SPEN_ContactSnapshot__c scsp = new SPEN_ContactSnapshot__c();
                   
                   scsp.SPEN_ContactID__c = con.id;
                   scsp.SPEN_CurrentValueJSON__c = JSON.serialize(con);
                   scsp.SPEN_PreviousValueJSON__c = JSON.serialize(oldMap.get(con.id));
                   conSnapList.add(scsp);
                   
               }
        }
        if(conSnapList.size()>0){
            try{
                insert conSnapList;
            }
            catch(exception e){
                //system.debug('Error Message' +e.getMessage());
                SEL_LoggingService.log(e);
            }
        }
    }
    
    public static void sPEN_ContactUpdateSyncADQMValueinsert (List<Contact> ConLst){
       /* List<Contact> LstCon=new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        for(Contact conRec: ConLst){
            conIds.add(conRec.Id);
        }
        
        Map<Id,Id> contactPremiseMap = new Map<Id,Id>();
        if(!conIds.IsEmpty())
        {
            contactPremiseMap = SPEN_ContactPremisesSelector.checkPremiseForContact(conIds);
        }
        for(Contact Co : ConLst){
            if(!Co.SPEN_RequireSynctoADQM__c && Co.SPENAdqmLastSyncDateTime__c==Null && !contactPremiseMap.isEmpty() && contactPremiseMap.containsKey(Co.Id)){
            	co.SPEN_RequireSynctoADQM__c=True;
            }
        }*/
        
    }
    
    public static void sPEN_ContactUpdateSyncADQMValueupdate ( Map<id,Contact> oldMap,List<Contact> ConLstnew){
        List<Contact> LstCon=new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        for(Contact conRec: ConLstnew){
            conIds.add(conRec.Id);
        }
        
        Map<Id,Id> contactPremiseMap = new Map<Id,Id>();
        if(!conIds.IsEmpty())
        {
            contactPremiseMap = SPEN_ContactPremisesSelector.checkPremiseForContact(conIds);
        }
        for(Contact Connew : ConLstnew){
            if(oldMap.get(Connew.id).SPENAdqmLastSyncDateTime__c==Connew.SPENAdqmLastSyncDateTime__c && !contactPremiseMap.isEmpty() && contactPremiseMap.containsKey(Connew.Id)){
            	Connew.SPEN_RequireSynctoADQM__c=True;
            }
        }
        
        
        
    }
    
}