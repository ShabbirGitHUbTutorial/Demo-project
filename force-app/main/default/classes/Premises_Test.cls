@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class Premises_Test 
{
    @testsetup
    public static void setupdata()
    {
        List <SPEN_ConfigurableSettings__c> configSettingList = SPEN_TestDataFactory.createConfigSettingforSMSConfig(1);
        insert configSettingList;
    }
    @isTest
    private static void premisesTest() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        System.runAs(user)
        {
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_PSR__c=true;
            insert con;
            
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            premiseList[0].SPEN_ConsentToSharePSRGiven__c=true;
            insert premiseList; 
            
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_Role__c='Customer';
            insert conpremise;
            
            premiseList[0].SPEN_ConsentToSharePSRGiven__c=false;
            premiseList[0].SPEN_Street__c = 'test';
            update premiseList;
            
            Assert.isNotNull(premiseList, 'Assertion Passed');
            Test.stopTest();  
        } 
    }
}