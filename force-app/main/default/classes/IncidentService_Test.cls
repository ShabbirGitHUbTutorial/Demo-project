/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        14/10/2022
* @Description: Test class is on IncidentTriggerHandler class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class IncidentService_Test 
{
   //@testSetUp static void setup() 
   @isTest
    private static void setup()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet caseAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
       insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess.Id);
        PermissionSet caseAccess3PD = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
    	   insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess3PD.Id);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        System.runAs(user)
        {  
                 
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
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            //insert zoneRegionRecord;
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            //zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            //zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            //zoneRecord.SPEN_Parent__r.name='North';
            //insert zoneRecord;
            zoneRec.add(zoneRecord);
            insert zoneRec;
            List<SPEN_Zone__c> updatezoneRec = new List<SPEN_Zone__c>();
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            updatezoneRec.add(zoneDistrictRecord);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            updatezoneRec.add(zoneRecord);
            update updatezoneRec;

            List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id ivrOperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id ivrVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> ivrORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            ivrORecList[0].RecordTypeId = ivrOperatingHoursRecordTypeId;
            ivrORecList[0].SPEN_isActive__c = true;
            ivrORecList[0].SPEN_isDaily__c = true;
            ivrORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            ivrORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert ivrORecList;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_IVROperatingHours__c> vaOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            vaOprHrList[0].RecordTypeId = ivrVARecTypeId;
            vaOprHrList[0].SPEN_isActive__c = true;
            vaOprHrList[0].SPEN_isDaily__c = true;
            vaOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vaOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vaOprHrList;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_OperatingZoneId__c = 'XOXO';
            inc.SPEN_IncidentType__c = 'SP';
            inc.SPEN_IncidentID__c = 'INC001';
            inc.SPEN_Zone__c=zoneRecord.id;
            inc.OwnerId=  UserInfo.getUserId();//grp.Id;
            inc.SPEN_Actual_Time__c = system.now();
            inc.SPEN_IncidentReference__c = 'INCD-1456749-r';
            String logComment = 'X/Y:230493/683210';
            insert inc;
            Map<String,String> incRefIncCoordMap = new Map<String,String>();
            incRefIncCoordMap.put(inc.SPEN_IncidentReference__c,logComment);
            Map<String,DateTime> incRefActualMap = new Map<String,DateTime>();
            incRefActualMap.put(inc.SPEN_IncidentReference__c,inc.SPEN_Actual_Time__c);
            Incidents.createNRSWACase(incRefIncCoordMap,incRefActualMap);
            
            testCase[0].SPEN_Incident__c = inc.id;
            testCase[0].SPEN_PreferredMethodofContact__c = 'T';
            testCase[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            testCase[0].SPEN_AdditionalCaller__c = true;
            update testCase;
      SPEN_IntegrationRequest__c intReqRecord = new SPEN_IntegrationRequest__c();
            intReqRecord.SPEN_RelatedRecord__c = inc.id;
            insert intReqRecord;         
            Test.startTest();          
            inc.SPEN_IVRMessage__c = 'IVR Message to be played';
            inc.SPEN_IncidentStatus__c='Delog';
            inc.SPEN_IsRecordViewed__c = TRUE;
            inc.SPEN_IncidentType__c = 'HV_N';
            inc.SPEN_HVIncidentMessage__c = cS4.SPEN_Description__c;
            update inc;
            
            //List<SPEN_MessagingTask__c> msgTask=SPEN_TestDataFactory.createMessagingTaskforIncCreated(1);
            List<Case> testCase2 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase2;
            Incident inc2 = SPEN_TestDataFactory.createIncidents(testCase2[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc2.SPEN_IncidentType__c = 'SP';
            inc2.SPEN_IncidentID__c = 'INC002';
            inc2.SPEN_IsRecordViewed__c = FALSE;
            inc2.OwnerId=user.Id;
            inc2.SPEN_Zone__c=zoneRecord.id;
            insert inc2;
            
            testCase2[0].SPEN_PreferredMethodofContact__c = 'H';
            testCase2[0].SPEN_CallerTelephone__c = '+448888334455';
            testCase2[0].SPEN_CallerMobileTelephone__c = null;
            testCase2[0].SPEN_Incident__c = inc2.id;
            testCase2[0].SPEN_AdditionalCaller__c = true;
            update testCase2[0];
            inc2.SPEN_IncidentType__c = 'HV_N';
            //update inc2;
            
            List<Case> testCase3 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase3;
            Incident inc3 = SPEN_TestDataFactory.createIncidents(testCase2[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc3.SPEN_IncidentType__c = 'SP';
            inc3.SPEN_IncidentID__c = 'INC00876543';
            inc3.OwnerId=user.Id;
            inc3.SPEN_IncidentCategory__c='ESOD';
            inc3.SPEN_HVIncidentMessage__c=NULL;
            inc3.SPEN_Zone__c=zoneRecord.id;
            insert inc3;
           
            
            List<Incident> incList = new List<Incident>();
            incList.add(inc);
            incList.add(inc2);
            incList.add(inc3);
             inc2.SubCategory = 'Third Party Damage';
             inc2.SPEN_IsRecordViewed__c = FALSE;
             update inc2;
            Test.stopTest();
            testCase[0].SPEN_Incident__c = null;
            update testCase[0];
            SPEN_Incident_to_case_status_mapping__mdt itcmdt = new SPEN_Incident_to_case_status_mapping__mdt( SPEN_IncidentStatus__c = 'Cancelled', SPEN_CaseStatus__c = 'Cancelled');
            testCase[0].status = itcmdt.SPEN_CaseStatus__c;
            //Update testCase[0];
            
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            List<SPEN_MessagingTask__c> messList=SPEN_TestDataFactory.createMessagingTask(SPEN_TestDataFactoryConstants.SINGLE_REC);
            messList[0].SPEN_IncidentId__c=inc.Id;
            messList[0].recordTypeId = msgTaskRecTypeId;
            Id msgRecordTypeId1 = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get(SPEN_TestDataFactoryConstants.MESSAGINGTASK_RECORDTYPE).getRecordTypeId();
            insert messList;
            
            SPEN_MessagingTaskService task=new SPEN_MessagingTaskService();
            task.createMessagingTask('Dropped Supply with Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            task.createMessagingTask('Dropped Supply without Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            
            IncidentService.getOutageTimeInModValue(Integer.valueOf(cS.SPEN_Value__c));
      	    Incidents.caseClosedStatus(testCase,inc2);
            IncidentService.assignHVIncidentMsg(incList,new Map<Id,Incident>());
            IncidentService incSer = new IncidentService();
            incSer.compareStatusOfIncident(incList);
            
            //Assert.areEqual(testCase[0].status,'Cancelled','Status Value');
            //Test.stopTest();
             
            
        }
    }
    @isTest
     private static void setup1()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet caseAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
       insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess.Id);
        PermissionSet caseAccess3PD = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
    	   insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess3PD.Id);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        System.runAs(user)
        {  
                 
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
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            //insert zoneRegionRecord;
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            //zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            //zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            //zoneRecord.SPEN_Parent__r.name='North';
            //insert zoneRecord;
            zoneRec.add(zoneRecord);
            insert zoneRec;
            List<SPEN_Zone__c> updatezoneRec = new List<SPEN_Zone__c>();
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            updatezoneRec.add(zoneDistrictRecord);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            updatezoneRec.add(zoneRecord);
            update updatezoneRec;

            List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id ivrOperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id ivrVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> ivrORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            ivrORecList[0].RecordTypeId = ivrOperatingHoursRecordTypeId;
            ivrORecList[0].SPEN_isActive__c = true;
            ivrORecList[0].SPEN_isDaily__c = true;
            ivrORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            ivrORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert ivrORecList;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_IVROperatingHours__c> vaOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            vaOprHrList[0].RecordTypeId = ivrVARecTypeId;
            vaOprHrList[0].SPEN_isActive__c = true;
            vaOprHrList[0].SPEN_isDaily__c = true;
            vaOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vaOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vaOprHrList;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_OperatingZoneId__c = 'XOXO';
            inc.SPEN_IncidentType__c = 'SP';
            inc.SPEN_IncidentID__c = 'INC001';
            inc.SPEN_Zone__c=zoneRecord.id;
            inc.OwnerId=  UserInfo.getUserId();//grp.Id;
             inc.SPEN_droppedsupply__c = false;
            insert inc;
            testCase[0].SPEN_Incident__c = inc.id;
            testCase[0].SPEN_PreferredMethodofContact__c = 'T';
            testCase[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            testCase[0].SPEN_AdditionalCaller__c = true;
            update testCase;
      SPEN_IntegrationRequest__c intReqRecord = new SPEN_IntegrationRequest__c();
            intReqRecord.SPEN_RelatedRecord__c = inc.id;
            insert intReqRecord;         
            Test.startTest();          
            inc.SPEN_IVRMessage__c = 'IVR Message to be played';
            inc.SPEN_IncidentStatus__c='Merged';
            inc.SPEN_IsRecordViewed__c = FALSE;
            inc.SPEN_IncidentType__c = 'HV_N';
            inc.SPEN_HVIncidentMessage__c = NULL;
            inc.SPEN_IncidentCategory__c='ESOD';
            inc.SPEN_droppedsupply__c = true;
            update inc;
            
            //List<SPEN_MessagingTask__c> msgTask=SPEN_TestDataFactory.createMessagingTaskforIncCreated(1);
            List<Case> testCase2 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase2;
            Incident inc2 = SPEN_TestDataFactory.createIncidents(testCase2[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc2.SPEN_IncidentType__c = 'SP';
            inc2.SPEN_IncidentID__c = 'INC002';
            inc2.SPEN_IsRecordViewed__c = FALSE;
            inc2.SPEN_IncidentStatus__c='Delog';
            inc2.OwnerId=user.Id;
            inc2.SPEN_Zone__c=zoneRecord.id;
            insert inc2;
            
            testCase2[0].SPEN_PreferredMethodofContact__c = 'H';
            testCase2[0].SPEN_CallerTelephone__c = '+448888334455';
            testCase2[0].SPEN_CallerMobileTelephone__c = null;
            testCase2[0].SPEN_Incident__c = inc2.id;
            testCase2[0].SPEN_AdditionalCaller__c = true;
            update testCase2[0];
            inc2.SPEN_IncidentType__c = 'HV_N';
            //update inc2;
            
            List<Case> testCase3 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase3;
            Incident inc3 = SPEN_TestDataFactory.createIncidents(testCase2[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc3.SPEN_IncidentType__c = 'SP';
            inc3.SPEN_IncidentID__c = 'INC7865984';
            inc3.OwnerId=user.Id;
            inc3.SPEN_IncidentCategory__c='ESOD';
            inc3.SPEN_HVIncidentMessage__c=NULL;
            inc3.SPEN_IncidentStatus__c='Delog';
            inc3.SPEN_Zone__c=zoneRecord.id;
            insert inc3;
           
            
            List<Incident> incList = new List<Incident>();
            incList.add(inc);
            incList.add(inc2);
            incList.add(inc3);
             inc2.SubCategory = 'Third Party Damage';
             inc2.SPEN_IsRecordViewed__c = FALSE;
             update inc2;
            Test.stopTest();
            testCase[0].SPEN_Incident__c = null;
            update testCase[0];
            SPEN_Incident_to_case_status_mapping__mdt itcmdt = new SPEN_Incident_to_case_status_mapping__mdt( SPEN_IncidentStatus__c = 'Cancelled', SPEN_CaseStatus__c = 'Cancelled');
            testCase[0].status = itcmdt.SPEN_CaseStatus__c;
            //Update testCase[0];
            
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            List<SPEN_MessagingTask__c> messList=SPEN_TestDataFactory.createMessagingTask(SPEN_TestDataFactoryConstants.SINGLE_REC);
            messList[0].SPEN_IncidentId__c=inc.Id;
            messList[0].recordTypeId = msgTaskRecTypeId;
            Id msgRecordTypeId1 = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get(SPEN_TestDataFactoryConstants.MESSAGINGTASK_RECORDTYPE).getRecordTypeId();
            insert messList;
            
            SPEN_MessagingTaskService task=new SPEN_MessagingTaskService();
            task.createMessagingTask('Dropped Supply with Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            task.createMessagingTask('Dropped Supply without Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            
            IncidentService.getOutageTimeInModValue(Integer.valueOf(cS.SPEN_Value__c));
      	    Incidents.caseClosedStatus(testCase,inc2);
            IncidentService.assignHVIncidentMsg(incList,new Map<Id,Incident>());
            IncidentService incSer = new IncidentService();
            incSer.compareStatusOfIncident(incList);
            
            //Assert.areEqual(testCase[0].status,'Cancelled','Status Value');
            //Test.stopTest();
             
            
        }
    }
     @isTest
     private static void setup2()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet caseAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
       insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess.Id);
        PermissionSet caseAccess3PD = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
    	   insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess3PD.Id);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        System.runAs(user)
        {  
                 
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
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            //insert zoneRegionRecord;
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            //zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            //zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            //zoneRecord.SPEN_Parent__r.name='North';
            //insert zoneRecord;
            zoneRec.add(zoneRecord);
            insert zoneRec;
            List<SPEN_Zone__c> updatezoneRec = new List<SPEN_Zone__c>();
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            updatezoneRec.add(zoneDistrictRecord);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            updatezoneRec.add(zoneRecord);
            update updatezoneRec;

            List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id ivrOperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id ivrVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> ivrORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            ivrORecList[0].RecordTypeId = ivrOperatingHoursRecordTypeId;
            ivrORecList[0].SPEN_isActive__c = true;
            ivrORecList[0].SPEN_isDaily__c = true;
            ivrORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            ivrORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert ivrORecList;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_IVROperatingHours__c> vaOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            vaOprHrList[0].RecordTypeId = ivrVARecTypeId;
            vaOprHrList[0].SPEN_isActive__c = true;
            vaOprHrList[0].SPEN_isDaily__c = true;
            vaOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vaOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vaOprHrList;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_OperatingZoneId__c = 'XOXO';
            inc.SPEN_IncidentType__c = 'SP';
            inc.SPEN_IncidentID__c = 'INC001';
            inc.SPEN_IsRecordViewed__c = TRUE;
            inc.SPEN_Zone__c=zoneRecord.id;
            inc.OwnerId=  UserInfo.getUserId();//grp.Id;
             inc.SPEN_droppedsupply__c = false;
            inc.SPEN_Outage_State__c ='Planned';
            insert inc;
            testCase[0].SPEN_Incident__c = inc.id;
            testCase[0].SPEN_PreferredMethodofContact__c = 'T';
            testCase[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            testCase[0].SPEN_AdditionalCaller__c = true;
            update testCase;
      SPEN_IntegrationRequest__c intReqRecord = new SPEN_IntegrationRequest__c();
            intReqRecord.SPEN_RelatedRecord__c = inc.id;
            insert intReqRecord;         
            Test.startTest();          
            inc.SPEN_IVRMessage__c = 'IVR Message to be played';
            inc.SPEN_IncidentStatus__c='Merged';
            inc.SPEN_IsRecordViewed__c = TRUE;
            inc.SPEN_IncidentType__c = 'HV_N';
            inc.SPEN_HVIncidentMessage__c = NULL;
            inc.SPEN_IncidentCategory__c='ESOD';
            inc.SPEN_droppedsupply__c = true;
            inc.SPEN_Outage_State__c ='Predicted';
            update inc;
           
           
            
            List<Incident> incList = new List<Incident>();
            incList.add(inc);
          
           
            Test.stopTest();
            testCase[0].SPEN_Incident__c = null;
            update testCase[0];
            SPEN_Incident_to_case_status_mapping__mdt itcmdt = new SPEN_Incident_to_case_status_mapping__mdt( SPEN_IncidentStatus__c = 'Cancelled', SPEN_CaseStatus__c = 'Cancelled');
            testCase[0].status = itcmdt.SPEN_CaseStatus__c;
            //Update testCase[0];
            
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            List<SPEN_MessagingTask__c> messList=SPEN_TestDataFactory.createMessagingTask(SPEN_TestDataFactoryConstants.SINGLE_REC);
            messList[0].SPEN_IncidentId__c=inc.Id;
            messList[0].recordTypeId = msgTaskRecTypeId;
            Id msgRecordTypeId1 = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get(SPEN_TestDataFactoryConstants.MESSAGINGTASK_RECORDTYPE).getRecordTypeId();
            insert messList;
            
            SPEN_MessagingTaskService task=new SPEN_MessagingTaskService();
            task.createMessagingTask('Dropped Supply with Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            task.createMessagingTask('Dropped Supply without Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            
            IncidentService.getOutageTimeInModValue(Integer.valueOf(cS.SPEN_Value__c));
      	    Incidents.caseClosedStatus(testCase,inc);
            IncidentService.assignHVIncidentMsg(incList,new Map<Id,Incident>());
            IncidentService incSer = new IncidentService();
            incSer.compareStatusOfIncident(incList);
            
            //Assert.areEqual(testCase[0].status,'Cancelled','Status Value');
            //Test.stopTest();
             
            
        }
    }

    @isTest
    private static void setup3()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet caseAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess.Id);
        PermissionSet caseAccess3PD = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = caseAccess3PD.Id);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        System.runAs(user)
        {
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
            
            Integer threshold = Integer.valueOf(cS.SPEN_Value__c);
            Datetime dateThreshHold = system.now().addHours(-threshold);            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Survey Inc Restored';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Restored';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Survey Inc Restored';
            insert message;
            SPEN_IVRMessage__c messageVA = new SPEN_IVRMessage__c();
            messageVA=new SPEN_IVRMessage__c();
            messageVA.Name='VA – Single Premise – Survey Inc Restored';
            messageVA.SPEN_IVRMessage__c='The following information is only for the customers';
            messageVA.RecordTypeId=msgRecordTypeId;
            messageVA.SPEN_Purpose__c='Incident Restored';
            messageVA.SPEN_ExternalId__c = 'VA – Single Premise – Survey Inc Restored';
            insert messageVA;
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            //insert zoneRegionRecord;
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            //zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            //zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            //zoneRecord.SPEN_Parent__r.name='North';
            //insert zoneRecord;
            zoneRec.add(zoneRecord);
            insert zoneRec;
            List<SPEN_Zone__c> updatezoneRec = new List<SPEN_Zone__c>();
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            updatezoneRec.add(zoneDistrictRecord);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            updatezoneRec.add(zoneRecord);
            update updatezoneRec;

            List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id ivrOperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id ivrVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> ivrORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            ivrORecList[0].RecordTypeId = ivrOperatingHoursRecordTypeId;
            ivrORecList[0].SPEN_isActive__c = true;
            ivrORecList[0].SPEN_isDaily__c = true;
            ivrORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            ivrORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert ivrORecList;
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_IVROperatingHours__c> vaOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            vaOprHrList[0].RecordTypeId = ivrVARecTypeId;
            vaOprHrList[0].SPEN_isActive__c = true;
            vaOprHrList[0].SPEN_isDaily__c = true;
            vaOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vaOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vaOprHrList;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC); 
            insert testCase;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_OperatingZoneId__c = 'XOXO';
            inc.SPEN_IncidentType__c = 'SP';
            inc.SPEN_IncidentID__c = 'INC001';
            inc.SPEN_IncidentCategory__c = 'ENS1';
            inc.SPEN_IsRecordViewed__c = TRUE;
            inc.SPEN_Zone__c=zoneRecord.id;
            inc.OwnerId=  UserInfo.getUserId();//grp.Id;
            inc.SPEN_droppedsupply__c = false;
            inc.SPEN_Outage_State__c ='Predicted';
            insert inc;

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

            //testCase[0].SPEN_AddressPremise__c = lstPremise[0].Id;
            testCase[0].contactId = contactObj.id;
            testCase[0].SPEN_Incident__c = inc.id;
            testCase[0].SPEN_PreferredMethodofContact__c = 'T';
            testCase[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            testCase[0].SPEN_AdditionalCaller__c = true;
            update testCase;

            // List<Case> lstTestCase = SPEN_TestDataFactory.createListOfCases(2); 
            // insert lstTestCase;
            // lstTestCase[0].contactId = contactObj.id;
            // lstTestCase[0].SPEN_Incident__c = inc.id;
            // lstTestCase[0].SPEN_PreferredMethodofContact__c = 'H';
            // lstTestCase[0].SPEN_CallerTelephone__c = '+448888334455';
            // lstTestCase[0].SPEN_AdditionalCaller__c = true;
            // update lstTestCase;
            // lstTestCase[1].contactId = contactObj.id;
            // lstTestCase[1].SPEN_Incident__c = inc.id;
            // //lstTestCase[1].SPEN_PreferredMethodofContact__c = 'T';
            // //lstTestCase[1].SPEN_CallerMobileTelephone__c = '+448888334455';
            // lstTestCase[1].SPEN_AdditionalCaller__c = true;
            // update lstTestCase;
            // lstTestCase[2].contactId = contactObj.id;
            // lstTestCase[2].SPEN_Incident__c = inc.id;
            // //lstTestCase[2].SPEN_PreferredMethodofContact__c = 'H';
            // //lstTestCase[2].SPEN_CallerTelephone__c = '+448888334455';
            // lstTestCase[2].SPEN_AdditionalCaller__c = true;
            // update lstTestCase;

            SPEN_IntegrationRequest__c intReqRecord = new SPEN_IntegrationRequest__c();
            intReqRecord.SPEN_RelatedRecord__c = inc.id;
            insert intReqRecord;         
            Test.startTest();          
            inc.SPEN_IVRMessage__c = 'IVR Message to be played';
            inc.SPEN_IncidentStatus__c='Merged';
            inc.SPEN_IsRecordViewed__c = TRUE;
            inc.SPEN_IncidentType__c = 'SP';
            inc.SPEN_HVIncidentMessage__c = NULL;
            inc.SPEN_IncidentCategory__c='ENS1';
            inc.SPEN_droppedsupply__c = true;
            inc.SPEN_Outage_State__c ='Restored';
            update inc;
            
            List<Incident> incList = new List<Incident>();
            incList.add(inc);
            
            //inc.SPEN_Outage_State__c ='Restored';
            //update inc;
            
            Test.stopTest();
            testCase[0].SPEN_Incident__c = null;
            update testCase[0];
            SPEN_Incident_to_case_status_mapping__mdt itcmdt = new SPEN_Incident_to_case_status_mapping__mdt( SPEN_IncidentStatus__c = 'Cancelled', SPEN_CaseStatus__c = 'Cancelled');
            testCase[0].status = itcmdt.SPEN_CaseStatus__c;
            //Update testCase[0];
            
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            List<SPEN_MessagingTask__c> messList=SPEN_TestDataFactory.createMessagingTask(SPEN_TestDataFactoryConstants.SINGLE_REC);
            messList[0].SPEN_IncidentId__c=inc.Id;
            messList[0].recordTypeId = msgTaskRecTypeId;
            Id msgRecordTypeId1 = Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get(SPEN_TestDataFactoryConstants.MESSAGINGTASK_RECORDTYPE).getRecordTypeId();
            insert messList;
            
            SPEN_MessagingTaskService task=new SPEN_MessagingTaskService();
            task.createMessagingTask('Dropped Supply with Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            task.createMessagingTask('Dropped Supply without Notice',inc.Id,msgRecordTypeId1,user.Id,'New');
            
            IncidentService.getOutageTimeInModValue(Integer.valueOf(cS.SPEN_Value__c));
                Incidents.caseClosedStatus(testCase,inc);
            IncidentService.assignHVIncidentMsg(incList,new Map<Id,Incident>());
            IncidentService incSer = new IncidentService();
            incSer.compareStatusOfIncident(incList);
            
            //Assert.areEqual(testCase[0].status,'Cancelled','Status Value');
            //Test.stopTest();
            
           
       }
   }
 
 
}