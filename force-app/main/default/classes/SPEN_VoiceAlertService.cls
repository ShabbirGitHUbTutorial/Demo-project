/**********************************************************************************************
* @Author:      Akshay Pandit
* @Date:        06/12/2022
* @Description: 
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_VoiceAlertService {
    
    public static void isServiceCall(List<SPEN_VoiceAlert__c> sVoiceAlertList){
        try{
       	Set<Id> vAlertId = new Set<Id>();
        String ivrMsg;
        for(SPEN_VoiceAlert__c sP:sVoiceAlertList){
            vAlertId.add(sP.Id);
            ivrMsg = sP.SPEN_BroadcastMessage__c;   
        }
        Id jobId;
        //system.debug('sVoiceAlertMap'+vAlertId);
        //system.debug('IVRMsg'+IVRMsg);
        //System.debug('before queueable Callout');
        if (vAlertId.Size () > 0) jobId= System.enqueueJob(new SPEN_VoiceAlertServiceQueueable(vAlertId,ivrMsg)); 
       // System.debug('After queueable Callout');
        //passPhoneNumberToAWS(vAlertId);
        
    	}
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
 //@InvocableMethod(label='Call Number' category='AWS Dialler')
        
}