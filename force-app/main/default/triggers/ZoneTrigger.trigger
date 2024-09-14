trigger ZoneTrigger on SPEN_Zone__c (before insert,before update, after update) {

    if(Trigger.isInsert && Trigger.isBefore){
        SPEN_ZoneConfigurationService.beforeZoneInsert(Trigger.new);
      }
 	if(Trigger.isUpdate && Trigger.isBefore){
       SPEN_ZoneConfigurationService.beforeZoneUpdate(Trigger.oldMap,Trigger.new);
       
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
       SPEN_ZoneConfigurationService.afterZoneUpdate(Trigger.oldMap,Trigger.new);
       SPEN_ZoneConfigurationService.createZoneCreate(Trigger.oldMap,Trigger.new);
    }
}