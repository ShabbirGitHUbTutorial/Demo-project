@IsTest
public class SPEN_SyncContactsBatchTEST {
    @IsTest
     private static void testBatchexecute()
    {	
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_StagingCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SEL_BatchFrameworkUser'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        System.runAs(user)
        {   
           
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            //accRec[0].SPEN_ExternalID__c = 'Prem_1';
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPENAdqmLastSyncDateTime__c=system.now()-1;
            con.SPEN_CustomerID__c = 'Con00002';
        	insert con;
            List<SPEN_Premise__c> lstPremise = SPEN_TestDataFactory.createListOfPremise(1);
            lstPremise[0].SPEN_PremiseID__c = 'Prem_12345';
            insert lstPremise;
            
            List<SPEN_ContactStaging__c> conListInsert=SPEN_TestDataFactory.createContactStagingrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            conListInsert[0].SPEN_ExternalId__c='Con00001';
            conListInsert[0].SPEN_AdqmAction__c='New';
            conListInsert[0].SPEN_SyncStatus__c='Not Started';
            conListInsert[0].SPEN_FirstName__c = 'Greg';
            conListInsert[0].SPEN_LastName__c = 'White';
       		conListInsert[0].SPEN_PremiseId__c = 'Prem_12345';
            conListInsert[0].SPEN_Salutation__c ='Mr';
            conListInsert[0].SPEN_Initials__c = 'GW';
            conListInsert[0].SPEN_ContactType__c = 'Customer';
            
            conListInsert[0].SPEN_AdqmLastModifiedDateTime__c = System.now();
            insert conListInsert;
            
                
            List<SPEN_ContactStaging__c> conListUpdate=SPEN_TestDataFactory.createContactStagingrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            conListUpdate[0].SPEN_ExternalId__c='Con00003';
            conListUpdate[0].SPEN_AdqmAction__c='Update';
            conListUpdate[0].SPEN_FirstName__c = 'Rob';
            conListUpdate[0].SPEN_LastName__c = 'White';
            conListUpdate[0].SPEN_SyncStatus__c='Not Started';
            conListUpdate[0].SPEN_AdqmLastModifiedDateTime__c = System.now();
            conListUpdate[0].SPEN_Salutation__c = 'Mrs';
             conListUpdate[0].SPEN_Initials__c = 'RW';
            conListInsert[0].SPEN_PremiseId__c = 'Prem_12345';
            
        	insert conListUpdate;
            
            List<SPEN_ContactStaging__c> conListDelete=SPEN_TestDataFactory.createContactStagingrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            conListDelete[0].SPEN_AdqmAction__c='Delete';
            conListDelete[0].SPEN_SyncStatus__c='Not Started';
            conListDelete[0].SPEN_FirstName__c = 'Greg';
            conListDelete[0].SPEN_LastName__c = 'White';
            conListDelete[0].SPEN_ExternalId__c='Con00002';
            insert conListDelete;
            
            List<SPEN_ContactNumberEmailStaging__c> contactEmailStageList = new List<SPEN_ContactNumberEmailStaging__c>();
			SPEN_ContactNumberEmailStaging__c emailStage = new SPEN_ContactNumberEmailStaging__c();
            emailStage.SPEN_ExternalId__c = 'Con00002';
            emailStage.SPEN_NumberOrEmail__c = '8888334455';
            emailStage.SPEN_Type__c = 'Mobile';
             emailStage.SPEN_SyncStatus__c = 'Not Started';
            contactEmailStageList.add(emailStage);
            
            SPEN_ContactNumberEmailStaging__c emailStage2 = new SPEN_ContactNumberEmailStaging__c();
            emailStage2.SPEN_ExternalId__c = 'Con00002';
            emailStage2.SPEN_NumberOrEmail__c = 'asm@accenture.com';
            emailStage2.SPEN_Type__c = 'Email';
             emailStage2.SPEN_SyncStatus__c = 'Not Started';
            contactEmailStageList.add(emailStage2);
            
            SPEN_ContactNumberEmailStaging__c emailStage3 = new SPEN_ContactNumberEmailStaging__c();
            emailStage3.SPEN_ExternalId__c = 'Con00002';
            emailStage3.SPEN_NumberOrEmail__c = '8888334455';
            emailStage3.SPEN_Type__c = 'Home';
            emailStage3.SPEN_SyncStatus__c = 'Not Started';
            contactEmailStageList.add(emailStage3);
            
            SPEN_ContactNumberEmailStaging__c emailStage4 = new SPEN_ContactNumberEmailStaging__c();
            emailStage4.SPEN_ExternalId__c = 'Con00002';
            emailStage4.SPEN_NumberOrEmail__c = '8888334455';
            emailStage4.SPEN_Type__c = 'Other';
             emailStage4.SPEN_SyncStatus__c = 'Not Started';
            contactEmailStageList.add(emailStage4);
            
            insert contactEmailStageList;
            
            
           	SPEN_ConfigurableSettings__c setting = SPEN_TestDataFactory.createConfigSetting(1,'RelatedMobileEmailStagingQuery');
            setting.SPEN_Value__c = 'SELECT Id,SPEN_ExternalId__c,SPEN_NumberOrEmail__c,SPEN_Type__c FROM SPEN_ContactNumberEmailStaging__c WHERE Createddate = Today';
            insert setting;
            
            /*List<SPEN_ContactStaging__c> conList3=SPEN_TestDataFactory.createContactStagingrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            conList3[0].SPEN_ExternalId__c='1234567';
            insert conList3;
            conList3[0].SPEN_AdqmAction__c='Delete';
        	//conList3[0].SPEN_AdqmSource__c='Other Contact';
        	conList3[0].SPEN_SyncStatus__c='Failed';
            conList3[0].SPEN_OtherContactId__c='SB__001';
            update conList3;*/
            
            SEL_Batch__c selBatch =new SEL_Batch__c(SPEN_AdqmLoadDate__c = system.today()+1,SEL_BatchTemplate__c = 'ADQM Delta Sync');
            insert selBatch;
            
            SEL_BatchStep__c selBatchStep =new SEL_BatchStep__c(SEL_BatchId__c =selBatch.id,SEL_BatchSize__c=200,SEL_Sequence__c=1,
                                                               SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED,
                                                                SEL_Class__c = 'SPEN_SyncContactsBatch'
                                                               );
            insert selBatchStep;
            Test.startTest();
            
            SPEN_SyncContactsBatch testA = new SPEN_SyncContactsBatch();
            testA.batchId = selBatch.id;
			testA.batchStepId = selBatchStep.id;
            testA.isValid();
            testA.executeBatch();
            Database.QueryLocator ql = testA.start(null);
            testA.execute(null,conListInsert);
            
           //Database.QueryLocator ql2 = testA.start(null);
            //testA.execute(null,conListUpdate);
            
            Database.QueryLocator ql3 = testA.start(null);
            testA.execute(null,conListDelete);
            System.assertEquals('Other',emailStage4.SPEN_Type__c,'type value');
            Test.stopTest();
        }
    }
}