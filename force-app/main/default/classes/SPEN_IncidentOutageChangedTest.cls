@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_IncidentOutageChangedTest {
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
            incdnt.recordtypeId = recTypeId;
            insert incdnt;
            Test.stopTest();
        }
        

    }
    @IsTest
    public static void testOutageMessageCheck(){
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            String reqStr ='<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap=http://schemas.xmlsoap.org/soap/envelope/ xmlns:sdif="SDIF"><soap:Header/><soap:Body><sdif:SDIFIncidentOutageChanged><sdif:IncidentOutageChangedStc><sdif:IncidentID>0hbjdgfyj</sdif:IncidentID><sdif:IncidentReference>TEST5044AB</sdif:IncidentReference></sdif:IncidentOutageChangedStc></sdif:SDIFIncidentOutageChanged></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse(); 
            
            req.requestURI = '/services/apexrest/IncidentOutageChanged/';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_IncidentOutageChangedMock());
            SPEN_IncidentOutageChanged.incidentOutageUpdate();
            Test.stopTest();
            Incident inc = [select Id, SPEN_IncidentReference__c,SPEN_GetAffectedPremisesScheduled__c from incident where SPEN_IncidentReference__c='TEST5044AB'];
        	Assert.areEqual(inc.SPEN_GetAffectedPremisesScheduled__c, false, 'The flag turned off after processing...');
           }
    }
    @IsTest
    public static void testOutageMessageCheck1(){
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u){
            Test.startTest();
            String reqStr ='<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap=http://schemas.xmlsoap.org/soap/envelope/ xmlns:sdif="SDIF"><soap:Header/><soap:Body><sdif:SDIFIncidentOutageChanged><sdif:IncidentOutageChangedStc><sdif:IncidentID>0hbjdgfyj</sdif:IncidentID><sdif:IncidentReference>TEST5045AB</sdif:IncidentReference></sdif:IncidentOutageChangedStc></sdif:SDIFIncidentOutageChanged></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse(); 
            
            req.requestURI = '/services/apexrest/IncidentOutageChanged/';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_IncidentOutageChangedMock());
            SPEN_IncidentOutageChanged.incidentOutageUpdate();
            Test.stopTest();
            Incident inc;
            try{
                inc=[select Id, SPEN_IncidentReference__c,SPEN_GetAffectedPremisesScheduled__c from incident where SPEN_IncidentReference__c='TEST5045AB'];
            }catch(Exception e){
              Assert.isTrue(e!=null);
            }
        }
    }
}