@IsTest
public with sharing class SPEN_TasksTest 
{
    @IsTest
    private static void newTaskCreateTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_AccountCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        
        System.runAs(user)
        {
            Test.startTest();
            SPEN_IVRMessage__c ivrMessage = SPEN_TestDataFactory.createIVRMessage(1);
            Insert ivrMessage;
            
            SPEN_Zone__c spdZoneParent = SPEN_TestDataFActory.createZoneRecords(ivrMessage.id);
            spdZoneParent.name = 'Ayrshire';
            spdZoneParent.SPEN_Type__c = 'Zone';
            insert spdZoneParent;
            
            SPEN_Zone__c spdZone = SPEN_TestDataFActory.createZoneRecords(ivrMessage.id);
            spdZone.name = 'CLYDE SOUTH';
            spdZone.SPEN_Type__c = 'Zone';
            spdZone.SPEN_Parent__c = spdZoneParent.Id;
            insert spdZone;
            
            List<SPEN_Premise__c> spdPremise = SPEN_TestDataFActory.createListOfPremise(1);
            spdPremise[0].SPEN_Zone__c = spdZone.id;
            insert spdPremise;
            SPEN_MPAN__c mpanList1 = SPEN_TestDataFactory.createMPANRecords(1);
            mpanList1.SPEN_ConnectionStatus__c='Energised';
            mpanList1.SPEN_Premise__c =spdPremise[0].Id;
            insert mpanList1;
            
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<Task> taskList = new List<Task>();
            Map<id,Contact> oldmap = new Map<id,Contact>();
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            insert testAccount;
            Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            oldmap.put(ct.id, ct);
            insert ct;
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_SendtoPowerOn__c = true;
            cse.SPEN_CallerInitials__c = ct.Salutation;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.SPEN_CallerTitle__c = ct.Suffix;
            cse.SPEN_AddressPremise__c = SPDPremise[0].id;
            cse.status='Restored';
            insert cse;
            //cse.RecordTypeId = caseRecType;
            //Database.SaveResult saveRes = Database.insert(cse);
            
            Task tsk = new Task();
            tsk.SPEN_DiarySubject__c = 'Chasers';
            tsk.Subject = 'Call';
            tsk.Priority = 'Normal';
            tsk.Status = 'Open';
            tsk.WhatId = cse.Id;
            insert tsk;
            taskList.add(tsk);
            SPEN_Tasks.beforeTaskInsert(taskList);
            System.assertEquals('Normal',tsk.Priority,'Task priority value');
            //Assert.areEqual('Normal',tsk.Priority,'Task priority value');

             Case caseGE = SPEN_TestDataFactory.createGECase(1)[0];
             caseGE.SPEN_AddressPremise__c = SPDPremise[0].id;
            insert caseGE;
         
            
            Task taskGE = new Task();
            taskGE.Subject = system.label.SPEN_GEAcknowledgementTaskSubject;
            taskGE.Priority = 'Normal';
            taskGE.Status = 'Open';
            taskGE.WhatId = caseGE.Id;
            insert taskGE;
            
             Task taskGE2 = new Task();
            taskGE2.Subject = system.label.SPEN_GEPlanofWorkTaskSubject;
            taskGE2.Priority = 'Normal';
            taskGE2.Status = 'Open';
            taskGE2.WhatId = caseGE.Id;
            insert taskGE2;
            //taskList.add(taskGE);
           
            SPEN_Tasks.beforeTaskInsert(taskList);
            Test.stopTest();
        }
    }
}