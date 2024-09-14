@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_InsertVABatchAllCusToggleTEST {
    @IsTest
    private static void testInsertVABatchAllCusToggle()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps8 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps8.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_OutboundContactHoursCRU']; //Riccha Mohanty-24-01-2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];//Riccha Mohanty-24-01-2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessR'];//Riccha Mohanty-24-01-2023
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps12.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);
        
        System.runAs(user)
        {
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
             Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();

            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c(); 
            message=new SPEN_IVRMessage__c();
            message.Name='Test IVR';
            message.SPEN_IVRMessage__c='The following information is only for the //////customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created'; //Riccha Mohanty 24-01-2023
            message.SPEN_ExternalId__c = 'Case-Creation-Message';
            insert message;
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_PSR__c=true;
            insert con;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
            insert testCase;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='SP';
            insert inc;
            testCase[0].SPEN_Incident__c=inc.Id;
            update testCase;
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiseList; 
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_Role__c='Customer';
            insert conpremise;
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            cSeting.Name='OutboundIncidentType';
          	insert cSeting;
            List<SPEN_ImpactedPremise__c> impList=SPEN_TestDataFactory.createImpactedPremiserecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            impList[0].SPEN_Status__c='Not Restored';
            impList[0].SPEN_RelatedIncident__c=inc.Id;
            impList[0].SPEN_ContactPremise__c=conpremise.Id;
            insert impList;
            List<SPEN_VoiceAlert__c> alertList=SPEN_TestDataFactory.createVoiceAlertrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert alertList;
            Datetime scTime=System.now().addDays(1);
            
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            
            cron=second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
            SPEN_InsertVoiceAlertBatchAllCusToggle obj=new SPEN_InsertVoiceAlertBatchAllCusToggle(inc.id, 'Toggle');
            Database.executeBatch(obj);
            Assert.isNotNull(obj);
            Test.stopTest();
        }
    }
}