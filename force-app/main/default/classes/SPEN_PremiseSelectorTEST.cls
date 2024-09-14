@IsTest
public class SPEN_PremiseSelectorTEST {
	@IsTest
    private static void testPremiseRecord()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id); 
        System.runAs(user)
        {   
	    Test.startTest(); 
            List<SPEN_Premise__c> premiselist=SPEN_TestDataFactory.createPremiseRecord('Premise','OX123',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiselist;
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_Premise__c = premiselist[0].id;
           	insert con;
            premiselist[0].SPEN_PremiseID__c = con.SPEN_CustomerID__c;
            update premiselist;
			Set<Id> conIdSet = new Set<Id>();
            conIdSet.add(con.id);
            
			Set<Id> premRecIds = new Set<Id>();
		    premRecIds.add(premiselist[0].Id);
			SPEN_PremiseSelector.getPremiseRecord(premiselist[0].SPEN_PremiseID__c);
            SPEN_PremiseSelector.getPresmise(conIdSet);
            SPEN_PremiseSelector.getPremiseFromUniqueCustomerId(con.SPEN_CustomerID__c);
            SPEN_PremisesSelector.getPresmise(conIdSet);
			SPEN_PremiseSelector.getPremiseEnergisedMPANCount(premRecIds);
            SPEN_PremiseSelector.getcaseRelatedPremiseRecord(premRecIds);
            Assert.isNotNull(premiselist[0].SPEN_PremiseID__c);
            Test.stopTest();
        }
    }
}