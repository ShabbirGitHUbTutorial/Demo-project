@isTest
public class SPEN_FinancialInfoTriggerTest {

    @isTest
    Public static void calculateFixedCummulativeFeeValue()
    {
        //Profile Creation
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        //User setup
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        //insert User
        Database.insert(user);
        //Permissionset assignment
        
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
         
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_FinancialInformationTransmissionAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);     
        
         System.runAs(user){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
	
            //Create Financial Record
            List<SPEN_FinancialInformation__c> finInfo = new List<SPEN_FinancialInformation__c>(); 
            SPEN_FinancialInformation__c finInfo1 = new SPEN_FinancialInformation__c(SPEN_TerminationAmount__c = 884.26);
            finInfo.add(finInfo1);
            insert finInfo;
        
    }
}
}