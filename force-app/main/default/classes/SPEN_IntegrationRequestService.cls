/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        11/11/2022
* @Description: Service class from IntegrationRequestHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with Sharing class SPEN_IntegrationRequestService 
{   
    public void isStatusProcessing(List<SPEN_IntegrationRequest__c> newCreatedIntegrationRequestList)
    {
        Map<Id, SPEN_IntegrationRequest__c> createdIntegrationRequestMap = new Map<Id, SPEN_IntegrationRequest__c>();
        
        try
        {
            for(SPEN_IntegrationRequest__c newIntegrationRequest : newCreatedIntegrationRequestList)
            {
                if(newIntegrationRequest.SPEN_Status__c == 'Processing' && newIntegrationRequest.SPEN_IntegrationRequestServiceClass__c == 'SPEN_MeterPingService')
                {
                    createdIntegrationRequestMap.put(newIntegrationRequest.Id, newIntegrationRequest);
                }
            }
            //system.debug('createdIntegrationRequestMap:' +createdIntegrationRequestMap);
            
            if(!createdIntegrationRequestMap.isEmpty())
            { 
                //system.debug('After insertion Future Callout');
                List<Id> listOfIds = new List<Id>(createdIntegrationRequestMap.keyset());
                //system.debug('listOfIds: '+listOfIds);
                SPEN_IntegrationRequest__c testReq = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(listOfIds[0]);
                pingMeterCalled(listOfIds[0],testReq.SPEN_Records__c);
                //system.debug('After pingMeterCalled()');
            }
        }
        catch(exception ex)
        {
            SEL_LoggingService.log(ex);
        }
    }
    
    public void isStatusChanged(Map<Id,SPEN_IntegrationRequest__c> oldUpdatedIntegrationRequestMap, List<SPEN_IntegrationRequest__c> newUpdatedIntegrationRequestList){
        try
        {
            Map<Id, SPEN_IntegrationRequest__c> updatedIntegrationRequestMap = new Map<Id, SPEN_IntegrationRequest__c>();
            for(SPEN_IntegrationRequest__c newIntegrationRequest : newUpdatedIntegrationRequestList)
            {
                if(isStatusChng(oldUpdatedIntegrationRequestMap.get(newIntegrationRequest.Id),newIntegrationRequest))
                {
                    updatedIntegrationRequestMap.put(newIntegrationRequest.Id, newIntegrationRequest);
                }
            }
            //system.debug('updatedIntegrationRequestMap:' +updatedIntegrationRequestMap);
            
            if(!updatedIntegrationRequestMap.isEmpty())
            {
                //system.debug('After updation Furure Callout');
                List<Id> listOfIds = new List<Id>(updatedIntegrationRequestMap.keyset());
                //system.debug('listOfIds: '+listOfIds);
                SPEN_IntegrationRequest__c testReq = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(listOfIds[0]);
                pingMeterCalled(listOfIds[0],testReq.SPEN_Records__c);
                //system.debug('After pingMeterCalled()');
            }
        }
        catch(exception ex)
        {
            SEL_LoggingService.log(ex);
        }
    }
    
    @future(callout=true)
    Public static void pingMeterCalled(Id testId, String mpanNumber)
    {
        SPEN_MeterPingService.getIntgReqResultDetails(testId, mpanNumber);  
    }
    
    Public static Boolean isStatusChng(SPEN_IntegrationRequest__c oldIntReq, SPEN_IntegrationRequest__c newIntReq)
    {
        Boolean isStatus = false;
        try
        {
            if(newIntReq.SPEN_IntegrationRequestServiceClass__c == 'SPEN_MeterPingService' && oldIntReq.SPEN_Status__c != newIntReq.SPEN_Status__c && (oldIntReq.SPEN_Status__c == 'Not Started' || oldIntReq.SPEN_Status__c == 'Failed') && newIntReq.SPEN_Status__c== 'Processing' )
            {
                isStatus = true;
            }
            return isStatus;
        }
        catch(exception ex)
        {
            SEL_LoggingService.log(ex);
            return isStatus;
        }
    }
    
    
    //////////////// Code for Assign IVR message Functionality
    
    public void isStatusProcessingForAssignIvrMsg(List<SPEN_IntegrationRequest__c> newUpdatedIntegrationRequestList){
     	   Map<Id, SPEN_IntegrationRequest__c> updtdIntegrationRequestMap = new Map<Id, SPEN_IntegrationRequest__c>();
        
        try{
            for(SPEN_IntegrationRequest__c newIntgrtnRequest : newUpdatedIntegrationRequestList){
                if(newIntgrtnRequest.SPEN_Status__c == 'Processing' && newIntgrtnRequest.SPEN_IntegrationRequestServiceClass__c == 'SPEN_IVRMessageService'){
                    updtdIntegrationRequestMap.put(newIntgrtnRequest.Id, newIntgrtnRequest);
                }
            }
            //system.debug('updtdIntegrationRequestMap:' +updtdIntegrationRequestMap);
            
            if(!updtdIntegrationRequestMap.isEmpty()){ 
                //system.debug('After Update Future Callout For Assign IVR message Functionality');
                List<Id> listOfIdsForIvrMsg = new List<Id>(updtdIntegrationRequestMap.keyset());
                //system.debug('listOfIdsForIvrMsg: '+listOfIdsForIvrMsg);
                SPEN_IntegrationRequest__c testReqIvrMsg = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(listOfIdsForIvrMsg[0]);
                assignIvrMsgCalled(listOfIdsForIvrMsg[0],testReqIvrMsg.SPEN_Records__c);
                //system.debug('After getIntgReqRsltForAssignIvrMsg()');
            }
        }
        catch(exception ex) {
            SEL_LoggingService.log(ex);
        }
    }
    
    @future(callout=true)
    Public static void assignIvrMsgCalled(Id testIdIvrMsg, String testPremiseIDIvrMsg)
    {
        SPEN_IVRMessageService.getIntgReqRsltForAssignIvrMsg(testIdIvrMsg, testPremiseIDIvrMsg);  
    }
    //////////////// CRMD-2180
    
    public void isStatusProcessingForEchoesSearch(List<SPEN_IntegrationRequest__c> newIntegrationRequestList)
    {
     	Map<Id, SPEN_IntegrationRequest__c> updtdIntegrationRequestMap = new Map<Id, SPEN_IntegrationRequest__c>();
        try
        {
            for(SPEN_IntegrationRequest__c newIntgrtnRequest : newIntegrationRequestList)
            {
                if(newIntgrtnRequest.SPEN_Status__c == 'Processing' && newIntgrtnRequest.SPEN_IntegrationRequestServiceClass__c == 'SPEN_SearchEcoesService'){
                    updtdIntegrationRequestMap.put(newIntgrtnRequest.Id, newIntgrtnRequest);
                }
            }
            if(!updtdIntegrationRequestMap.isEmpty())
            { 
                List<Id> listOfIdsForMpan = new List<Id>(updtdIntegrationRequestMap.keyset());
                SPEN_IntegrationRequest__c testReqIvrMsg = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(listOfIdsForMpan[0]);
                mpanRecordMethod(listOfIdsForMpan[0],testReqIvrMsg.SPEN_Records__c);
            }
        }
        catch(exception ex) 
        {
            SEL_LoggingService.log(ex);
        }
	
    }
    
    
    @future(callout=true)
    Public static void mpanRecordMethod(Id testIdIvrMsg, String details)
    {
        SPEN_SearchEcoesService.getResultFromMpan(testIdIvrMsg, details);  
    }
    //4489
	public void isStatusProcessingForMeterDetails(List<SPEN_IntegrationRequest__c> newIntegrationRequestList)
    {
     	Map<Id, SPEN_IntegrationRequest__c> updtdIntegrationRequestMap = new Map<Id, SPEN_IntegrationRequest__c>();
        try
        {
            for(SPEN_IntegrationRequest__c newIntgrtnRequest : newIntegrationRequestList)
            {
                if(newIntgrtnRequest.SPEN_Status__c == 'Processing' && newIntgrtnRequest.SPEN_IntegrationRequestServiceClass__c == 'SPEN_GetMeterDetailsByMpanService'){
                    updtdIntegrationRequestMap.put(newIntgrtnRequest.Id, newIntgrtnRequest);
                }
            }
            if(!updtdIntegrationRequestMap.isEmpty())
            { 
                List<Id> listOfIdsForIntReq = new List<Id>(updtdIntegrationRequestMap.keyset());
                SPEN_IntegrationRequest__c testReqIvrMsg = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(listOfIdsForIntReq[0]);

                meterDetailsForMpan(listOfIdsForIntReq[0],testReqIvrMsg.SPEN_Records__c);
            }
        }
        catch(exception ex) 
        {
            SEL_LoggingService.log(ex);
        }
	
    }
    
    @future(callout=true)
    Public static void meterDetailsForMpan(Id testIdIvrMsg, String mpanNumber)
    {
        SPEN_GetMeterDetailsByMpanService.getMeterDetailsFromMpan(testIdIvrMsg, mpanNumber);  
    }
	//CRMD - 5165
    public void isStatusProcessingForPremise(List<SPEN_IntegrationRequest__c> newUpdatedIntegrationRequestList)
    {
        Map<Id, SPEN_IntegrationRequest__c> updtdIntegrationRequestMap = new Map<Id, SPEN_IntegrationRequest__c>();
        
        try
        {
            for(SPEN_IntegrationRequest__c newIntgrtnRequest : newUpdatedIntegrationRequestList)
            {
                if(newIntgrtnRequest.SPEN_Status__c == 'Processing' && newIntgrtnRequest.SPEN_IntegrationRequestServiceClass__c == 'SPEN_ActiveIncidentGetPremiseService')
                {
                    getPremiseCalled(newIntgrtnRequest.id,newIntgrtnRequest.SPEN_Records__c);
                    //updtdIntegrationRequestMap.put(newIntgrtnRequest.Id, newIntgrtnRequest);
                }
            }
        }
        catch(exception ex) {
            SEL_LoggingService.log(ex);
        }
    }
    
    @future(callout=true)
    Public static void getPremiseCalled(Id newIntgrtnRequestId,String premiseId)
    {
        system.debug('newIntgrtnRequest**' + premiseId);
         system.debug('newIntgrtnRequest**' + newIntgrtnRequestId);
        SPEN_ActiveIncidentGetPremiseService.getIntgRequestRecord(newIntgrtnRequestId,premiseId); 
        SPEN_IntegrationRequest__c newIntgrtnRequest = [Select id,SPEN_RelatedVoiceCall__c,SPEN_RelatedRecord__c from SPEN_IntegrationRequest__c where id =: newIntgrtnRequestId];
        system.debug('newIntgrtnRequest**' + newIntgrtnRequest);
        List<VoiceCall> voicecallRec = [Select id,SPEN_RelatedIncident__c from VoiceCall where id =: newIntgrtnRequest.SPEN_RelatedVoiceCall__c];
        voicecallRec[0].SPEN_RelatedIncident__c = newIntgrtnRequest.SPEN_RelatedRecord__c;
        update voicecallRec[0];
        system.debug('voicecallRec**' + voicecallRec);
    }
}