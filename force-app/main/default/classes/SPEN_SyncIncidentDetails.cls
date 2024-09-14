@RestResource(urlMapping ='/Incidents/*')
global with sharing class SPEN_SyncIncidentDetails 
{
    
    @HttpPost
    global static Incident createIncident() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        List<Id> sampleIds = new List<Id>();
        String caseCallRef;
        Incident incident = new Incident();
        List<String> strList = new List<String>();
        Incident incToUpdate = new Incident();
        Incident incForXRTCheck = new Incident();
        String incidentId;
        
        SPEN_MessagingTaskService msgTaskSrv=new SPEN_MessagingTaskService();
        Datetime varLogTime;
        String varLogComment;
        String eventVar;
        String statusVar;
        RecordType recType=[Select id, SobjectType,  DeveloperName from RecordType where DeveloperName ='Incident' and SobjectType='SPEN_MessagingTask__c'];
        Id IVRRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
        
        List<SPEN_SMS__c> SMSCreation = new List<SPEN_SMS__c>();
        List<SPEN_VoiceAlert__c> lstVoiceAlert = new List<SPEN_VoiceAlert__c>();
        Set<String> setIVRExternalID = new Set<String>{'SP Resource Dispatched SMS',
            'SP ETA Changes SMS','SP Resource Dispatched VA','SP ETA Changed VA'};
                Map<String,Id> mapIVRExtId2Id = new Map<String,Id>();
        Map<String,String> mapIVRExtId2Message = new Map<String,String>();
        
        Map<String,String> incRefIncCoordMap =  new Map<String,String>(); 
        Map<String,DateTime> incRefIncActualTimeMap =  new Map<String,DateTime>(); //9249
                
        try{
            SPEN_IntegrationXMLNodes.SoapBodyNode incidentPowerOn = new SPEN_IntegrationXMLNodes.SoapBodyNode();
            strList = req.requestBody.toString().split('<soap:Body>');
            String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', '');
            String soapString = newStr.replaceAll('soap:', '');
            String soapNoNullString = soapString.replaceAll('xsi:nil=\"true\"', '');
            incidentPowerOn.load(soapNoNullString);    
            SPEN_SyncIncidentDetailsWrapper.RequestBody createWrapper = (SPEN_SyncIncidentDetailsWrapper.RequestBody) System.JSON.deserialize(JSON.serialize(incidentPowerOn), SPEN_SyncIncidentDetailsWrapper.RequestBody.class);
            //Incident create scenario
            if(!createWrapper.sdifIncidentCreated.isEmpty())
            {
                for(SPEN_SyncIncidentDetailsWrapper.sdifIncidentCreated incCre: createWrapper.sdifIncidentCreated){            
                    for(SPEN_SyncIncidentDetailsWrapper.incidentCreatedStc nextValC : incCre.incidentCreatedStc){ 
                        incident.SPEN_ComponentDescription__c = nextValC.componentDescription;
                        incident.SPEN_CreationDateTime__c = stringGMTConverstion(nextValC.creationDate);
                        incident.SPEN_DangerFlag__c = (nextValC.dangerFlag == 0) ? false : true; 
                        incident.SPEN_DeadDeviceAlias__c = nextValC.deadDeviceAlias; 
                        incident.SPEN_IncidentID__c  =  nextValC.incidentID;
                        incident.SPEN_GroupID__c     =  nextValC.groupID;    
                        incident.SPEN_GroupName__c   =  nextValC.groupName; 
                        if(nextValC.estimatedRestorationDate != null ) incident.SPEN_EstimatedRestorationTime__c = stringGMTConverstion(nextValC.estimatedRestorationDate);
                        incident.SPEN_IncidentPriority__c = nextValC.incidentPriority;    
                        incident.SPEN_IncidentReference__c   =  nextValC.incidentReference;
                        incident.SPEN_IncidentCategory__c = nextValC.incidentCategory;
                        incident.SPEN_IncidentCategoryDescription__c = nextValC.incidentCategoryDescription;
                        incident.SPEN_IncidentDescription__c = nextValC.incidentDescription;
                        incident.SPEN_IncidentType__c = nextValC.incidentType;
                        if(nextValC.ivrMessageFlag != '0'){
                            incident.SPEN_IVRMessage__c = nextValC.ivrMessageFlag;
                        }                       
                        incident.SPEN_Main_Message__c = nextValC.mainMessage;   
                        
                        incident.SPEN_OperatingZone__c = nextValC.operatingZone;  
                        incident.SPEN_OperatingZoneId__c = nextValC.operatingZoneId;    
                        incident.SPEN_IncidentStatus__c = 'Awaiting';
                        incident.SPEN_LastStatus__c = 'Created';
                        //messaing task service call;
                        incident.SPEN_LastCommunicationTime__c=system.now();			
                        if(nextValC.receivedDate != null ) incident.DetectedDateTime = stringGMTConverstion(nextValC.receivedDate);
                        incident.SPEN_SupplementaryMessage__c=nextValC.supplementaryMessage; //updated for SFAMS-559
                        
                    }
                    
                    incident.Subject = 'PowerOn Incident';
                    insert incident;
                    SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskTypeCreate' Limit 1];
                    List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                    if(MessageINCTypeList.contains(String.ValueOf(incident.SPEN_IncidentType__c))){

                        msgTaskSrv.createMessagingTaskIncCreated('Incident Created',incident.id,recType.id,incident.SPEN_OperatingZone__c,'New');

                    }
                }
                return incident;
            }
            else {
                if(createWrapper.sdifIncidentScopeChanged.isEmpty()){
                    if(createWrapper.sdifIncidentCancelled != null && !createWrapper.sdifIncidentCancelled.isEmpty()){
                        for(SPEN_SyncIncidentDetailsWrapper.sdifIncidentCancelled incCan: createWrapper.sdifIncidentCancelled){            
                            for(SPEN_SyncIncidentDetailsWrapper.incidentCancelledStc nextVal : incCan.incidentCancelledStc){
                                incidentId = nextVal.incidentID;
                                incToUpdate.SPEN_IncidentID__c   =  nextVal.incidentID;        
                                incToUpdate.SPEN_IncidentReference__c =  nextVal.incidentReference;   
                                incToUpdate.SPEN_CancelledDate__c = stringGMTConverstion(nextVal.incTime); 
                                incToUpdate.SPEN_IncidentStatus__c = 'Cancelled';
                            }
                        }
                    } else if(!createWrapper.SDIFIncidentDetailsChanged.isEmpty()){
                        for(SPEN_SyncIncidentDetailsWrapper.SDIFIncidentDetailsChanged incCngd: createWrapper.SDIFIncidentDetailsChanged){            
                            for(SPEN_SyncIncidentDetailsWrapper.incidentDetailsChangedStc nextChng : incCngd.incidentDetailsChangedStc){ 
                                if(!String.isEmpty(nextChng.estimatedRestorationDate)){
                                    incToUpdate.SPEN_EstimatedRestorationTime__c = stringGMTConverstion(nextChng.estimatedRestorationDate);    
                                }
                                incToUpdate.SPEN_DeadDeviceAlias__c = nextChng.deadDeviceAlias; 
                                incidentId = nextChng.incidentID;
                                incToUpdate.SPEN_IncidentID__c   =  nextChng.incidentID; 
                                incToUpdate.Description = nextChng.description;
                                if(nextChng.incidentRef != null){
                                    incToUpdate.SPEN_IncidentReference__c =  nextChng.incidentRef;
                                }  
                                //CRMD -1289
                                incForXRTCheck = [SELECT Id,IncidentNumber,SPEN_IncidentID__c,SPEN_EstimatedRestorationTime__c,SPEN_ResourceArrivalDate__c,SPEN_IncidentStatus__c FROM Incident WHERE SPEN_IncidentID__c = :nextChng.incidentID Limit 1];
                                if(nextChng.estimatedRestorationDate != null){
                                    incToUpdate.SPEN_EstimatedRestorationTime__c = stringGMTConverstion(nextChng.estimatedRestorationDate);
                                    //CRMD-1289
                                    if(incForXRTCheck.SPEN_EstimatedRestorationTime__c != stringGMTConverstion(nextChng.estimatedRestorationDate)){
                                        /*List<String> incStrLst = new List<String>();
                                        incStrLst.add(String.valueOf(incForXRTCheck.SPEN_IncidentID__c));
                                        //SPEN_GetAffectedPremiseService.createRecord(incStrLst);*/
                                        Incident GetRelatedImp =[select id,(select id from Impacted_Premises__r where SPEN_Status__c='Restored' limit 1) from Incident where SPEN_IncidentID__c =:nextChng.incidentID];
                                        if(GetRelatedImp.Impacted_Premises__r.size()>=1){
                                            incToUpdate.SPEN_LastStatus__c='ExtendedRestorationTime';
                                            incToUpdate.SPEN_LastCommunicationTime__c=system.now(); 
                                            eventVar = 'Estimated Restoration Time Extended';
                                            statusVar = 'New';
                                        }                           
                                    }
                                }else if(nextChng.estimatedRestorationDate != null)  {
                                    incToUpdate.SPEN_ETA__c = stringGMTConverstion(nextChng.eta);
                                }
                                if(nextChng.status != null && nextChng.status == 7 && incForXRTCheck.SPEN_IncidentStatus__c!='Merged'){
                                   //CRMD-5249 fixed related to To Be Merged
                                    List<Case> lstOfCasesPresent = [select id, SPEN_Incident__c from case where SPEN_Incident__c = :incForXRTCheck.Id];
                                    if(lstOfCasesPresent.isEmpty()){
                                        incToUpdate.SPEN_IncidentStatus__c = 'Merged';
                                    }
                                    else{
                                        incToUpdate.SPEN_IncidentStatus__c = 'To Be Merged';
									 }
                                }
                                else if((nextChng.status != null && nextChng.status == 1 && incForXRTCheck.SPEN_ResourceArrivalDate__c == Null) || (nextChng.status != null && nextChng.status == 1 && incForXRTCheck.SPEN_IncidentStatus__c=='Delog')){
                                    incToUpdate.SPEN_IncidentStatus__c = 'In Progress';
                                }
                                
                                if(nextChng.mainMessage != null){
                                    incToUpdate.SPEN_Main_Message__c = nextChng.mainMessage;
                                }
                                if(nextChng.category != null){
                                    incToUpdate.SPEN_IncidentCategory__c = nextChng.category;
                                }
                                if(nextChng.incidentCategoryDescription != null){
                                    incToUpdate.SPEN_IncidentCategoryDescription__c = nextChng.incidentCategoryDescription;
                                }
                                if(nextChng.type != null){
                                    incToUpdate.SPEN_IncidentType__c = nextChng.type;
                                }
                                if(nextChng.priority != null){
                                    incToUpdate.SPEN_IncidentPriority__c = nextChng.priority;
                                }
                                if(nextChng.supplementaryMessage != null){
                                    incToUpdate.SPEN_SupplementaryMessage__c = nextChng.supplementaryMessage;  //updated for SFAMS-559
                                }
                            }
                        }
                    } else if(createWrapper.sdifIncidentDelogged !=null && !createWrapper.sdifIncidentDelogged.isEmpty()){
                        Incident incForDelogCheck = new Incident();
                        for(SPEN_SyncIncidentDetailsWrapper.sdifIncidentDelogged incDlogd: createWrapper.sdifIncidentDelogged){            
                            for(SPEN_SyncIncidentDetailsWrapper.incidentDeloggedStc nextDlg : incDlogd.incidentDeloggedStc){ 
                                incForDelogCheck = [SELECT Id,IncidentNumber,SPEN_IncidentID__c,SPEN_EstimatedRestorationTime__c FROM Incident WHERE SPEN_IncidentID__c = :nextDlg.incidentID Limit 1];
                                incidentId = nextDlg.incidentID;
                                incToUpdate.SPEN_IncidentID__c   =  nextDlg.incidentID;
                                incToUpdate.SPEN_SecondaryFeeder__c = nextDlg.secondaryFeeder;
                                incToUpdate.SPEN_IncidentStatus__c   =  'Delog';
                                incToUpdate.SPEN_LastStatus__c = 'Delog';
                                incToUpdate.SPEN_LastCommunicationTime__c=system.now();                    
                                caseCallRef = nextDlg.callReference;
                                //eventVar = 'Incident Restored';//SFAMS-647
                                //statusVar = 'New';//SFAMS-647
                                /*List<String> incStrLst = new List<String>();
                                incStrLst.add(String.valueOf(nextDlg.incidentID));
                                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);*/
                                /*SFAMS-647: commented the Incident Restored messaging Task Creation logic
                                SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType' Limit 1];
                                List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                                if(MessageINCTypeList.contains(String.ValueOf(nextDlg.Type))){
                                    msgTaskSrv.createMessagingTask('Incident Restored',incForDelogCheck.id,recType.id,Null,'New');
                                }*/
                            }
                        }
                    } else if(createWrapper.sdifIncidentCompleted != null && !createWrapper.sdifIncidentCompleted.isEmpty()){            
                        for(SPEN_SyncIncidentDetailsWrapper.sdifIncidentCompleted incCmpltd: createWrapper.sdifIncidentCompleted){            
                            for(SPEN_SyncIncidentDetailsWrapper.incidentCompletedStc nextCmp : incCmpltd.incidentCompletedStc){ 
                                incidentId = nextCmp.incidentID;
                                incToUpdate.SPEN_IncidentID__c = nextCmp.incidentID;  
                                incToUpdate.Description = nextCmp.description;
                                incToUpdate.SPEN_IncidentStatus__c   =  'Complete';
                            }
                        }
                    } else if(createWrapper.sdifResourceDispatched != null && !createWrapper.sdifResourceDispatched.isEmpty()){            
                        for(SPEN_SyncIncidentDetailsWrapper.sdifResourceDispatched rsCmpltd: createWrapper.sdifResourceDispatched){            
                            for(SPEN_SyncIncidentDetailsWrapper.resourceDispatchedStc nextRs : rsCmpltd.resourceDispatchedStc){ 
                                for(SPEN_SyncIncidentDetailsWrapper.dispatches dis : nextRs.dispatches){  
                                    
                                    Incident incidentRecord = [select id,SPEN_IncidentType__c, SPEN_Forename__c,SPEN_Surname__c, SPEN_ResourceID__c, SPEN_DispatchedDate__c,SPEN_IncidentStatus__c,
                                    SPEN_IncidentID__c,SPEN_ResourceArrivalDate__c,(select id,ContactId,CaseNumber,SPEN_PreferredMethodofContact__c,SPEN_CallerTelephone__c,SPEN_CallerMobileTelephone__c from cases__r Limit 1)
                                     from Incident where SPEN_IncidentID__c = :dis.incidentID Limit 1 ];
                                    
                                    Case caseRec=new Case();
                                    if(incidentRecord != null && (incidentRecord.SPEN_ResourceID__c != dis.resourceID || incidentRecord.SPEN_DispatchedDate__c != null)){
                                        eventVar = 'Resource Dispatched';
                                        statusVar = 'New';
                                    }
                                    incidentId = dis.incidentID;
                                    incToUpdate.SPEN_IncidentID__c   =  dis.incidentID; 
                                    if(String.isBlank(incidentRecord.SPEN_Forename__c) && String.isBlank(incidentRecord.SPEN_Surname__c) && String.isBlank(incidentRecord.SPEN_ResourceID__c)){
                                        String tempVar = dis.resourceForename;
                                        if(tempVar.contains('(')){
                                            String firstName = tempVar.split('\\(')[0].trim();
                                            incToUpdate.SPEN_Forename__c = firstName; 
                                        }
                                        else{
                                            incToUpdate.SPEN_Forename__c = tempVar; 
                                        }
                                        incToUpdate.SPEN_Surname__c = dis.resourceSurname;  
                                        incToUpdate.SPEN_ResourceID__c = dis.resourceID; 
                                        incToUpdate.SPEN_DispatchedDate__c = System.now();
                                        DateTime currDateTime = System.now();
                                        SPEN_ConfigurableSettings__c defaultETAInMinutes = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='ETADefaultForDispatch' Limit 1];
                                        Integer defaultMin = Integer.valueOf(defaultETAInMinutes.SPEN_Value__c);
                                        DateTime newDateTime = currDateTime.addMinutes(defaultMin);
                                        incToUpdate.SPEN_ETA__c = newDateTime;
                                        
                                        if(incidentRecord != Null && !incidentRecord.cases__r.isEmpty()){
                                            caseRec = incidentRecord.cases__r[0];
                                            list<SPEN_IVRMessage__c> lstIVRMessage = new list<SPEN_IVRMessage__c>();
                                            lstIVRMessage = [Select ID,SPEN_IVRMessage__c,SPEN_ExternalId__c from SPEN_IVRMessage__c where SPEN_ExternalId__c IN: setIVRExternalID];
                                            if(lstIVRMessage !=null && !lstIVRMessage.isEmpty()){
                                                for(SPEN_IVRMessage__c ivr: lstIVRMessage){
                                                    mapIVRExtId2Id.put(ivr.SPEN_ExternalId__c,ivr.Id);
                                                    mapIVRExtId2Message.put(ivr.SPEN_ExternalId__c,ivr.SPEN_IVRMessage__c);
                                                }
                                            }
                                            if((caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='T') || (caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){
                                                //Send SMS
                                                SMSCreation.add(SPEN_SyncIncidentDetails.createSMSRecord('Resource Dispatched',caseRec,incidentRecord,mapIVRExtId2Id.get('SP Resource Dispatched SMS'),mapIVRExtId2Message.get('SP Resource Dispatched SMS')));
                                            }else if((caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='H') || (caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){
                                                //Send VA
                                                lstVoiceAlert.add(SPEN_SyncIncidentDetails.createVARecord(caseRec,incToUpdate,mapIVRExtId2Message.get('SP Resource Dispatched VA')));
                                            }
                                        }

                                        SPEN_ConfigurableSettings__c AutoSMSINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='AutoSMSTaskType' Limit 1];
								        List<String> AutoSMSINCTypeList = AutoSMSINCType.SPEN_Value__c.split(',');
								        if(AutoSMSINCTypeList.contains(String.ValueOf(incidentRecord.SPEN_IncidentType__c))){
									    //Check if BlockoutWindow
									    Boolean isSMSOptOut = checkBlackoutWindowPeriod('SMS Blackout Window');
									    Boolean isVAOptOut = checkBlackoutWindowPeriod('VA Blackout Window');
									    if(SMSCreation != null && !SMSCreation.isEmpty() && isSMSOptOut){
										    insert SMSCreation;
									    }
									    if(lstVoiceAlert != null && !lstVoiceAlert.isEmpty() && isVAOptOut){
										    insert lstVoiceAlert;
										    //Call VA Batch
										    SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
									        }
								        }
                                        
                                        if(incidentRecord.SPEN_ResourceArrivalDate__c == Null){
                                        incToUpdate.SPEN_IncidentStatus__c   =  'In Progress';    
                                        }
                                    } 
                                   
                                    if(incToUpdate.SPEN_ResourceID__c!=Null){
                                        incToUpdate.SPEN_LastStatus__c='Dispatch';
                                        incToUpdate.SPEN_LastCommunicationTime__c=system.now();
                                        SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType' Limit 1];
                                        List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                                        if(MessageINCTypeList.contains(String.ValueOf(incidentRecord.SPEN_IncidentType__c))){
                                            msgTaskSrv.createMessagingTask('Resource Dispatched',incidentRecord.id,recType.id,Null,'New');
                                        }
                                    }  
                                }
                            }
                        }
                    } else if(createWrapper.sdifResourceCancelled != null && !createWrapper.sdifResourceCancelled.isEmpty()){            
                        for(SPEN_SyncIncidentDetailsWrapper.sdifResourceCancelled rsCncld: createWrapper.sdifResourceCancelled){            
                            for(SPEN_SyncIncidentDetailsWrapper.resourceCancelledStc nextRs : rsCncld.resourceCancelledStc){ 
                                for(SPEN_SyncIncidentDetailsWrapper.Cancellations can : nextRs.cancellations){  
                                    
                                    Incident incidentRecordResCan = [select id,SPEN_IncidentID__c, SPEN_ResourceID__c,SPEN_IncidentStatus__c from Incident where SPEN_IncidentID__c = :can.incidentID Limit 1 ];
                                    
                                    if(incidentRecordResCan.SPEN_ResourceID__c == can.resourceID && incidentRecordResCan.SPEN_IncidentStatus__c!='Merged' && incidentRecordResCan.SPEN_IncidentStatus__c!='Delog' && incidentRecordResCan.SPEN_IncidentStatus__c!='To Be Merged'){
                                        incidentId = can.incidentID;
                                        incToUpdate.SPEN_Forename__c = ''; 
                                        incToUpdate.SPEN_Surname__c = '';  
                                        incToUpdate.SPEN_ResourceID__c = '';
                                        incToUpdate.SPEN_ETA__c = null;
                                        incToUpdate.SPEN_DispatchedDate__c = null;
                                        incToUpdate.SPEN_ResourceArrivalDate__c = null;
                                        incToUpdate.SPEN_IncidentStatus__c = 'In Progress';
                                    }
                                }
                            }
                        }
                    } else if(createWrapper.sdifResourceOnSite != null && !createWrapper.sdifResourceOnSite.isEmpty()){            
                        for(SPEN_SyncIncidentDetailsWrapper.SDIFResourceOnSite rsOnSite: createWrapper.sdifResourceOnSite){            
                            for(SPEN_SyncIncidentDetailsWrapper.ResourceOnSiteStc rsrce : rsOnSite.resourceOnSiteStc){ 

                                Incident incidentRecord = [select id,SPEN_IncidentType__c,SPEN_IncidentID__c, SPEN_ResourceID__c,SPEN_Forename__c,SPEN_Surname__c,SPEN_ResourceArrivalDate__c, SPEN_DispatchedDate__c,SPEN_IncidentStatus__c from Incident where SPEN_IncidentID__c = :rsrce.incidentID Limit 1 ];
                                
                                if(incidentRecord != null && incidentRecord.SPEN_ResourceArrivalDate__c != stringGMTConverstion(rsrce.arrivalDate)){
                                    eventVar = 'Resource Arrival On Site';
                                    statusVar = 'New';
                                }

                                incToUpdate.Description = rsrce.incidentDescription;
                                incToUpdate.SPEN_IncidentStatus__c =  'On Site'; 
                                if(incidentRecord.SPEN_ResourceArrivalDate__c == null){
                                    incToUpdate.SPEN_ResourceArrivalDate__c = stringGMTConverstion(rsrce.arrivalDate); 
                                }
                                incToUpdate.SPEN_OperatingZone__c = rsrce.operatingZone;  

                                if(String.isBlank(incidentRecord.SPEN_Forename__c) && String.isBlank(incidentRecord.SPEN_Surname__c) && String.isBlank(incidentRecord.SPEN_ResourceID__c)){
                                        String tempVar = rsrce.resourceForename;
                                        if(tempVar.contains('(')){
                                            String firstName = tempVar.split('\\(')[0].trim();
                                            incToUpdate.SPEN_Forename__c = firstName;
                                        }
                                        else{
                                            incToUpdate.SPEN_Forename__c = tempVar; 
                                        }
                                        incToUpdate.SPEN_Surname__c = rsrce.resourceSurname;  
                                        incToUpdate.SPEN_ResourceID__c = rsrce.resourceID; 
							        }  
                                incidentId = rsrce.incidentID;
                                if(incToUpdate.SPEN_ResourceArrivalDate__c != Null){
                                    incToUpdate.SPEN_LastStatus__c='On Site';
                                    incToUpdate.SPEN_LastCommunicationTime__c=system.now();
                                    eventVar = 'Resource Arrival On Site';
                                    statusVar = 'New';
                                    /*List<String> incStrLst = new List<String>();
                                    incStrLst.add(String.valueOf(incidentRecord.SPEN_IncidentID__c));
                                    //SPEN_GetAffectedPremiseService.createRecord(incStrLst);*/
									
                                    SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType' Limit 1];
                                    List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                                    if(MessageINCTypeList.contains(String.ValueOf(incidentRecord.SPEN_IncidentType__c))){
                                        msgTaskSrv.createMessagingTask(eventVar,incidentRecord.id,recType.id,Null,'New');
                                    }
                                }
                            }
                        }
                    } 
                    else if(createWrapper.sdifIncidentLogCreated != null && !createWrapper.sdifIncidentLogCreated.isEmpty()){
                        for(SPEN_SyncIncidentDetailsWrapper.SDIFIncidentLogCreated incdLog: createWrapper.SDIFIncidentLogCreated){
                            for(SPEN_SyncIncidentDetailsWrapper.IncidentLogCreatedStc nextIncLog : incdLog.IncidentLogCreatedStc){
                                incidentId = nextIncLog.incidentID;
                                incToUpdate.SPEN_IncidentID__c   =  nextIncLog.incidentID;
                                if(nextIncLog.logSubCategoryID ==106 && nextIncLog.logCategoryID==1){
                                    incToUpdate.SPEN_IncidentReference__c = nextIncLog.incidentReference;
                                    incToUpdate.SubCategory = 'Third Party Damage';
                                    
                                }else if(nextIncLog.logSubCategoryID ==75 && nextIncLog.logCategoryID==1){
                                    incToUpdate.SPEN_IncidentReference__c = nextIncLog.incidentReference;
                                    incToUpdate.SubCategory = 'Rechargeable';
                                }
                                else if(nextIncLog.logSubCategoryID == 9 && nextIncLog.logCategoryID== 6)
                                {
                                    incRefIncCoordMap.put(nextIncLog.IncidentReference, nextIncLog.logComment);
                                    //CRMD-9429 - START
                                    if(nextIncLog.actualTime!=NULL)
                                    {
                                        incToUpdate.SPEN_Actual_Time__c = nextIncLog.actualTime;
                                        incRefIncActualTimeMap.put(nextIncLog.IncidentReference, nextIncLog.actualTime);
                                    }
                                //CRMD-9429 - END
                                }
                                
                            }
                        }
                    }
                    if(!incRefIncCoordMap.isEmpty())
                    {
                        //Incidents.createNRSWACase(incRefIncCoordMap);//9249 commented
                        Incidents.createNRSWACase(incRefIncCoordMap,incRefIncActualTimeMap);//9249 added
                    }
                    
                    
                    List<Incident> inc = new List<Incident>();
                   
                    inc = [Select Id,SPEN_ETA__c,SPEN_Forename__c,SPEN_DispatchedDate__c,SPEN_IncidentType__c,SPEN_droppedsupply__c,SPEN_DroppedSupplyWithoutNotice__c,SPEN_EstimatedRestorationTime__c,SPEN_IncidentID__c,SPEN_IncidentCategory__c, SPEN_ResourceArrivalDate__c,
                           (select id,ContactId,Contact.FirstName,Contact.LastName,Contact.MobilePhone,Contact.Phone,CaseNumber, Contact.SPEN_PSR__c,SPEN_AddressPremise__r.SPEN_Area__c,Contact.SPEN_PreferredMethodofContact__c,

                            SPEN_AddressPremise__r.SPEN_PostCode__c,SPEN_AddressPremise__r.SPEN_Town__c,SPEN_PreferredMethodofContact__c,SPEN_CallerTelephone__c,SPEN_CallerMobileTelephone__c from cases__r limit 1)

                           from Incident WHERE SPEN_IncidentID__c =: incidentId LIMIT 1];

                    if(!inc.isEmpty())
                    {
                        incToUpdate.Id = inc[0].Id;
                        
                        if(caseCallRef !=null){                
                            List<Case> caseRef = new List<Case>();
                            for(Case caseObj: [select id,SPEN_Incident__c from Case where SPEN_PowerOnCallReference__c =:caseCallRef and SPEN_Incident__c=null]){
                                caseObj.SPEN_Incident__c =inc[0].Id;
                                caseRef.add(caseObj);
                            }
                            if(!caseRef.IsEmpty()){
                                update caseRef;
                            }
                        }
                    
                    Case caseRec=new Case();
                    if(!inc.isEmpty() && inc[0] != Null && !inc[0].cases__r.isEmpty()){
                        caseRec = inc[0].cases__r[0];
                    }
                    incToUpdate.SPEN_IsRecordViewed__c =false;
                  
                    //[Asmita]: CRMD 662 S
                    //Single Premise
                    
                        
                            list<SPEN_IVRMessage__c> lstIVRMessage = new list<SPEN_IVRMessage__c>();
                            lstIVRMessage = [Select ID,SPEN_IVRMessage__c,SPEN_ExternalId__c from SPEN_IVRMessage__c where SPEN_ExternalId__c IN: setIVRExternalID];
                            if(lstIVRMessage !=null && !lstIVRMessage.isEmpty()){
                                for(SPEN_IVRMessage__c ivr: lstIVRMessage){
                                    mapIVRExtId2Id.put(ivr.SPEN_ExternalId__c,ivr.Id);
                                    mapIVRExtId2Message.put(ivr.SPEN_ExternalId__c,ivr.SPEN_IVRMessage__c);
                                }
                            }
                            
                            if(!createWrapper.sdifIncidentLogCreated.isEmpty()){
                                for(SPEN_SyncIncidentDetailsWrapper.SDIFIncidentLogCreated incdLog: createWrapper.SDIFIncidentLogCreated){
                                    for(SPEN_SyncIncidentDetailsWrapper.IncidentLogCreatedStc nextIncLog : incdLog.IncidentLogCreatedStc){

                                        //Accepted should go to Dispatch - Accepted to be removed CRMD-5061
                                        //En Route should go to ETA
                                        if(nextIncLog.logSubCategoryID == -17 && nextIncLog.logCategoryID==2 && nextIncLog.logComment != null){
                                            String temp = nextIncLog.logComment;

                                            if(inc[0].SPEN_DispatchedDate__c == null){
                                                incToUpdate.SPEN_DispatchedDate__c =   stringGMTConverstion(nextIncLog.loggedTime);

                                                incToUpdate.SPEN_LastStatus__c='Dispatch';
                                                incToUpdate.SPEN_LastCommunicationTime__c=system.now();
                                                /*List<String> incStrLst = new List<String>();
                                                incStrLst.add(String.valueOf(inc[0].SPEN_IncidentID__c));
                                                //SPEN_GetAffectedPremiseService.createRecord(incStrLst);*/
                                                SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType' Limit 1];
                                                List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                                                if(MessageINCTypeList.contains(String.ValueOf(inc[0].SPEN_IncidentType__c))){
                                                    msgTaskSrv.createMessagingTask('Resource Dispatched',inc[0].id,recType.id,Null,'New');
                                                }
                                            }

                                            if(temp.contains('ETA')){
                                                temp = temp.split('ETA')[1].replaceFirst(':','').trim();
                                                if(inc[0].SPEN_ETA__c == null){
                                                    incToUpdate.SPEN_ETA__c = SPEN_SyncIncidentDetails.getDateTime(temp);
													
													if((caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='T') || (caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){
														//Send SMS
														SMSCreation.add(SPEN_SyncIncidentDetails.createSMSRecord('Resource Dispatched',caseRec,inc[0],mapIVRExtId2Id.get('SP Resource Dispatched SMS'),mapIVRExtId2Message.get('SP Resource Dispatched SMS')));
														
													}else if((caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='H') || (caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){
														//Send VA
														lstVoiceAlert.add(SPEN_SyncIncidentDetails.createVARecord(caseRec,incToUpdate,mapIVRExtId2Message.get('SP Resource Dispatched VA')));
													}
                                                }
                                            }
                                        }//ETA Updated
                                        else if(nextIncLog.logSubCategoryID == 0 && nextIncLog.logCategoryID==2 && nextIncLog.logComment != null){
                                            String temp = nextIncLog.logComment;
                                            temp = temp.split('\'')[1].trim();
                                            if(inc[0].SPEN_ETA__c == null){
                                                incToUpdate.SPEN_ETA__c= SPEN_SyncIncidentDetails.getDateTime(temp);
												

												if((caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='T') || (caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){
													//Send SMS
													SMSCreation.add(SPEN_SyncIncidentDetails.createSMSRecord('Resource Dispatched',caseRec,inc[0],mapIVRExtId2Id.get('SP Resource Dispatched SMS'),mapIVRExtId2Message.get('SP Resource Dispatched SMS')));
														//SMSCreation.add(SMSRec);
												}else if((caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='H') || (caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){

													//Send VA
													lstVoiceAlert.add(SPEN_SyncIncidentDetails.createVARecord(caseRec,incToUpdate,mapIVRExtId2Message.get('SP Resource Dispatched VA')));
												}
                                            }
                                            
                                            if(inc[0].SPEN_ETA__c != null && SPEN_SyncIncidentDetails.getDateTime(temp) != inc[0].SPEN_ETA__c){
                                                
                                                incToUpdate.SPEN_ETA__c= SPEN_SyncIncidentDetails.getDateTime(temp);
                                                
                                                //Send SMS

                                                if((caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='T') || (caseRec != null && caseRec.SPEN_CallerMobileTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){
                                                    SMSCreation.add(SPEN_SyncIncidentDetails.createSMSRecord('Resource ETA Change',caseRec,inc[0],mapIVRExtId2Id.get('SP ETA Changes SMS'),mapIVRExtId2Message.get('SP ETA Changes SMS')));
                                                    
                                                }else if((caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c=='H') || (caseRec != null && caseRec.SPEN_CallerTelephone__c != null && caseRec.SPEN_PreferredMethodofContact__c==null)){

                                                    //Send VA
                                                    lstVoiceAlert.add(SPEN_SyncIncidentDetails.createVARecord(caseRec,incToUpdate,mapIVRExtId2Message.get('SP ETA Changed VA')));
                                                }
                                            }
                                        }
                                        else if(nextIncLog.logSubCategoryID == 7 && nextIncLog.logCategoryID==2 && nextIncLog.logComment != null && inc[0].SPEN_Forename__c ==null){
                                            String tempVar = nextIncLog.logComment;
                                            tempVar = tempVar.split('None to')[1].trim();
                                            tempVar = tempVar.split('by')[0].trim();
                                            String resFirstName ='';
                                            String resLastName ='';
                                            String resId ='';
                                            if(tempVar.contains('(') && tempVar.contains(')')){
                                                String resName = tempVar.split('\\(')[0].trim();
                                                List<String> nameSplit = resName.split(' ');
                                                resFirstName = nameSplit[0];
                                                resLastName = nameSplit[nameSplit.size()-1];
                                                resId = tempVar.split('\\(')[1].replaceFirst('\\)','').trim();
                                            }
                                            else{
                                                List<String> nameSplit = tempVar.split(' ');
                                                resFirstName = nameSplit[0];
                                                resLastName = nameSplit[nameSplit.size()-1];
                                            }
                                            incToUpdate.SPEN_Forename__c = resFirstName; 
                                            incToUpdate.SPEN_Surname__c = resLastName;  
                                            incToUpdate.SPEN_ResourceID__c = resId; 
                                            incToUpdate.SPEN_IncidentStatus__c = 'In Progress';    
                                        }else if(nextIncLog.logSubCategoryID == -17 && nextIncLog.logCategoryID==1 && nextIncLog.logComment != null){
                                            incToUpdate = SPEN_OutageStateHandler.outageStateupdate(incToUpdate, nextIncLog.logComment,inc[0].SPEN_IncidentType__c);
                                        }
                                    }
                                }
                              
								SPEN_ConfigurableSettings__c AutoSMSINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='AutoSMSTaskType' Limit 1];
								List<String> AutoSMSINCTypeList = AutoSMSINCType.SPEN_Value__c.split(',');
								if(AutoSMSINCTypeList.contains(String.ValueOf(inc[0].SPEN_IncidentType__c))){
									//Check if BlockoutWindow
									Boolean isSMSOptOut = checkBlackoutWindowPeriod('SMS Blackout Window');
									Boolean isVAOptOut = checkBlackoutWindowPeriod('VA Blackout Window');
									if(SMSCreation != null && !SMSCreation.isEmpty() && isSMSOptOut){
										insert SMSCreation;
									}
									if(lstVoiceAlert != null && !lstVoiceAlert.isEmpty() && isVAOptOut){
										insert lstVoiceAlert;
										//Call VA Batch
										SPEN_VoiceAlertService.isServiceCall(lstVoiceAlert);
									}
								}
                            }
                    }            
                    upsert incToUpdate;
                    SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType' Limit 1];
                    List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                    if(eventVar != null && statusVar != null && MessageINCTypeList.contains(String.ValueOf(incident.SPEN_IncidentType__c))){
                        msgTaskSrv.createMessagingTask(eventVar,incToUpdate.id,recType.id,Null,statusVar);
                    }                   
                    return incToUpdate; 
                }
                else{                    
                    Incident incidentObjScopeChanged = new Incident();
                    List<String> callRef = new List<String>();
                    List<Case> cse = new List<Case>();
                    Set<Id> premSet=new Set<Id>();
                    List<String> cseId=new List<String>();
                    Map<string,integer> ConfigMap = New Map<string,integer>();
                    List<String> ConfiValueList = new List<String>{'ReparentCallSize','ScopeChangeDelay'};
                    
					for(SPEN_ConfigurableSettings__c ConfigSettings : [SELECT Name,SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name IN :ConfiValueList]){
					   ConfigMap.put(ConfigSettings.Name,integer.valueOf(ConfigSettings.SPEN_Value__c)); 
					}

                    for(SPEN_SyncIncidentDetailsWrapper.sdifIncidentScopeChanged incScopeCngd: createWrapper.sdifIncidentScopeChanged)
                    {
						List<Incident> incChange = new List<Incident>();
                        incChange = [SELECT Id,SPEN_IncidentID__c,SPEN_IncidentType__c,SPEN_IncidentStatus__c,(select id from SPEN_MessagingTasks__r where SPEN_Event__c = '3rd Call Received') FROM Incident WHERE SPEN_IncidentReference__c = :incScopeCngd.IncidentScopeChangedStc[0].incidentReference limit 1];
                        
						if(!incChange.isEmpty())
                        {
                            incidentObjScopeChanged= incChange[0];
                        }
                        if(ConfigMap != null && ConfigMap.containskey('ScopeChangeDelay'))
                        {
                            System.enqueueJob(new SPEN_IncidentQueueableClass(incScopeCngd),ConfigMap.get('ScopeChangeDelay'));
                        }
                    }
                    return incidentObjScopeChanged;  
                }
            }
           
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    public static SPEN_SMS__c createSMSRecord(String event,case caseRec, Incident incToUpdate, Id IvrMsgId,String IvrMsg){
        SPEN_SMS__c SMSRec = New SPEN_SMS__c();
        Id SMSRecordTypeId = Schema.SObjectType.SPEN_SMS__c.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        
        SMSRec.SPEN_CaseId__c =caseRec.id;
        SMSRec.SPEN_ContactId__c = caseRec.ContactId;
        SMSRec.RecordTypeId = SMSRecordTypeId;
        SMSRec.SPEN_IvrMessageId__c = IvrMsgId;
        SMSRec.SPEN_Message__c = IvrMsg;
        SMSRec.SPEN_Status__c = 'Ready';
        string Mobilenumber =caseRec.SPEN_CallerMobileTelephone__c;
        Mobilenumber = (String.isNotBlank(Mobilenumber) &&  Mobilenumber.startsWith('0')) ? '+44'+Mobilenumber.removeStart('0'):Mobilenumber ;
        SMSRec.SPEN_Mobile__c = Mobilenumber != null ? Mobilenumber : null;
        SMSRec.SPEN_MessageType__c = 'Outbound';
        SMSRec.SPEN_IncidentId__c = incToUpdate.Id;
        SMSRec.SPEN_Event__c = event;
        return SMSRec;
    }
    public static SPEN_VoiceAlert__c createVARecord(Case caseRec,Incident inc, String msgPSRTemp){
        Id VoiceAlertRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
        SPEN_VoiceAlert__c objVoiceAlert = new SPEN_VoiceAlert__c();
        objVoiceAlert.SPEN_ContactId__c = caseRec.ContactId;
        objVoiceAlert.RecordTypeId = VoiceAlertRecordTypeId;
        objVoiceAlert.SPEN_IncidentId__c =inc.Id;
        objVoiceAlert.SPEN_CalledInTelephone__c=caseRec.SPEN_CallerTelephone__c;
        String numCase=String.ValueOf(Integer.valueOf(caseRec.CaseNumber));
        Integer numLen = numCase.length();
        String spaceCase='';
        for(integer i=0;i<numLen;i++){
            spaceCase = spaceCase + ' ' + String.valueOf(numCase.mid(i,1));
        }
        msgPSRTemp = msgPSRTemp.replace('[ETA]',(String.valueOf(inc.SPEN_ETA__c.format('h:mm a'))).replace(' ',''));
        msgPSRTemp = msgPSRTemp.replace('[CASENUMBER]',spaceCase); 
        objVoiceAlert.SPEN_BroadcastMessage__c = msgPSRTemp;
        objVoiceAlert.SPEN_Status__c = 'Ready';
        return objVoiceAlert;
    }
    
    //[Asmita]:
    public static DateTime getDateTime(String dateTimeString) {
        Map<String,Integer> monthNames = new Map<String,Integer>{
            'jan' => 1,
                'feb' => 2,
                'mar' => 3,
                'apr' => 4,
                'may' => 5,
                'jun' => 6,
                'jul' => 7,
                'aug' => 8,
                'sep' => 9,
                'oct' => 10,
                'nov' => 11,
                'dec' => 12
                };
                    
        Integer day = Integer.valueOf(dateTimeString.split('-')[0]);
        Integer currYear = system.today().year();
        Integer month = monthNames.get(dateTimeString.split(' ')[0].split('-')[1].toLowerCase());
        List<String> timeArr = dateTimeString.split(' ')[1].trim().split(':');
        Date myDate = Date.newInstance(currYear, month, day);
        Time myTime = Time.newInstance(Integer.valueOf(timeArr[0]), Integer.valueOf(timeArr[1]), 0, 0);
        DateTime dt = DateTime.newInstance(myDate, myTime);
        return dt;
    }
    // Method to check SMS Black out window period to send the Communication by sms.
    public static Boolean checkBlackoutWindowPeriod(String typeCheck){
        Boolean result = false;
        Id recTypeIdOfBlackoutWindowRT = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get(typeCheck).getRecordTypeId();
        List<SPEN_IVROperatingHours__c> lstIvrHour = [select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordTypeId = :recTypeIdOfBlackoutWindowRT and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
        
        if(lstIvrHour[0] != null && !lstIvrHour.isEmpty()){
            if(lstIvrHour[0].SPEN_StartTime__c == null && lstIvrHour[0].SPEN_EndTime__c == null){
                result = true;
            }
            else if((lstIvrHour[0].SPEN_StartTime__c < lstIvrHour[0].SPEN_EndTime__c) && ((System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() < lstIvrHour[0].SPEN_EndTime__c) || (System.now().time() > lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c))){
                 result = true;
             }
             else if((lstIvrHour[0].SPEN_StartTime__c > lstIvrHour[0].SPEN_EndTime__c) && (System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c)){
                 result = true;
             }
        }
        return result;
    }
    
    global static Datetime stringGMTConverstion(String poweronTime){
        List<String> timeList = poweronTime.contains('+') ? poweronTime.split('\\+') : new List<String>{poweronTime};
        DateTime dt = (timeList.size() >1) ?  Datetime.valueOfGmt(timeList[0].replace('T', ' ')+'Z').addHours(Integer.valueOF(timeList[1].left(2))*-1) : Datetime.valueOfGmt(timeList[0].replace('T', ' ')) ;
        return dt;
    } 	
}