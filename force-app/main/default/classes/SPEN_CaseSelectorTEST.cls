@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_CaseSelectorTEST 
{
    @IsTest
    private static void testgetCustomerInfo()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);  
        PermissionSet incidentAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = incidentAccess.Id);       
        System.runAs(user)
        {   
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ConfigurableSettings__c configSetting =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert configSetting;
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
            Contact cont = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert cont;
            
            List<Incident> incList = SPEN_TestDataFactory.createListofIncidents(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert incList;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(2);
            testCase[0].Origin = 'Web';
            testCase[1].SPEN_Incident__c = incList[0].Id;
            insert testCase;
            
            Set<Id> caseIds = new Set<Id>();
            caseIds.add(testCase[0].Id);
            
            List<Case> caseList = SPEN_CaseSelector.getUncheckedSendToPowerOnCaseList(caseIds);    
            Contact conRec = SPEN_CaseSelector.getCustomerInfo(cont.Id);
            List<Group> groupList = SPEN_CaseSelector.getQueueDetails();
            Case caseRec = SPEN_CaseSelector.getCancelCse(caseIds);
            Case caseRecord = SPEN_CaseSelector.getUpdateCse(caseIds);
            SPEN_CaseSelector.getCaseNumber(testCase[0].Id);
            SPEN_CaseSelector.getCaseRecord();
            SPEN_CaseSelector.getCaseFromIncRecId(incList[0].Id);
            SPEN_CaseSelector.getCaseFromIncidentids(new Set<String>{incList[0].SPEN_IncidentID__c});
            Assert.isNotNull(conRec, 'Customer Information Passed');
            Test.stopTest();
        }
    }
}