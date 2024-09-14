/**
 * @description       : Test class for SPEN_InsertVoice_AlertBatch
 * @author            : Akshay Pandit
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : a.rajendra.pandit@accenture.com
**/
@IsTest(SeeAllData=false)
@SuppressWarnings('PMD.SOQLSelectorPattern')
private class SPEN_InsertVoice_AlertBatch_TEST 
{
    @testSetup 
    static void dataSetup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
         PermissionSet ps14 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CommunicationSchedulerAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps14.Id);
         PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MessagingTaskCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            SPEN_ConfigurableSettings__c cS3 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert cS3;
             SPEN_ConfigurableSettings__c cS4 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
                        insert cS4;
SPEN_ConfigurableSettings__c cS5 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cS5;
             SPEN_ConfigurableSettings__c cS6 =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cS6;
            
             
            List<SPEN_IVR__c> ivrVARecord = SPEN_TestDataFactory.createIVRrecord(1);
            insert ivrVARecord;
            List<SPEN_IVR__c> ivrVoiceRecord = SPEN_TestDataFactory.createIVRrecord(1);
            ivrVoiceRecord[0].Name ='Sample Voice alert';
            insert ivrVoiceRecord;
            
        SPEN_IVRMessage__c  ivrMsgforVoice = SPEN_TestDataFactory.createIVRMessage(1);
        ivrMsgforVoice.recordTypeId =  Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('Voice Alert').getRecordTypeId();
        ivrMsgforVoice.SPEN_Purpose__c = 'HV';
         ivrMsgforVoice.SPEN_ExternalId__c = 'testExt001';
            insert ivrMsgforVoice;
       
        List<SPEN_IVROperatingHours__c> ivrHoursForVA = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrVoiceRecord[0].Id, ivrMsgforVoice.id);
        ivrHoursForVA[0].SPEN_isActive__c = true;
        ivrHoursForVA[0].Name = 'VA Blackout WIndow';
        ivrHoursForVA[0].recordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
        insert ivrHoursForVA;
		
        SPEN_IVRMessage__c ivrTemplate = SPEN_TestDataFactory.createIVRMessage(1);
            ivrTemplate.SPEN_ExternalId__c = 'testExt003';
        insert ivrTemplate;
        
        Incident inc = SPEN_TestDataFactory.createListofIncidents(1)[0];
        inc.Status = 'New';
        inc.SPEN_IncidentCategory__c = 'HV';
