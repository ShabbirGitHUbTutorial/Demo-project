@IsTest
public class SPEN_PremisesSelectorTEST {
    @IsTest
    private static void testgetPremiseRecord()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
         PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        System.runAs(user)
        {
        Test.startTest();
        List<SPEN_Premise__c> premiselist=SPEN_TestDataFactory.createPremiseRecord('Premise','OX123',SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert premiselist;
        List<Account> accList = SPEN_TestDataFactory.createAccounts('Test_Account',SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert accList;
        Contact contact = SPEN_TestDataFactory.createContacts(accList[0].Id ,SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert contact;
        Set<Id> contactSet = new Set<Id>();
        contactSet.add(contact.Id);
        Set<String> premiseIdSet = new Set<String>();
        premiseIdSet.add(premiselist[0].id);
        
        SPEN_PremisesSelector premiseObj = new SPEN_PremisesSelector();
        
        //new SPEN_PremisesSelector().selectByExternalId(new Set<String>{premiselist[0].SPEN_PremiseID__c},'SPEN_PremiseID__c');
        /*Set<String> prem=new Set<String>();
        prem.add(premiselist[0].SPEN_PremiseID__c);
        SPEN_PremiseSelector.premDetailsForSyncContactsBatchService(prem);*/
        SPEN_Premise__c prem1 = SPEN_PremisesSelector.getPremiseRecord(premiselist[0].SPEN_PremiseID__c);
        SPEN_Premise__c prem2 = SPEN_PremisesSelector.getPremiseFromUniqueCustomerId(premiselist[0].SPEN_PremiseID__c);
        List<SPEN_Premise__c> lstPrem1 = SPEN_PremisesSelector.premDetailsForSyncContactsBatchService(new set<String>{premiselist[0].SPEN_PremiseID__c});
        List<SPEN_Premise__c> lstPrem2 = SPEN_PremisesSelector.getPresmise(contactSet);
        
        List<SPEN_Premise__c> lstPrem3 = premiseObj.getPremiseForBeforeTrigger(premiseIdSet);
        Assert.isNotNull(premiselist[0].SPEN_PremiseID__c);
        Test.stopTest();
    }
    }

}