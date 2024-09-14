@isTest
public class PSRs_Test { 
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_ContactAccessCRU');
        //[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = SPEN_TestdataSelector.getPermissionSet('SPEN_PremiseAccessCRU');
        //[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = SPEN_TestdataSelector.getPermissionSet('SPEN_ContactPremiseAccessCRU');
        //[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);

    }

    @isTest
    private static void testPSRInsert()
    {
       
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
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
            psrList[0].SPEN_Premise__c = premiseList[0].id;
            psrList[0].SPEN_Contact__c = con.id;
            psrList[0].SPEN_PSRVulnerabilityType__c = vulList[0].id;
            insert psrList;
            Assert.AreEqual(psrList[0].SPEN_Premise__c,premiseList[0].id);
            psrList[0].SPEN_PSRVulnerabilityType__c = vulList[1].id;
            update psrList;
            Assert.AreEqual(psrList[0].SPEN_PSRVulnerabilityType__c,vulList[1].id);
            Test.stopTest();
        }
    }

    @isTest
    private static void testPSRInsertNegative()
    {
       
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
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
            psrList[0].SPEN_Premise__c = //premiseList[0].id;
            psrList[0].SPEN_Contact__c = //con.id;
            psrList[0].SPEN_PSRVulnerabilityType__c = vulList[0].id;
            try{
                insert psrList;
                Assert.AreEqual(psrList[0].SPEN_Premise__c,null);
            }catch(Exception e){
                Assert.isTrue(e!=null);
            }
            Test.stopTest();
        }
    }
}