@IsTest
public class SPEN_SendVoiceAlertCallServiceTest
{
    @IsTest
    public static void alertVoiceService()
    {
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
        System.runAs(user){
            /*SPEN_ConfigurableSettings__c CS1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert CS1;
            SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert CS2;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<Id> ids = new List<Id>();
            String vAlertMessage = 'Thanks for contacting';
            datetime dt = system.now()+4;
            
            List<Account> accReclist = SPEN_TestDataFactory.createAccounts('Acc Name',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accReclist;
            Contact conRec = SPEN_TestDataFactory.createContacts(accReclist[0].Id, SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert conRec;
            
            List<SPEN_PSR__c> psrRecList = SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psrRecList[0].SPEN_Contact__c = conRec.Id;
            insert psrRecList;
            
            for(SPEN_PSR__c s : psrRecList)
            {
                ids.add(s.Id);
            }
            
            
            Id recTypeIdOfSchedule = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
            
            //SPEN_IVRMessage__c ivrMsg = new SPEN_IVRMessage__c();
            SPEN_IVRMessage__c ivrMsg = SPEN_TestDataFactory.createIVRMessage(SPEN_TestDataFactoryConstants.SINGLE_REC);
            //ivrMsg.Name = 'TESTMessageRecord';
            ivrMsg.SPEN_IVRMessage__c = 'Thanks for Contacting SPEN';
            insert ivrMsg;
            
            SPEN_IVR__c ivr = new SPEN_IVR__c();
            ivr.Name = 'IVRTEST';
            insert ivr;
            
            List<SPEN_IVROperatingHours__c> ivrList = new List<SPEN_IVROperatingHours__c>();
            
            SPEN_IVROperatingHours__c ivrRec1 = new SPEN_IVROperatingHours__c();
            ivrRec1.SPEN_isActive__c = true;
            ivrRec1.SPEN_isDaily__c = true;
            ivrRec1.SPEN_StartTime__c = system.now().time();
            ivrRec1.SPEN_EndTime__c = system.now().time()+5;
            ivrRec1.RecordTypeId = recTypeIdOfSchedule;
            ivrRec1.SPEN_IVR__c = ivr.Id;
            ivrRec1.SPEN_IVRMessage__c = ivrMsg.Id;
            
            SPEN_IVROperatingHours__c ivrRec2 = new SPEN_IVROperatingHours__c();
            ivrRec2.SPEN_isActive__c = true;
            ivrRec2.SPEN_isDaily__c = true;
            ivrRec2.SPEN_StartTime__c = system.now().time()+10;
            ivrRec2.SPEN_EndTime__c = system.now().time()-1;
            ivrRec2.RecordTypeId = recTypeIdOfSchedule;
            ivrRec2.SPEN_IVR__c = ivr.Id;
            ivrRec2.SPEN_IVRMessage__c = ivrMsg.Id;
            
            ivrList.add(ivrRec2);
            ivrList.add(ivrRec1);
            insert ivrList;*/
            String vAlertMessage = 'Thanks for contacting';
            List<Id> ids = new List<Id>();
            datetime dt = system.now()+4;
            Test.StartTest();
            SPEN_SendVoiceAlertCallService.alertService(ids,vAlertMessage);
            SPEN_SendVoiceAlertCallService.scheduleAlertService(ids,vAlertMessage,dt);
            Assert.isNotNull(vAlertMessage);
            Test.StopTest();
        }
    }
    
    @IsTest
    public static void exceptionCoverage()
    {
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
        System.runAs(user){
            /*SPEN_ConfigurableSettings__c CS1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert CS1;
            SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert CS2;
            List<SPEN_IVROperatingHours__c> ivrList = new List<SPEN_IVROperatingHours__c>();
            insert ivrList;
            List<Id> ids = new List<Id>();
            
            for(SPEN_IVROperatingHours__c ivr : ivrList)
            {
                ids.add(ivr.Id);
            }*/
            String vAlertMessage = 'Thanks for contacting';
            List<Id> ids = new List<Id>();
            Test.StartTest();
            SPEN_SendVoiceAlertCallService.alertService(ids,null);
            Assert.isNotNull(vAlertMessage);
        }
    }
    
