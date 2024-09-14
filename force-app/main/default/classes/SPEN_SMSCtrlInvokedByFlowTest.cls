/**
 * @description       : Test class for SPEN_SMSCtrlInvokedByFlow
 * @author            : rahul.dd.kumar@accenture.com
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : rahul.dd.kumar@accenture.com
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount,PMD.SOQLSelectorPattern')
@IsTest(SeeAllData=false)
public class SPEN_SMSCtrlInvokedByFlowTest {
 	@testSetup 
    static void dataSetup() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet impactedPremiseps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = impactedPremiseps.Id);
        System.runAs(user)
        {
            Test.startTest();
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
            
           
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_IVR__c> ivrSMSRecord = SPEN_TestDataFactory.createIVRrecord(1);
            insert ivrSMSRecord;
            List<SPEN_IVR__c> ivrVoiceRecord = SPEN_TestDataFactory.createIVRrecord(1);
            ivrVoiceRecord[0].Name ='Sample Voice alert';
            insert ivrVoiceRecord;
            SPEN_IVRMessage__c ivrMsgforSMS = SPEN_TestDataFactory.createIVRMessage(1);
            insert ivrMsgforSMS;

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
        inc.SPEN_IncidentType__c = 'HV_N';
        inc.Subject = 'Testing';
        insert inc;
        Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            
        SPEN_MessagingTask__c msgTask = new SPEN_MessagingTask__c();
        msgTask.SPEN_Status__c = 'New';
        msgTask.SPEN_Event__c = '3-Hour Comfort Call';
        msgTask.SPEN_IncidentId__c = inc.Id;
        msgTask.recordTypeId = msgTaskRecTypeId;
        // msgTask.SPEN_TotalMessagingTaskPresent__c = 1;
       	insert msgTask;
		List<SPEN_Premise__c> lstPrem = SPEN_TestDataFactory.createPremiseRecord('TestPremise','Premise',2);
            insert lstPrem;
          Id smsBroadCaseRecTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('SMS Broadcast').getRecordTypeId();
          Id vaBroadCaseRecTypeId =  Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('Voice Alert Broadcast').getRecordTypeId();

           List<SPEN_CommunicationScheduler__c > lstOfCommScheduler = new  List<SPEN_CommunicationScheduler__c > ();
           Integer count = 0;
        
            for(SPEN_CommunicationScheduler__c scheduler : SPEN_TestDataFactory.createCommunicationSchedulerRecord(6)){
                
                if(count == 0){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendSMSMCtoPSR__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 1){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendSMSMCtocalledin__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 2){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendSMStoAllCustomerinScope__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 3){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVoiceAlerttoPSR__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 4){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = smsBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVoiceAlerttocalledin__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                if(count == 5){
                    scheduler.SPEN_Event__c = '3-Hour Comfort Call';
                    scheduler.SPEN_IncidentId__c = inc.id;
                    scheduler.SPEN_MessagingTaskId__c = msgTask.id;
                    scheduler.recordTypeId = vaBroadCaseRecTypeId;
                    scheduler.SPEN_SendNow__c = true;
                    scheduler.SPEN_SendVAtoAllCustomerinScope__c = true;
                    lstOfCommScheduler.add(scheduler);
                }
                count++;
                
            }
            if(!lstOfCommScheduler.isEmpty()){
                try{
                  insert lstOfCommScheduler;  
                    //System.debug('line 14000');
                } 
                catch(Exception e){
                   
                    //System.debug('exception messss==='+e.getMessage()+' get line number===='+e.getLineNumber());
                     //throw e;
                    SEL_LoggingService.log(e);
                }
            }
            SPEN_CommunicationScheduler__c schedulerDistSMS = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerDistSMS.SPEN_Event__c  = 'Medically Dependent by District';
            schedulerDistSMS.SPEN_district__c = 'TestZone';
            schedulerDistSMS.recordTypeId = smsBroadCaseRecTypeId;
            schedulerDistSMS.SPEN_SendNow__c = true;
            insert schedulerDistSMS;
            SPEN_CommunicationScheduler__c schedulerDistVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerDistVA.SPEN_Event__c  = 'Medically Dependent by District';
            schedulerDistVA.SPEN_district__c = 'TestZoneVA';
            schedulerDistVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerDistSMS.SPEN_SendNow__c = true;
            insert schedulerDistVA;
            
            SPEN_CommunicationScheduler__c schedulerPremSMS = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerPremSMS.SPEN_Event__c  = 'Planned Outage Communication';
            schedulerPremSMS.recordTypeId = smsBroadCaseRecTypeId;
            schedulerPremSMS.SPEN_SendNow__c = true;
            schedulerPremSMS.SPEN_PremiseQuery__c = ' Name != null';
            insert schedulerPremSMS;
            
            SPEN_CommunicationScheduler__c schedulerPremVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerPremVA.SPEN_Event__c  = 'Planned Outage Communication';
            schedulerPremVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerPremVA.SPEN_SendNow__c = true;
            schedulerPremVA.SPEN_PremiseQuery__c = ' Name != null';
            insert schedulerPremVA;
            
            Id onDemandMsgTaskId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('OnDemand').getRecordTypeId();
            SPEN_MessagingTask__c msgTask2 = new SPEN_MessagingTask__c();
            msgTask2.SPEN_Status__c = 'New';
            msgTask2.SPEN_Event__c = 'On Demand';
            msgTask2.recordTypeId = onDemandMsgTaskId;
            msgTask2.SPEN_PremiseIds__c = lstPrem[0].id;
            insert msgTask2;
            
            SPEN_CommunicationScheduler__c schedulerOnDemandSMS = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerOnDemandSMS.SPEN_Event__c  = 'On Demand';
            schedulerOnDemandSMS.recordTypeId = smsBroadCaseRecTypeId;
            schedulerOnDemandSMS.SPEN_MessagingTaskId__c = msgTask2.id;
            schedulerOnDemandSMS.SPEN_SendNow__c = true;
            insert schedulerOnDemandSMS;
            
            SPEN_CommunicationScheduler__c schedulerOnDemandVA = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            schedulerOnDemandVA.SPEN_Event__c  = 'On Demand';
            schedulerOnDemandVA.recordTypeId = vaBroadCaseRecTypeId;
            schedulerOnDemandVA.SPEN_SendNow__c = true;
             schedulerOnDemandVA.SPEN_MessagingTaskId__c = msgTask2.id;
            insert schedulerOnDemandVA;
            Test.stopTest();
        }
    
    }
    @isTest
    private static void testCheckBlackoutWindowPeriodForStartEndAsBlank()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
            Boolean isOptoutForSMS = SPEN_SMSCtrlInvokedByFlow.checkBlackoutWindowPeriod('SMS Blackout Window');
            System.assertEquals(true, isOptoutForSMS, 'This window period allows to send sms');
            Boolean isOptoutForVA = SPEN_SMSCtrlInvokedByFlow.checkBlackoutWindowPeriod('VA Blackout Window');
            System.assertEquals(true, isOptoutForVA, 'This window period allows to send VA');
        }
    }
    
    @isTest
    private static void testCheckBlackoutWindowPeriodForStartEndTime()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
        SPEN_IVROperatingHours__c lstIvrHour = [select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordType.Name = 'SMS Blackout WIndow' and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
        lstIvrHour.SPEN_StartTime__c = System.now().addHours(-2).time();
        lstIvrHour.SPEN_EndTime__c = System.now().addHours(-1).time();
        update lstIvrHour;
         Boolean isOptoutForSMS = SPEN_SMSCtrlInvokedByFlow.checkBlackoutWindowPeriod('SMS Blackout Window');
         System.assertEquals(true, isOptoutForSMS, 'This window period allows to send sms');
        }
    }
    
    @isTest
    private static void testCheckBlackoutWindowPeriodForEndStartTime()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
        SPEN_IVROperatingHours__c lstIvrHour = [select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordType.Name = 'SMS Blackout WIndow' and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
        lstIvrHour.SPEN_StartTime__c = System.now().addHours(10).time();
        lstIvrHour.SPEN_EndTime__c = System.now().addHours(12).time();
        update lstIvrHour;
         Boolean isOptoutForSMS = SPEN_SMSCtrlInvokedByFlow.checkBlackoutWindowPeriod('SMS Blackout Window');
         System.assertEquals(true, isOptoutForSMS, 'This window period allows to send sms');
        }
    }
    
    @isTest
    private static void testCallBatchApexFromFlow()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_SendSMSMCtoPSR__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_SendSMSMCtoPSR__c = true limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for sms psr');
            Test.stopTest();
        }
    }
    @isTest
    private static void testCallBatchApexFromFlow2()
    {
       	//User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_SendSMSMCtocalledin__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_SendSMSMCtocalledin__c = true limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for sms called in');
            Test.stopTest();
        }
    }
    @isTest
    private static void testCallBatchApexFromFlow3()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_SendSMStoAllCustomerinScope__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_SendSMStoAllCustomerinScope__c = true limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for sms All customer');
            Test.stopTest();
        }
    }
     @isTest
    private static void testCallBatchApexFromFlow4()
    {
       	//User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_SendVoiceAlerttoPSR__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_SendVoiceAlerttoPSR__c = true limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for VA PSR customer');
            Test.stopTest();
        }
    }
     @isTest
    private static void testCallBatchApexFromFlow5()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_SendVoiceAlerttocalledin__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_SendVoiceAlerttocalledin__c = true limit 1];
                                                      
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for VA Called in customer');
            Test.stopTest();
        }
    }
   
     @isTest
    private static void testCallBatchApexFromFlow6()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_SendVAtoAllCustomerinScope__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_SendVAtoAllCustomerinScope__c = true limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for VA All customer');
            Test.stopTest();
        }
    }
    @isTest
    private static void testCallBatchApexFromFlow7()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_District__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_District__c = 'TestZone' limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for District level SMS customer');
            Test.stopTest();
        }
    }
   
    @isTest
    private static void testCallBatchApexFromFlow8()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            SPEN_CommunicationScheduler__c commSch = [select id,SPEN_District__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_District__c = 'TestZoneVA' limit 1];
            Test.startTest();
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(new List<Id>{commSch.id});
            System.assert(true, 'Flow executed for District level VA customer');
            Test.stopTest();
        }
    }
    @isTest
    private static void testCallBatchApexFromFlow9()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            List<SPEN_CommunicationScheduler__c> commSch = [select id,SPEN_PremiseQuery__c,SPEN_Event__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_Event__c = 'Planned Outage Communication'];
            Test.startTest();
            List<id> lstId = new List<Id>();
            for(SPEN_CommunicationScheduler__c comm: commSch){
                lstId.add(comm.id);
            }
                //lstId.add(comm.id);
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(lstId);
            System.assert(true, 'Flow executed for District level VA customer');
            Test.stopTest();
        }
    }
       @isTest
    private static void testCallBatchApexFromFlow10()
    {
        //User u = [select id, name,Lastname, email, username from user where email='test@gmail.com' and Lastname ='TESTLASTNAME' and Profile.name ='System Administrator' limit 1];
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            List<SPEN_CommunicationScheduler__c> commSch = [select id,SPEN_PremiseQuery__c,SPEN_Event__c from  SPEN_CommunicationScheduler__c
                                                      where SPEN_Event__c = 'On Demand'];
            Test.startTest();
            List<id> lstId = new List<Id>();
            for(SPEN_CommunicationScheduler__c comm: commSch){
                lstId.add(comm.id);
            }
                //lstId.add(comm.id);
            SPEN_SMSCtrlInvokedByFlow.callBatchApexFromFlow(lstId);
            System.assert(true, 'Flow executed for District level VA customer');
            Test.stopTest();
        }
    }
}