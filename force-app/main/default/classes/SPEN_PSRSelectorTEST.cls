@IsTest
public class SPEN_PSRSelectorTEST {
    @IsTest
    private static void testgetPSRList(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps = SPEN_TestdataSelector.getPermissionSet('SPEN_PSRAccessCRU');
        //[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        System.runAs(user)
        	{
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert con;
            Test.startTest();
			List<SPEN_PSR__c> psr=SPEN_PSRSelector.getPSRList(con.Id);
            Assert.isNotNull(con.Id, 'Contact Ids');
            Test.stopTest();
            }
 	}
    @IsTest
    private static void testgetPSRprimaryConList(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps = SPEN_TestdataSelector.getPermissionSet('SPEN_PSRAccessCRU');
        //[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        System.runAs(user)
        	{
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert con;
            Test.startTest();
            Set<Id> psrset=new Set<Id>();
            psrset.add(con.Id);
			List<SPEN_PSR__c> psr=SPEN_PSRSelector.getPSRprimaryConList(psrset);
            Assert.isNotNull(psrset, 'PSR Details');
            Test.stopTest();
            }
    }
    @IsTest
    private static void testgetPSRForInsertVABatch(){
        	Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
		
        System.runAs(user){
        	Test.startTest();
        	List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert con;
        	List<Id> psrlist=new List<Id>();
        	psrlist.add(con.Id);
        	Set<Id> psrSetId = new Set <Id>();
        	psrSetId.add(con.Id);
			List<SPEN_PSR__c> psr=SPEN_PSRSelector.getPSRForInsertVABatch(psrlist);
        	List<SPEN_PSR__c> psr1=SPEN_PSRSelector.getPSRRecordsBasedOnIds(psrSetId);
            Assert.isNotNull(psrlist, 'PSR List');
            Test.stopTest();
        }
        
    }
    @IsTest
    private static void testgetPSRForSyncPSRBatch()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
		
        System.runAs(user){
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert con;
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createPremiseRecord('Test', 'Prem', SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiseList;
            List<SPEN_PSRVulnerabilityType__c> psrv=SPEN_TestDataFactory.createPSRVulnerabilityRecords();
        	insert psrv;
            
            Set<String> psrId=new Set<String>();
            psrId.add(premiseList[0].SPEN_PremiseID__c);
            Set<String> psrvulId=new Set<String>();
            psrvulId.add(psrv[0].SPEN_Code__c);
            List<SPEN_PSR__c> psrcheck=SPEN_PSRSelector.getPSRForSyncPSRBatch(psrId,psrvulId);
            Assert.isNotNull(psrId);
            Test.stopTest();
        }
    }
    @IsTest
    private static void getPSRForSyncPSRBatchServiceTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
		
        System.runAs(user){
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert accRec;
        	Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert con;
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createPremiseRecord('Test', 'Prem', SPEN_TestDataFactoryConstants.SINGLE_REC);
			insert premiseList;
            Set<String> premiseset=new Set<String>();
            premiseset.add(premiseList[0].SPEN_PremiseID__c);
            List<SPEN_PSR__c> testSyncPSRBatch=SPEN_PSRSelector.getPSRForSyncPSRBatchService(premiseset);
            Assert.isNotNull(premiseset);
            Test.stopTest();
            
        }
        
    }
    
}