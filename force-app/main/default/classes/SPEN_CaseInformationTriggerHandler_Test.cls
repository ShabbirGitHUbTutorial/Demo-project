@isTest
public class SPEN_CaseInformationTriggerHandler_Test {
    Public static Id faultRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
    Public static Id bypassRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedBypass').getRecordTypeId();
    Public static Id recordTypeIdIncident = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('SPEN_SPENIncident').getRecordTypeId();
    Public static Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    Public static Id caseInfoRecordTypeId = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_3PDDamageForm').getRecordTypeId();
    Public Static ID LCTRecordTypeId =  Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_LCTRecordType').getRecordTypeId();
	Public Static ID SIRecordTypeId =  Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SmartIntervention').getRecordTypeId();

    
    @isTest 
    public static void creat3PDCaseTest4()
    {
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
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseInformationCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        System.runAs(user){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
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
            csList.add(cS4);
            insert csList;
             SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            Insert IVRMessage;
			
             Incident inc = new Incident();
            inc.Subject='Test Subject';
            inc.SPEN_IncidentReference__c='INCD-434014-r';
            inc.RecordTypeId=recordTypeIdIncident;
            insert inc;
            
            Case ThreePDCase =new Case();
            ThreePDCase.SPEN_Incident__c = inc.id;
            //ThreePDCase.SPEN_IncidentRefFormula__c = inc.SPEN_IncidentReference__c;
            ThreePDCase.Status ='Created';
            ThreePDCase.Priority='Medium';
            ThreePDCase.RecordTypeId = recordTypeId3PD;
            insert ThreePDCase;
            
          	
    		List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
            Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert ct;
            
            Case faultCase = new Case();
            faultCase.ContactId = ct.Id;
            faultCase.SPEN_CallerInitials__c = ct.Salutation;
            faultCase.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            faultCase.SPEN_CallerName__c = ct.Name;
            faultCase.SPEN_CallerTelephone__c = ct.Phone;
            faultCase.SPEN_CallerTitle__c = ct.Suffix;
            faultCase.status='Restored';
            faultCase.RecordTypeId = faultRecordTypeId;
            faultCase.Subject = 'Damaged Equipment Wizard Case';
            faultCase.SPEN_Incident__c = inc.id;
           	insert faultCase;
            
             SPEN_CaseInformation__c caseInfo = new SPEN_CaseInformation__c();
            caseInfo.recordtypeid = caseInfoRecordTypeId;
            caseInfo.SPEN_Case__c = ThreePDCase.id;
            insert caseInfo;
            
             SPEN_Zone__c SPDZoneParent = SPEN_TestDataFActory.createZoneRecords(IVRMessage.id);
            SPDZoneParent.name = 'Ayrshire';
            SPDZoneParent.SPEN_Type__c = 'Zone';
            insert SPDZoneParent;
            
            SPEN_Zone__c SPDZone = SPEN_TestDataFActory.createZoneRecords(IVRMessage.id);
            SPDZone.name = 'CLYDE SOUTH';
            SPDZone.SPEN_Type__c = 'Zone';
            SPDZone.SPEN_Parent__c = SPDZoneParent.Id;
            insert SPDZone;
            
            SPEN_Zone__c townRecord = SPEN_TestDataFActory.createZoneRecords(IVRMessage.id);
            townRecord.SPEN_Type__c = 'Town';
            townRecord.name = 'Test Town';
            townRecord.SPEN_Parent__c = SPDZone.Id;
            insert townRecord;
            
            faultCase.SPEN_Incident__c = null;
            update faultCase;
            Case bypassCase = new Case();
            bypassCase.ContactId = ct.Id;
            bypassCase.SPEN_CallerInitials__c = ct.Salutation;
            bypassCase.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            bypassCase.SPEN_CallerName__c = ct.Name;
            bypassCase.SPEN_CallerTelephone__c = ct.Phone;
            bypassCase.SPEN_CallerTitle__c = ct.Suffix;
            bypassCase.status='Restored';
            bypassCase.SPEN_Town__c = townRecord.id;
            bypassCase.RecordTypeId = bypassRecordTypeId;
            bypassCase.Subject = 'Damaged Equipment Wizard Case';
            bypassCase.SPEN_Incident__c = inc.id;
           	insert bypassCase;
            
            SPEN_CaseInformation__c caseInfo1 = new SPEN_CaseInformation__c();
            caseInfo1.recordtypeid = caseInfoRecordTypeId;
            caseInfo1.SPEN_Case__c = ThreePDCase.id;
            insert caseInfo1;

//Added to cover blocks in interface class
            caseInfo1.SPEN_LocationofDamage__c = 'test';
            update caseInfo1;
            
            SPEN_CaseInformation__c caseInfo2 = new SPEN_CaseInformation__c();
            caseInfo2.recordtypeid = LCTRecordTypeId;
            caseInfo2.SPEN_Case__c = ThreePDCase.id;
            insert caseInfo2;
			caseInfo2.SPEN_SubStatus__c = 'Missing Information Requested';
            update caseInfo2;
            //Added to cover blocks in interface class
            caseInfo1.SPEN_LocationofDamage__c = 'test';
            update caseInfo1;
            SPEN_CaseInformationInterface obj = new SPEN_CaseInformationInterface(); 
            Map<Id, sObject> deleteMap = new Map<Id,sObject>();
            deleteMap.put(caseInfo1.id,caseInfo1);
            obj.beforeDelete(deleteMap);
            obj.afterDelete(deleteMap);
            obj.afterUndelete(deleteMap);
            Test.stopTest();
            
        }
    }

    
    @isTest
    static void calculateAndSetDatesTest() {
        // Create test data
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Connection Business Hours' LIMIT 1];
        //SPEN_CaseInformation__c caseInfo = new SPEN_CaseInformation__c(SPEN_FlowReceivedDate__c = Datetime.now());
        SPEN_CaseInformation__c caseInfo = new SPEN_CaseInformation__c();
        caseInfo.RecordTypeId = SIRecordTypeId;
        caseInfo.SPEN_MPANCore__c = '1800000000';
        caseInfo.SPEN_AssetConditionCode__c = 'B06';
        caseInfo.SPEN_FlowReceivedDate__c = Datetime.now();
        insert caseInfo;
        //insert caseInfo;
        // Call the helper method
        Test.startTest();
        List<SPEN_CaseInformation__c> caseInfosToUpdate = new List<SPEN_CaseInformation__c>{caseInfo};
            if(!caseInfosToUpdate.isEmpty() && caseInfosToUpdate.size() > 0 ){
                SPEN_CaseInformationTriggerHandler.calculateAndSetDates(caseInfosToUpdate);
            }
        SPEN_CaseInformationInterface handler = new SPEN_CaseInformationInterface();
        handler.beforeInsert(new List<SObject>{caseInfo});
        Test.stopTest();
    }
    @isTest
    static void calculateAndSetDatesTestNull() {
        // Create test data
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'SPEN GE SPD Business Hours' LIMIT 1];
        SPEN_CaseInformation__c caseInfo = new SPEN_CaseInformation__c(SPEN_FlowReceivedDate__c = null);
        insert caseInfo;
        // Call the helper method
        Test.startTest();
        List<SPEN_CaseInformation__c> caseInfosToUpdate = new List<SPEN_CaseInformation__c>{caseInfo};
            if(!caseInfosToUpdate.isEmpty() && caseInfosToUpdate.size() > 0 ){
                SPEN_CaseInformationTriggerHandler.calculateAndSetDates(caseInfosToUpdate);
        SPEN_CaseInformationInterface handler = new SPEN_CaseInformationInterface();
        handler.beforeInsert(new List<SObject>{caseInfo});
            }
        Test.stopTest();
    }
}