    @IsTest
    public static void operationHourscodeCoverage()
    {
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
        System.runAs(user){ 
            /*SPEN_ConfigurableSettings__c CS1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert CS1;
            SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert CS2;
            List<Id> psrIds = new List<Id>();
            List<Sobject> sobjectList;
            String vAlertMessage = 'Thanks for contacting';
            datetime dt = system.now()+4;
            
            Contact con = new Contact(LastName = 'Contact', FirstName ='Sheker', email= 'sheker.kulkacherla@accenture.com');
            //insert con;
            SPEN_Premise__c  pri = new SPEN_Premise__c(SPEN_PremiseID__c = 'TEST', SPEN_PremiseNumber__c ='Prem1', SPEN_PostCode__c ='AK28');
            sobjectList = new List<Sobject>{con,pri};
                insert sobjectList;
            Id recTypeIdOfSchedule = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
            SPEN_PSR__c psr = new SPEN_PSR__c();
            psr.SPEN_Contact__c = con.Id;
            psr.SPEN_Premise__c = pri.Id;
            insert psr;
            
            psrIds.add(psr.Id);
            
            SPEN_IVRMessage__c ivrMsg = new SPEN_IVRMessage__c();
            ivrMsg.Name = 'TESTMessageRecord';
            ivrMsg.SPEN_IVRMessage__c = 'Thanks for Contacting SPEN';
            insert ivrMsg;
            
            SPEN_IVR__c ivr = new SPEN_IVR__c();
            ivr.Name = 'IVRTEST';
            insert ivr;
            
            SPEN_IVROperatingHours__c ivrRec1 = new SPEN_IVROperatingHours__c();
            ivrRec1.SPEN_isActive__c = true;
            ivrRec1.SPEN_isDaily__c = false;
            
            Time expected = Time.newInstance(12, 1, 2, 0);
            ivrRec1.SPEN_RestrictStartDate__c =  System.today().addDays(7);
            ivrRec1.SPEN_RestrictEndDate__c =  System.today().addDays(9);
            ivrRec1.RecordTypeId = recTypeIdOfSchedule;
            ivrRec1.SPEN_IVR__c = ivr.Id;
            ivrRec1.SPEN_IVRMessage__c = ivrMsg.Id;
            System.debug( ivrRec1.SPEN_StartTime__c +'<'+ivrRec1.SPEN_EndTime__c);
            System.debug( ivrRec1.SPEN_EndTime__c +'<'+ivrRec1.SPEN_StartTime__c);
            insert ivrRec1;*/
            Test.startTest();
            List<Id> psrIds = new List<Id>();
            datetime dt = system.now()+4;
            String vAlertMessage = 'Thanks for contacting';
            SPEN_SendVoiceAlertCallService.scheduleAlertService(psrIds, vAlertMessage, dt);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Assert.isNotNull(vAlertMessage);
            Test.stopTest();
        }
    }
    @IsTest
    public static void operationHourscodeCoverage1()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.id;
        insert devOpsAssign;
        System.runAs(user){   
            /*SPEN_ConfigurableSettings__c CS1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert CS1;
            SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert CS2;
            List<Id> psrIds = new List<Id>();
            Id jobId;
            List<Sobject> sobjectList;
            String vAlertMessage = 'Thanks for contacting';
            datetime dt = system.now()+4;
            
            Contact con = new Contact(LastName = 'Contact', FirstName ='Sheker', email= 'sheker.kulkacherla@accenture.com');
            //insert con;
            SPEN_Premise__c  pri = new SPEN_Premise__c(SPEN_PremiseID__c = 'TEST', SPEN_PremiseNumber__c ='Prem1', SPEN_PostCode__c ='AK28');
            sobjectList = new List<Sobject>{con,pri};
                insert sobjectList;
            Id recTypeIdOfSchedule = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
            SPEN_PSR__c psr = new SPEN_PSR__c();
            psr.SPEN_Contact__c = con.Id;
            psr.SPEN_Premise__c = pri.Id;
            insert psr;
            
            psrIds.add(psr.Id);
            
            SPEN_IVRMessage__c ivrMsg = new SPEN_IVRMessage__c();
            ivrMsg.Name = 'TESTMessageRecord';
            ivrMsg.SPEN_IVRMessage__c = 'Thanks for Contacting SPEN';
            insert ivrMsg;
            
            SPEN_IVR__c ivr = new SPEN_IVR__c();
            ivr.Name = 'IVRTEST';
            insert ivr;
            
            SPEN_IVROperatingHours__c ivrRec1 = new SPEN_IVROperatingHours__c();
            ivrRec1.SPEN_isActive__c = true;
            ivrRec1.SPEN_isDaily__c = true;
            Time expected = Time.newInstance(12, 1, 2, 0);
            ivrRec1.SPEN_StartTime__c = system.now().time()+10;
            ivrRec1.SPEN_EndTime__c = system.now().time()-1;
            ivrRec1.RecordTypeId = recTypeIdOfSchedule;
            ivrRec1.SPEN_IVR__c = ivr.Id;
            ivrRec1.SPEN_IVRMessage__c = ivrMsg.Id;
            System.debug( ivrRec1.SPEN_StartTime__c +'<'+ivrRec1.SPEN_EndTime__c);
            System.debug( ivrRec1.SPEN_EndTime__c +'<'+ivrRec1.SPEN_StartTime__c);
            insert ivrRec1;*/
            Test.startTest();
            List<Id> psrIds = new List<Id>();
            datetime dt = system.now()+4;
            String vAlertMessage = 'Thanks for contacting';
            SPEN_SendVoiceAlertCallService.scheduleAlertService(psrIds, vAlertMessage, dt);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            SPEN_SendVoiceAlertCallService.getBatchJobStatus(database.executeBatch(new SPEN_InsertVoiceAlertBatch(psrIds, vAlertMessage, System.now())));
            Assert.isNotNull(vAlertMessage);
            Test.stopTest();
            //SPEN_SendVoiceAlertCallService.getBatchJobStatus(database.executeBatch(new SPEN_InsertVoiceAlertBatch(psrIds, vAlertMessage)));
        }
    }
    @IsTest
    public static void operationHourscodeCoverage2()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.id;
        insert devOpsAssign;
        System.runAs(user){   
            /*SPEN_ConfigurableSettings__c CS1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert CS1;
            SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert CS2;
            List<Id> psrIds = new List<Id>();
            Id jobId;
            List<Sobject> sobjectList;
            String vAlertMessage = 'Thanks for contacting';
            datetime dt = system.now()+4;
            
            Contact con = new Contact(LastName = 'Contact', FirstName ='Sheker', email= 'sheker.kulkacherla@accenture.com');
            //insert con;
            SPEN_Premise__c  pri = new SPEN_Premise__c(SPEN_PremiseID__c = 'TEST', SPEN_PremiseNumber__c ='Prem1', SPEN_PostCode__c ='AK28');
            sobjectList = new List<Sobject>{con,pri};
                insert sobjectList;
            Id recTypeIdOfSchedule = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('Outbound Contact Hours').getRecordTypeId();
            SPEN_PSR__c psr = new SPEN_PSR__c();
            psr.SPEN_Contact__c = con.Id;
            psr.SPEN_Premise__c = pri.Id;
            insert psr;
            
            psrIds.add(psr.Id);
            
            SPEN_IVRMessage__c ivrMsg = new SPEN_IVRMessage__c();
            ivrMsg.Name = 'TESTMessageRecord';
            ivrMsg.SPEN_IVRMessage__c = 'Thanks for Contacting SPEN';
            insert ivrMsg;
            
            SPEN_IVR__c ivr = new SPEN_IVR__c();
            ivr.Name = 'IVRTEST';
            insert ivr;
            
            SPEN_IVROperatingHours__c ivrRec1 = new SPEN_IVROperatingHours__c();
            ivrRec1.SPEN_isActive__c = true;
            ivrRec1.SPEN_isDaily__c = true;
            Time expected = Time.newInstance(12, 1, 2, 0);
            ivrRec1.SPEN_StartTime__c = system.now().time();
            ivrRec1.SPEN_EndTime__c = system.now().time();
            ivrRec1.RecordTypeId = recTypeIdOfSchedule;
            ivrRec1.SPEN_IVR__c = ivr.Id;
            ivrRec1.SPEN_IVRMessage__c = ivrMsg.Id;
            System.debug( ivrRec1.SPEN_StartTime__c +'<'+ivrRec1.SPEN_EndTime__c);
            System.debug( ivrRec1.SPEN_EndTime__c +'<'+ivrRec1.SPEN_StartTime__c);
            insert ivrRec1;*/
            List<Id> psrIds = new List<Id>();
            datetime dt = system.now()+4;
            String vAlertMessage = 'Thanks for contacting';
            Test.startTest();
            SPEN_SendVoiceAlertCallService.scheduleAlertService(psrIds, vAlertMessage, dt);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            SPEN_SendVoiceAlertCallService.getBatchJobStatus(database.executeBatch(new SPEN_InsertVoiceAlertBatch(psrIds, vAlertMessage)));
            Test.stopTest();
            Assert.isNotNull(vAlertMessage);
        }
    }
}