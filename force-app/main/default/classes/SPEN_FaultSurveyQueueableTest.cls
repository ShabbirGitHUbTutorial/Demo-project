/**
* @description       : Test class for SPEN_FaultSurveyQueueableTest
* @author            : Akshay Pandit
* @group             : 
* @last modified on  : 02-05-2024
* @last modified by  : a.rajendra.pandit@accenture.com
**/

@IsTest(SeeAllData=false)
@SuppressWarnings('PMD.SOQLSelectorPattern , PMD.CodeBestPracticesNonFilteredQueries')

public class SPEN_FaultSurveyQueueableTest 
{
    @testSetup 
    static void dataSetup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        //system.debug('user'+user.Id);
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet ps14 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CommunicationSchedulerAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps14.Id);
         PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
         PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet impactedPremiseps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = impactedPremiseps.Id);
		PermissionSet surveyAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_SurveyAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = surveyAdmin.Id);
        
        System.runAs(user)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,SPEN_ConstantData.IncidentMessage);
            cs.Name = 'OutboundIncidentType';
            insert cs;
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            SPEN_ConfigurableSettings__c cs3 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert cs3;
            SPEN_ConfigurableSettings__c cs4 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert cs4;
            SPEN_ConfigurableSettings__c cS5 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cS5;
             SPEN_ConfigurableSettings__c cS6 =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cS6;
            
            Id smsBroadCastRecordTypeId = Schema.SObjectType.SPEN_SMS__c.getRecordTypeInfosByName().get('Broadcast').getRecordTypeId();
            
            List<SPEN_IVR__c> ivrSMSRecord = SPEN_TestDataFactory.createIVRrecord(1);
            insert ivrSMSRecord;
            List<SPEN_IVR__c> ivrVoiceRecord = SPEN_TestDataFactory.createIVRrecord(1);
            ivrVoiceRecord[0].Name ='Sample Voice alert';
            insert ivrVoiceRecord;
            SPEN_IVRMessage__c ivrMsgforSMS = SPEN_TestDataFactory.createIVRMessage(1);
            insert ivrMsgforSMS;
            
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(ivrMsgforSMS.Id);
            insert zoneRegionRecord;
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(ivrMsgforSMS.Id);
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneDistrictRecord.Name = 'districtzone';
            insert zoneDistrictRecord;
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(ivrMsgforSMS.Id);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            insert zoneRecord;
            zoneRec.add(zoneRegionRecord);
            zoneRec.add(zoneDistrictRecord);
            zoneRec.add(zoneRecord);
            
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
            inc.Subject = 'Testing';
            insert inc;
            Id msgTaskRecTypeId =  Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByName().get('Incident').getRecordTypeId();
            
            SPEN_MessagingTask__c msgTask = new SPEN_MessagingTask__c();
            msgTask.SPEN_Status__c = 'New';
            msgTask.SPEN_Event__c = '3-Hour Comfort Call';
            msgTask.SPEN_IncidentId__c = inc.Id;
            msgTask.recordTypeId = msgTaskRecTypeId;
            insert msgTask;
            
            Id smsBroadCaseRecTypeId = Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('SMS Broadcast').getRecordTypeId();
            Id vaBroadCaseRecTypeId =  Schema.SObjectType.SPEN_CommunicationScheduler__c.getRecordTypeInfosByName().get('Voice Alert Broadcast').getRecordTypeId();
            
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
            
            Case caseForCalledinSMS = SPEN_TestDataFactory.createListOfCases(1)[0];
            caseForCalledinSMS.contactId = contactObj.id;
            caseForCalledinSMS.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();
            caseForCalledinSMS.SPEN_Incident__c = inc.id;
            //caseForCalledinSMS.SPEN_AddressPremise__c = lstPremise[0].Id;
            caseForCalledinSMS.SPEN_PreferredMethodofContact__c ='T'; 
            caseForCalledinSMS.SPEN_CallerMobileTelephone__c = '07111111111'; //mobile number update
            caseForCalledinSMS.SPEN_CallerTelephone__c = '07111111111';
            insert caseForCalledinSMS;
            
            //SMS Record Creation
            List<SPEN_SMS__c> lstSMS = new List<SPEN_SMS__c>();
            Set<Id> setSMSSurveyId = new Set<Id>();
            Map<Id,SPEN_SMS__c> mapIdSMS = new Map<Id,SPEN_SMS__c> ();
            
            SPEN_SMS__c objSMS = new SPEN_SMS__c();
            objSMS.SPEN_ContactId__c = contactObj.id;
            objSMS.SPEN_IncidentId__c = inc.id;
            objSMS.SPEN_Message__c = 'SPEN_NonPSRMessage__c';
            objSMS.SPEN_Event__c = 'Incident Restored';
            
            objSMS.RecordTypeId = smsBroadCastRecordTypeId;
            objSMS.SPEN_Status__c = 'Created';
            objSMS.SPEN_MessageType__c = 'Outbound';
            system.debug(contactObj);
			system.debug(contactPremise);
            system.debug(impactedPremise+'>>>>'+impactedPremise.SPEN_CustomerMobileNumberFormula__c);
            String mobilePhone = '07123456789';//impactedPremise.SPEN_CustomerMobileNumberFormula__c;
            objSMS.SPEN_Mobile__c = mobilePhone.startsWith('0') ? ('+44'+mobilePhone.removeStart('0')) : mobilePhone;
            objSMS.SPEN_PremiseId__c = impactedPremise.SPEN_ContactPremise__r.SPEN_Premise__c;
            //objSMS.SPEN_CaseId__c = caseForCalledinSMS.id;
            objSMS.SPEN_IsProactive__c =true;
            lstSMS.add(objSMS);

            set<SPEN_VoiceAlert__c> lstVASP = new set<SPEN_VoiceAlert__c>();
            Id instantVARecTypeId = Schema.SObjectType.SPEN_VoiceAlert__c.getRecordTypeInfosByName().get('Instant').getRecordTypeId();
            SPEN_VoiceAlert__c objVoiceAlert = New SPEN_VoiceAlert__c();
            objVoiceAlert.SPEN_ContactId__c = contactObj.id;
            objVoiceAlert.SPEN_IncidentId__c = inc.id;
            objVoiceAlert.SPEN_Event__c = 'Incident Restored'; 
            objVoiceAlert.SPEN_BroadcastMessage__c = 'SPEN_Message__c';
            objVoiceAlert.SPEN_Case__c = caseForCalledinSMS.id;
            objVoiceAlert.RecordTypeId = instantVARecTypeId;
            objVoiceAlert.SPEN_Status__c = 'Ready';
            objVoiceALert.SPEN_CalledInTelephone__c = caseForCalledinSMS.SPEN_CallerTelephone__c;
            lstVASP.add(objVoiceAlert);
                        
            insert objVoiceALert;

            setSMSSurveyId.add(lstSMS[0].id);
            mapIdSMS.put(lstSMS[0].id, lstSMS[0]);
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void FaultSurvey()
    {
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            List<SPEN_SMS__c>smsRecord = [select Id, Name, SPEN_IncidentId__c, SPEN_ContactId__c, SPEN_Message__c, SPEN_IsProactive__c, SPEN_CaseId__c  from SPEN_SMS__c];
            set<Id>setSMSSurveyId= new set<Id>();
            Map<Id,SPEN_SMS__c> mapIdSMS = new Map<Id,SPEN_SMS__c> ();
            if(!smsRecord.isEmpty()|| smsRecord.size() > 0){
            setSMSSurveyId.add(smsRecord[0].id);
            }
            Id jobId;
            jobId = System.enqueueJob(new SPEN_FaultSurveyQueueable(setSMSSurveyId, 'Faults', 'SMS')); 
            Test.stopTest();
        }
    }

    @isTest
    public static void SPIncResSurvey()
    {
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            List<SPEN_VoiceAlert__c> vaRec = [select id,SPEN_ContactId__c,SPEN_IncidentId__c,SPEN_Event__c,SPEN_CommunicationScheduler__c,SPEN_BroadcastMessage__c,SPEN_IsProactive__c,SPEN_Case__c,RecordTypeId,SPEN_Status__c from SPEN_VoiceAlert__c];
            set<Id> lstVASP= new set<Id>();
            if(!vaRec.isEmpty()){
            lstVASP.add(vaRec[0].id);
            }
            Id jobId = System.enqueueJob(new SPEN_FaultSurveyQueueable(lstVASP,'Single Premise','Voice Alert')); 
            Test.stopTest();
        }
    }
    
}