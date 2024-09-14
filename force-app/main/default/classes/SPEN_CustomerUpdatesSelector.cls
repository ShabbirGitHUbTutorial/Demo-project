/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the SPEN_CustomerUpdate__c Queries.
HISTORY     :
Date            Author              Comment
Jan-19-2023     Deepraj Bhushan        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_CustomerUpdatesSelector {
		/**************************************************
	   	@Author: Smita Raikar
	   	@Date: 31/10/22
	   	@purpose: Method to get contact premise details.
	   	***************************************************/
		public static Map<Id,SPEN_CustomerUpdate__c> getCustomerUpdateForVoiceCall(VoiceCall voiceCallObj)
	   	{
            Map<Id,SPEN_CustomerUpdate__c> voiceCustomerUpdateMap = new Map<Id,SPEN_CustomerUpdate__c>();
            	string contactIdPrefix = Schema.SObjectType.Contact.getKeyPrefix();
            	if(voiceCallObj.RelatedRecordId !=null && String.valueOf(voiceCallObj.RelatedRecordId).startsWith(contactIdPrefix) && voiceCallObj.CallType == 'Outbound'){
                	List<SPEN_CustomerUpdate__c> odObjList = [SELECT Id,SPEN_IncidentId__c 
                                                              	FROM SPEN_CustomerUpdate__c 
                                                              	WHERE OwnerId =: voiceCallObj.OwnerId 
                                                              	AND SPEN_ContactId__c =: voiceCallObj.RelatedRecordId
                                                              	AND LastModifiedDate=today Limit 1];
                	if(!odObjList.isEmpty()){
                    	voiceCustomerUpdateMap.put(voiceCallObj.Id,odObjList[0]);
                	}
            	}
		   return voiceCustomerUpdateMap;
	   	}
}