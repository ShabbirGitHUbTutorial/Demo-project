@isTest
public class SPEN_SyncPSRFlagonContact_Test {
    @IsTest
    private static void testSyncPSRFlagExecute()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SEL_BatchFrameworkUser'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        
        System.runAs(user)
        {
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_CustomerID__c = 'Test123';
            insert con;
            List<SPEN_PSR__c> psralert=SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psralert[0].SPEN_Contact__c=con.Id;
            insert psralert;
            
            List<SPEN_VoiceAlert__c> voicealert=SPEN_TestDataFactory.createVoiceAlertrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert voicealert;
            
            SEL_Batch__c selBatch =new SEL_Batch__c(SPEN_AdqmLoadDate__c = system.today()+1,SEL_BatchTemplate__c = 'ADQM Delta Sync');
            insert selBatch;
            
            SEL_BatchStep__c selBatchStep =new SEL_BatchStep__c(SEL_BatchId__c =selBatch.id,SEL_BatchSize__c=200,SEL_Sequence__c=1,
                                                                SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED,
                                                                SEL_Class__c = 'SPEN_SyncPSRFlagonContact'
                                                               );
            insert selBatchStep;
            Test.startTest();
            SPEN_PSRStaging__c stage= new SPEN_PSRStaging__c(SPEN_PremiseID__c = 'Test123',SPEN_PsrVulnerabilityTypeId__c = '123',
                                                             SPEN_SyncStatus__c = 'Successful');
            insert stage;
            SPEN_SyncPSRFlagonContact testA = new SPEN_SyncPSRFlagonContact();
            testA.batchId = selBatch.id;
            testA.batchStepId = selBatchStep.id;
            testA.isValid();
            testA.executeBatch();
            Database.QueryLocator ql = testA.start(null);
            testA.execute(null,new List<SPEN_PSRStaging__c>{stage});
            
            
            psralert[0].SPEN_Contact__c=null;    
            update psralert[0];
            Database.QueryLocator ql2 = testA.start(null);
            testA.execute(null,new List<SPEN_PSRStaging__c>{stage});
            //Assert.areEqual('Test123',SPEN_PremiseID__c,'PSRStaging premise id value');
            System.assertEquals('Test123',stage.SPEN_PremiseID__c,'PSRStaging premise id value');
            Test.stopTest();
        }
    }
}