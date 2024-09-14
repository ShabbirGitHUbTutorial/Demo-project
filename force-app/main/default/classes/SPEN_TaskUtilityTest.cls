/*-----------------------------------------------------------------------------
DESCRIPTION :   Unit test class for Task Utility and Task Trigger
AUTHOR      :   Amrita Sarkar
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
June-30-2023    Amrita Sarkar         Initial version
-----------------------------------------------------------------------------*/
@IsTest
public  with sharing class SPEN_TaskUtilityTest {
 /***************************************************************************
* @Author:      Amrita Sarkar
* @Date:        30/06/2023
* @Description: Method to specifically for test coverage of Task utility class
*****************************************************************************/
 @testsetup
    public static void setupdata(){
       Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
    }
/***************************************************************************
* @Author:      Amrita Sarkar
* @Date:        30/06/2023
* @Description: Method for test coverage of Pre quote Task  Creation
*****************************************************************************/
    @IsTest
    Public static void duplicatePreQuoteTaskTest() 
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
        System.runAs(user)
        {   
          try
            {
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                List<Case> conCaseList = new List<Case>();
                Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                Case conCase = new Case();
                conCase.ContactId = ct.Id;
                conCase.Origin = 'Email';
                conCase.RecordTypeId = recordTypeIdFormal;
                conCase.Status ='Open';
                insert conCase;
                Id preQuoteRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SPEN_PreQuoteContactTask').getRecordTypeId();
                Task newTask = new Task();
            	newTask.WhatId = conCase.id;
            	newTask.RecordTypeId = preQuoteRecordTypeId;
            	newTask.Status = 'Not Started';
                newTask.SPEN_TaskType__c = 'Pre-Quote Contact';
            	newTask.Subject = 'TestTaskPreQuote';
            	insert newTask;
            	Task duplicatePreTask = new Task();
            	duplicatePreTask.WhatId = conCase.id;
            	duplicatePreTask.RecordTypeId = preQuoteRecordTypeId;
            	duplicatePreTask.Status = 'Not Started';
                duplicatePreTask.SPEN_TaskType__c = 'Pre-Quote Contact';
            	duplicatePreTask.Subject = 'TestTaskPreQuote';
            	insert duplicatePreTask;
                Test.stopTest();
                Assert.areEqual(duplicatePreTask.Id,Null);
            }
            catch(Exception ex)
            {
                System.assert(ex != NULL);
            }
        }
    }
/***************************************************************************
* @Author:      Amrita Sarkar
* @Date:        30/06/2023
* @Description: Method for test coverage of Post Enquiry Task  Creation
*****************************************************************************/    
    @IsTest
    Public static void duplicatePostEnquiryTaskTest() 
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
        System.runAs(user)
        {   
          try
            {
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                List<Case> conCaseList = new List<Case>();
                Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                Case conCase = new Case();
                conCase.ContactId = ct.Id;
                conCase.Origin = 'Email';
                conCase.RecordTypeId = recordTypeIdFormal;
                conCase.Status ='Open';
                insert conCase;
                Id preQuoteRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SPEN_PreQuoteContactTask').getRecordTypeId();
                Task newTask = new Task();
            	newTask.WhatId = conCase.id;
            	newTask.RecordTypeId = preQuoteRecordTypeId;
            	newTask.Status = 'Not Started';
                newTask.SPEN_TaskType__c = 'Post Enquiry Contact';
            	newTask.Subject = 'TestTaskPostEnquiry';
            	insert newTask;
            	Task duplicatePostTask = new Task();
            	duplicatePostTask.WhatId = conCase.id;
            	duplicatePostTask.RecordTypeId = preQuoteRecordTypeId;
            	duplicatePostTask.Status = 'Not Started';
                duplicatePostTask.SPEN_TaskType__c = 'Post Enquiry Contact';
            	duplicatePostTask.Subject = 'TestTaskPostEnquiry';
            	insert duplicatePostTask;
                Test.stopTest();
                Assert.areEqual(duplicatePostTask.Id,Null);
            }
            catch(Exception ex)
            {
                System.assert(ex != NULL);
            }
        }
    }
    
}