inc.SPEN_IncidentType__c = 'HV_N';
        inc.Subject = 'Testing';
        insert inc;
        Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            
        SPEN_MessagingTask__c msgTask = new SPEN_MessagingTask__c();
        msgTask.SPEN_Status__c = 'New';
        msgTask.SPEN_Event__c = '3-Hour Comfort Call';
        msgTask.SPEN_IncidentId__c = inc.Id;
        msgTask.recordTypeId = msgTaskRecTypeId; 
       	insert msgTask;
       Id vaBroadCaseRecTypeId =  Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('Voice Alert Broadcast').getRecordTypeId();

           List<SPEN_CommunicationScheduler__c > lstOfCommScheduler = new  List<SPEN_CommunicationScheduler__c > ();
           Integer count = 0;
        
            for(SPEN_CommunicationScheduler__c scheduler : SPEN_TestDataFactory.createCommunicationSchedulerRecord(6)){
                
                if(count == 0){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = vaBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVoiceAlerttoPSR__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for PSR in VA';
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 1){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = vaBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVoiceAlerttocalledin__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for called in VA';
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 2){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = vaBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVAtoAllCustomerinScope__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for ALL in VA';
                    lstOfCommScheduler.add(scheduler);
                } 
                 if(count == 3){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = vaBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVAtoPSRCalledin__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for ALL in VA';
                    lstOfCommScheduler.add(scheduler);
                }
                count++;


            }
            if(!lstOfCommScheduler.isEmpty()){
                
                     insert lstOfCommScheduler;
                
            }
            
            List<SPEN_Premise__c> lstPremise =  SPEN_TestDataFactory.createListOfPremise(1);
			insert lstPremise;
            
            Contact contactObj = SPEN_TestDataFactory.createContacts(null,1);
            contactObj.SPEN_PSR__c = true;
            contactObj.SPEN_PreferredMethodofContact__c = 'H';
            insert contactObj;
            
            SPEN_ContactPremise__c contactPremise = SPEN_TestDataFactory.createContactPremises(1, contactObj.id, lstPremise[0].id);
            contactPremise.SPEN_ExternalId__c='12445';
            contactPremise.SPEN_Role__c='Customer';
            insert contactPremise;

            SPEN_ImpactedPremise__c impactedPremise = SPEN_TestDataFactory.createImpactedPremiserecord(1)[0];
            impactedPremise.SPEN_RelatedIncident__c = inc.id;
            impactedPremise.SPEN_ContactPremise__c = contactPremise.id;
            insert impactedPremise;
           
            Case caseForCalledinSMS = SPEN_TestDataFactory.createListOfCases(1)[0];
            caseForCalledinSMS.contactId = contactObj.id;
            caseForCalledinSMS.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
            caseForCalledinSMS.SPEN_Incident__c = inc.id;
            //caseForCalledinSMS.SPEN_AddressPremise__c = lstPremise[0].Id;
            caseForCalledinSMS.SPEN_PreferredMethodofContact__c ='H';
            caseForCalledinSMS.SPEN_CallerTelephone__c ='09999999999';
            caseForCalledinSMS.SPEN_CallerMobileTelephone__c ='';
            
            insert caseForCalledinSMS;
            
            SPEN_CommunicationScheduler__c schedulerDistVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerDistVA.SPEN_Event__c  = 'Medically Dependent by District';
            schedulerDistVA.SPEN_district__c = 'TestZoneVA';
            schedulerDistVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerDistVA.SPEN_SendNow__c = true;
            insert schedulerDistVA;
            
             SPEN_CommunicationScheduler__c schedulerPremVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerPremVA.SPEN_Event__c  = 'Planned Outage Communication';
            schedulerPremVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerPremVA.SPEN_SendNow__c = true;
            insert schedulerPremVA;
            
            
            Test.stopTest();
        }
    }
     @isTest
    public static void insertVABatchTestForPremise()
    {
        User u= [Select id FROM User where Id!=null and IsActive=true LIMIT 1];
        Id ondemandtRT = SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByDeveloperName().get('OnDemand').getRecordTypeId();
        SPEN_MessagingTask__c mtask = new SPEN_MessagingTask__c(recordTypeId = ondemandtRT, SPEN_Event__c= 'On Demand', SPEN_Status__c = 'new');
		insert mTask;
        mtask.SPEN_Status__c = 'Completed';
		mTask.SPEN_PremiseIds__c ='4286,7983';
        update mTask;
        System.runAs(u)
        {   
            Test.startTest();
            SPEN_Premise__c prem = [SELECT id FROM SPEN_Premise__c where id!=null LIMIT 1];
            Set<String> setPremId = new Set<String>();
            setPremId.add(prem.id);
            list<SPEN_CommunicationScheduler__c> lstcommSche = [select id, SPEN_Message__c, SPEN_Event__c, SPEN_MessagingTaskId__r.SPEN_PremiseIds__c
                                                               from SPEN_CommunicationScheduler__c
                                                               //WHERE SPEN_Event__c = : mTask.Id
                                                               limit 1
                                                              ];
            
            lstcommSche[0].SPEN_MessagingTaskId__c = mTask.Id;
            update lstcommSche;
            list<SPEN_CommunicationScheduler__c> lstcommSch = [select id, SPEN_Message__c, SPEN_Event__c, SPEN_MessagingTaskId__r.SPEN_PremiseIds__c
                                                               from SPEN_CommunicationScheduler__c
                                                               WHERE Id = : lstcommSche[0].Id
                                                               limit 1
                                                              ];
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
          
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(lstcommSch));
            Assert.isNotNull(lstcommSch, 'Communication Scheduler should not empty');
            Test.stopTest();
        }
    }
     @isTest
    public static void insertVABatchTestForDistrict()
    {
         User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];

        System.runAs(u)
        {   
            Test.startTest();
            list<SPEN_CommunicationScheduler__c> lstcommSch = [select id, SPEN_district__c,SPEN_Message__c,SPEN_Event__c
                                                               from SPEN_CommunicationScheduler__c 
                                                               WHERE SPEN_Event__c = 'Medically Dependent by District'
                                                              ];
            Map<String, SPEN_CommunicationScheduler__c> testMap = new Map<String, SPEN_CommunicationScheduler__c>();
            testMap.put(lstcommSch[0].SPEN_district__c,lstcommSch[0]);
            Database.executeBatch(new SPEN_InsertSMSBatch(testMap));
            Assert.isNotNull(lstcommSch, 'Communication Scheduler should not empty');
            Test.stopTest();
        }
    }
    @isTest 
    private static void insertVABatchTestForPSR(){
        User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' and IsActive=true limit 1];
        System.runAs(u){
            Incident incObj = [select id  from Incident where id!=null limit 1];
            SPEN_CommunicationScheduler__c commSch = [select id, SPEN_IncidentId__c, SPEN_MessagingTaskId__c, SPEN_SendSMSMCtoPSR__c,SPEN_Message__c,SPEN_Event__c,SPEN_SendVoiceAlerttoPSR__c,SPEN_SendVAtoAllCustomerinScope__c,SPEN_SendVAtoPSRCalledin__c,SPEN_SendVoiceAlerttocalledin__c from SPEN_CommunicationScheduler__c where SPEN_SendVoiceAlerttoPSR__c =true and SPEN_IncidentId__c = :incObj.id  limit 1];

            /*Map<String, String> mapCommunicationIDToIncidentId = new Map<String, String>();
            mapCommunicationIDToIncidentId.put(commSch.id, incObj.id);
            
            Map<String, SPEN_CommunicationScheduler__c> mapIncidentIdToCommunicationSch = new Map<String, SPEN_CommunicationScheduler__c> ();
            mapIncidentIdToCommunicationSch.put(incObj.id, commSch);*/
            Test.startTest();
               Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            List<Boolean> boolist=new List<Boolean>();
            boolist.add(true);
            boolist.add(false);
            boolist.add(false);
			boolist.add(false);
            Map<SPEN_CommunicationScheduler__c,Id> mapIncidentIdToCommunicationSch=new Map<SPEN_CommunicationScheduler__c,Id>();
            mapIncidentIdToCommunicationSch.put(commSch,incObj.id);
            Map<SPEN_CommunicationScheduler__c, List<Boolean>> testmapOfCommSchedulerWithCheckboxes=new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
            testmapOfCommSchedulerWithCheckboxes.put(commSch,boolist);
            //Database.executeBatch(new SPEN_InsertSMSBatch(mapCommunicationIDToIncidentId,mapIncidentIdToCommunicationSch,true, false, false, false));
            Database.executeBatch(new SPEN_InsertVoice_AlertBatch(mapIncidentIdToCommunicationSch,testmapOfCommSchedulerWithCheckboxes,1));
            System.assert(true, 'Batch processed successfully for PSR VA');
            Test.stopTest();

        }
    }
    @isTest 
    private static void insertVABatchTestForCalledIn(){
        User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' and IsActive=true limit 1];
        System.runAs(u){
            Incident incObj = [select id  from Incident where id!=null limit 1];
            if(incObj.id !=null){
                SPEN_CommunicationScheduler__c commSch = [select id, SPEN_IncidentId__c, SPEN_MessagingTaskId__c, SPEN_SendSMSMCtoPSR__c,SPEN_Message__c,
                                                          SPEN_Event__c,SPEN_SendVoiceAlerttoPSR__c,SPEN_SendVAtoAllCustomerinScope__c,
                                                          SPEN_SendVAtoPSRCalledin__c,SPEN_SendVoiceAlerttocalledin__c 
                                                          from SPEN_CommunicationScheduler__c 
                                                          where SPEN_SendVAtoPSRCalledin__c =true and SPEN_IncidentId__c = :incObj.id  
                                                          limit 1];
                /* Map<String, String> mapCommunicationIDToIncidentId = new Map<String, String>();
                mapCommunicationIDToIncidentId.put(commSch.id, incObj.id);
                
                Map<String, SPEN_CommunicationScheduler__c> mapIncidentIdToCommunicationSch = new Map<String, SPEN_CommunicationScheduler__c> ();
                mapIncidentIdToCommunicationSch.put(incObj.id, commSch);*/
                Test.startTest();
                 Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
          
                List<Boolean> boolist=new List<Boolean>();
                boolist.add(false);
                boolist.add(false);
                boolist.add(true);
                boolist.add(false);
                Map<SPEN_CommunicationScheduler__c,Id> mapIncidentIdToCommunicationSch=new Map<SPEN_CommunicationScheduler__c,Id>();
                mapIncidentIdToCommunicationSch.put(commSch,incObj.id);
                Map<SPEN_CommunicationScheduler__c, List<Boolean>> testmapOfCommSchedulerWithCheckboxes=new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
                testmapOfCommSchedulerWithCheckboxes.put(commSch,boolist);
                //Database.executeBatch(new SPEN_InsertSMSBatch(mapCommunicationIDToIncidentId,mapIncidentIdToCommunicationSch,false, false, false, true));
                Database.executeBatch(new SPEN_InsertVoice_AlertBatch(mapIncidentIdToCommunicationSch,testmapOfCommSchedulerWithCheckboxes,2));
            }
        	Assert.isTrue(true, 'Batch processed successfully for Called in VA');   
		 Test.stopTest();

        }
    }
}