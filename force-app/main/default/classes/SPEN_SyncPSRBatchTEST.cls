@IsTest
public class SPEN_SyncPSRBatchTEST{
    private static final String BATCH_TEMPLATE_A = 'BatchStepBase_Test_A';
    @IsTest
    private static void testPSRexecute()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_StagingCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRVulnerabilityTypeAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SEL_BatchFrameworkUser'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        System.runAs(user)
        {
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_CustomerID__c = 'TEST1234';
            insert con;
            
            List<SPEN_PSRVulnerabilityType__c> vulList = SPEN_TestDataFactory.createPSRVulnerabilityRecords();
            insert vulList;
            
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(1);
            premiseList[0].SPEN_PremiseID__c = 'TEST1234';
            insert premiseList;
            
            List<SPEN_PSR__c> psrList = SPEN_TestDataFactory.createPSRrecord(1);
            psrList[0].SPEN_PSREffectiveFromDate__c = System.today()-10;
            psrList[0].SPEN_PSREffectiveToDate__c = System.today()+15;
            psrList[0].SPEN_ADQMLastSync__c = System.today()-1;
            insert psrList;
            
            List<SPEN_PSRStaging__c> stagingListInsert=SPEN_TestDataFactory.createPSRStagingrecord(1);
			stagingListInsert[0].SPEN_PsrVulnerabilityTypeId__c = '1';//'Test-123'; 
            stagingListInsert[0].SPEN_Code__c = '1'; 
            stagingListInsert[0].SPEN_ADQMAction__c='New';
            stagingListInsert[0].SPEN_PremiseID__c='TEST1234';
            stagingListInsert[0].SPEN_SyncStatus__c='New';
            insert stagingListInsert;
            
            List<SPEN_PSRStaging__c> stagingListDelete =SPEN_TestDataFactory.createPSRStagingrecord(1);
			stagingListDelete[0].SPEN_PsrVulnerabilityTypeId__c = '1';//'Test-123'; 
            stagingListDelete[0].SPEN_Code__c = '1'; 
            stagingListDelete[0].SPEN_ADQMAction__c='Delete';
            stagingListDelete[0].SPEN_PremiseID__c='TEST1234';
            stagingListDelete[0].SPEN_SyncStatus__c='New';
            insert stagingListDelete;
            
            List<SPEN_PSRStaging__c> stagingListUpdate=SPEN_TestDataFactory.createPSRStagingrecord(1);
			stagingListUpdate[0].SPEN_PsrVulnerabilityTypeId__c = '17';//'Test-123'; 
            stagingListUpdate[0].SPEN_Code__c = '17'; 
            stagingListUpdate[0].SPEN_ADQMAction__c='Update';
            stagingListUpdate[0].SPEN_PremiseID__c='TEST1234';
            stagingListUpdate[0].SPEN_SyncStatus__c='New';
            stagingListUpdate[0].SPEN_EffectiveDateFrom__c=system.today()-1;
            stagingListUpdate[0].SPEN_EffectiveDateTo__c=system.today()+1;
            stagingListUpdate[0].SPEN_ADQMLastModifiedDateTime__c=system.today();
            insert stagingListUpdate;
            
            SEL_Batch__c selBatch =new SEL_Batch__c(SPEN_AdqmLoadDate__c = system.today()+1,SEL_BatchTemplate__c = 'ADQM Delta Sync');
            insert selBatch;
            
            SEL_BatchStep__c selBatchStep =new SEL_BatchStep__c(SEL_BatchId__c =selBatch.id,SEL_BatchSize__c=200,SEL_Sequence__c=1,
                                                               SEL_Status__c = SEL_BatchConstants.STATUS_COMPLETED,
                                                                SEL_Class__c = 'SPEN_SyncPSRBatch'
                                                               );
            insert selBatchStep;
            SPEN_SyncPSRBatch testA = new SPEN_SyncPSRBatch();
            testA.batchId = selBatch.id;
			testA.batchStepId = selBatchStep.id;
            testA.isValid();
            testA.executeBatch();
            Database.QueryLocator ql = testA.start(null);
            testA.execute(null,stagingListInsert);
            
            Database.QueryLocator ql2 = testA.start(null);
            testA.execute(null,stagingListUpdate);
            
            Database.QueryLocator ql3 = testA.start(null);
            testA.execute(null,stagingListDelete);
            //Assert.areEqual('TEST1234',stagingListUpdate[0].SPEN_PremiseID__c,'premise id value');
            System.assertEquals('TEST1234',stagingListUpdate[0].SPEN_PremiseID__c,'premise id value');
            Test.stopTest();
        }   
    }
}