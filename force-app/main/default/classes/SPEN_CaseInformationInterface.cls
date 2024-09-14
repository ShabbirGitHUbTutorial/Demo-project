@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_CaseInformationInterface implements TriggerHandlerInterface{
    Public Static ID LCTRecordTypeId =  Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_LCTRecordType').getRecordTypeId();
    Public Static ID SIRecordTypeId =  Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SmartIntervention').getRecordTypeId();
    public void beforeInsert(SObject[] newItems){
        SPEN_CaseInformationTriggerHandler.beforeInsert(newItems);
		List<SPEN_CaseInformation__c> caseInfos = new List<SPEN_CaseInformation__c>();
        for (SObject newItem : newItems) {
            SPEN_CaseInformation__c newCaseInfo = (SPEN_CaseInformation__c)newItem;
            if (newCaseInfo.SPEN_FlowReceivedDate__c != null || (newCaseInfo.SPEN_DateLetter1__c != null 
                                                                 && 'Reject: Unable to Contact Customer Reasonable Endeavours Made'.equalsIgnorecase(newCaseInfo.SPEN_JobStatus__c))){
                                                                     caseInfos.add((SPEN_CaseInformation__c)newItem);
                                                                 }
        }
        if(!caseInfos.isEmpty() && caseInfos.size() > 0 ){
        SPEN_CaseInformationTriggerHandler.calculateAndSetDates(caseInfos);           
        }
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
	List<SPEN_CaseInformation__c> caseInfosToUpdate = new List<SPEN_CaseInformation__c>();
        for (Id caseInfoId : newItems.keySet()){
            SPEN_CaseInformation__c newCaseInfo = (SPEN_CaseInformation__c)newItems.get(caseInfoId);
            SPEN_CaseInformation__c oldCaseInfo = (SPEN_CaseInformation__c)oldItems.get(caseInfoId);
            if ((newCaseInfo.SPEN_FlowReceivedDate__c != oldCaseInfo.SPEN_FlowReceivedDate__c) ||
                (newCaseInfo.SPEN_DateLetter1__c != oldCaseInfo.SPEN_DateLetter1__c 
                 && 'Reject: Unable to Contact Customer Reasonable Endeavours Made'.equalsIgnorecase(newCaseInfo.SPEN_JobStatus__c))){
                     caseInfosToUpdate.add(newCaseInfo);
                     if (!caseInfosToUpdate.isEmpty() && caseInfosToUpdate.size()>0){
                         SPEN_CaseInformationTriggerHandler.calculateAndSetDates(caseInfosToUpdate);
                     }
                 }
            
        }
        
    }
    public void afterInsert(Map<Id, SObject> newItems)
    {
		/*List<Id> caseInfoIds = new List<Id>();
		//CRMD-11219 starts here
        Map<String,Id> mapMpan = new Map<String,Id>();
        List<String> mpanCoreList = new List<String>();
        Set<Id> mpanIds = new Set<Id>();
        for(SPEN_CaseInformation__c cseInfo : (List<SPEN_CaseInformation__c>)newItems.values())
        {
            mpanCoreList.add(cseInfo.SPEN_MPANCore__c);
        }
        if (!mpanCoreList.isEmpty())
        {
            for(SPEN_MPAN__c mpan : SPEN_MPANSelector.getRecordForMpanAccountNumber(mpanCoreList))
            {
                mapMpan.put(mpan.SPEN_AccountNumberMPAN__c, mpan.Id);
            }
        }
        //CRMD-11219 ends here
			
			for (SPEN_CaseInformation__c newItem : (List<SPEN_CaseInformation__c>)newItems.values()) {
				if (//newItem.SPEN_JobStatus__c != null &&
					newItem.SPEN_JobStatus__c != 'Reject: Duplicate' &&
					newItem.SPEN_JobStatus__c != 'Reject: Incomplete contact details' &&
					newItem.SPEN_JobStatus__c != 'Reject: Out of Area / unknown postcode' &&
					newItem.SPEN_JobStatus__c != 'In flight job (CAT-A or CAT-B)' &&
					newItem.SPEN_JobStatus__c != 'MEX completed' &&
					newItem.SPEN_JobStatus__c != 'Cat C Job - On Hold'/*&&
					newItem.Owner.Name.contains('SPEN Azure User')) {
					//caseInfoIds.add(newItem.Id);
				}
			//CRMD-11219 starts here
             if (newItem.SPEN_MPANCore__c!= NULL && 
                newItem.SPEN_IsMigrated__c == FALSE && 
                newItem.recordtypeid == SIRecordTypeId &&
		        newItem.SPEN_AssetConditionCode__c!=null &&
                newItem.SPEN_AssetConditionCode__c.startswith ('B') == TRUE
                && mapMpan.containsKey(newItem.SPEN_MPANCore__c))
            {
                mpanIds.add(mapMpan.get(newItem.SPEN_MPANCore__c));
                //system.debug('mpanIds-->'+mpanIds);
                
            }
               
        }
        if(!mpanIds.isEmpty())
        {
            SPEN_CaseInformationTriggerHandler.fetchMpanDetails(mpanIds);
        }
              //CRMD-11219 ends here   
			
			
			if (!caseInfoIds.isEmpty()) {
				Database.executeBatch(new SPEN_CaseInfoJobStatusBatchUpdate(caseInfoIds));
			}*/
        
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        //List<SPEN_CaseInformation__c> caseInfosToUpdateEntitlement = new List<SPEN_CaseInformation__c>();
        
        /*for (Id caseInfoId : newItems.keySet())
        {
            SPEN_CaseInformation__c newCaseInfo = (SPEN_CaseInformation__c)newItems.get(caseInfoId);
            SPEN_CaseInformation__c oldCaseInfo = (SPEN_CaseInformation__c)oldItems.get(caseInfoId);
            if (newCaseInfo.recordtypeid == LCTRecordTypeId && newCaseInfo.SPEN_SubStatus__c != null && newCaseInfo.SPEN_SubStatus__c != oldCaseInfo.SPEN_SubStatus__c && 
                (newCaseInfo.SPEN_SubStatus__c.equalsIgnoreCase(System.label.SPEN_CaseInfo28DaysLetterSubStatus) || 
                 newCaseInfo.SPEN_SubStatus__c.equalsIgnoreCase(System.label.SPEN_CaseInfoMissingInfoRequestedSubStaus))){
                     caseInfosToUpdateEntitlement.add(newCaseInfo);
                     SPEN_CaseInformationTriggerHandler.updateParentCaseEntitlement(caseInfosToUpdateEntitlement);
                 }
        }*/
        SPEN_CaseInformationTriggerHandler.updateParentCaseEntitlement(newItems,oldItems);
		/*List<Id> caseInfoIds = new List<Id>();
        
        for (SPEN_CaseInformation__c newItem : (List<SPEN_CaseInformation__c>)newItems.values()) {
            SPEN_CaseInformation__c oldItem = (SPEN_CaseInformation__c)oldItems.get(newItem.Id);
            
            // Check if SPEN_JobStatus__c has changed and meets the criteria
            if (newItem.SPEN_JobStatus__c != oldItem.SPEN_JobStatus__c &&
                newItem.SPEN_JobStatus__c != null &&
                newItem.SPEN_JobStatus__c != 'Reject: Duplicate' &&
				newItem.SPEN_JobStatus__c != 'Reject: Incomplete contact details' &&
				newItem.SPEN_JobStatus__c != 'Reject: Out of Area / unknown postcode' &&
				newItem.SPEN_JobStatus__c != 'In flight job (CAT-A or CAT-B)' &&
				newItem.SPEN_JobStatus__c != 'MEX completed' &&
                UserInfo.getUserName() == 'SPEN Azure User') {
                caseInfoIds.add(newItem.Id);
            }
        }
        
        if (!caseInfoIds.isEmpty()) {
            Database.executeBatch(new SPEN_CaseInfoJobStatusBatchUpdate(caseInfoIds));
        }*/
        //CRMD-10762
        SPEN_CaseInformationTriggerHandler.afterUpdate(newItems,oldItems);
        //END
    }
    
     public void afterDelete(Map<Id, SObject> oldItems){
        
    }
	 public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
}