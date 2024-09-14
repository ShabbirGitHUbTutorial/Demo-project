@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_MessagingTaskService_Test {
    @IsTest
    private static void testMessagingTask()
    {
        Test.startTest();
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id); 
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MessagingTaskCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        System.runAs(user)
        {
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            SPEN_ConfigurableSettings__c cS4 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert cS4;
            SPEN_ConfigurableSettings__c cS5 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cS5;
             SPEN_ConfigurableSettings__c cS6 =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cS6;
           
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            //testCase[0].ContactId=con.Id;
            insert testCase;
            
            SPEN_IVRMessage__c ivrMessage = SPEN_TestDataFactory.createIVRMessage(1);
            insert ivrMessage;
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(ivrMessage.Id);
            zoneRegionRecord.Name='North';
            insert zoneRegionRecord;
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(ivrMessage.Id);
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            insert zoneDistrictRecord;
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(ivrMessage.Id);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            //zoneRecord.SPEN_Parent__r.name='North';
            insert zoneRecord;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            //inc.SPEN_IncidentType__c='SP';
            inc.SPEN_Zone__c=zoneRecord.id;
            insert inc;
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            List<SPEN_MessagingTask__c> messList=SPEN_TestDataFactory.createMessagingTask(SPEN_TestDataFactoryConstants.SINGLE_REC);
            messList[0].SPEN_IncidentId__c=inc.Id;
            messList[0].recordTypeId = msgTaskRecTypeId;
            Id msgRecordTypeId = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get(SPEN_TestDataFactoryConstants.MESSAGINGTASK_RECORDTYPE).getRecordTypeId();
            insert messList;
            SPEN_MessagingTaskService task=new SPEN_MessagingTaskService();
            task.createMessagingTask('3-Hour Comfort Call',inc.Id,msgRecordTypeId,user.Id,'New');
            task.createMessagingTaskIncCreated('3-Hour Comfort Call',inc.Id,msgRecordTypeId,'Test_Zone','New');
            Assert.isNotNull(task, 'Assertion Passed');
            Test.stopTest();
        }
    }
}