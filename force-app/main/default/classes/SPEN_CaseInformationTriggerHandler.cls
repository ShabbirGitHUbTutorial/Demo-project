public class SPEN_CaseInformationTriggerHandler {

    Public static Id faultRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
    Public static Id bypassRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedBypass').getRecordTypeId();
    Public Static ID LCTRecordTypeId =  Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_LCTRecordType').getRecordTypeId();
    Public Static ID SIRecordTypeId =  Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SmartIntervention').getRecordTypeId();
    Public static BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();//CRMD-10762
    public static void beforeInsert(List<SPEN_CaseInformation__c> listCaseInfo){
        Set<Id> setIncidentId = new Set<Id>();
        Map<Id,Case> mapIncident2DamageCase = new Map<Id,Case>();
        Case damageWizardCase;
        List<SPEN_CaseInformation__c> listCaseInfoUpdate = new List<SPEN_CaseInformation__c>();
        for(SPEN_CaseInformation__c caseInfo : listCaseInfo){
            if(caseInfo.SPEN_IncidentId__c != null){
                setIncidentId.add(Id.valueOf(caseInfo.SPEN_IncidentId__c));
            }
            
        }
        mapIncident2DamageCase = SPEN_CaseSelector.getDamageEquipWizardCase(setIncidentId);
        if(!mapIncident2DamageCase.isEmpty()){
            for(SPEN_CaseInformation__c caseInfo : listCaseInfo){
                if(mapIncident2DamageCase.get(caseInfo.SPEN_IncidentId__c) != null)
                {
                    damageWizardCase = mapIncident2DamageCase.get(caseInfo.SPEN_IncidentId__c);
                    //Non-bypass Case
                    if(damageWizardCase.recordtypeId == faultRecordTypeId){
                        caseInfo.SPEN_ReportedBy__c = damageWizardCase.Contact.name;
                        caseInfo.SPEN_ReportedByContactNumber__c = damageWizardCase.Contact.MobilePhone != null ? damageWizardCase.Contact.MobilePhone : damageWizardCase.Contact.Phone;
                    }//Bypass Case
                    else if(damageWizardCase.recordtypeId == bypassRecordTypeId){
                        caseInfo.SPEN_ReportedBy__c = damageWizardCase.SPEN_CallerName__c;
                        caseInfo.SPEN_ReportedByContactNumber__c = damageWizardCase.SPEN_CallerMobileTelephone__c != null ? damageWizardCase.SPEN_CallerMobileTelephone__c : damageWizardCase.SPEN_CallerTelephone__c;
                    }
                }
            }
        }
    }
	
	
	
	//CRMD-10211 starts -Tanaya
    
    public static void calculateAndSetDates(List<SPEN_CaseInformation__c> caseInfos) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id,Id> caseVSBusinessHourMap = new Map<Id,Id>();
        for(SPEN_CaseInformation__c caseInfo : caseInfos){
                caseIds.add(caseInfo.SPEN_Case__c);
            }
        for(Case cseObj : [Select Id,BusinessHoursId From Case where ID IN : caseIds]){
                caseVSBusinessHourMap.put(cseObj.Id,cseObj.BusinessHoursId);
            }
        
        List<BusinessHours> bh = [SELECT Id FROM BusinessHours WHERE Name = 'SPEN GE SPD Business Hours' LIMIT 1];
 
        for (SPEN_CaseInformation__c caseInfo : caseInfos) {
            //CRMD 10997
            if(caseInfo.SPEN_DateLetter1__c != null 
               && 'Reject: Unable to Contact Customer Reasonable Endeavours Made'.equalsIgnorecase(caseInfo.SPEN_JobStatus__c)){
                Datetime outcomeDate = SPEN_BusinessDaysCalculationUtil.addDays(caseInfo.SPEN_DateLetter1__c, 10,bh[0].Id);
                caseInfo.SPEN_ResolutionDate__c = Date.valueOf(String.valueof(outcomeDate));
            }
            //END
            if(caseInfo.SPEN_FlowReceivedDate__c!=null){
			Datetime spenFlowReceivedDate = caseInfo.SPEN_FlowReceivedDate__c;
            caseInfo.SPEN_28CDresolutiondate__c=caseInfo.SPEN_FlowReceivedDate__c.date() + 28;
            // Calculate 10 WD date
            //Date spen10WDApptDate = calculateWorkingDays(bh[0].Id, spenFlowReceivedDate, 10);
            if(caseInfo.SPEN_Case__c != Null)
            {
                Date spen10WDApptDate = calculateWorkingDays(caseVSBusinessHourMap.get(caseInfo.SPEN_Case__c), spenFlowReceivedDate, 10);
            	system.debug('Businesshours======'+caseVSBusinessHourMap.get(caseInfo.SPEN_Case__c));
            	// Calculate 40 WD date
            	Date spen40WDApptDate = calculateWorkingDays(caseVSBusinessHourMap.get(caseInfo.SPEN_Case__c), spenFlowReceivedDate, 40);
 				// Set the calculated dates
                caseInfo.SPEN_10WDApptBooked__c = spen10WDApptDate;
                caseInfo.SPEN_40WDresolutiondate__c = spen40WDApptDate;
            }
            
            
        }
            else{
                caseInfo.SPEN_28CDresolutiondate__c=null;
                caseInfo.SPEN_10WDApptBooked__c=null;
                caseInfo.SPEN_40WDresolutiondate__c=null;
            }
    }
	}
    /*************************************************************************
@Author: Rajat Verma
@Date: 14/06/2024
@purpose: Execute after update logic
*************************************************************************************/
    public static void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<Id> caseInfoIds = new List<Id>();
        String eventType = '';
        
        for (Id caseInfoId : newItems.keySet()){
            SPEN_CaseInformation__c newCaseInfo = (SPEN_CaseInformation__c)newItems.get(caseInfoId);
            SPEN_CaseInformation__c oldCaseInfo = (SPEN_CaseInformation__c)oldItems.get(caseInfoId);
            if (newCaseInfo.recordtypeid == LCTRecordTypeId && newCaseInfo.SPEN_SubStatus__c != null && 
                newCaseInfo.SPEN_SubStatus__c != oldCaseInfo.SPEN_SubStatus__c 
                && 'Missing Information Requested'.equalsIgnoreCase(newCaseInfo.SPEN_SubStatus__c))
            {
                caseInfoIds.add(caseInfoId);
            }
        }
        system.debug('caseInfoIds======'+caseInfoIds);
        if(!caseInfoIds.isEmpty())
        {
            eventType = 'MissingInfoReq';
            invokeCommunicationSchedulerRecrdForTask(caseInfoIds,eventType);
        }
    }
 
    public static Date calculateWorkingDays(Id businessHoursId,Datetime startDate, Integer daysToAdd) {
        Datetime endDate = BusinessHours.add(businessHoursId, startDate, daysToAdd * 24 * 60 * 60 * 1000L);
		return endDate.date();
    }
    public static void updateParentCaseEntitlement(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
       	 List<Case> lstCase = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        Map<id,Case> caseMap = new Map<id,Case>();
        Map<id,Case> dupCaseMap = new Map<id,Case>();
        Map<id,case> finalMap = new Map<id,Case>();
        Map<Id,Id> caseVSBusinessHourMap = new Map<Id,Id>();
        Set <String> setStatus = new Set<String>{
            'Awaiting Appointment Call 1 Made', 'Awaiting Appointment Call 2 Made','Awaiting Appointment Call 3 Made'};
         Set <String> setStatusCaseEscalation = new Set<String>{
            'Awaiting Appointment Call 1 Made', 'Awaiting Appointment Call 2 Made','Awaiting Appointment Call 3 Made',
                'Appointment Booked 1', 'Appointment Booked 2','Awaiting Appointment Letter 1 Sent', 'Issued To LP - pending delivery instruction',
                'Land Registry', 'Escalation L2 Manager/Legal', 'Reject: Access Refused Safety'};        
                            //For Getting the Case Ids
                            for (Id caseInfoId : newItems.keySet()){
                                SPEN_CaseInformation__c newCaseInfo = (SPEN_CaseInformation__c)newItems.get(caseInfoId);
                                SPEN_CaseInformation__c oldCaseInfo = (SPEN_CaseInformation__c)oldItems.get(caseInfoId);
                                if (newCaseInfo.recordtypeid == SIRecordTypeId){
                                    caseIds.add(newCaseInfo.SPEN_Case__c);   
                                }
                            }
        if(!caseIds.isEmpty() && caseIds != null){
            for(Case cseObj : [Select Id,BusinessHoursId From Case where ID IN : caseIds]){
                caseVSBusinessHourMap.put(cseObj.Id,cseObj.BusinessHoursId);
            } 
        }
        for (Id caseInfoId : newItems.keySet()){
            SPEN_CaseInformation__c newCaseInfo = (SPEN_CaseInformation__c)newItems.get(caseInfoId);
            SPEN_CaseInformation__c oldCaseInfo = (SPEN_CaseInformation__c)oldItems.get(caseInfoId);
            if(newCaseInfo.SPEN_Case__c != null)
            {
            if (newCaseInfo.recordtypeid == LCTRecordTypeId && newCaseInfo.SPEN_SubStatus__c != null && 
                newCaseInfo.SPEN_SubStatus__c != oldCaseInfo.SPEN_SubStatus__c)
            {
                if(newCaseInfo.SPEN_SubStatus__c.equalsIgnoreCase(system.label.SPEN_CaseInfoMissingInfoRequestedSubStaus))
             {
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_LastStatus__c = system.label.SPEN_CaseInfoMissingInfoRequestedSubStaus);
                lstCase.add(cse);
             }
                if(newCaseInfo.SPEN_SubStatus__c.equalsIgnoreCase(system.label.SPEN_CaseInfo28DaysLetterSubStatus))
             {
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_LSOA__c = system.label.SPEN_CaseInfo28DaysLetterSubStatus);
                    lstCase.add(cse);
                }
            }
            //Update LCT Competent Date
                   /* if (newCaseInfo.recordtypeid == LCTRecordTypeId && newCaseInfo.SPEN_LCTCompetentDate__c != null)
            {
                Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_WaiverActiveFrom__c = newCaseInfo.SPEN_LCTCompetentDate__c);
                lstCase.add(cse);
            }
            
            //Update LCT sub status
            if (newCaseInfo.recordtypeid == LCTRecordTypeId && newCaseInfo.SPEN_SubStatus__c != null)
            {
                Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_Generator_Delivery_Confirmed_By__c = newCaseInfo.SPEN_SubStatus__c);
                lstCase.add(cse);
                    }*/
                    if (newCaseInfo.recordtypeid == LCTRecordTypeId){
						if (newCaseInfo.SPEN_LCTCompetentDate__c != null && newCaseInfo.SPEN_SubStatus__c != null){
							Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_WaiverActiveFrom__c = newCaseInfo.SPEN_LCTCompetentDate__c,SPEN_Generator_Delivery_Confirmed_By__c = newCaseInfo.SPEN_SubStatus__c);
							lstCase.add(cse);
						}
						else if (newCaseInfo.SPEN_LCTCompetentDate__c != null && newCaseInfo.SPEN_SubStatus__c== null){
							Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_WaiverActiveFrom__c = newCaseInfo.SPEN_LCTCompetentDate__c,SPEN_Generator_Delivery_Confirmed_By__c = null);
							lstCase.add(cse);
						}
						else if (newCaseInfo.SPEN_LCTCompetentDate__c == null && newCaseInfo.SPEN_SubStatus__c!= null){
							Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_WaiverActiveFrom__c = null,SPEN_Generator_Delivery_Confirmed_By__c = newCaseInfo.SPEN_SubStatus__c);
							lstCase.add(cse);
						}
						
					}
            
            //SI - Jobstatus update
            if (newCaseInfo.recordtypeid == SIRecordTypeId && newCaseInfo.SPEN_JobStatus__c != null && 
                newCaseInfo.SPEN_JobStatus__c != oldCaseInfo.SPEN_JobStatus__c)
            {
                if(newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Awaiting Appointment Letter 1 Sent'))
                {
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_LastStatus__c = newCaseInfo.SPEN_JobStatus__c, 
                                        SPEN_FunctionalChecksDueDate__c = System.now(),
                                        SPEN_Generator_Delivery_Confirmed_By__c=newCaseInfo.SPEN_JobStatus__c,SPEN_ManagementDepart__c = newCaseInfo.SPEN_JobStatus__c);
                    lstCase.add(cse);
                }
                if(newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Issued To LP - pending delivery instruction'))
                {
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_OmbudsmanResolution__c = newCaseInfo.SPEN_JobStatus__c, 
                                                SPEN_FunctionalChecksDateTimeCompleted__c = System.now(),
                                               SPEN_Generator_Delivery_Confirmed_By__c=newCaseInfo.SPEN_JobStatus__c,SPEN_ManagementDepart__c = newCaseInfo.SPEN_JobStatus__c);
                            lstCase.add(cse);
                        }
                        if(newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Land Registry'))
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c,SPEN_LetterRef__c=newCaseInfo.SPEN_JobStatus__c,
                                                SPEN_Generator_Delivery_Confirmed_By__c=newCaseInfo.SPEN_JobStatus__c);
                            lstCase.add(cse);
                        }
                         if(newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Escalation L2 Manager/Legal'))
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c,SPEN_Grossduration__c=newCaseInfo.SPEN_JobStatus__c,
                                               SPEN_HotWaterChecksDateTimeCompleted__c = System.now(), 
                                                SPEN_Generator_Delivery_Confirmed_By__c=newCaseInfo.SPEN_JobStatus__c);
                            lstCase.add(cse);
                        }
                        if(newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Reject: Access Refused Safety'))
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c,SPEN_Middle_Name__c=newCaseInfo.SPEN_JobStatus__c,
                                               SPEN_HeatingChecksDateTimeCompleted__c = System.now(), 
                                                SPEN_Generator_Delivery_Confirmed_By__c=newCaseInfo.SPEN_JobStatus__c);
                    lstCase.add(cse);
                }
                 //Commented for New SI milestones S
                /*if(setStatus.contains(newCaseInfo.SPEN_JobStatus__c))
                {
                    
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_ManagementDepart__c = newCaseInfo.SPEN_JobStatus__c);
                    lstCase.add(cse);
                }*/
                //Commented for New SI milestones E
                        if(!setStatusCaseEscalation.contains(newCaseInfo.SPEN_JobStatus__c))
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c,SPEN_Generator_Delivery_Confirmed_By__c=newCaseInfo.SPEN_JobStatus__c);
                            lstCase.add(cse);
                        }
                
            }
                    if (newCaseInfo.recordtypeid == SIRecordTypeId)
                    {
                if(newCaseInfo.SPEN_ResolutionDate__c != null && 
                   newCaseInfo.SPEN_ResolutionDate__c != oldCaseInfo.SPEN_ResolutionDate__c)
                {
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_HeatingChecksDateTime1stAttended__c = newCaseInfo.SPEN_ResolutionDate__c);
                    lstCase.add(cse);
                }
                //Commented for New SI milestones S
                /*if(newCaseInfo.SPEN_DateLetter2__c != null && 
                           newCaseInfo.SPEN_DateLetter2__c != oldCaseInfo.SPEN_DateLetter2__c)
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_HeatingChecksDateTime1stAttended__c = newCaseInfo.SPEN_DateLetter2__c);
                            lstCase.add(cse);
                        }
                         if(newCaseInfo.SPEN_Appointment1date__c != null && 
                           newCaseInfo.SPEN_Appointment1date__c != oldCaseInfo.SPEN_Appointment1date__c)
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_HotWaterChecksDateTimeAttended__c = newCaseInfo.SPEN_Appointment1date__c);
                            lstCase.add(cse);
                }*/
                /*if(newCaseInfo.SPEN_Flowreceiveddate__c != null && 
                newCaseInfo.SPEN_Flowreceiveddate__c != oldCaseInfo.SPEN_Flowreceiveddate__c)
            {
                    Datetime arrivalDT = calculateWorkingDays(caseVSBusinessHourMap.get(newCaseInfo.SPEN_Case__c), newCaseInfo.SPEN_Flowreceiveddate__c, 40);
                    Datetime newDateTm = calculateWorkingDays(caseVSBusinessHourMap.get(newCaseInfo.SPEN_Case__c), newCaseInfo.SPEN_Flowreceiveddate__c, 45);
                    Datetime functionDT = calculateWorkingDays(caseVSBusinessHourMap.get(newCaseInfo.SPEN_Case__c), newCaseInfo.SPEN_Flowreceiveddate__c, 50);
                    Datetime fuseDateTm = calculateWorkingDays(caseVSBusinessHourMap.get(newCaseInfo.SPEN_Case__c), newCaseInfo.SPEN_Flowreceiveddate__c, 55);
                    Datetime heatingChecksDT = calculateWorkingDays(caseVSBusinessHourMap.get(newCaseInfo.SPEN_Case__c), newCaseInfo.SPEN_Flowreceiveddate__c, 60);
                    Datetime powerFullyDateTm = calculateWorkingDays(caseVSBusinessHourMap.get(newCaseInfo.SPEN_Case__c), newCaseInfo.SPEN_Flowreceiveddate__c, 65);
                    Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, SPEN_LiveToCableheadDateTime__c = newCaseInfo.SPEN_Flowreceiveddate__c,SPEN_ArrivalDateTime__c = arrivalDT,SPEN_DateTime__c = newDateTm,SPEN_FunctionalChecksDateTime1stAttended__c = functionDT,SPEN_FuseReplacementsDateTime__c = fuseDateTm, SPEN_HeatingChecksDueDateTime__c = heatingChecksDT,SPEN_PowerFullyRestoredDateTime__c = powerFullyDateTm );
                lstCase.add(cse);
                }*/
   				//Commented for New SI milestones E
                        /*if (newCaseInfo.SPEN_JobStatus__c != null && newCaseInfo.SPEN_MOPID__c != null &&
                            newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Reject: Incomplete contact details'))
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, status = 'Closed');
                            lstCase.add(cse);
                        }
                        else if (newCaseInfo.SPEN_JobStatus__c != null && newCaseInfo.SPEN_MOPID__c == null &&
                                 newCaseInfo.SPEN_JobStatus__c.equalsIgnoreCase('Reject: Incomplete contact details'))
                        {
                            Case cse = new Case(Id=newCaseInfo.SPEN_Case__c, status = 'In Review');
                            lstCase.add(cse);
                    }*/
                }
            }
                
        }
       system.debug('lstCase >>'+ lstCase);
        if(!lstCase.isEmpty()){
            caseMap.putall(lstCase);
        if(caseMap.size()>0){
            upsert caseMap.values();
        }
        }
            
           //  update lstCase;
    }
    /*************************************************************************
@Author: Rajat Verma
@Date: 14/06/24
@purpose: Invoke creation of Communication Scheduler records 
*************************************************************************************/
    @future(callout=false)
    public static void invokeCommunicationSchedulerRecrdForTask(List<Id> caseInfoList,String eventType){
        Id emailCommSchrecordTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByDeveloperName().get('SPEN_EmailNotification').getRecordTypeId();
        Id taskCommSchrecordTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByDeveloperName().get('SPEN_TaskNotification').getRecordTypeId();
        List<SPEN_CommunicationScheduler__c> schCommList = new List<SPEN_CommunicationScheduler__c>();
        Map<id, String> mapOfDetails = new Map<id, String>();
        
        try{
            if(eventType!= null && eventType == 'MissingInfoReq'){
                if(!caseInfoList.isEmpty()){
                    for(SPEN_CaseInformation__c cseInfoRec : [Select Id,SPEN_Case__c 
                                                              from SPEN_CaseInformation__c where Id IN : caseInfoList]){
                                                                  mapOfDetails.put(cseInfoRec.SPEN_Case__c, 'isMissingInfoReq');
                                                              }
                }
            }
            system.debug('mapOfDetails====='+mapOfDetails);
            if(mapOfDetails != null && !mapOfDetails.isEmpty()){
                for(String caseId : mapOfDetails.keySet()){
                    if(mapOfDetails.get(caseId) == 'isMissingInfoReq'){
                        SPEN_CommunicationScheduler__c emailCommSchRec1 = createCommSchdlerRecord( Long.valueOf(System.Label.SPEN_EmailCreationOn3Days),'3 Days Email Creation On Case',emailCommSchrecordTypeId,caseId,'Missing Information Request Email 3 days',null);
                        SPEN_CommunicationScheduler__c emailCommSchRec2 = createCommSchdlerRecord( Long.valueOf(System.Label.SPEN_EmailCreationOn5Days),'5 Days Email Creation On Case',emailCommSchrecordTypeId,caseId,'Missing Information Request Email 5 days',null);
                        SPEN_CommunicationScheduler__c taskCommSchRec1 = createCommSchdlerRecord( Long.valueOf(System.Label.SPEN_MissingInfoTaskCreation6Days),'6 Days Task Creation On Case',taskCommSchrecordTypeId,caseId,'Missing Information Request Task',null);
                        schCommList.add(emailCommSchRec1);
                        schCommList.add(emailCommSchRec2);
                        schCommList.add(taskCommSchRec1);
                    }
                }
            }
            system.debug('commScheduler***' + schCommList.size());
            if(schCommList != null && schCommList.size() > 0){
                insert schCommList;
            }   
        }catch(Exception ex){
            system.debug('exception** ' + Ex);
            SEL_LoggingService.log(Ex);
        }
        
    }
    
    /*************************************************************************
@Author: Rajat Verma
@Date: 14/06/24
@purpose: Create new Communication Scheduler records according to event type
*************************************************************************************/
    public static SPEN_CommunicationScheduler__c createCommSchdlerRecord(Long reminderDate,String eventName,String recordTypeId,String Id,String message,DateTime eventDate)
    {
        SPEN_CommunicationScheduler__c commSchRec =  New SPEN_CommunicationScheduler__c();
        if(eventDate != null){
            commSchRec.SPEN_ScheduledDateTime__c = SPEN_CaseInformationTriggerHandler.getWorkingDays(bh.Id, eventDate, reminderDate);
        }else{
            commSchRec.SPEN_ScheduledDateTime__c =  SPEN_CaseInformationTriggerHandler.getWorkingDays(bh.Id, system.now(), reminderDate); 
        }
        commSchRec.SPEN_Case__c = Id;
        commSchRec.RecordTypeId = recordTypeId;
        commSchRec.SPEN_Event__c = eventName;
        commSchRec.SPEN_Status__c = CasesConstants.COMMSCHDULER_STATUSSCHEDULED;
        commSchRec.SPEN_Message__c = message;
        system.debug('commSchRec======'+commSchRec);
        return commSchRec;
    }
    /*************************************************************************
@Author: Rajat Verma
@Date: 14/06/24
@purpose: Calculate working days
*************************************************************************************/
    //CRMD-10763 starts here
    public static DateTime getWorkingDays(Id businessHrId, DateTime baseDate, Long days)
    {
        Long addNDays = 86400000 *days;
        return BusinessHours.add(businessHrId, baseDate, addNDays);
    }
    /*************************************************************************
@Author: Rohit Chowdhury
@Date: 26/06/24
@purpose: Method to fetch MPAN Details from ECOES (CRMD-11219)
*************************************************************************************/
    //CRMD-11219 starts here
    public static void fetchMpanDetails(Set<Id> mpanrRecIds)
    {
        List<SPEN_IntegrationRequest__c> intReqList = new List<SPEN_IntegrationRequest__c>();
        if(!mpanrRecIds.isEmpty())
        {
            for(SPEN_MPAN__c mpanObj : [SELECT Id,SPEN_AccountNumberMPAN__c,SPEN_PingResult__c,SPEN_LastGasp__c,ExternalId__c  
                                        FROM SPEN_MPAN__c WHERE Id IN: mpanrRecIds WITH SECURITY_ENFORCED LIMIT:(Limits.getLimitQueryRows()-Limits.getQueryRows())])
            							{
                                            SPEN_IntegrationRequest__c intReqObj = new SPEN_IntegrationRequest__c();
                                            intReqObj.SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetMeterDetailsByMpanService';
                                            intReqObj.SPEN_Records__c = mpanObj.SPEN_AccountNumberMPAN__c;
                                            intReqObj.SPEN_Status__c = 'Processing';
                                            intReqList.add(intReqObj);
                                        }
        }
        //system.debug('intReqList-->'+intReqList);
        if(!intReqList.isEmpty())
        {
            insert intReqList;
        }
    }
    //CRMD-11219 ends here
}