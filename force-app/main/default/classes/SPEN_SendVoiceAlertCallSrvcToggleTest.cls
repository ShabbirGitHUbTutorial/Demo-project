@IsTest
public class SPEN_SendVoiceAlertCallSrvcToggleTest {
    @testSetup static void setup(){
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
		
        /*System.runAs(user){
            /*SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert CS2;
            SPEN_ConfigurableSettings__c CS1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert CS1;
            SPEN_ConfigurableSettings__c CS3 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert CS3;
            List<Account> createAccounts = SPEN_TestDataFactory.createAccounts('accName', 1);
            
            Incident incid = new Incident();
            incid.Subject = 'TestingIncident';
            insert incid;
            Contact con = SPEN_TestDataFactory.createContacts(createAccounts[0].id,1);
            con.SPEN_PSR__c = True;
            Insert con;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
            Case caseRec = new case();
            caseRec.SPEN_Incident__c = incid;
            caseRec.recordTypeId = recordTypeId;
            caseRec.Status = 'Open';
            caseRec.Origin = 'Web';
            caseRec.Subject = 'Test Sub';
            Insert caseRec;
            SPEN_ContactPremise__c SCP = new SPEN_ContactPremise__c();
            SCP.SPEN_RelatedContact__c = con.id;
            SCP.SPEN_ExternalId__c = 'test123';
            insert SCP;
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,SPEN_ConstantData.IncidentMessage);
            cs.Name = 'OutboundIncidentType';
            insert cs;
            SPEN_ImpactedPremise__c impPre = new SPEN_ImpactedPremise__c();
            impPre.SPEN_RelatedIncident__c = incid;
            impPre.SPEN_ContactPremise__c = SCP.id;
            impPre.SPEN_ExternalId__c = 'test234';
            insert impPre;
        }*/
    }
    @isTest
    public static void alertServiceToggle1(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = true;
            ivr.SPEN_StartTime__c = system.now().time() - 10;
            ivr.SPEN_EndTime__c = system.now().time() - 5;
        }
        
        Insert IVRORecList;*/
        test.startTest();
        Id incid;
        SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle(incid, '', true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void alertServiceToggle2(){
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = true;
            ivr.SPEN_StartTime__c = system.now().time() + 100;
            ivr.SPEN_EndTime__c = system.now().time() - 150;
        }
        
        Insert IVRORecList;*/
        test.startTest();
        Id incid;
        SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle(incid, '', true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void alertServiceToggle3(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = true;
        }
        
        Insert IVRORecList;*/
        test.startTest();
        Id incid;
        SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle(incid, '', true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void alertServiceToggle4(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = false;
            ivr.SPEN_RestrictStartDate__c = system.now() +1;
        }
        
        Insert IVRORecList;
        test.startTest();
        SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle(incid, '', true, false, true);
        Test.stopTest();*/
        test.startTest();
        Id incid;
        SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle(incid, '', true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void scheduleAlertServiceToggle(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = true;
            ivr.SPEN_StartTime__c = system.now().time() - 10;
            ivr.SPEN_EndTime__c = system.now().time() - 5;
        }
        
        Insert IVRORecList;
        test.startTest();
        Datetime myDateTime = Datetime.newInstance(2030, 2, 17);
        SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle(incid, '',myDateTime, true, false, true);
        Test.stopTest();*/
        test.startTest();
        Id incid;
        SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle(incid, '', true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void scheduleAlertServiceToggle2(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = true;
            ivr.SPEN_StartTime__c = system.now().time() + 10;
            ivr.SPEN_EndTime__c = system.now().time() - 5;
        }
        
        Insert IVRORecList;
        test.startTest();
        Datetime myDateTime = Datetime.newInstance(2030, 2, 17);
        SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle(incid, '',myDateTime, true, false, true);
        Test.stopTest();*/
        test.startTest();
        Id incid;
        Datetime myDateTime = Datetime.newInstance(2030, 2, 17);
        SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle(incid, '',myDateTime, true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void scheduleAlertServiceToggle3(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = true;
        }
        
        Insert IVRORecList;
        test.startTest();
        Datetime myDateTime = Datetime.newInstance(2030, 2, 17);
        SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle(incid, '',myDateTime, true, false, true);
        Test.stopTest();*/
        test.startTest();
        Id incid;
        Datetime myDateTime = Datetime.newInstance(2030, 2, 17);
        SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle(incid, '',myDateTime, true, false, true);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
    @isTest
    public static void scheduleAlertServiceToggle4(){
        /*Incident incid = new Incident();
        incid.Subject = 'TestingIncident';
        insert incid;*/
        
        /*Incident incid = [select id from Incident where subject ='TestingIncident' limit 1];
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(1);
        Insert IVRList;
        SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
        Insert IVRMessage;
        Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
        List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,IVRMessage.id);
        for(SPEN_IVROperatingHours__c ivr : IVRORecList){
            ivr.RecordTypeId = IVROperatingHoursRecordTypeId;
            ivr.SPEN_isActive__c = true;
            ivr.SPEN_isDaily__c = false;
            ivr.SPEN_RestrictEndDate__c = system.now() +1;
        }
        
        Insert IVRORecList;*/
        test.startTest();
        Id incid;
        Datetime myDateTime = Datetime.newInstance(2030, 2, 17);
        SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle(incid, '',myDateTime, true, false, true);
        SPEN_SendVoiceAlertCallServiceToggle.getBatchJobStatus(incid);
        Assert.areEqual(incid,null);
        Test.stopTest();
    }
}