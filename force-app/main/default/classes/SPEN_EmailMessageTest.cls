@isTest
public with sharing class SPEN_EmailMessageTest 
{
    @testSetup static void setup(){
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
    	Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        //creating User
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {   
            //creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            caseRecords[0].SPEN_Type__c = 'Streetworks';
            
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            emailMsgList[0].parentId = caseRecords[0].id;
            insert emailMsgList;
            
        }
    }
    
    @isTest
    public static void testCalculateAgentResponeTime(){
    	User usr= [SELECT id FROM USER WHERE isActive= true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Test.startTest();
            Case caseRec = [SELECT id FROM Case WHERE RecordTypeId =:recordTypeIdQuery LIMIT 1];
            EmailMessage emailMsgRec = [SELECT id,CreatedDate FROM EmailMessage where ReplyToEmailMessageId=null LIMIT 1];
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            emailMsgList[0].ParentId = caseRec.Id;
            emailMsgList[0].Incoming=false;
            emailMsgList[0].ReplyToEmailMessageId=emailMsgRec.Id;
			insert emailMsgList;
            Test.stopTest();
            EmailMessage emailMsgRecUpdate = [SELECT id,CreatedDate,SPEN_AgentResponseTime__c FROM EmailMessage where id =:emailMsgRec.id LIMIT 1];
            Date dt1 = System.today();
            Date dt2 = Date.valueOf(emailMsgRecUpdate.createdDate);
            System.assertEquals(emailMsgRecUpdate.SPEN_AgentResponseTime__c,dt2.daysBetween(dt1));
        }
    }
    
	@IsTest
    Public static void testEmailMessageCaseStatusUpdate()
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
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCustomerJourney'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
            
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Case cse = new Case();
            cse.RecordTypeId = recordTypeIdQuery;
 	cse.SPEN_Type__c = 'Third Party Damage';
            cse.Status = 'Closed';
            insert cse;

            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            emailMsgList[0].ParentId = cse.Id;
			insert emailMsgList;
            Test.stopTest();
            Case cseRec = [Select Id, Status from Case where id=:cse.Id];
            System.assertEquals(cseRec.Status, 'Open');
            
            /*List<EmailMessage> emailMsgList1 = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,'streetworks-scotland-additional-requests');
            emailMsgList1[0].ParentId = cse.Id;
			insert emailMsgList1;
            //Test.stopTest();
            Case cseRec1 = [Select Id, Status from Case where id=:cse.Id];
            System.assertEquals(cseRec1.Status, 'Open');*/
        }
    }
    
   /* @IsTest
    Public static void testEmailMessageCaseStatusUpdate1()
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
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCustomerJourney'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
            
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Case cse = new Case();
            cse.RecordTypeId = recordTypeIdQuery;
 			cse.SPEN_Type__c = 'Streetworks';
            cse.Status = 'Closed';
            cse.SPEN_Email_WI_Queue_Routing_Outcome__c='30 Min SLA South';
            insert cse;

            List<EmailMessage> emailMsgList1 = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_StreetworksJointingNorthAddress);
            emailMsgList1[0].ParentId = cse.Id;
			insert emailMsgList1;
            
            cse.Status = 'Closed';
            update cse;
            
            List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_StreerworksAdditionalRequestSouthAddress);
            emailMsgList2[0].ParentId = cse.Id;
			insert emailMsgList2;

            
            Case cseRec3 = [Select Id, Status,SPEN_Email_WI_Queue_Routing_Outcome__c from Case where id=:cse.Id];
            Test.stopTest();
            System.assertEquals(cseRec3.Status, 'Open');
        }
    }*/
    
    @IsTest
    Public static void testEmailMessageCaseStatusUpdateCCAddresss()
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
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCustomerJourney'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
            
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Case cse = new Case();
            cse.RecordTypeId = recordTypeIdQuery;
 			cse.SPEN_Type__c = 'Streetworks';
            cse.Status = 'closed';
            cse.SPEN_Email_WI_Queue_Routing_Outcome__c='1 Hr SLA South';
            insert cse;
            
            Case cse3 = new Case();
            cse3.RecordTypeId = recordTypeIdQuery;
 			cse3.SPEN_Type__c = 'Streetworks';
            cse3.Status = 'closed';
            cse3.SPEN_Email_WI_Queue_Routing_Outcome__c='30 Min SLA South';
            insert cse3;
            
            Case cse1 = new Case();
            cse1.RecordTypeId = recordTypeIdQuery;
 			cse1.SPEN_Type__c = 'NRSWA';
            cse1.Status = 'closed';
            cse1.SPEN_Email_WI_Queue_Routing_Outcome__c='4 Hr SLA North-Lowest';
            insert cse1;
            
            Case cse2 = new Case();
            cse2.RecordTypeId = recordTypeIdQuery;
 			cse2.SPEN_Type__c = 'NRSWA';
            cse2.Status = 'closed';
            cse2.SPEN_Email_WI_Queue_Routing_Outcome__c='4 Hr SLA South-Lowest';
            insert cse2;
            
            List<EmailMessage> insertEmail=new List<EmailMessage>();
            List<EmailMessage> emailMsgList1 = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_StreerworksAdditionalRequestSouthAddress);
            emailMsgList1[0].ParentId = cse.Id;
			insertEmail.add(emailMsgList1[0]);
            
            List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecordsCCAddress(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_NRSWANorthAddress);
            emailMsgList2[0].ParentId = cse1.Id;
			insertEmail.add(emailMsgList2[0]);
            
            List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecordsCCAddress(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_NRSWASouthAddress);
            emailMsgList3[0].ParentId = cse2.Id;
			insertEmail.add(emailMsgList3[0]);
            
            List<EmailMessage> emailMsgList4 = SPEN_TestDataFactory.createEmailMessageRecordsCCAddress(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_StreerworksAdditionalRequestSouth);
            emailMsgList4[0].ParentId = cse3.Id;
			insertEmail.add(emailMsgList4[0]);
            
            insert insertEmail;
            
             Test.stopTest();
            Case cseRec3 = [Select Id, Status,SPEN_Email_WI_Queue_Routing_Outcome__c from Case where id=:cse.Id];
            System.assertEquals(cseRec3.Status, 'Open');
        }
    }
    
    @IsTest
    Public static void testEmailMessageCaseStatusUpdateBCCAddresss()
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
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCustomerJourney'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
            
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Case cse = new Case();
            cse.RecordTypeId = recordTypeIdQuery;
 			cse.SPEN_Type__c = 'Streetworks';
            cse.Status = 'closed';
            cse.SPEN_Email_WI_Queue_Routing_Outcome__c='1 Hr SLA South';
            insert cse;
            
            Case cse3 = new Case();
            cse3.RecordTypeId = recordTypeIdQuery;
 			cse3.SPEN_Type__c = 'Streetworks';
            cse3.Status = 'closed';
            cse3.SPEN_Email_WI_Queue_Routing_Outcome__c='30 Min SLA South';
            insert cse3;
            
            Case cse1 = new Case();
            cse1.RecordTypeId = recordTypeIdQuery;
 			cse1.SPEN_Type__c = 'NRSWA';
            cse1.Status = 'closed';
            cse1.SPEN_Email_WI_Queue_Routing_Outcome__c='4 Hr SLA North-Lowest';
            insert cse1;
            
            Case cse2 = new Case();
            cse2.RecordTypeId = recordTypeIdQuery;
 			cse2.SPEN_Type__c = 'NRSWA';
            cse2.Status = 'closed';
            cse2.SPEN_Email_WI_Queue_Routing_Outcome__c='4 Hr SLA South-Lowest';
            insert cse2;
            
            List<EmailMessage> insertEmail=new List<EmailMessage>();
            List<EmailMessage> emailMsgList1 = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_StreerworksAdditionalRequestSouthAddress);
            emailMsgList1[0].ParentId = cse.Id;
			insertEmail.add(emailMsgList1[0]);
            
            List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecordsBCCAddress(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_NRSWANorthAddress);
            emailMsgList2[0].ParentId = cse1.Id;
			insertEmail.add(emailMsgList2[0]);
            
            List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecordsBCCAddress(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_NRSWASouthAddress);
            emailMsgList3[0].ParentId = cse2.Id;
			insertEmail.add(emailMsgList3[0]);
            
            List<EmailMessage> emailMsgList4 = SPEN_TestDataFactory.createEmailMessageRecordsBCCAddress(SPEN_TestDataFactoryConstants.SINGLE_REC,System.Label.SPEN_StreerworksAdditionalRequestSouth);
            emailMsgList4[0].ParentId = cse3.Id;
			insertEmail.add(emailMsgList4[0]);
            
            insert insertEmail;
            
             Test.stopTest();
            Case cseRec3 = [Select Id, Status,SPEN_Email_WI_Queue_Routing_Outcome__c from Case where id=:cse.Id];
            System.assertEquals(cseRec3.Status, 'Open');
        }
    }
            
}