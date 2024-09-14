/**
* @description       : Test class for SPEN_VoiceAlertServiceBatch
* @author            : Rahul Kumar
* @group             : 
* @last modified on  : 05-12-2023
* @last modified by  : rahul.dd.kumar@accenture.com
**/
@IsTest(SeeAllData=false)
public class SPEN_VoiceAlertServiceBatchTest {
    @testSetup 
    static void dataSetup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated'){
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        
        
        System.runAs(user){
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
            
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            insert zoneRegionRecord;
            
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneDistrictRecord.Name = 'districtzone';
            insert zoneDistrictRecord;
            
            List<SPEN_Premise__c> lstPremise =  SPEN_TestDataFactory.createListOfPremise(1);
            lstPremise[0].SPEN_PremiseDistrict__c = zoneDistrictRecord.id;
            insert lstPremise;
            
            Contact contactObj = SPEN_TestDataFactory.createContacts(null,1);
            contactObj.SPEN_PSR__c = true;
            contactObj.SPEN_SpecificVulnerability__c =true;
            insert contactObj;
            
            Incident inc2 = SPEN_TestDataFactory.createListofIncidents(1)[0];        
            inc2.Status = 'New';
            inc2.SPEN_IncidentCategory__c = 'HV';
            inc2.SPEN_IncidentReference__c ='TESTREF001';
            insert inc2;
            
            Id unplannedFaultRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
            List<Case> lstCases = new List<Case>();
           
            List<Case> lstOfCasesRecords = SPEN_TestDataFactory.createListOfCases(5);
           
            for(Integer i=0;i<lstOfCasesRecords.size();i++){
                Case cse = new Case();
                cse.contactId = contactObj.id;
                cse.SPEN_AddressPremise__c = lstPremise[0].Id;
                cse.SPEN_PreferredMethodofContact__c ='H'; 
                cse.SPEN_CallerTelephone__c = '011111111'+i; 
                lstCases.add(cse);
            }
            
            if(!lstCases.isEmpty()){
                insert lstCases;
            }
        }
    }
    @isTest 
    private static void testVoiceAlertServiceBatch(){
        User u= [Select id FROM User where IsActive=true LIMIT 1];
        System.runAs(u){
            Incident inc = [select id, SPEN_IncidentReference__c,SPEN_IncidentType__c from Incident where SPEN_IncidentReference__c='TESTREF001' limit 1];
          
            List<Case> lstOfCases = new List<Case>();
            
            for(Case caseUpdate : [select Id,SPEN_PreferredMethodofContact__c,SPEN_CallerTelephone__c,SPEN_Incident__c, ContactId
                                   from Case limit 1]){
                                       caseUpdate.SPEN_Incident__c = inc.Id;
                                       lstOfCases.add(caseUpdate);
                                   }
            if(!lstOfCases.isEmpty()){
                update lstOfCases;
            }
            
            List<Id> lstOfCaseRef = new List<Id>();
            for(Case cc: [select Id,SPEN_PreferredMethodofContact__c,SPEN_CallerTelephone__c,SPEN_Incident__c, ContactId
                          from Case where SPEN_Incident__c=:inc.Id]){
                              
                              lstOfCaseRef.add(cc.Id);
                          }
            Id VoiceAlertRecordTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Test.startTest();
            
            Database.executeBatch(new SPEN_VoiceAlertServiceBatch(lstOfCaseRef,'Thanks for calling to SPEN Network',VoiceAlertRecordTypeId));
             Assert.areEqual(inc.SPEN_IncidentType__c, 'HV_S');
            Test.stopTest();
            
        }
    }
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Test JSON';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}