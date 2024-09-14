@IsTest(seeAllData = false)
private class MessagingTaskTrigger_TEST {
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user){
            Test.startTest();
            List<SPEN_ConfigurableSettings__c> csList=new List<SPEN_ConfigurableSettings__c>();
            SPEN_ConfigurableSettings__c cS =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            csList.add(cS);
            SPEN_ConfigurableSettings__c cS1 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            csList.add(cS1);
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            csList.add(cS2);
            SPEN_ConfigurableSettings__c cS3 =SPEN_TestDataFactory.createConfigSetting(1,'HV Incident Message');
            csList.add(cS3);
            SPEN_ConfigurableSettings__c cS4 =SPEN_TestDataFactory.createConfigSetting(1,'GetAffectedPremiseINCType');
            cS4.SPEN_Value__c = 'HV_N,HV_S,LV';
            cS4.SPEN_Description__c ='config setting description';
            SPEN_ConfigurableSettings__c cs7 =SPEN_TestDataFactory.createConfigSetting(1,'OutageChangeDelay');
            csList.add(cS4);
            csList.add(cS7);
            insert csList;
            
            Integer threshold = Integer.valueOf(cS.SPEN_Value__c);
            Datetime dateThreshHold = system.now().addHours(-threshold);            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
    
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            insert zoneRegionRecord;
    
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneDistrictRecord.Name = 'districtzone';
            insert zoneDistrictRecord;
          
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = '0hbjdgfyj';
            incdnt.SPEN_IncidentType__c = 'HV_N';
            incdnt.SPEN_IncidentReference__c = 'TEST5044AB';
            incdnt.SPEN_Outage_State__c ='Confirmed';
            incdnt.recordtypeId = recTypeId;
            insert incdnt;
            Test.stopTest();
        }
    }
	@isTest
    static void testMessagingTaskRecord(){
        Id incId = [Select Id from Incident][0].Id;
        SPEN_MessagingTask__c mTask = new SPEN_MessagingTask__c(SPEN_Event__c = SPEN_ConstantData.ONDEMAND, SPEN_Status__c = 'new', SPEN_Category__c ='3rd Call Received',SPEN_IncidentId__c =incId );
        insert mTask;
        Test.startTest();
        mTask.SPEN_Status__c = 'Completed';
        update mTask;
        Assert.areEqual(mTask.SPEN_Status__c, 'Completed','Messaging task Successfully completed');
        Test.stopTest();
    }
    @isTest
    static void testMessagingTaskError(){
        SPEN_MessagingTask__c mTask = new SPEN_MessagingTask__c(SPEN_Event__c = SPEN_ConstantData.ONDEMAND, SPEN_Status__c = 'Completed', SPEN_Category__c ='3rd Call Received');
        insert mTask;
        Test.startTest();
        mTask.SPEN_Status__c = 'new';
        try{
            update mTask; 
        }catch(Exception ex){
            ex.getMessage();
        }
       
        Test.stopTest();
    }
}