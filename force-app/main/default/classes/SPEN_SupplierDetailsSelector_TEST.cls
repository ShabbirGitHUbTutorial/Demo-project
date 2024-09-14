@IsTest
public class SPEN_SupplierDetailsSelector_TEST 
{
    @IsTest
	public static void getSupplierDetailsRecordTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_SupplierDetails_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user)
        {
        List<SPEN_SupplierDetails__c> suppDetails=SPEN_TestDataFactory.createSupplierDetailsrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert suppDetails;
        Test.startTest();
        SPEN_SupplierDetailsSelector.getSupplierDetailsRecord(suppDetails[0].SPEN_SupplierMPID__c);
        Assert.isNotNull(suppDetails[0].SPEN_SupplierMPID__c);
        Test.stopTest();
      	}
        
    }
}