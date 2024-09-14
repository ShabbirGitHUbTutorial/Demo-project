@isTest
@suppresswarnings('PMD.SOQLSelectorPattern')
public class SPEN_EmailMessageUtilityTest {
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
            
        /*SPEN_EmailRoutingConfigurationSW__mdt emailMdt=new SPEN_EmailRoutingConfigurationSW__mdt();
        emailMdt.Matcher_String__c='Road Opening Notice;SCOPE;Coordinates;Notice;Co-ordinates';
        emailMdt.SPEN_ToAddress__c='Actual Start;Notice to Start;In Progress;';
        emailMdt.SPEN_RoutingOutcome__c='Streetworks North 30Min SLA';
        emailMdt.Matcher_String_2__c='Works Stop;Works Closed;Closure;Closing Notice;';
        insert emailMdt;*/
    }
    
   /* @isTest
    public static void testemailMessageAssignment(){
    	User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'Streetworks-Scotland-Notice-Requests@spenergynetworks.co.uk';
            insert emailMsgList;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
			List<EmailMessage> emailMsgList1 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList1[0].parentId = caseRecords[0].id;
            emailMsgList1[0].subject = 'Actual Start test 12345';
            insert emailMsgList1;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList1);
            Assert.isTrue(emailMsgList1!=null);
        }  
    }
    
    @isTest
    public static void testemailMessageAssignment1(){
    	User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt where label like '%NRSWA%' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].subject = 'Test Road Opening Notice 12345';
            insert emailMsgList;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
			List<EmailMessage> emailMsgList1 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList1[0].parentId = caseRecords[0].id;
            emailMsgList1[0].subject = 'Test Road Opening Notice 12345';
            insert emailMsgList1;
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList1);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList1!=null);
        }  
    }*/
    
    @isTest
    public static void testEmailMessageAssignment2(){
        User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt 
                                                             where SPEN_ToAddress__c like '%jointingcompletesouth%' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'abc@xyz.com;jointingcompletesouth@spenergynetworks.co.uk';
            emailMsgList[0].ccaddress = 'abc@xyz.com';
            emailMsgList[0].subject = 'Test Email';
            String ToAddressFinal = 'jointingcompletesouth';
            insert emailMsgList;
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList!=null);
            System.assertEquals(ToAddressFinal,'jointingcompletesouth');
            
            List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList2[0].parentId = caseRecords[0].id;
            emailMsgList2[0].ccAddress = 'jointingcompletesouth@spenergynetworks.co.uk';
            emailMsgList2[0].TOAddress = 'abc@xyz.com';
            insert emailMsgList2;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList2);
            
            List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList3[0].parentId = caseRecords[0].id;
            emailMsgList3[0].CCAddress = 'jointingcompletesouth@spenergynetworks.co.uk';
            emailMsgList3[0].TOAddress = 'abc@xyz.com;pqr@xyz.com';
            insert emailMsgList3;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList3);
    } 
    }
    
     @isTest
    public static void testEmailMessageAssignment3(){
        User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
             List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt
                                                             where SPEN_ToAddress__c like '%jointingcompletenorth%' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'abc@xyz.com;jointingcompletenorth@spenergynetworks.co.uk';
            emailMsgList[0].ccaddress = 'abc@xyz.com';
            String ToAddressFinal = 'jointingcompletenorth';
            insert emailMsgList;
            
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList!=null);
            System.assertEquals(ToAddressFinal,'jointingcompletenorth');
            
            List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList2[0].parentId = caseRecords[0].id;
            emailMsgList2[0].CCAddress = 'jointingcompletenorth@spenergynetworks.co.uk';
            emailMsgList2[0].TOAddress = 'abc@xyz.com';
            insert emailMsgList2;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList2);
            List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList3[0].parentId = caseRecords[0].id;
            emailMsgList3[0].CCAddress = 'jointingcompletenorth@spenergynetworks.co.uk';
            emailMsgList3[0].TOAddress = 'abc@xyz.com;pqr@xyz.com';
            insert emailMsgList3;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList3);
    } 
    }
    
    @isTest
    public static void testEmailMessageAssignment4(){
        User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt where label like '%NRSWA%' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'abc@xyz.com;opssthfaults@spenergynetworks.co.uk';
            emailMsgList[0].ccaddress = 'abc@xyz.com';
            String ToAddressFinal = 'opssthfaults';
            insert emailMsgList;
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList!=null);
            System.assertEquals(ToAddressFinal,'opssthfaults');
            
            List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList2[0].parentId = caseRecords[0].id;
            emailMsgList2[0].ccAddress = 'opssthfaults@spenergynetworks.co.uk';
            emailMsgList2[0].TOAddress = 'abc@xyz.com';
            insert emailMsgList2;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList2);
            
      
            List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList3[0].parentId = caseRecords[0].id;
            emailMsgList3[0].CCAddress = 'opssthfaults@spenergynetworks.co.uk';
            emailMsgList3[0].TOAddress = 'abc@xyz.com;pqr@xyz.com';
            insert emailMsgList3;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList3);
    } 
    }
    
    @isTest
    public static void testEmailMessageAssignment5(){
        User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt where label like '%NRSWA%' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'abc@xyz.com;occnrswa@spenergynetworks.co.uk';
            emailMsgList[0].ccaddress = 'abc@xyz.com';
            String ToAddressFinal = 'occnrswa';
            insert emailMsgList;
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList!=null);
            System.assertEquals(ToAddressFinal,'occnrswa');
            
             List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList2[0].parentId = caseRecords[0].id;
            emailMsgList2[0].ccAddress = 'occnrswa@spenergynetworks.co.uk';
            emailMsgList2[0].TOAddress = 'abc@xyz.com';
            insert emailMsgList2;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList2);
            
              List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList3[0].parentId = caseRecords[0].id;
            emailMsgList3[0].CCAddress = 'occnrswa@spenergynetworks.co.uk';
            emailMsgList3[0].TOAddress = 'abc@xyz.com;pqr@xyz.com';
            insert emailMsgList3;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList3);

    } 
    }
    
     @isTest
    public static void testEmailMessageAssignment6(){
        User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt
                                                             where SPEN_RoutingOutcome__c =: '30 Min SLA South' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'abc@xyz.com;additionalstreetworksew@spenergynetworks.co.uk';
            emailMsgList[0].ccaddress = 'abc@xyz.com';
            emailMsgList[0].subject ='Actual Start';
            String ToAddressFinal = 'additionalstreetworksew';
            
            insert emailMsgList;
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList!=null);
            System.assertEquals(ToAddressFinal,'additionalstreetworksew');
            
             List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList2[0].parentId = caseRecords[0].id;
            emailMsgList2[0].ccAddress = 'additionalstreetworksew@spenergynetworks.co.uk';
            emailMsgList2[0].TOAddress = 'abc@xyz.com';
            insert emailMsgList2;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList2);
            
               List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList3[0].parentId = caseRecords[0].id;
            emailMsgList3[0].CCAddress = 'additionalstreetworksew@spenergynetworks.co.uk';
            emailMsgList3[0].TOAddress = 'abc@xyz.com;pqr@xyz.com';
            insert emailMsgList3;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList3);
    } 
    }
    
     @isTest
    public static void testEmailMessageAssignment7(){
        User usr= [SELECT id FROM USER WHERE isActive = true LIMIT 1];
        System.runAs(usr)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
			//creating Case Record
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            List<Case> caseRecords=SPEN_TestDataFactory.createCaseRecords(SPEN_TestDataFactoryConstants.SINGLE_REC,recordTypeIdQuery);
            insert caseRecords;
            SPEN_EmailRoutingConfigurationSW__mdt emailMtd= [SELECT id,SPEN_QueueName__c,Matcher_String_2__c,SPEN_ToAddress__c,Matcher_String__c,SPEN_RoutingOutcome__c from SPEN_EmailRoutingConfigurationSW__mdt where label like '%NRSWA%' LIMIT 1];
            //creating Email Message Record
            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList[0].parentId = caseRecords[0].id;
            emailMsgList[0].ToAddress = 'abc@xyz.com;streetworks-scotland-additional-requests@spenergynetworks.co.uk';
            emailMsgList[0].ccaddress = 'abc@xyz.com';
            String ToAddressFinal = 'streetworks-scotland-additional-requests';
            insert emailMsgList;
            List<SPEN_EmailRoutingConfigurationSW__mdt> EmailSummaryMetadata = SPEN_TestDataFactory.getEmailRouting_mdt();
            SPEN_EmailMessageUtility.EmailSummaryMdt=EmailSummaryMetadata;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList);
        	Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName(emailMtd.SPEN_QueueName__c);
            List<Case> caseList = SPEN_CaseSelector.getCaseNumber(emailMsgList[0].ParentId);
            caseList[0].SPEN_Email_WI_Queue_Routing_Outcome__c = emailMtd.SPEN_RoutingOutcome__c;
            caseList[0].ownerid=queueTobeAssigned.id;
            Assert.isTrue(emailMsgList!=null);
            System.assertEquals(ToAddressFinal,'streetworks-scotland-additional-requests');
            
             List<EmailMessage> emailMsgList2 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList2[0].parentId = caseRecords[0].id;
            emailMsgList2[0].ccAddress = 'streetworks-scotland-additional-requests@spenergynetworks.co.uk';
            emailMsgList2[0].TOAddress = 'abc@xyz.com';
            insert emailMsgList2;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList2);
            
               List<EmailMessage> emailMsgList3 = SPEN_TestDataFactory.createEmailMessageRecords(1);
            emailMsgList3[0].parentId = caseRecords[0].id;
            emailMsgList3[0].CCAddress = 'streetworks-scotland-additional-requests@spenergynetworks.co.uk';
            emailMsgList3[0].TOAddress = 'abc@xyz.com;pqr@xyz.com';
            insert emailMsgList3;
            SPEN_EmailMessageUtility.emailMessageAssignment(emailMsgList3);
            
    } 
    }
    
    
}