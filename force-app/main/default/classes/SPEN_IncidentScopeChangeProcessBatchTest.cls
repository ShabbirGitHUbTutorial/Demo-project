/**
* @description       : Test class for SPEN_IncidentScopeChangedProcessingBatch
* @author            : Rahul Kumar
* @group             : 
* @last modified on  : 21-11-2023
* @last modified by  : rahul.dd.kumar@accenture.com
**/
@IsTest(SeeAllData=false)
public class SPEN_IncidentScopeChangeProcessBatchTest{
   
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
        List<PermissionSetAssignment> psaList=new list<PermissionSetAssignment>();
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        psaList.add(new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id));
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        psaList.add(new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id));
        insert psaList;
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
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
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

            List<Incident> incList=new List<Incident>();
            Incident inc1 = SPEN_TestDataFactory.createListofIncidents(1)[0];        
            inc1.Status = 'New';
            inc1.SPEN_IncidentCategory__c = 'HV';
            inc1.SPEN_IncidentType__c = 'SP';
            inc1.Subject = 'Testing1';
            incList.add(inc1);
            
            Incident inc2 = SPEN_TestDataFactory.createListofIncidents(1)[0];        
            inc2.Status = 'New';
            inc2.SPEN_IncidentCategory__c = 'HV';
            inc2.Subject = 'Testing2';
            inc2.SPEN_IncidentType__c = 'HV_N';
            inc2.SPEN_IncidentID__c = inc2.SPEN_IncidentID__c + Integer.valueof((Math.random()*10));
            incList.add(inc2); 
            
            insert incList;
            
            Id unplannedFaultRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
            Integer count = 0;
            List<Case> lstCases = new List<Case>();
            for(Case cse : SPEN_TestDataFactory.createListOfCases(1)){
            
                cse.contactId = contactObj.id;
                cse.recordTypeId = unplannedFaultRecId;
                cse.SPEN_Incident__c = inc1.id;
                cse.SPEN_AddressPremise__c = lstPremise[0].Id;
                cse.SPEN_PreferredMethodofContact__c ='T'; 
                cse.SPEN_CallerMobileTelephone__c = '07111111111'; //Mobile number update
                lstCases.add(cse);
            }
            for(Case cse : SPEN_TestDataFactory.createListOfCases(1)){
            
                cse.contactId = contactObj.id;
                cse.recordTypeId = unplannedFaultRecId;
                cse.SPEN_Incident__c = inc1.id;
                cse.SPEN_AddressPremise__c = lstPremise[0].Id;
                cse.SPEN_PreferredMethodofContact__c ='H'; 
                cse.SPEN_CallerTelephone__c = '0111111111'; //Mobile number update
                lstCases.add(cse);
            }
            for(Case cse : SPEN_TestDataFactory.createListOfCases(1)){
            
                cse.contactId = contactObj.id;
                cse.recordTypeId = unplannedFaultRecId;
            // cse.SPEN_Incident__c = inc1.id;
                cse.SPEN_AddressPremise__c = lstPremise[0].Id;
                cse.SPEN_PreferredMethodofContact__c ='H'; 
                cse.SPEN_CallerTelephone__c = '0111111111'; //Mobile number update
                lstCases.add(cse);
            }
			Test.startTest();
            if(!lstCases.isEmpty()){
                insert lstCases;
            }
            Test.stopTest();
        }
    }
    @isTest 
    private static void testInsertScopeChnageProcessing(){
        User u= [Select id FROM User where IsActive=true LIMIT 1];
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            Incident inc2  = [select id, ParentIncidentId, SPEN_IncidentStatus__c,SPEN_IncidentType__c from Incident where Subject='Testing2' LIMIT 1];
            List<Id> lstOfCaseRef = new List<Id>();

            for(Case cc: [Select Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c from CASE where SPEN_Incident__c!=null LIMIT 1]){
                lstOfCaseRef.add(cc.Id);
            }
            
            Database.executeBatch(new SPEN_IncidentScopeChangedProcessingBatch(inc2,lstOfCaseRef));
            Test.stopTest();
        	Case cc = [Select Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c from CASE where SPEN_Incident__c!=null LIMIT 1]; 
               
        	Assert.areEqual(cc.SPEN_IsMerge__c, true, 'Case field updated by merged true flag');
        }
    }

}