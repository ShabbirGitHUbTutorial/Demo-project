/*-----------------------------------------------------------------------------
DESCRIPTION :   Test class for SPEN_UpdateCheckboxQueueable
AUTHOR      :   Sheker Kulkacherla
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0
HISTORY     :
Date            Author              Comment
Jun-28-2023     Sheker Kulkacherla         Initial version
-----------------------------------------------------------------------------*/ 
@isTest
public with sharing class SPEN_UpdateCheckboxQueueable_Test {
     static final string INTEGRATION_PROFILE='SPEN_IntegrationRequestAccessCRU';
    @isTest
    @SuppressWarnings('PMD.SOQLSelectorPattern')
    private static void setUp()
    {
        //Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        user.isActive=true;
        user.Firstname='ZoneTestUser';
        Database.insert(user);
        PermissionSet ps1=SPEN_TestdataSelector.getPermissionSet(INTEGRATION_PROFILE);
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);  
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);	
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
		System.runAs(user)
        {
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cSeting;
            SPEN_ConfigurableSettings__c cSeting1= SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cSeting1;
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            List<Case> cs = SPEN_TestDataFactory.createListOfCases(3); 
            cs[0].Origin = 'Web';
            cs[0].Status = 'Restored';
            cs[1].Origin = 'Web';
            cs[1].Status = 'Restored';
            cs[2].Origin = 'Web';
            cs[2].Status = 'Restored';
            insert cs;
            List<Incident> incRecords = new List<Incident>();
            Test.startTest();         
            Incident inc = SPEN_TestDataFactory.createIncidents(cs[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='HV_S';
            inc.SPEN_IncidentStatus__c = 'Awaiting';
            insert inc;
            Set<Id> incIdSet = new Set<Id>();
            Incident inc1 = SPEN_TestDataFactory.createIncidents(cs[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc1.subject = 'Test Incident1';
            inc1.ParentIncidentId = inc.Id;
            inc1.SPEN_IncidentType__c='SP';
            inc1.SPEN_IncidentStatus__c = 'Awaiting';
            inc1.SPEN_StatusUpdated__c = true;
            insert inc1;
            incIdSet.add(inc.id);
            incIdSet.add(inc1.id);
            //SPEN_UpdateCheckboxQueueable ucq = new SPEN_UpdateCheckboxQueueable();
			//ucq.SPEN_UpdateCheckboxQueueable(incIdSet);
            //ID jobID = System.enqueueJob(ucq);
            System.enqueueJob(new SPEN_UpdateCheckboxQueueable(incIdSet));
            Assert.areEqual('Test Incident1', inc1.subject, 'subject line');
            Test.stopTest();
        }
    }
}