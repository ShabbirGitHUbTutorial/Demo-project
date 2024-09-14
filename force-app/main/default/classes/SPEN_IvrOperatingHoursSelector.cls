public with sharing class SPEN_IvrOperatingHoursSelector 
{   
    
    public static list<SPEN_IVROperatingHours__c> getIVROperatingHours(String iVRRecordTypename){
        list<SPEN_IVROperatingHours__c> listivr=new list<SPEN_IVROperatingHours__c>();       
        if(String.isNotBlank(iVRRecordTypename))  {
            try{
                listivr = [SELECT Id,SPEN_isActive__c, SPEN_isDaily__c,SPEN_StartTime__c, SPEN_EndTime__c,SPEN_RestrictStartDate__c, 
                            SPEN_RestrictEndDate__c FROM SPEN_IVROperatingHours__c
                            WHERE SPEN_isActive__c = true AND RecordType.Name = :iVRRecordTypename //WITH SECURITY_ENFORCED //201
                             limit 1];
            }catch(Exception e){
            	SEL_LoggingService.log(e);
        	}
        }
        return listivr;
    }
    //added by shubhi
    //usage in spen_ivroperatinghourshandler
    public static list<SPEN_IVROperatingHours__c> getIVROperatingHours(Set<Id> recidset,Set<Id> currentidset){
        list<SPEN_IVROperatingHours__c> listivr=new list<SPEN_IVROperatingHours__c>();       
        if(recidset!=null && currentidset!=null)  {
            listivr = [SELECT id,recordtypeid 
                FROM SPEN_IVROperatingHours__c
                WHERE recordtypeid IN :recidset and SPEN_isActive__c = TRUE and ID NOT IN :currentidset WITH SECURITY_ENFORCED];
        }
        return listivr;
    }
    //added by Sheker kulkacherla for remediation
    // usage: used in IncidentService and SPEN_BlockOutWindowPeriod Class
    public static SPEN_IVROperatingHours__c getIVROperatingHourTypeCheck(Id ivrRecordTypeId){
        SPEN_IVROperatingHours__c ivrTypeCheck = new SPEN_IVROperatingHours__c();
        try{
            if(ivrRecordTypeId != null) {
            ivrTypeCheck = [SELECT Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId
                        	FROM SPEN_IVROperatingHours__c
                    		WHERE SPEN_isActive__c = true AND RecordType.Id = :ivrRecordTypeId WITH SECURITY_ENFORCED LIMIT 1];
        	}
        }catch(Exception e){
            SEL_LoggingService.log(e);
        }
        return ivrTypeCheck;
    }
}