/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        11/10/2022
* @Description: Service class is on IncidentTrigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  
***********************************************************************************************/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount')
public without sharing class IncidentService
{
    public static final String INCIDENT_CONFIGSETTING = 'Incident broadcast message updated last one hour';
    public static final String MESSAGINGTASKEVENT = 'Incident Created';
    public static final String MESSAGINGTASKSTATUS = 'New';
	public static final Id MSGTASKRECTYPE = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
    //Method to Compare Status from IncidentOldMap To IncidentNewMap
    
public void compareStatusOfIncident(List<Incident> incdntListToCheckStatus)
    {
        try
        {
            for (Incident incdntAllToChckStatus: incdntListToCheckStatus)
            {
                Incident oldValue = (Incident) Trigger.oldMap.get(incdntAllToChckStatus.Id);
                if(incdntAllToChckStatus.SPEN_IncidentStatus__c!=((Incident)(trigger.oldMap.get(incdntAllToChckStatus.Id))).SPEN_IncidentStatus__c)
                {
                    incdntAllToChckStatus.SPEN_StatusUpdated__c = true;
                    incdntAllToChckStatus.SPEN_StatusUpdateDate__c = System.now(); //CRMD-549 
                }
                if(incdntAllToChckStatus.SPEN_IsRecordViewed__c == false && oldValue.SPEN_IsRecordViewed__c == false)
                {
                    incdntAllToChckStatus.SPEN_IsRecordViewed__c = True;
                }
                else if(incdntAllToChckStatus.SPEN_IsRecordViewed__c == true && oldValue.SPEN_IsRecordViewed__c == true)
                {
                    incdntAllToChckStatus.SPEN_IsRecordViewed__c = true;
                }
                else
                {
                    incdntAllToChckStatus.SPEN_IsRecordViewed__c = false;
                }
                //incdntAllToChckStatus.SPEN_IsRecordViewed__c = true;
            }
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }
    
    //Method to update the HV Incident Message
    public static void assignHVIncidentMsg(List<Incident> incidentList,Map<Id, Incident> incidentOldMap)
    {    
        try
        {
            for(Incident inc: incidentList)
            {
                
                if((inc.SPEN_IncidentType__c=='HV_S' || inc.SPEN_IncidentType__c=='HV_N') && inc.SPEN_IncidentCategory__c=='ESOD' && inc.SPEN_HVIncidentMessage__c==NULL)    
                {
                    SPEN_ConfigurableSettings__c config=new SPEN_ConfigurableSettings__c();
                    config = SEL_ConfigurationSettingSelector.getHVconfigSetting();
                    inc.SPEN_HVIncidentMessage__c = config.SPEN_Description__c;
                    if (inc.SPEN_IVRMessages__c == NULL)
                    {
                        inc.SPEN_IVRMessage__c = inc.SPEN_HVIncidentMessage__c;
                    }
                    
                } 
                else if((inc.SPEN_IncidentType__c=='HV_S' || inc.SPEN_IncidentType__c=='HV_N') && inc.SPEN_HVIncidentMessage__c==NULL && inc.SPEN_IncidentCategory__c!='ESOD')     
                {
                    SPEN_ConfigurableSettings__c config=new SPEN_ConfigurableSettings__c();
                    config = SEL_ConfigurationSettingSelector.getconfigSetting();
                    String calculatedtimeVal;
                    calculatedtimeVal = getOutageTimeInModValue(Integer.valueOf(config.SPEN_Value__c));
                    inc.SPEN_HVIncidentMessage__c = config.SPEN_Description__c+' '+calculatedtimeVal;
                    if (inc.SPEN_IVRMessages__c == NULL)
                    {
                        inc.SPEN_IVRMessage__c = inc.SPEN_HVIncidentMessage__c;
                    }
                } 
                else if((inc.SPEN_IncidentType__c=='HV_S' || inc.SPEN_IncidentType__c=='HV_N')  && inc.SPEN_IncidentCategory__c!=incidentOldMap.get(inc.id).SPEN_IncidentCategory__c && inc.SPEN_IncidentCategory__c=='ESOD')
                {
                   
                    SPEN_ConfigurableSettings__c config=new SPEN_ConfigurableSettings__c();
                    config = SEL_ConfigurationSettingSelector.getHVconfigSetting();
                    inc.SPEN_HVIncidentMessage__c = config.SPEN_Description__c;
                     if (inc.SPEN_IVRMessages__c == NULL)
                    {
                    	inc.SPEN_IVRMessage__c = inc.SPEN_HVIncidentMessage__c;
                    
                    }
                }
                else if((inc.SPEN_IncidentType__c=='HV_S' || inc.SPEN_IncidentType__c=='HV_N')  && inc.SPEN_IncidentCategory__c!=incidentOldMap.get(inc.id).SPEN_IncidentCategory__c && inc.SPEN_IncidentCategory__c!='ESOD')
                {
                    SPEN_ConfigurableSettings__c config=new SPEN_ConfigurableSettings__c();
                    config = SEL_ConfigurationSettingSelector.getconfigSetting();
                    String calculatedtimeVal;
                    calculatedtimeVal = getOutageTimeInModValue(Integer.valueOf(config.SPEN_Value__c));
                    inc.SPEN_HVIncidentMessage__c = config.SPEN_Description__c+' '+calculatedtimeVal;
                    if (inc.SPEN_IVRMessages__c == NULL)
                    {
                        inc.SPEN_IVRMessage__c = inc.SPEN_HVIncidentMessage__c;
                    }
                    
                }
                
            }
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }
     
    /*
     * This method will calculate actual time value 
     * based on respective config settings
     * Retutn type: String
     * Parameters : Integer (threshold)
     */ 
    @AuraEnabled
    public static String getOutageTimeInModValue(Integer valueThreshold)
    {
        String calculatedtimeVal = '';
        Datetime latestTimeVal = system.now().addHours(valueThreshold);//add threshold in system.now
        Integer hourVal = latestTimeVal.hour(); //hoursValue //.hourGmt();
        Integer minVal = latestTimeVal.minute(); // minuteValue //.minuteGmt();
        Decimal expectedMin = (Decimal.valueOf(minVal)/15).round(System.RoundingMode.CEILING);// divide by 15 and set to ceiling value
        String finalMinVal = String.valueOf(Integer.valueOf(expectedMin)*15);
        if(finalMinVal == '60')               // if last quarter, then consider next hour
        {
            finalMinVal = '00';
            hourVal++;
        }
        else if(finalMinVal == '0')           //when minval is 0,then consider as 00  
        {
            finalMinVal = '00';
        }
        
        calculatedtimeVal = String.valueOf(system.today())+ ' ' +hourVal + ':' + finalMinVal;
        return calculatedtimeVal;
    }
    
    //Method to update Status from Incident To Case
    /*public void updateStatusfromIncidentToCase(List<Incident> incidentList)
    {
        
        List<SPEN_Incident_to_case_status_mapping__mdt> incToCseMetadata = new List<SPEN_Incident_to_case_status_mapping__mdt>();
        List<Case> caseList = new List<Case>();
        List<Incident> newIncident = new List<Incident>();
        Map<String, List<SPEN_Incident_to_case_status_mapping__mdt>> incToCseMetadataMap = new Map<String,  List<SPEN_Incident_to_case_status_mapping__mdt>>();
        Set<Id> incdntIdSet = new Set<Id>();
        
        try
        {
            for (Incident incdntAll: incidentList)
            {
                if(incdntAll.SPEN_StatusUpdated__c == true)
                {
                    incdntIdSet.add(incdntAll.Id); 
                }
            }
            
            if(incidentList.isEmpty()){return;}
            else
            {
                caseList = IncidentSelector.getRelatedCaseInfo(incdntIdSet);
                incToCseMetadata = IncidentSelector.getIncndtToCaseMetaDataInfo();
                
                if(incToCseMetadata != Null && incToCseMetadata.size() > 0)
                {
                    for(SPEN_Incident_to_case_status_mapping__mdt inCsMap : incToCseMetadata)
                    {
                        String inCsMapIncndtStatus  =  inCsMap.SPEN_IncidentStatus__c;
                        
                        List<SPEN_Incident_to_case_status_mapping__mdt> inCsMapList = IncidentSelector.getIncndtToCaseMetaDataMapList(inCsMapIncndtStatus);
                        incToCseMetadataMap.put(inCsMapIncndtStatus, inCsMapList);     
                    }
                    if(incToCseMetadataMap != Null && incToCseMetadataMap.size()>0)
                    {
                        for(Incident incdntObj : incidentList)
                        {
                            if(incdntObj.SPEN_IncidentStatus__c != Null && incToCseMetadataMap.containsKey(incdntObj.SPEN_IncidentStatus__c))
                            {
                                List<SPEN_Incident_to_case_status_mapping__mdt> tm = incToCseMetadataMap.get(incdntObj.SPEN_IncidentStatus__c);
                                for(SPEN_Incident_to_case_status_mapping__mdt forEachtm : tm)
                                {
                                    for(Case forEachcaseList : caseList)
                                    {
                                        forEachcaseList.Status = forEachtm.SPEN_CaseStatus__c; 
                                    }  
                                }
                            }
                        } 
                    }
                }
                if(caseList.size()>0){
                    update caseList; 
                }
            }  
            //if(System.IsBatch() == false && System.isFuture() == false){
            if(System.isFuture() == false)
            {
                //uncheckedStatusUpdateCheckbox(incdntIdSet);
                System.enqueueJob(new SPEN_UpdateCheckboxQueueable(incdntIdSet));
            }
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }*/
    
    //Method commented as moved the code to Queueable class since getting too many future calls error
    /*
    @future
    public Static void uncheckedStatusUpdateCheckbox(Set<Id> incdntIdSet)
    {
        List<Incident> incList = new List<Incident>();
        try
        { 
            incList = IncidentSelector.getRelatedIncInfoForStatusUnchecked(incdntIdSet);
            for (Incident incdntAllTrueValue:incList)
            {
                if(incdntAllTrueValue.SPEN_StatusUpdated__c == true)
                {
                    incdntAllTrueValue.SPEN_StatusUpdated__c = False; 
                }
                update incdntAllTrueValue;
            }   
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }
	*/
    //@SuppressWarnings('PMD.CognitiveComplexity,PMD.CyclomaticComplexity,PMD.NcssMethodCount')
    public static void afterIncidentUpdate(Map<Id,Incident> oldIncidentREcords, List<Incident> newIncidentList)
    {
        //SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType' Limit 1];
        //List<String> messageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
        List<String> messageINCTypeList = SEL_ConfigurationSettingSelector.getMsgTaskType().SPEN_Value__c.split(',');
        //Group msgTaskQueue=[select id,CreatedBy.name from Group where Type ='Queue' and DeveloperName ='Messaging_Task'];
        List<SPEN_Incident_to_case_status_mapping__mdt> incToCseMetadata = new List<SPEN_Incident_to_case_status_mapping__mdt>();
        //RecordType recType=[Select id, SobjectType,  DeveloperName from RecordType where DeveloperName ='Incident' and SobjectType='SPEN_MessagingTask__c'];
        SPEN_MessagingTaskService msgTaskSrv=new SPEN_MessagingTaskService();
        Map<Id, Incident> selectedIncidentIds = new  Map<Id, Incident>();
        String mergeINCIdStr = '';
        String delogINCIdStr = '';
        String ertChangeINCIdStr = '';
        String dropwithorwithoutINCIdStr ='';
        List<Case> caseUpdList = new List<Case>();
        List<Incident> newIncident = new List<Incident>();
        Map<String, List<SPEN_Incident_to_case_status_mapping__mdt>> incToCseMetadataMap = new Map<String,  List<SPEN_Incident_to_case_status_mapping__mdt>>();
        Set<Id> incdntIdSet = new Set<Id>();
        Set<Id> incIdTypeChangeSet = new Set<Id>();
        Set<Id> incSPIdSet = new Set<Id>();
       
        for(Incident incRecord : newIncidentList){	
            if(incRecord.SPEN_TotalMessagingTaskPresent__c == oldIncidentREcords.get(incRecord.Id).SPEN_TotalMessagingTaskPresent__c){
            if(incRecord.SPEN_IVRMessage__c != Null && incRecord.SPEN_IVRMessage__c != oldIncidentREcords.get(incRecord.Id).SPEN_IVRMessage__c )
            {
                selectedIncidentIds.put(incRecord.Id, incRecord);
            }

            //Below code has been added as Power is not sending the dropped supply w/wo field so it needs to be in trigger
            //for creating the Messaging Task or the Outbound Dialler
           if(incRecord.SPEN_droppedsupply__c && incRecord.SPEN_droppedsupply__c != oldIncidentREcords.get(incRecord.Id).SPEN_droppedsupply__c && messageINCTypeList.contains(String.ValueOf(incRecord.SPEN_IncidentType__c))){
                msgTaskSrv.createMessagingTask('Dropped Supply with Notice',incRecord.id,MSGTASKRECTYPE,Null,'New');
                List<String> incStrLst = new List<String>();
                incStrLst.add(String.valueOf(incRecord.SPEN_IncidentID__c));
                dropwithorwithoutINCIdStr = String.valueOf(incRecord.Id)+','+dropwithorwithoutINCIdStr;
                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);
           }
           else if(incRecord.SPEN_DroppedSupplyWithoutNotice__c && incRecord.SPEN_DroppedSupplyWithoutNotice__c != oldIncidentREcords.get(incRecord.Id).SPEN_DroppedSupplyWithoutNotice__c && messageINCTypeList.contains(String.ValueOf(incRecord.SPEN_IncidentType__c))){
                msgTaskSrv.createMessagingTask('Dropped Supply without Notice',incRecord.id,MSGTASKRECTYPE,Null,'New');
                List<String> incStrLst = new List<String>();
                incStrLst.add(String.valueOf(incRecord.SPEN_IncidentID__c));
                dropwithorwithoutINCIdStr = String.valueOf(incRecord.Id)+','+dropwithorwithoutINCIdStr;
                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);
           }
           else if(incRecord.SPEN_EstimatedRestorationTime__c !=null && incRecord.SPEN_EstimatedRestorationTime__c != oldIncidentREcords.get(incRecord.Id).SPEN_EstimatedRestorationTime__c && messageINCTypeList.contains(String.ValueOf(incRecord.SPEN_IncidentType__c))){
                msgTaskSrv.createMessagingTask('Estimated Restoration Time Extended',incRecord.id,MSGTASKRECTYPE,Null,'New');
                List<String> incStrLst = new List<String>();
                incStrLst.add(String.valueOf(incRecord.SPEN_IncidentID__c));
                ertChangeINCIdStr = String.valueOf(incRecord.Id)+','+ertChangeINCIdStr;
                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);
           }
          	//changes done for CRMD-5276 when an incident is upgraded to HV from LV or SP
    		if(incRecord.SPEN_IncidentType__c != oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c )
           {
				createMessagingTaskIncCreated(incRecord,oldIncidentREcords);
              
              
			}
           if(incRecord.SPEN_IncidentType__c != oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c){
                List<String> incStrLst = new List<String>();
                Set<String> setCaseIncType = new Set<String> {'HV_N','HV_S','LV'};
                if(setCaseIncType.contains(incRecord.SPEN_IncidentType__c) && oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c =='SP'){
                    incIdTypeChangeSet.add(incRecord.Id);
                }
                incStrLst.add(String.valueOf(incRecord.SPEN_IncidentID__c));
                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);
           }
           /* if(incRecord.SPEN_IncidentType__c != oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c){
                List<String> incStrLst = new List<String>();
                Set<String> setCaseIncType = new Set<String> {'HV_N','HV_S'};
                if(setCaseIncType.contains(incRecord.SPEN_IncidentType__c) && oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c =='LV'){
                    incIdTypeChangeSet.add(incRecord.Id);
                }
                incStrLst.add(String.valueOf(incRecord.SPEN_IncidentID__c));
                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);
           }*/
           if(incRecord.SPEN_IncidentStatus__c != oldIncidentREcords.get(incRecord.Id).SPEN_IncidentStatus__c){
                if(incRecord.SPEN_IncidentStatus__c == 'Merged'){
                    mergeINCIdStr = String.valueOf(incRecord.Id)+','+mergeINCIdStr;
                }//Issue where INC status directly goes to Complete skipping Delog so added Complete also
                else if(incRecord.SPEN_IncidentStatus__c == 'Delog' || incRecord.SPEN_IncidentStatus__c == 'Complete'){
                    delogINCIdStr = String.valueOf(incRecord.Id)+','+delogINCIdStr;
                }
                incdntIdSet.add(incRecord.Id); 
           } 

        	}
	   if(incRecord.SPEN_IncidentType__c == 'SP' && (incRecord.SPEN_IncidentCategory__c == 'ENS1' || incRecord.SPEN_IncidentCategory__c == 'SPSO' || incRecord.SPEN_IncidentCategory__c == 'SPSU') && incRecord.SPEN_Outage_State__c !=  oldIncidentREcords.get(incRecord.Id).SPEN_Outage_State__c && incRecord.SPEN_Outage_State__c == 'Restored')
           {
                incSPIdSet.add(incRecord.id);
           } 
        }

        //if(System.IsBatch() == false && System.isFuture() == false){
        if(System.isFuture() == false && !incdntIdSet.isEmpty() && system.isQueueable() == false)
        {
            //uncheckedStatusUpdateCheckbox(incdntIdSet);
            System.enqueueJob(new SPEN_UpdateCheckboxQueueable(incdntIdSet));
        }

        

        if(!incIdTypeChangeSet.isEmpty()){
            /*List<Case> lstNewCases = [SELECT id, SPEN_Incident__c, SPEN_PreferredMethodofContact__c,
            SPEN_Incident__r.SPEN_IncidentType__c,SPEN_CaseCategoryOutcome__c,ContactId,
            SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c
            FROM Case WHERE SPEN_Incident__c IN: incIdTypeChangeSet];*/
            List<Case> lstNewCases = SPEN_CaseSelector.getCaseIncRecords(incIdTypeChangeSet);
            SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
            SPEN_IVRMessage__c ivrMsg= ivrSel.selectByExternalId('SMS – Single Premise – Network Fault');
            SPEN_IVRMessage__c ivrNetworkFault= ivrSel.selectByExternalId('Single Premise Network Fault VA');
    
            //RecordType caseRecType=[select id,RecordType.name from RecordType  where RecordType.name ='Case' LIMIT 1];
            Id caseRecType = Schema.SObjectType.SPEN_Sms__c.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            Id voiceAlertRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
            List<SPEN_SMS__c> smsLst=new List<SPEN_SMS__c>();
            List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
            List<Id> lstOfCaseIds = new List<Id>();
            for(Case c : lstNewCases){
                if((c.SPEN_PreferredMethodofContact__c == 'T' && c.SPEN_CallerMobileTelephone__c != Null) || (c.SPEN_PreferredMethodofContact__c == Null && c.SPEN_CallerMobileTelephone__c != Null))
                {
                    //Send SMS
                    String mobNo= (c.SPEN_CallerMobileTelephone__c !=Null && c.SPEN_CallerMobileTelephone__c.startsWith('0')) ? '+44'+c.SPEN_CallerMobileTelephone__c.removeStart('0'):c.SPEN_CallerMobileTelephone__c ;
                    SPEN_SMS__c sms= new SPEN_SMS__c(SPEN_ContactId__c=c.ContactId,
                    SPEN_IvrMessageId__c=ivrMsg.id,
                    SPEN_Message__c = ivrMsg.SPEN_IVRMessage__c,
                    SPEN_Status__c='Ready',
                    SPEN_Event__c='Merged from SP to Network',
                    SPEN_Mobile__c=mobNo,
                    RecordTypeId=caseRecType,
                    SPEN_CaseId__c=c.id,
                    SPEN_IncidentId__c=c.SPEN_Incident__c,
                    SPEN_MessageType__c='Outbound');
                    smsLst.add(sms);
                }
                else if((c.SPEN_PreferredMethodofContact__c =='H' && c.SPEN_CallerTelephone__c != null) || (c.SPEN_PreferredMethodofContact__c==null && c.SPEN_CallerTelephone__c != null))
                {
                    lstOfCaseIds.add(c.Id);
                }
            }
            Boolean isSMSOptOut = checkBlackoutWindowPeriod('SMS Blackout Window');
                    
            if(smsLst != null && !smsLst.isEmpty()  && isSMSOptOut && Schema.sObjectType.SPEN_SMS__c.isCreateable()){
                //if(smsLst != null && !smsLst.isEmpty() && (String.isNotBlank(smsLst))  && isSMSOptOut){
                insert smsLst;
            }  
            Boolean isVAOptOut = checkBlackoutWindowPeriod('VA Blackout Window');
            
            
            if(!lstOfCaseIds.isEmpty() && isVAOptOut){
                Integer voiceAlertBatchSize=Integer.valueof(SPEN_BatchSettings__mdt.getInstance('SPEN_InsertVoiceBatchSize').SPEN_BatchSize__c);
                Database.executeBatch(new SPEN_VoiceAlertServiceBatch(lstOfCaseIds,ivrNetworkFault.SPEN_IVRMessage__c,VoiceAlertRecordTypeId),voiceAlertBatchSize);
            }
        }
        


        if(mergeINCIdStr!=''){
            SPEN_AsyncFuture__e mergeFuture = new SPEN_AsyncFuture__e();
            mergeFuture.SPEN_Action__c = SPEN_AsyncFutures.ACTION_MERGE;
            mergeFuture.SPEN_RecordIds__c = mergeINCIdStr;
            Eventbus.publish(mergeFuture);
            //SPEN_OutboundDialerService.dropOlderODTasksOnMerge(mergeINCIdLst);
        }

        if(delogINCIdStr!=''){
            SPEN_AsyncFuture__e delogFuture = new SPEN_AsyncFuture__e();
            delogFuture.SPEN_Action__c = SPEN_AsyncFutures.ACTION_DELOG;
            delogFuture.SPEN_RecordIds__c = delogINCIdStr;
            Eventbus.publish(delogFuture);
            //SPEN_OutboundDialerService.dropOlderODTasksOnDelog(delogINCIdLst);
        }

        if(ertChangeINCIdStr!=''){
            SPEN_AsyncFuture__e ertChangeFuture = new SPEN_AsyncFuture__e();
            ertChangeFuture.SPEN_Action__c = SPEN_AsyncFutures.ACTION_ERTCHANGE;
            ertChangeFuture.SPEN_RecordIds__c = ertChangeINCIdStr;
            Eventbus.publish(ertChangeFuture);
            //SPEN_OutboundDialerService.dropComfortODTasksOnERTChange(delogINCIdLst);
        }

        if(dropwithorwithoutINCIdStr!=''){
            SPEN_AsyncFuture__e ertChangeFuture = new SPEN_AsyncFuture__e();
            ertChangeFuture.SPEN_Action__c = SPEN_AsyncFutures.ACTION_DROPCHANGE;
            ertChangeFuture.SPEN_RecordIds__c = dropwithorwithoutINCIdStr;
            Eventbus.publish(ertChangeFuture);
            //SPEN_OutboundDialerService.dropODTasksOnDROPChange(delogINCIdLst);
        }

        if(!incSPIdSet.isEmpty())
        {
            system.debug('434>>>>');
            Set<String> setOfFaultBypass = new Set<String>{'SPEN_UnplannedFault','SPEN_UnplannedBypass'};
            SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
            SPEN_IVRMessage__c sMSMsg = ivrSel.selectByExternalId('SMS – Single Premise – Survey Inc Restored');
            SPEN_IVRMessage__c vAMsg = ivrSel.selectByExternalId('VA – Single Premise – Survey Inc Restored');
            Id caseRecType = Schema.SObjectType.SPEN_Sms__c.getRecordTypeInfosByName().get('Case').getRecordTypeId();
            Id instantVARecTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
            List<SPEN_SMS__c> lstSmsSP=new List<SPEN_SMS__c>();
            List<SPEN_VoiceAlert__c> lstVASP = new List<SPEN_VoiceAlert__c>();

            for(Case cse : [select id,ContactId,contact.MobilePhone,contact.SPEN_PSR__c, Contact.SPEN_PreferredMethodofContact__c,SPEN_AddressPremise__c,SPEN_Incident__c, Contact.Phone,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c,SPEN_PreferredMethodofContact__c,RecordType.Name,RecordType.DeveloperName,Status,ContactMobile,ContactPhone from Case where SPEN_Incident__c IN :incSPIdSet AND RecordType.DeveloperName = :setOfFaultBypass AND ContactId != null])
            {
                system.debug('445>>>>');
                if((cse.SPEN_PreferredMethodofContact__c == 'T' && cse.SPEN_CallerMobileTelephone__c != null) || (cse.SPEN_PreferredMethodofContact__c == null && cse.SPEN_CallerMobileTelephone__c != null))
                {
                    system.debug('448>>>>');
                    //Create SMS through Case Details for SP Restored
                    String mobNo= (cse.SPEN_CallerMobileTelephone__c !=Null && cse.SPEN_CallerMobileTelephone__c.startsWith('0')) ? '+44'+cse.SPEN_CallerMobileTelephone__c.removeStart('0'):cse.SPEN_CallerMobileTelephone__c ;
                    SPEN_SMS__c sms= new SPEN_SMS__c();
                    sms.SPEN_ContactId__c=cse.ContactId;
                    sms.SPEN_IvrMessageId__c=sMSMsg.id;
                    sms.SPEN_Message__c = sMSMsg.SPEN_IVRMessage__c;
                    sms.SPEN_Status__c='Created';
                    sms.SPEN_Event__c='Incident Restored';
                    sms.SPEN_Mobile__c=mobNo;
                    sms.RecordTypeId=caseRecType;
                    sms.SPEN_CaseId__c=cse.id;
                    sms.SPEN_IncidentId__c=cse.SPEN_Incident__c;
                    sms.SPEN_MessageType__c='Outbound';
                    lstSmsSP.add(sms);
                }
                else if((cse.SPEN_PreferredMethodofContact__c == 'H' && cse.SPEN_CallerTelephone__c != null) || (cse.SPEN_PreferredMethodofContact__c == null && cse.SPEN_CallerTelephone__c != null))
                {
                    system.debug('466>>>>');
                    //Create VA through Case Details for SP Restored
                    SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                    objVoiceAlert.SPEN_ContactId__c = cse.contactId;
                    objVoiceAlert.SPEN_IncidentId__c = cse.SPEN_Incident__c;
                    objVoiceAlert.SPEN_Event__c = 'Incident Restored'; 
                    objVoiceAlert.SPEN_BroadcastMessage__c = vAMsg.SPEN_IVRMessage__c;
                    objVoiceAlert.SPEN_Case__c = cse.id;
                    objVoiceAlert.RecordTypeId = instantVARecTypeId;
                    objVoiceAlert.SPEN_Status__c = 'Ready';
                    objVoiceALert.SPEN_CalledInTelephone__c = cse.SPEN_CallerTelephone__c;
                    lstVASP.add(objVoiceAlert);
                }
                else if(String.isNotBlank(cse.contactId) && (cse.Contact.SPEN_PreferredMethodofContact__c == 'T' && cse.ContactMobile != null) || (cse.Contact.SPEN_PreferredMethodofContact__c == null && cse.ContactMobile != null))
                {
                    system.debug('481>>>>');
                    //Create SMS through Case's Contact Details for SP Restored
                    String mobNo= (cse.ContactMobile !=Null && cse.ContactMobile.startsWith('0')) ? '+44'+cse.ContactMobile.removeStart('0'):cse.ContactMobile ;
                    SPEN_SMS__c sms= new SPEN_SMS__c();
                    sms.SPEN_ContactId__c=cse.ContactId;
                    sms.SPEN_IvrMessageId__c=sMSMsg.id;
                    sms.SPEN_Message__c = sMSMsg.SPEN_IVRMessage__c;
                    sms.SPEN_Status__c='Created';
                    sms.SPEN_Event__c='Incident Restored';
                    sms.SPEN_Mobile__c=mobNo;
                    sms.RecordTypeId=caseRecType;
                    sms.SPEN_CaseId__c=cse.id;
                    sms.SPEN_IncidentId__c=cse.SPEN_Incident__c;
                    sms.SPEN_MessageType__c='Outbound';
                    lstSmsSP.add(sms);
                }
                else if(String.isNotBlank(cse.contactId) && (cse.Contact.SPEN_PreferredMethodofContact__c == 'H' && cse.ContactPhone != null) || (cse.Contact.SPEN_PreferredMethodofContact__c == null && cse.ContactPhone != null))
                {
                    system.debug('499>>>>');
                    //Create VA through Case's Contact Details for SP Restored
                    SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
                    objVoiceAlert.SPEN_ContactId__c = cse.contactId;
                    objVoiceAlert.SPEN_IncidentId__c = cse.SPEN_Incident__c;
                    objVoiceAlert.SPEN_Event__c = 'Incident Restored'; 
                    objVoiceAlert.SPEN_BroadcastMessage__c = vAMsg.SPEN_IVRMessage__c;
                    objVoiceAlert.SPEN_Case__c = cse.id;
                    objVoiceAlert.RecordTypeId = instantVARecTypeId;
                    objVoiceAlert.SPEN_Status__c = 'Ready';
                    lstVASP.add(objVoiceAlert);
                }
            }

            if(!lstSmsSP.isEmpty())
            {
                try
                {
                    system.debug('516>>>>');
                    insert lstSmsSP;
                    Map<Id,SPEN_SMS__c> mapIdSMS = new Map<Id,SPEN_SMS__c>(lstSmsSP);
                    Id jobId = System.enqueueJob(new SPEN_FaultSurveyQueueable(mapIdSMS.keySet(),'Single Premise','SMS')); 
                }
                catch(exception e)
                {
                    SEL_LoggingService.log(e);
                }
            }
            if(!lstVASP.isEmpty())
            {
                try
                {
                    system.debug('523>>>>');
                    insert lstVASP;
                    Set<Id> voiceAlertIds = new Set<Id>();
                    for(SPEN_VoiceAlert__c va : lstVASP)
                    {
                        voiceAlertIds.add(va.id);
                    }
                    //SPEN_SurveyUtility.updateVoiceAlertWithInvitation(voiceAlertIds);
                    Id jobId = System.enqueueJob(new SPEN_FaultSurveyQueueable(voiceAlertIds,'Single Premise','Voice Alert')); 
                }
                catch(exception e)
                {
                    SEL_LoggingService.log(e);
                }
            }
        }
        SPEN_IncidentIntegrationRequestUpdate.afterIncidentIVRMessageAPIUpdate(selectedIncidentIds,INCIDENT_CONFIGSETTING);

        
        /*Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>(); 
        configSetMap = SPEN_CaseSelector.configSettingsMap;
        
        Integer threshold = Integer.valueOf(configSetMap.get(INCIDENT_CONFIGSETTING).SPEN_Value__c);
        Datetime dateThreshold = system.now().addHours(-threshold);
        List<SPEN_IntegrationRequest__c> intReqList = new List<SPEN_IntegrationRequest__c>();
        if(!selectedIncidentIds.isEmpty())
        {
            for(SPEN_IntegrationRequest__c intRequest : SPEN_IntegrationRequestSelector.geIntegrationRequestZoneRecord(selectedIncidentIds.keySet(), dateThreshold))
            {
                intRequest.SPEN_Response__c = selectedIncidentIds.get(intRequest.SPEN_RelatedRecord__c).SPEN_IVRMessage__c;
                intReqList.add(intRequest);
            }
        }
        
        if(!intReqList.isEmpty())
        {
            update intReqList;
        }*/
    }

    public static Boolean checkBlackoutWindowPeriod(String typeCheck){
        Boolean result = false;
        Id recTypeIdOfBlackoutWindowRT = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get(typeCheck).getRecordTypeId();
       
        //List<SPEN_IVROperatingHours__c> lstIvrHour = [select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordTypeId = :recTypeIdOfBlackoutWindowRT and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
        SPEN_IVROperatingHours__c lstIvrHour = SPEN_IvrOperatingHoursSelector.getIVROperatingHourTypeCheck(recTypeIdOfBlackoutWindowRT);
        result = SPEN_BlockOutWindowPeriodClass.findResult(lstIvrHour);
        /*if(!lstIvrHour.isEmpty() && lstIvrHour[0] != null){
            if(lstIvrHour[0].SPEN_StartTime__c == null && lstIvrHour[0].SPEN_EndTime__c == null){
                result = true;
            }
            else if((lstIvrHour[0].SPEN_StartTime__c < lstIvrHour[0].SPEN_EndTime__c) && ((System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() < lstIvrHour[0].SPEN_EndTime__c) || (System.now().time() > lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c))){
             
                 result = true;
             }
             else if((lstIvrHour[0].SPEN_StartTime__c > lstIvrHour[0].SPEN_EndTime__c) && (System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c)){
                 result = true;
             }
            
        }*/
        return result;
    }
    
       public static void beforeEventZone(List<Incident> newIncidentList){

        //SPEN_ConfigurableSettings__c batchDelayInMinutes = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='CreationBatchDelay' Limit 1];
		SPEN_ConfigurableSettings__c batchDelayInMinutes = SEL_ConfigurationSettingSelector.getBatchDelay();
        Integer delayMin = Integer.valueOf(batchDelayInMinutes.SPEN_Value__c);
        DateTime currDateTime = System.now();
        DateTime newDateTime = currDateTime.addMinutes(delayMin);
        Map<String,SPEN_Zone__c> zoneRecordMap = new Map<String,SPEN_Zone__c>();
        Set<String> incidentSet = new Set<String>();
        for(Incident incRecord : newIncidentList){
            if (incRecord.SPEN_OperatingZoneId__c != NULL){
                incidentSet.add(incRecord.SPEN_OperatingZoneId__c);
            }  
            incRecord.SPEN_CreateBatchTriggerTime__c = newDateTime;
        }
        for(SPEN_Zone__c zoneRecord : SPEN_ZoneSelector.getZoneRecordforInc(incidentSet)){
            zoneRecordMap.put(zoneRecord.SPEN_ExternalId__c, zoneRecord);      
        }
        
        if(!zoneRecordMap.isempty()){
            for(Incident incRecord : newIncidentList){
                if(zoneRecordMap.containsKey(incRecord.SPEN_OperatingZoneId__c)){
                    incRecord.SPEN_Zone__c = zoneRecordMap.get(incRecord.SPEN_OperatingZoneId__c).ID;
                }
            }
        }
    }
    //changes done for CRMD-5276 when an incident is upgraded to HV from LV or SP
