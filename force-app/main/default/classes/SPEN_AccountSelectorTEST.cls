@IsTest
public with sharing class SPEN_AccountSelectorTEST 
{
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_AccountCRU');//[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_AccountCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user)
        {
            test.startTest();
        	Id recordTypeIdPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SPEN_Partner').getRecordTypeId();
            List<Account> accountList = SPEN_TestDataFactory.createSpenAccount();
            accountList[0].SPEN_Streetworks_Contractor__c=true;
            update accountList;
            
            test.stopTest();
    	}        
    }
    @IsTest
    public static void getAccountListTest()
    {
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        System.runAs(user)
        {
            Test.startTest();
            List<Account> accList=SPEN_AccountSelector.getPartnerAccount(CasesConstants.SPEN);
            Assert.isNotNull(accList);
            Test.stopTest();
        }
    }
     @IsTest
    public static void getStreetWorkContractorTest()
    {
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        System.runAs(user)
        {
            Test.startTest();
            //psotive scenario 1
            Account acc=SPEN_AccountSelector.getStreetWorkContractor('SPEN');
            acc.SPEN_Streetworks_Contractor__c=true;
            update acc;
            //negative scenario 1
            Account acc1=SPEN_AccountSelector.getStreetWorkContractor('SPEN123');
			Assert.isTrue(acc1==new account());
            //negative scenario 2
            Account acc2=SPEN_AccountSelector.getStreetWorkContractor('');
			Assert.isTrue(acc2==new account());

            Test.stopTest();
        }
    }
    @IsTest
    public static void getNRSWAContractorTest()
    {
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        System.runAs(user)
        {
            Test.startTest();
            //psotive scenario 1
            List<Account> accountList = SPEN_TestDataFactory.createSpenAccount();
            accountList[0].SPEN_NRSWA_Contractor__c=true;
            update accountList;
            //negative scenario 1
            Account acc1=SPEN_AccountSelector.getNRSWAContractor('SPEN123');
			Assert.isTrue(acc1==new account());
            //negative scenario 2
            Account acc2=SPEN_AccountSelector.getNRSWAContractor('');
			Assert.isTrue(acc2==new account());

            Test.stopTest();
        }
    }

}