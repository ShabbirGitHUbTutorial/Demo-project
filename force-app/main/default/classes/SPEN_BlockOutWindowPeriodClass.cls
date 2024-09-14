public with sharing class SPEN_BlockOutWindowPeriodClass 
{
    public static Boolean checkBlackoutWindowPeriod(String typeCheck){
        Boolean result = false;
        if(String.isNotBlank(typeCheck)){
            Id recTypeIdOfBlackoutWindowRT = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get(typeCheck).getRecordTypeId();
            SPEN_IVROperatingHours__c lstIvrHour =SPEN_IvrOperatingHoursSelector.getIVROperatingHourTypeCheck(recTypeIdOfBlackoutWindowRT);
            //[select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordTypeId = :recTypeIdOfBlackoutWindowRT and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
            if(lstIvrHour != null){
                result=SPEN_BlockOutWindowPeriodClass.findResult(lstIvrHour);
            }
        }
            return result;
    }
    public static Boolean findResult(SPEN_IVROperatingHours__c lstIvrHour){
        Boolean result = false;
        Boolean isStartTimegreater=lstIvrHour.SPEN_StartTime__c > lstIvrHour.SPEN_EndTime__c;
        Boolean isCurrentTimeFuture=System.now().time() < lstIvrHour.SPEN_StartTime__c && System.now().time() < lstIvrHour.SPEN_EndTime__c;
        Boolean isCurrentTimePast=System.now().time() > lstIvrHour.SPEN_StartTime__c && System.now().time() > lstIvrHour.SPEN_EndTime__c;
        if((lstIvrHour.SPEN_StartTime__c == null && lstIvrHour.SPEN_EndTime__c == null) 
            || (!isStartTimegreater && (isCurrentTimeFuture||isCurrentTimePast))
            || (isStartTimegreater && (System.now().time() < lstIvrHour.SPEN_StartTime__c && System.now().time() > lstIvrHour.SPEN_EndTime__c))){
            result = true;
        }
        return result;
    }

}