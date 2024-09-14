@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_SyncContactFieldsBatch_TEST {
@IsTest
     private static void testBatchexecute()
    {	
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactNumberEmailStagingCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id); 
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SEL_BatchFrameworkUser'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id); 
        System.runAs(user)
        {   
           
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPENAdqmLastSyncDateTime__c=system.now();
            con.SPEN_CustomerID__c = 'MyContact';
        	insert con;
            
            
            SPEN_ContactNumberEmailStaging__c emailStage = new SPEN_ContactNumberEmailStaging__c();
            emailStage.SPEN_ExternalId__c = 'MyContact';
            emailStage.SPEN_NumberOrEmail__c = 'test@test.com';
            emailStage.SPEN_SyncStatus__c = 'Not Started';
            emailStage.SPEN_Type__c = 'Email';
            insert emailStage;
            
            SPEN_ContactNumberEmailStaging__c mobileStage = new SPEN_ContactNumberEmailStaging__c();
            mobileStage.SPEN_ExternalId__c = 'MyContact';
            mobileStage.SPEN_NumberOrEmail__c = '+448888223344';
            mobileStage.SPEN_SyncStatus__c = 'Not Started';
            mobileStage.SPEN_Type__c = 'Mobile';
            insert mobileStage;

            SPEN_ContactNumberEmailStaging__c otherPhoneStage = new SPEN_ContactNumberEmailStaging__c();
            otherPhoneStage.SPEN_ExternalId__c = 'MyContact';
            otherPhoneStage.SPEN_NumberOrEmail__c = '+448888223344';
            otherPhoneStage.SPEN_SyncStatus__c = 'Not Started';
            otherPhoneStage.SPEN_Type__c = 'Other';
            insert otherPhoneStage;
            
            SPEN_ContactNumberEmailStaging__c homePhoneStage = new SPEN_ContactNumberEmailStaging__c();
            homePhoneStage.SPEN_ExternalId__c = 'MyContact';
            homePhoneStage.SPEN_NumberOrEmail__c = '+448888223344';
            homePhoneStage.SPEN_SyncStatus__c = 'Not Started';
            homePhoneStage.SPEN_Type__c = 'Home';
            insert homePhoneStage;
            
            SEL_Batch__c selBatch =new SEL_Batch__c(SPEN_AdqmLoadDate__c = system.today()+1,SEL_BatchTemplate__c = 'ADQM Delta Sync');
            insert selBatch;
            
             SEL_BatchStep__c selBatchStep =new SEL_BatchStep__c(SEL_BatchId__c =selBatch.id,SEL_BatchSize__c=200,SEL_Sequence__c=1,
                                                               SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED,
                                                                SEL_Class__c = 'SPEN_SyncContactFieldsBatch'
                                                               );
            insert selBatchStep;
            Test.startTest();
 			SPEN_SyncContactFieldsBatch testA = new SPEN_SyncContactFieldsBatch();
            testA.batchId = selBatch.id;
			testA.batchStepId = selBatchStep.id;
            testA.isValid();
            testA.executeBatch();
            Database.QueryLocator ql = testA.start(null);
            testA.execute(null,new List<SPEN_ContactNumberEmailStaging__c>{emailStage});
             // testA.finishBatch(null,testA.batchId,testA.batchStepId);
            Contact conRec = [Select Id, Email FROM Contact LIMIT 1];
            system.assertEquals('test@test.com', conRec.Email,'Contact record Email');

            Database.QueryLocator ql2 = testA.start(null);
            testA.execute(null,new List<SPEN_ContactNumberEmailStaging__c>{mobileStage});
            Contact conRec1 = [Select Id, MobilePhone FROM Contact LIMIT 1];
            Assert.areNotEqual('07888822334', conRec1.MobilePhone);
            
            Database.QueryLocator ql3 = testA.start(null);
            testA.execute(null,new List<SPEN_ContactNumberEmailStaging__c>{homePhoneStage});
             Contact conRec2 = [Select Id, Phone FROM Contact LIMIT 1];
             Assert.areNotEqual('07888822334', conRec2.Phone);

            
            Database.QueryLocator ql4 = testA.start(null);
            testA.execute(null,new List<SPEN_ContactNumberEmailStaging__c>{otherPhoneStage});
            Contact conRec3 = [Select Id, OtherPhone FROM Contact LIMIT 1];
            Assert.areNotEqual('07888822334', conRec3.OtherPhone);
            Test.stopTest();

            //To increase coverage
            Set<String> contactExtIdSet= new Set<String>();
            contactExtIdSet.add(con.SPEN_CustomerID__c);
            //Date adqmLoadDate=Today();
            SPEN_ContactStagingSelector cntStg=new SPEN_ContactStagingSelector();
            cntStg.getStageRecordForContactUpdate(Date.today(),contactExtIdSet);
        }
    }
}