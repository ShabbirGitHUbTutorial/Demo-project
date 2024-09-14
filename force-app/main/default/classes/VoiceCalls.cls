/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain class of the VoiceCall object
LIBRARY		:	SPEN
VERSION		:	1.0
HISTORY		:
Date			Author				Comment
NOV-11-2022		Ayush Mittal		Initial version
FEB-02-2023		Macjules Sevilla	Added after update
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class VoiceCalls 
{
	@TestVisible
	private Boolean allowVoicemailDML = true;
	public static Boolean premiseUpdateFlag = false;
    
	/**
	 * @description CONSTANTS
	 */ 
	public final static String CALL_ORIGIN_VOICEMAIL = 'Voicemail';

	/**
	 * @description BUSINESS LOGIC VARIABLES
	 */
	@TestVisible
	List<SPEN_Voicemail__c> voicemails = new List<SPEN_Voicemail__c>();

	static Map<String,String> mapPlatKeyMasterLabel= new Map<String,String>();


	/**
	 * @description Handles the BEFORE UPDATE trigger event
	 */
	public void onBeforeUpdate(Map<Id, VoiceCall> oldVoiceCallMap, List<VoiceCall> newVoiceCall){
		//CRMD-4874, Premise will be puplated from IVR and uncommented 33 line for outbound calls
		new SPEN_VoiceCallService().isUpdatingPremiseOnVoiceCall(oldVoiceCallMap, newVoiceCall);	
         try{
		for(VoiceCall voice : newVoiceCall)
		{
			VoiceCall  voicecallOldData = oldVoiceCallMap.get(voice.Id);
			// BUSINESS RULE 1 - WALLBOARD FUNCTIONALITY
			// Update the Accepted Date Time immediately when the voice call is assigned to an agent.
			// This metric is important to the wallboard functionality.
			if(voice.SPEN_CallAcceptedDateTime__c == null && voice.UserId != oldVoiceCallMap.get(voice.Id).UserId)
			{
				voice.SPEN_CallAcceptedDateTime__c = Datetime.now();
			}
			//New field was created as it should be populated only for the Callback 
			if(voice.CallType == 'Callback' && voice.SPEN_CallbackAcceptDateTime__c == null && voice.UserId != oldVoiceCallMap.get(voice.Id).UserId)
			{
				voice.SPEN_CallbackAcceptDateTime__c = Datetime.now();
			}
			// to poulating the SPEN_nextCallId__c field value
			if(voicecallOldData.NextCallId == null && voicecallOldData.NextCallId != voice.NextCallId){
				voice.SPEN_NextCallId__c = voice.NextCallId;
			}
		}      
        }catch(exception ex){
		   SEL_LoggingService.log(ex);
	    }
	}

	/* Added Under [CRMD]: 1322 */
	public void onBeforeInsert(List<VoiceCall> currentList){ 
		Map<String,String> mapExtId2CallGrp = new Map<String,String>();
		Map<String,List<VoiceCall>> mapPhone2ListOfVoiceCall = new Map<String,List<VoiceCall>>();
	    try{
			mapPhone2ListOfVoiceCall=VoiceCalls.getVoiceCallMap(currentList);
			if(mapPhone2ListOfVoiceCall != null && !mapPhone2ListOfVoiceCall.keySet().isEmpty()){
				mapExtId2CallGrp=VoiceCalls.getCallGroupMap(mapPhone2ListOfVoiceCall);
				if(mapExtId2CallGrp != null){
					VoiceCalls.updateCallGroup(mapExtId2CallGrp,currentList);
				}
			}
	    }catch(exception ex){
		   SEL_LoggingService.log(ex);
	    }
	}
	private static Map<String,List<VoiceCall>> getVoiceCallMap(List<VoiceCall> currentList){
		Map<String,List<VoiceCall>> mapPhone2ListOfVoiceCall = new Map<String,List<VoiceCall>>();
		for(VoiceCall objVoice : currentList){
			if(mapPhone2ListOfVoiceCall.containsKey(String.valueOf(objVoice.ToPhoneNumber))){
				mapPhone2ListOfVoiceCall.get(String.valueOf(objVoice.ToPhoneNumber)).add(objVoice);
			}else{
				mapPhone2ListOfVoiceCall.put(String.valueOf(objVoice.ToPhoneNumber),new List<VoiceCall>{objVoice});
			}
		}
		return mapPhone2ListOfVoiceCall;
	}
	@SuppressWarnings('PMD.SOQLSelectorPattern,PMD.ApexCRUDViolation')
	private static Map<String,String> getCallGroupMap(Map<String,List<VoiceCall>> mapPhone2ListOfVoiceCall){
		Map<String,String> mapExtId2CallGrp = new Map<String,String>();
		List<MessagingChannel> lstMsgChannel = new List<MessagingChannel>();
		List<SPEN_IVR__c > lstIVR = new List<SPEN_IVR__c >();
		if(mapPhone2ListOfVoiceCall != null && !mapPhone2ListOfVoiceCall.keySet().isEmpty()){
			lstMsgChannel= [SELECT MasterLabel,MessagingPlatformKey FROM MessagingChannel WHERE MessageType = 'Voice' AND 
			MessagingPlatformKey IN: mapPhone2ListOfVoiceCall.keySet()];
			for(MessagingChannel msgCh : lstMsgChannel)
			{
				mapPlatKeyMasterLabel.put(msgCh.MessagingPlatformKey,msgCh.MasterLabel);
			}
			if(mapPlatKeyMasterLabel != null && !mapPlatKeyMasterLabel.keySet().isEmpty()){
					lstIVR = SPEN_IVRSelector.getIvrSelector(mapPlatKeyMasterLabel.values());
					//[SELECT SPEN_CallGroup__c,SPEN_ExternalId__c FROM SPEN_IVR__c	WHERE SPEN_ExternalId__c IN:mapPlatKeyMasterLabel.values()];
			}
			if(lstIVR != null && !lstIVR.isEmpty()){
				for(SPEN_IVR__c ivr : lstIVR){
					mapExtId2CallGrp.put(ivr.SPEN_ExternalId__c,ivr.SPEN_CallGroup__c);
				}
			}
		}
		return mapExtId2CallGrp;
	}
	private static void updateCallGroup(Map<String,String> mapExtId2CallGrp ,List<VoiceCall> currentList){
		String callGroup;
		for(VoiceCall vc: currentList){
			callGroup = mapExtId2CallGrp.get(mapPlatKeyMasterLabel.get(String.valueOf(vc.ToPhoneNumber)));
			if(String.isNotBlank(callGroup)){
				vc.SPEN_CallGroup__c = callGroup;
			}else {
				vc.SPEN_CallGroup__c = 'Unclassified';
			}
		}
	}

	
	/**
	 * @description Handles the AFTER UPDATE trigger event
	 */
	public void onAfterUpdate(Map<Id, VoiceCall> prior, Map<Id, VoiceCall> current){
		List<VoiceCall> priorList = new List<VoiceCall>();
		List<VoiceCall> currentList = new List<VoiceCall>();
		 system.debug('after update Come here***');
		Set<Id> voiceCallIdSet = new Set<Id>();	
        
		if(!prior.isEmpty()) { 
			priorList = prior.values(); 
		}
		if(!current.isEmpty()) { 
			currentList = current.values(); 
		}
		voicemails=VoiceCalls.voiceMailList(currentList,prior);
		//CRMD-7689 
		voicecalls.setMPANNumberOnCallDetails(currentList, prior);
		// BUSINESS RULE 1
		// Insert voicemails for prioritisation
		if(voicemails.isEmpty() == false && this.allowVoicemailDML == true && Schema.sObjectType.SPEN_Voicemail__c.isCreateable())
		{
			insert voicemails;
		}
        for(VoiceCall voice : currentList)	{
         VoiceCall voicecallOldData = prior.get(voice.Id);
        if(voice.SPEN_VoicecallPremise__c != null && voicecallOldData.SPEN_VoicecallPremise__c != voice.SPEN_VoicecallPremise__c){
                voiceCallIdSet.add(voice.id);// 8331 Enh changes
            }
        }
        system.debug('voiceCallIdSet**' + voiceCallIdSet);
             if(voiceCallIdSet != null && voiceCallIdSet.size()>0){
                 premiseUpdateFlag = true;
                 system.debug('come here**');
               SPEN_ActiveIncidentCheck.fetchIncidentRecValue(voiceCallIdSet);// 8331 Enh changes
             }
	}
	private static List<SPEN_Voicemail__c> voiceMailList(List<VoiceCall> currentList,Map<Id, VoiceCall> prior){
        List<SPEN_Voicemail__c> voicemailList = new List<SPEN_Voicemail__c>();
		for(VoiceCall c : currentList)	{
			// BUSINESS RULE 1
			// IF the Call Origin is changed to Voicemail
			// THEN create the corresponding SPEN_Voicemail__c records
			String callOrigin=c?.CallOrigin != null?c?.CallOrigin:'';
			if(callOrigin.equalsIgnoreCase(VoiceCalls.CALL_ORIGIN_VOICEMAIL) && callOrigin!= prior.get(c.Id)?.CallOrigin){
				SPEN_Voicemail__c voicemail = new SPEN_Voicemail__c();
				voicemail.SPEN_Status__c = SPEN_Voicemails.STATUS_NOT_STARTED;
				voicemail.SPEN_Type__c = SPEN_Voicemails.TYPE_MPAS; // TODO: At some point, the type must be adjusted based on the call type
				voicemail.SPEN_VoiceCallId__c = c.Id;
				voicemailList.add(voicemail);
			}
		}
        return voicemailList;
	}
	// CRMD-7689: Voice call premise MPAN to be added to VC record
	public static void setMPANNumberOnCallDetails(List<VoiceCall> currentList,Map<Id, VoiceCall> prior){
        Map<Id,Id> callDetailsId = new Map<Id,ID>();
        Set<Id> callDetailsIds = new Set<Id>();
        Set<Id> voiceCallPremiseId = new Set<Id>();
        List<SPEN_CallDetails__c> callDetailsList = new List<SPEN_CallDetails__c>();
        Map<Id, SPEN_MPAN__c> mpanDeails = new Map<Id, SPEN_MPAN__c>();
        for(VoiceCall vc :  currentList){
            if(vc.SPEN_RelatedCallDetails__c != Null && vc.SPEN_VoicecallPremise__c != Null){
                callDetailsIds.add(vc.SPEN_RelatedCallDetails__c);
                voiceCallPremiseId.add(vc.SPEN_VoicecallPremise__c);
                callDetailsId.put(vc.SPEN_VoicecallPremise__c,vc.SPEN_RelatedCallDetails__c);
            }
        }
        if(voiceCallPremiseId.size() >0 && callDetailsIds.size() >0){
            for(SPEN_MPAN__c mp : [Select Id,SPEN_AccountNumberMPAN__c,SPEN_Premise__c from SPEN_MPAN__c where SPEN_Premise__c =:voiceCallPremiseId and SPEN_ConnectionStatus__c = 'Energised']){
                mpanDeails.put(mp.SPEN_Premise__c, mp);
            }
        }
        if(mpanDeails.size() >0){
            for(VoiceCall vc :  currentList){
                if(vc.SPEN_VoicecallPremise__c != prior.get(vc.Id).SPEN_VoicecallPremise__c && callDetailsId.get(vc.SPEN_VoicecallPremise__c) != null){
                    SPEN_CallDetails__c cDetails = new SPEN_CallDetails__c(Id = callDetailsId.get(vc.SPEN_VoicecallPremise__c), SPEN_MPAN_Number__c = mpanDeails.get(vc.SPEN_VoicecallPremise__c).SPEN_AccountNumberMPAN__c  );
                    callDetailsList.add(cDetails);
                }
            } 
        }
        
        if(!callDetailsList.isEmpty()){
            update callDetailsList; 
        }
    }
	
}