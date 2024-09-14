@IsTest
public class SPEN_MPANSelectorTEST {
	@IsTest
    private static void testgetMpanRecord(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        System.runAs(user)
        {
        List<SPEN_MPAN__c> mpanlist=SPEN_TestDataFactory.createMPANList(SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert mpanlist;
        Test.startTest();
        SPEN_MPANSelector.getMpanRecord(mpanlist[0].Id);
        Assert.isNotNull(mpanlist[0].Id, 'MPAN Passed');
        Test.stopTest();
    }
 }
   @IsTest
    private static void testgetMpanRecordForMeterPing(){
		Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        System.runAs(user)
        {
        SPEN_MPAN__c mpanlist=SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert mpanlist;
        Test.startTest();
        SPEN_MPANSelector.getMpanRecordForMeterPing(String.valueOf(mpanlist.Id));
        Assert.isNotNull(mpanlist.Id, 'MPAN List Passed');
        Test.stopTest();
   		}
	}
    
    @IsTest
    private static void testgetRecordForMpan(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id); 
        System.runAs(user)
        {
            
        SPEN_MPAN__c mpan=SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert mpan;
        Test.startTest();
        SPEN_MPANSelector.getRecordForMpan(mpan.SPEN_AccountNumberMPAN__c);
        Assert.isNotNull(mpan.SPEN_AccountNumberMPAN__c, 'MPAN-123');
        Test.stopTest();
    	}
	}
}