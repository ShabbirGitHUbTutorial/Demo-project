trigger SPEN_IVROperatingHoursTrigger on SPEN_IVROperatingHours__c (before insert, before Update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
        SPEN_IVROperatingHoursHandler.ActiveRecordValidation(Trigger.new,null);
        } else if(Trigger.isUpdate){
        SPEN_IVROperatingHoursHandler.ActiveRecordValidation(Trigger.new,Trigger.oldmap); 
        }
        }
}