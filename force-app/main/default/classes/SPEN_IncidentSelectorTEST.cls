@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_IncidentSelectorTEST {
	@IsTest
    private static void testgetRelatedCaseInfo()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        System.runAs(user){
            Test.startTest();
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            SPEN_ConfigurableSettings__c getAffectedPremiseINCType = new SPEN_ConfigurableSettings__c(SPEN_Feature__c='Outbound Dialler',SPEN_Value__c='20',SPEN_Description__c='IC wants to confirm the impacted premise in powerOn and then GetAffectedPremise batch to be called so minutes to add a delay',Name='CreationBatchDelay');
			insert getAffectedPremiseINCType;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert inc;
            Set<Id> incIds = new Set<Id>();
            incIds.add(inc.Id);
            SPEN_IncidentSelector.getRelatedCaseInfo(incIds);
            IncidentSelector.getRelatedCaseInfo(incIds);
            Assert.isTRUE(inc != NULL);
            Test.stopTest();
        }
    }
    @IsTest
    private static void testgetIncidentRecord()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        System.runAs(user){
            Test.startTest();
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            cSeting.Name='OutboundIncidentType';
            insert cSeting;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            SPEN_ConfigurableSettings__c getAffectedPremiseINCType = new SPEN_ConfigurableSettings__c(SPEN_Feature__c='Outbound Dialler',SPEN_Value__c='20',SPEN_Description__c='IC wants to confirm the impacted premise in powerOn and then GetAffectedPremise batch to be called so minutes to add a delay',Name='CreationBatchDelay');
			insert getAffectedPremiseINCType;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert inc;
            if(inc.IncidentNumber != null){
                SPEN_IncidentSelector.getIncidentRecord(inc.IncidentNumber);
            }
            Assert.areEqual(testCase[0].Origin,'Web','case origin value is web');
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void testgetRelatedIncInfoForStatusUnchecked()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet conSettings = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = conSettings.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        System.runAs(user){
            Test.startTest();
            SPEN_ConfigurableSettings__c getAffectedPremiseINCType = new SPEN_ConfigurableSettings__c(SPEN_Feature__c='Outbound Dialler',SPEN_Value__c='20',SPEN_Description__c='IC wants to confirm the impacted premise in powerOn and then GetAffectedPremise batch to be called so minutes to add a delay',Name='CreationBatchDelay');
			insert getAffectedPremiseINCType;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_StatusUpdated__c=true;
            insert inc;
            Set<Id> incIds = new Set<Id>();
            incIds.add(inc.Id);
            SPEN_IncidentSelector.getRelatedIncInfoForStatusUnchecked(incIds);
            IncidentSelector.getRelatedIncInfoForStatusUnchecked(incIds);
            Assert.isTrue(inc!=null);
            Test.stopTest();
        }
    }
    @IsTest
    private static void testgetIncndtToCaseMetaDataMapList()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        System.runAs(user){
            Test.startTest();
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            insert testCase;
            SPEN_ConfigurableSettings__c getAffectedPremiseINCType = new SPEN_ConfigurableSettings__c(SPEN_Feature__c='Outbound Dialler',SPEN_Value__c='20',SPEN_Description__c='IC wants to confirm the impacted premise in powerOn and then GetAffectedPremise batch to be called so minutes to add a delay',Name='CreationBatchDelay');
			insert getAffectedPremiseINCType;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentStatus__c='Awaiting';
            insert inc;
            SPEN_IncidentSelector.getIncndtToCaseMetaDataMapList(inc.SPEN_IncidentStatus__c);
            IncidentSelector.getIncndtToCaseMetaDataMapList(inc.SPEN_IncidentStatus__c);
            IncidentSelector.getIncidentRecord(inc.IncidentNumber);
            Assert.areEqual(inc.SPEN_IncidentStatus__c,'Awaiting','incident status value is Awaiting');
            Test.stopTest();
        }
        
    }
    @isTest
    private static void testgetIncndtToCaseMetaDataInfo()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        PermissionSet conSettings = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = conSettings.Id);
        System.runAs(user){
            Test.startTest();
            SPEN_Incident_to_case_status_mapping__mdt incToCaseList = new SPEN_Incident_to_case_status_mapping__mdt( SPEN_IncidentStatus__c = 'Cancelled', SPEN_CaseStatus__c = 'Cancelled');
            SPEN_IncidentSelector.getIncndtToCaseMetaDataInfo();
            IncidentSelector.getIncndtToCaseMetaDataInfo();
            Assert.isNotNull(incToCaseList, 'Incident to Case Passed');
            Test.stopTest();
        }
    }
     @IsTest
    private static void testgetIncidentRecordwithStatus()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        PermissionSet conSettings = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = conSettings.Id);
        System.runAs(user){
            Test.startTest();
            List<Incident> inc = SPEN_TestDataFactory.createListofIncidents(SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc[0].SPEN_IncidentStatus__c = 'Complete';
            inc[0].SPEN_IncidentID__c = 'Test123';
            insert inc[0];
            
            SPEN_IncidentSelector.getIncidentRecordWithoutClosedStatus(inc[0].SPEN_IncidentID__c);
            Assert.isNotNull(inc[0].SPEN_IncidentStatus__c, 'Complete');
            Test.stopTest();
        }
    }
    @IsTest
    private static void testgetIncidentRecordwithStatusAwaiting()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        PermissionSet conSettings = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = conSettings.Id);
        System.runAs(user){
            Test.startTest();
            List<Incident> inc = SPEN_TestDataFactory.createListofIncidents(SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc[0].SPEN_IncidentStatus__c = 'Awaiting';
            inc[0].SPEN_IncidentID__c = 'Test123';
            insert inc[0];
            SPEN_IncidentSelector.getIncidentRecordWithoutClosedStatus(inc[0].SPEN_IncidentID__c);
            SPEN_IncidentSelector.getIncidentRecord(inc[0].SPEN_IncidentID__c);
            Assert.isNotNull(inc[0].SPEN_IncidentStatus__c, 'Awaiting');
            Test.stopTest();
        }
    }    
}