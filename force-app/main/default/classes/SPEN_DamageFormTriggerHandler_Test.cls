@isTest
public class SPEN_DamageFormTriggerHandler_Test {
    @isTest 
    public static void creat3PDCaseTest4() 
    {
        //Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        //User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        //Database.insert(user); 
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);	
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign; 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_DamageFormStagingCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseInformationCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        System.runAs(user){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
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
            csList.add(cS4);
            insert csList;

            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;

            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            zoneRec.add(zoneRecord);
            insert zoneRec;

            Id recordTypeIdIncident = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('SPEN_SPENIncident').getRecordTypeId();
            Incident inc = new Incident();
            inc.Subject='Test Subject';
            inc.SPEN_IncidentReference__c='INCD-434014-r';
            inc.RecordTypeId=recordTypeIdIncident;
            insert inc;

            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            Case ThreePDCase =new Case();
            ThreePDCase.SPEN_Incident__c = inc.id;
            //ThreePDCase.SPEN_IncidentRefFormula__c = inc.SPEN_IncidentReference__c;
            ThreePDCase.Status ='Created';
            ThreePDCase.Priority='Medium';
            ThreePDCase.RecordTypeId = recordTypeId3PD;
            insert ThreePDCase;

            SPEN_DamageFormStaging__c dform = new SPEN_DamageFormStaging__c();
            dform.Name = 'Test Form';
            dform.SPEN_DateofIncident__c = System.today()+1;
            dform.SPEN_Incident_Number__c = inc.SPEN_IncidentReference__c;
            dform.SPEN_Photos_Missing__c = true;
            insert dform;

             //Added to cover blocks in interface class
             dform.SPEN_LocationofDamage__c = 'Test';
             update dform;
             SPEN_DamageFormTriggerInterface obj = new SPEN_DamageFormTriggerInterface(); 
             Map<Id, sObject> deleteMap = new Map<Id,sObject>();
             deleteMap.put(dform.id,dform);
             obj.beforeDelete(deleteMap);
             obj.afterDelete(deleteMap);
             obj.afterUndelete(deleteMap);
        }
    }

    @isTest
    public static void creat3PDCaseTest2()
    {
        //Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        //User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        //Database.insert(user); 
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);	
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign; 

        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_DamageFormStagingCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseInformationCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
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
            csList.add(cS4);
            insert csList;

            //Integer threshold = Integer.valueOf(cS.SPEN_Value__c);
            //Datetime dateThreshHold = system.now().addHours(-threshold);            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;

            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            zoneRec.add(zoneRecord);
            insert zoneRec;

            Id recordTypeIdIncident = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('SPEN_SPENIncident').getRecordTypeId();
            Incident inc = new Incident();
            inc.Subject='Test Subject';
            inc.SPEN_IncidentReference__c='INCD-434014-r';
            inc.RecordTypeId=recordTypeIdIncident;
            insert inc;

            SPEN_DamageFormStaging__c dform = new SPEN_DamageFormStaging__c();
            dform.Name = 'Test Form';
            dform.SPEN_DateofIncident__c = System.today()+1;
            dform.SPEN_Incident_Number__c = '434014-r';
            dform.SPEN_Photos_Missing__c = true;
           /* dform.SPEN_MaterialDetails__c = '{'+
                '   \"Materials\":[{'+
                '         \"3PDJobCategory\": \"'+'U/G'+'\",'+
                '         \"3PDMaterialCategory\": \"'+'Ducting'+'\",'+
                '         \"3PDMaterial\": \"'+'Service Ducting (per Metre)'+'\",'+
                '         \"3PDQuantity\": \"'+3+'\"'+
                '}'+
                ']'+
                '}';*/
            insert dform;
        }
    }

    @isTest
    public static void creat3PDCaseTest3()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_DamageFormStagingCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        System.runAs(user){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_DamageFormStaging__c dform = new SPEN_DamageFormStaging__c();
            dform.Name = 'Test Form';
            dform.SPEN_DateofIncident__c = System.today()+1;
            dform.SPEN_Incident_Number__c = '-434014-';
            dform.SPEN_Photos_Missing__c = true;
            insert dform;
        }
    }


}