private static void createMessagingTaskIncCreated(Incident incRecord,Map<Id,Incident> oldIncidentREcords){
    List<String> incStrLst = new List<String>();
    Set<Id> incIdTypeChangeSet = new Set<Id>();
    //RecordType recType=[Select id, SobjectType,  DeveloperName from RecordType where DeveloperName ='Incident' and SobjectType='SPEN_MessagingTask__c'];
    SPEN_MessagingTaskService msgTaskSrv=new SPEN_MessagingTaskService();
    Set<String> setCaseIncType = new Set<String> {'HV_N','HV_S'};
    if(setCaseIncType.contains(incRecord.SPEN_IncidentType__c) && (oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c =='SP' || oldIncidentREcords.get(incRecord.Id).SPEN_IncidentType__c =='LV')){
        incIdTypeChangeSet.add(incRecord.Id);
        msgTaskSrv.createMessagingTask(MESSAGINGTASKEVENT, incRecord.id, MSGTASKRECTYPE, Null, MESSAGINGTASKSTATUS);
    
    incStrLst.add(String.valueOf(incRecord.SPEN_IncidentID__c));
        
        //SPEN_GetAffectedPremiseService.createRecord(incStrLst);
    }
}
//CRMD-9211: Completed messaging tasks toggles are changing dependent on future outage state changes
public static void updateOutageFlagOnMessagingTask(List<Incident> incdntList){
    Set<Id> incidentIds = new Set<Id>();
    Map<Id,String> outageStatevalueMap = new Map<Id,String>();
    Map<Id,Boolean> droppedSupplyValueMap = new Map<Id,Boolean>();

    List<SPEN_MessagingTask__c> msgTaskRecordsList = new List<SPEN_MessagingTask__c>();
    for(Incident inc : incdntList){
        Incident oldvalue = (Incident) Trigger.oldMap.get(inc.Id);
        if(inc.SPEN_Outage_State__c != Null && (oldvalue.SPEN_Outage_State__c != inc.SPEN_Outage_State__c) ){
            incidentIds.add(inc.Id);
            outageStatevalueMap.put(inc.Id, inc.SPEN_Outage_State__c);
        }
        if(oldvalue.SPEN_droppedsupply__c != inc.SPEN_droppedsupply__c){
            incidentIds.add(inc.Id);
            droppedSupplyValueMap.put(inc.Id, inc.SPEN_droppedsupply__c);
        }
        
    }
    if(!incidentIds.isEmpty()){
        for(SPEN_MessagingTask__c mTask : [SELECT Id, SPEN_Status__c, SPEN_Incident_Outage_Flag__c, SPEN_IncidentId__c, Incident_Outage_Status__c FROM SPEN_MessagingTask__c WHERE SPEN_IncidentId__c=:incidentIds AND SPEN_Status__c Not In('Completed','Cancelled')] ){
            mTask.SPEN_Incident_Outage_Flag__c = true;
            mTask.Incident_Outage_Status__c = outageStatevalueMap.get(mTask.SPEN_IncidentId__c);
            mTask.SPEN_DroppedSupplyCheckbox__c = droppedSupplyValueMap.get(mTask.SPEN_IncidentId__c);

            msgTaskRecordsList.add(mTask);
        }
    }
    if(!msgTaskRecordsList.isEmpty()){
        try{
            update msgTaskRecordsList;
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
    }
}
}