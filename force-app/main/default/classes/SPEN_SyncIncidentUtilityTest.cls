@isTest
public class SPEN_SyncIncidentUtilityTest {
    
    @testSetup static void setup() 
    {
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
        System.runAs(user)
        {
            Test.startTest();
            List<SPEN_ConfigurableSettings__c> csList=new List<SPEN_ConfigurableSettings__c>();
            SPEN_ConfigurableSettings__c cs1 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'MessagingTaskType');
            csList.add(cs1);
            SPEN_ConfigurableSettings__c cs2 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'AutoSMSTaskType');
            cs2.SPEN_Value__c = 'LV';
            csList.add(cs2);
            SPEN_ConfigurableSettings__c cs3 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'MessagingTaskTypeCreate');
            csList.add(cs3);
            SPEN_ConfigurableSettings__c cs4 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'NoAutoSMSTaskType');
            csList.add(cs4);
            SPEN_ConfigurableSettings__c cs5 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'GetAffectedPremiseINCType');
            csList.add(cs5);
            SPEN_ConfigurableSettings__c cs6 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'OutboundIncidentType');
            csList.add(cs6);
            SPEN_ConfigurableSettings__c cs7 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            csList.add(cs7);
            SPEN_ConfigurableSettings__c cs8 =SPEN_TestDataFactory.createConfigSetting(1,'ETADefaultForDispatch');
            csList.add(cs8);
            SPEN_ConfigurableSettings__c cs9 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchNODelayINCType');
            csList.add(cs9);
            SPEN_ConfigurableSettings__c config = new SPEN_ConfigurableSettings__c();
            config.Name = 'Incident broadcast message updated last one hour';
            config.SPEN_Value__c = '1';
            config.SPEN_Description__c = 'the broadcast message of the Incident object is updated in the last hour';
           	csList.add(config);
            insert csList;
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            List<Incident> incList=new List<Incident>();
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = 'I001';
            incdnt.SPEN_IncidentType__c = 'SP';
            incdnt.SPEN_IncidentReference__c = 'SP';
            incdnt.SPEN_IncidentStatus__c='Awaiting';
            incdnt.recordtypeId = recTypeId;
            incList.add(incdnt);
            
            List<Incident> lstInct = SPEN_TestDataFactory.createListofIncidents(1);
            lstInct[0].SPEN_IncidentCategory__c = 'SP';
            lstInct[0].SPEN_IncidentID__c = '123';
            lstInct[0].SPEN_IncidentStatus__c='In Progress';
            lstInct[0].SPEN_IncidentType__c='HV_N';
            incList.add(lstInct[0]);
            
            List<Incident> incd = SPEN_TestDataFactory.createListofIncidents(1);
            incd[0].SPEN_IncidentCategory__c = 'SP';
            incd[0].SPEN_IncidentID__c = 's000c7cb7INCD';
            incd[0].SPEN_IncidentReference__c = 'INCD-4311141-r';
            incList.add(incd[0]);
            
            insert incList;
            
            List<SPEN_ImpactedPremise__c> impPremList = SPEN_TestDataFactory.createImpactedPremiserecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            impPremList[0].SPEN_RelatedIncident__c = incdnt.Id;
            impPremList[0].SPEN_Status__c = 'Restored';
            insert impPremList;
            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='Test IVR';
            message.SPEN_IVRMessage__c='The following information is only for the //////customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
            
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.MobilePhone = '07883344559';
            insert con;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
            testCase[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            testCase[0].RecordTypeId = recordTypeId;
            testCase[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            testCase[0].SPEN_PreferredMethodofContact__c = 'H';
            insert testCase;
            
            List<Case> testCase2 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase2[0].Origin = 'Web';
            testCase2[0].ContactId=con.Id;
            testCase2[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            testCase2[0].RecordTypeId = recordTypeId;
            testCase2[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            testCase2[0].SPEN_PreferredMethodofContact__c = 'H';

            //testCase2[0].SPEN_Incident__c = lstInct[0].id;
            insert testCase2; 
            
             List<Case> testCase3 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
             testCase3[0].Origin = 'Web';
             testCase3[0].ContactId=con.Id;
             testCase3[0].SPEN_Incident__c = incdnt.id;
             testCase3[0].RecordTypeId = recordTypeId;
             testCase3[0].SPEN_PreferredMethodofContact__c = 'T';
             testCase3[0].SPEN_CallerMobileTelephone__c = '+448888334455';
             insert testCase3;
            /*
            List<Case> testCaseScopeChanged = SPEN_TestDataFactory.createListOfCases(2);
            testCaseScopeChanged[0].SPEN_Incident__c = incdnt.id;
            testCaseScopeChanged[1].SPEN_Incident__c = incdnt.id;
            insert testCaseScopeChanged;
            */
            
            List<SPEN_IVRMessage__c> lstIVR = new List<SPEN_IVRMessage__c>();
            SPEN_IVRMessage__c msg = new SPEN_IVRMessage__c();
            msg=new SPEN_IVRMessage__c();
            msg.Name='SP Resource Dispatched SMS';
            msg.SPEN_IVRMessage__c='The following information is only for the customers';
            msg.RecordTypeId=msgRecordTypeId;
            msg.SPEN_Purpose__c='Incident Created';
            msg.SPEN_ExternalId__c = 'SP Resource Dispatched SMS';
            
            SPEN_IVRMessage__c etaMsg = new SPEN_IVRMessage__c();
            etaMsg=new SPEN_IVRMessage__c();
            etaMsg.Name='SP ETA Changes SMS';
            etaMsg.SPEN_IVRMessage__c='The following information is only for the customers';
            etaMsg.RecordTypeId=msgRecordTypeId;
            etaMsg.SPEN_Purpose__c='Incident Created';
            etaMsg.SPEN_ExternalId__c = 'SP ETA Changes SMS';
            
            SPEN_IVRMessage__c eTAVA = new SPEN_IVRMessage__c();
            eTAVA=new SPEN_IVRMessage__c();
            eTAVA.Name='SP ETA Changed VA';
            eTAVA.SPEN_IVRMessage__c='Hello, This is a message from SP Energy Networks.Thank you for reporting a fault, Case ref: [CASENUMBER]. Our engineer has been delayed.Our estimated time of arrival has changed to [ETA].If you no longer require our attendance please contact us on our emergency telephone number 105';
            eTAVA.RecordTypeId=msgRecordTypeId;
            eTAVA.SPEN_Purpose__c='Incident Created';
            eTAVA.SPEN_ExternalId__c = 'SP ETA Changed VA';
            
            SPEN_IVRMessage__c resDispVA = new SPEN_IVRMessage__c();
            resDispVA=new SPEN_IVRMessage__c();
            resDispVA.Name='SP Resource Dispatched VA';
            resDispVA.SPEN_IVRMessage__c='Hello, This is a message from SP Energy Networks. Thank you for reporting a fault, Case ref: [CASENUMBER]. Our engineer has been dispatched and will require access to your property. Our estimated time of arrival is [ETA].If you no longer require our attendance please contact us on our emergency telephone number 105';
            resDispVA.RecordTypeId=msgRecordTypeId;
            resDispVA.SPEN_Purpose__c='Incident Created';
            resDispVA.SPEN_ExternalId__c = 'SP Resource Dispatched VA';
            
            lstIVR.add(msg);
            lstIVR.add(etaMsg);
            lstIVR.add(eTAVA);
            lstIVR.add(resDispVA);
            insert lstIVR;
            
            List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id ivrOperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id ivrVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> ivrORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,lstIVR[0].id);
            ivrORecList[0].RecordTypeId = ivrOperatingHoursRecordTypeId;
            ivrORecList[0].SPEN_isActive__c = true;
            ivrORecList[0].SPEN_isDaily__c = true;
            ivrORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            ivrORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert ivrORecList;
            
            List<SPEN_IVROperatingHours__c> vaOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,lstIVR[0].id);
            vaOprHrList[0].RecordTypeId = ivrVARecTypeId;
            vaOprHrList[0].SPEN_isActive__c = true;
            vaOprHrList[0].SPEN_isDaily__c = true;
            vaOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vaOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vaOprHrList;
            Assert.areEqual(true, vaOprHrList[0].SPEN_isActive__c, 'opertaing hours record is in active');
            Test.stopTest();
        }
    }
    @IsTest
    public static void incidentReparentSyncCallTest1() 
    {
         User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
         System.runAs(user){
             Test.startTest();
             Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
            List<case> caselist= [SELECT Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c 
                                        FROM Case WHERE recordTypeId=:recordTypeId];
            Incident inc=[Select id,SPEN_IncidentStatus__c,SPEN_IncidentType__c from incident where SPEN_IncidentStatus__c='In Progress' ];
            SPEN_SyncIncidentUtility.incidentReparentSyncCall(caselist,inc); 
             SPEN_SMS__c sms=[Select id from SPEN_SMS__c where SPEN_IvrMessageId__c!=null];            
            Assert.isTrue(sms!=null);
             Test.stopTest();
                
         }
    }
    @IsTest
    public static void incidentReparentSyncCallTest2() 
    {
         User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
         System.runAs(user){
             Test.startTest();
             Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
            List<case> caselist= [SELECT Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c 
                                        FROM Case WHERE recordTypeId=:recordTypeId];
            Incident inc=[Select id,SPEN_IncidentStatus__c,SPEN_IncidentType__c from incident where SPEN_IncidentStatus__c='Awaiting' ];
            SPEN_SyncIncidentUtility.incidentReparentSyncCall(caselist,inc);
            Incident afterUpdate=[Select id,SPEN_IncidentStatus__c from incident where id=:inc.id];            
            Assert.isTrue(afterUpdate.SPEN_IncidentStatus__c=='Awaiting'); //no change in status

             Test.stopTest();
                
         }
    }
    @IsTest
    public static void incidentReparentSyncCallTestNegative() 
    {
         User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
         System.runAs(user){
             Test.startTest();
             Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
            List<case> caselist;//= [SELECT Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c 
                                       // FROM Case WHERE recordTypeId=:recordTypeId];
            Incident inc=new Incident();//[Select id,SPEN_IncidentStatus__c,SPEN_IncidentType__c from incident where SPEN_IncidentStatus__c='Awaiting' ];
            SPEN_SyncIncidentUtility.incidentReparentSyncCall(caselist,inc); 
            Assert.isTrue(caselist==null);
            Test.stopTest();
                
         }
    }

}