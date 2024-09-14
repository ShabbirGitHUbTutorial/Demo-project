@isTest(SeeAllData=False)
public class SPEN_PhysicalInformationServiceTest 
{
    @testsetup
    public static void setupdata()
    { 
        List <SPEN_ConfigurableSettings__c> configSettingList = SPEN_TestDataFactory.createConfigSettingforSMSConfig(1);
        insert configSettingList;
    }
    
    @isTest
    public static void testMethod1 ()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PhysicalInformationAccessCRUD'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Map<id,Contact> oldMap = new Map<id,Contact>();
            Map<id,Contact> newMap = new Map<id,Contact>();
            Test.startTest();
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            insert testAccount;
            Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            oldMap.put(ct.id, ct);
            insert ct;
            Id recTypeId=[select Id from RecordType where DeveloperName='SPEN_BudgetConnectionEnquiry'].Id;
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_SendtoPowerOn__c = true;
            cse.SPEN_CallerInitials__c = ct.Salutation;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.SPEN_CallerTitle__c = ct.Suffix;
            cse.status='Restored';
            cse.RecordTypeId=recTypeId;
            //cse.SPEN_SubStatus__c ='test';
            Database.SaveResult saveRes = Database.insert(cse);
            List<SPEN_PhysicalInformation__c> physInfoLst=SPEN_TestDataFactory.createPhysInfoRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            //List<SPEN_PhysicalInformation__c> physInfoLstWrong=SPEN_TestDataFactory.createPhysInfoRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            physInfoLst[0].SPEN_Case__c=cse.Id;
            insert physInfoLst;
            List<Id> phyIdList = new List<Id>();
            //List<Id> itemIdList = new List<Id>();
            phyIdList.add(physInfoLst[0].id);
            //physInfoLstWrong[0].SPEN_ItemClass__c='IT-UITEMM';
            //itemIdList.add(physInfoLstWrong[0].id);
            SPEN_PhysicalInformationService.callSAPCallout(phyIdList);
            //SPEN_PhysicalInformationService.callSAPCallout(itemIdList);
            Test.stopTest();
        }
    }
}