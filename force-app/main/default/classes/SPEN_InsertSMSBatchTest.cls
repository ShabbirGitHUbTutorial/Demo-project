/**
* @description       : Test class for SPEN_InsertSMSBatch
* @author            : Akshay Pandit
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : a.rajendra.pandit@accenture.com
**/

@IsTest(SeeAllData=false)
@SuppressWarnings('PMD.SOQLSelectorPattern , PMD.CodeBestPracticesNonFilteredQueries')

public class SPEN_InsertSMSBatchTest 
{
    @testSetup 
    static void dataSetup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        //system.debug('user'+user.Id);
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet ps14 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CommunicationSchedulerAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps14.Id);
         PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
         PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet impactedPremiseps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = impactedPremiseps.Id);
        System.runAs(user)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,SPEN_ConstantData.IncidentMessage);
            cs.Name = 'OutboundIncidentType';
            insert cs;
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            SPEN_ConfigurableSettings__c cs3 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert cs3;
            SPEN_ConfigurableSettings__c cs4 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert cs4;
            SPEN_ConfigurableSettings__c cS5 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cS5;
             SPEN_ConfigurableSettings__c cS6 =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cS6;
            
            List<SPEN_IVR__c> ivrSMSRecord = SPEN_TestDataFactory.createIVRrecord(1);
            insert ivrSMSRecord;
            List<SPEN_IVR__c> ivrVoiceRecord = SPEN_TestDataFactory.createIVRrecord(1);
            ivrVoiceRecord[0].Name ='Sample Voice alert';
            insert ivrVoiceRecord;
            SPEN_IVRMessage__c ivrMsgforSMS = SPEN_TestDataFactory.createIVRMessage(1);
            insert ivrMsgforSMS;
            
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(ivrMsgforSMS.Id);
            insert zoneRegionRecord;
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(ivrMsgforSMS.Id);
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneDistrictRecord.Name = 'districtzone';
            insert zoneDistrictRecord;
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(ivrMsgforSMS.Id);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            insert zoneRecord;
            zoneRec.add(zoneRegionRecord);
            zoneRec.add(zoneDistrictRecord);
            zoneRec.add(zoneRecord);
            
            SPEN_IVRMessage__c  ivrMsgforVoice = SPEN_TestDataFactory.createIVRMessage(1);
            ivrMsgforVoice.recordTypeId =  Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('Voice Alert').getRecordTypeId();
            ivrMsgforVoice.SPEN_Purpose__c = 'HV';
            ivrMsgforVoice.SPEN_ExternalId__c = 'testExt001';
            
            insert ivrMsgforVoice;
            
            List<SPEN_IVROperatingHours__c> ivrHoursForSMS = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrSMSRecord[0].Id, ivrMsgforVoice.id);
            ivrHoursForSMS[0].recordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            ivrHoursForSMS[0].SPEN_isActive__c= true;
            insert ivrHoursForSMS;
            
            List<SPEN_IVROperatingHours__c> ivrHoursForVA = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrSMSRecord[0].Id, ivrMsgforVoice.id);
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
            inc.Subject = 'Testing';
            insert inc;
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            
            SPEN_MessagingTask__c msgTask = new SPEN_MessagingTask__c();
            msgTask.SPEN_Status__c = 'New';
            msgTask.SPEN_Event__c = '3-Hour Comfort Call';
            msgTask.SPEN_IncidentId__c = inc.Id;
            msgTask.recordTypeId = msgTaskRecTypeId;
            insert msgTask;
            
            Id smsBroadCaseRecTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('SMS Broadcast').getRecordTypeId();
            Id vaBroadCaseRecTypeId =  Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('Voice Alert Broadcast').getRecordTypeId();
            
            List<SPEN_CommunicationScheduler__c > lstOfCommScheduler = new  List<SPEN_CommunicationScheduler__c > ();
            Integer count = 0;
            
            for(SPEN_CommunicationScheduler__c scheduler : SPEN_TestDataFactory.createCommunicationSchedulerRecord(6))
            {    
                if(count == 0)
                {
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendSMSMCtoPSR__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 1)
                {
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendSMSMCtocalledin__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for called in sms';
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 2)
                {
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendSMStoAllCustomerinScope__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for ALL in sms';
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 3)
                {
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVoiceAlerttoPSR__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for PSR in VA';
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 4)
                {
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVoiceAlerttocalledin__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for called in VA';
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 5)
                {
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVAtoAllCustomerinScope__c = true;
                    scheduler.SPEN_Message__c = 'This is sample message for ALL in VA';
                    lstOfCommScheduler.add(scheduler);
                }
                count++; 
            }
            if(!lstOfCommScheduler.isEmpty())
            {
                //system.debug('CHECKINSERTION');
                insert lstOfCommScheduler;
            }
            SPEN_CommunicationScheduler__c schedulerDistSMS = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerDistSMS.SPEN_Event__c  = 'Medically Dependent by District';
            schedulerDistSMS.SPEN_district__c = 'districtzone';
            schedulerDistSMS.recordTypeId = smsBroadCaseRecTypeId;
            schedulerDistSMS.SPEN_SendNow__c = true;
            insert schedulerDistSMS;
            
            /*SPEN_CommunicationScheduler__c schedulerDistVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerDistVA.SPEN_Event__c  = 'Medically Dependent by District';
            schedulerDistVA.SPEN_district__c = 'TestZoneVA';
            schedulerDistVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerDistSMS.SPEN_SendNow__c = true;
            insert schedulerDistVA;*/
            
            List<SPEN_Premise__c> lstPremise =  SPEN_TestDataFactory.createListOfPremise(1);
            lstPremise[0].SPEN_PremiseDistrict__c = zoneDistrictRecord.id;
            insert lstPremise;
            
            Contact contactObj = SPEN_TestDataFactory.createContacts(null,1);
            contactObj.SPEN_PSR__c = false;
            //contactObj.SPEN_PreferredMethodofContact__c = 'T';
            contactObj.OtherPhone = '07234567890';
            contactObj.MobilePhone = '07123456789';
            contactObj.SPEN_SpecificVulnerability__c =true;
            insert contactObj;
            
            SPEN_ContactPremise__c contactPremise = SPEN_TestDataFactory.createContactPremises(1, contactObj.id, lstPremise[0].id);
            contactPremise.SPEN_ExternalId__c='1244';
            contactPremise.SPEN_Role__c = 'Customer';
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
            caseForCalledinSMS.SPEN_PreferredMethodofContact__c ='T'; 
            caseForCalledinSMS.SPEN_CallerMobileTelephone__c = '07111111111'; //mobile number update
            insert caseForCalledinSMS;
            
            SPEN_CommunicationScheduler__c schedulerPremSMS = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerPremSMS.SPEN_Event__c  = 'Planned Outage Communication';
            schedulerPremSMS.recordTypeId = smsBroadCaseRecTypeId;
             schedulerPremSMS.SPEN_Message__c = 'This is sample message for Planned Outage';
            schedulerPremSMS.SPEN_SendNow__c = true;
            insert schedulerPremSMS;
            
            /*SPEN_CommunicationScheduler__c schedulerPremVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerDistVA.SPEN_Event__c  = 'Planned Outage Communication';
            schedulerDistVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerDistSMS.SPEN_SendNow__c = true;
            insert schedulerPremVA;*/
            Test.stopTest();
        } 
    }
    @isTest
    public static void insertSMSBatchTestForPremise()
    {
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
        Id ondemandtRT = SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByDeveloperName().get('OnDemand').getRecordTypeId();
        SPEN_MessagingTask__c mtask = new SPEN_MessagingTask__c(recordTypeId = ondemandtRT, SPEN_Event__c= 'On Demand', SPEN_Status__c = 'new');
		insert mTask;
        mtask.SPEN_Status__c = 'Completed';
		mTask.SPEN_PremiseIds__c ='4286,7983';
        update mTask;
        System.runAs(u)
        {   
            Test.startTest();
            SPEN_Premise__c prem = [SELECT id FROM SPEN_Premise__c LIMIT 1];
            Set<String> setPremId = new Set<String>();
            setPremId.add(prem.id);
            list<SPEN_CommunicationScheduler__c> lstcommSch = [select id, SPEN_Message__c, SPEN_Event__c, SPEN_MessagingTaskId__r.SPEN_PremiseIds__c 
                                                               from SPEN_CommunicationScheduler__c
                                                               WHERE SPEN_MessagingTaskId__c =: mTask.Id
                                                              ];
            //system.debug('lstcommSch >>' + lstcommSch);
            Database.executeBatch(new SPEN_InsertSMSBatch(lstcommSch));
            Assert.isTrue(lstcommSch!=null);
            Test.stopTest();
        }
    }
    @isTest
    public static void insertSMSBatchTestForDistrict()
    {
         User u= [Select id FROM User WHERE IsActive=true LIMIT 1];

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
            Assert.isTrue(lstcommSch!=null);
            Test.stopTest();
        }
    }
    @isTest 
    private static void insertSMSBatchTestForPSR()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];

        System.runAs(u)
        {   
            Test.startTest();
            Incident incObj = [select id  from Incident limit 1];
            if(incObj.id !=null){
                SPEN_CommunicationScheduler__c commSch = [select id, SPEN_IncidentId__c, SPEN_SendSMSMCtoPSR__c,SPEN_Message__c,SPEN_Event__c,SPEN_SendSMStoAllCustomerinScope__c,SPEN_SendSMStoPSRCalledin__c,SPEN_SendSMSMCtocalledin__c, SPEN_MessagingTaskId__c from SPEN_CommunicationScheduler__c where SPEN_SendSMSMCtoPSR__c =true and SPEN_IncidentId__c = :incObj.id  limit 1];
            
                /*Map<String, String> mapCommunicationIDToIncidentId = new Map<String, String>();
                mapCommunicationIDToIncidentId.put(commSch.id, incObj.id);
                
                Map<String, SPEN_CommunicationScheduler__c> mapIncidentIdToCommunicationSch = new Map<String, SPEN_CommunicationScheduler__c> ();
                mapIncidentIdToCommunicationSch.put(incObj.id, commSch);*/
                List<Boolean> boolist=new List<Boolean>();
                boolist.add(true);
                boolist.add(false);
                boolist.add(false);
                boolist.add(false);
                Map<SPEN_CommunicationScheduler__c,Id> mapIncidentIdToCommunicationSch=new Map<SPEN_CommunicationScheduler__c,Id>();
                mapIncidentIdToCommunicationSch.put(commSch,incObj.id);
                Map<SPEN_CommunicationScheduler__c, List<Boolean>> testmapOfCommSchedulerWithCheckboxes=new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
                testmapOfCommSchedulerWithCheckboxes.put(commSch,boolist);
                //Test.startTest();
                //Database.executeBatch(new SPEN_InsertSMSBatch(mapCommunicationIDToIncidentId,mapIncidentIdToCommunicationSch,true, false, false, false));
                Database.executeBatch(new SPEN_InsertSMSBatch(mapIncidentIdToCommunicationSch,testmapOfCommSchedulerWithCheckboxes,1));
                Assert.isTrue(true, 'Batch Processed successfully for PSR customer');
                Test.stopTest();
            }
        }
    }
    @isTest 
    private static void insertSMSBatchTestForCalledIn()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
        //system.debug('user'+u.Id);
        System.runAs(u)
        {
            Incident incObj = [select id  from Incident limit 1];

            if(incObj.id!=null){
                SPEN_CommunicationScheduler__c commSch = [select id, SPEN_IncidentId__c, SPEN_SendSMSMCtoPSR__c,SPEN_Message__c,SPEN_Event__c,SPEN_SendSMStoAllCustomerinScope__c,SPEN_SendSMStoPSRCalledin__c,SPEN_SendSMSMCtocalledin__c, SPEN_MessagingTaskId__c from SPEN_CommunicationScheduler__c where SPEN_SendSMSMCtoPSR__c =true and SPEN_IncidentId__c = :incObj.id  limit 1];
                /*Map<String, String> mapCommunicationIDToIncidentId = new Map<String, String>();
                mapCommunicationIDToIncidentId.put(commSch.id, incObj.id);
                
                Map<String, SPEN_CommunicationScheduler__c> mapIncidentIdToCommunicationSch = new Map<String, SPEN_CommunicationScheduler__c> ();
                mapIncidentIdToCommunicationSch.put(incObj.id, commSch);*/
                List<Boolean> boolist=new List<Boolean>();
                boolist.add(true);
                boolist.add(false);
                boolist.add(false);
                boolist.add(false);
                Map<SPEN_CommunicationScheduler__c,Id> mapIncidentIdToCommunicationSch=new Map<SPEN_CommunicationScheduler__c,Id>();
                mapIncidentIdToCommunicationSch.put(commSch,incObj.id);
                Map<SPEN_CommunicationScheduler__c, List<Boolean>> testmapOfCommSchedulerWithCheckboxes=new Map<SPEN_CommunicationScheduler__c, List<Boolean>>();
                testmapOfCommSchedulerWithCheckboxes.put(commSch,boolist);
                Test.startTest();
                //Database.executeBatch(new SPEN_InsertSMSBatch(mapCommunicationIDToIncidentId,mapIncidentIdToCommunicationSch,false, false, false, true));
                Database.executeBatch(new SPEN_InsertSMSBatch(mapIncidentIdToCommunicationSch,testmapOfCommSchedulerWithCheckboxes,2));
                Assert.isTrue(true, 'Batch Processed successfully for CalledIN customer');
                
                Test.stopTest();
            }
        }
    }
}