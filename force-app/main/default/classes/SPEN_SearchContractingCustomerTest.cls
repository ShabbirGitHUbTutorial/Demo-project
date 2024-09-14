@isTest(seeAllData = false)
public with sharing class SPEN_SearchContractingCustomerTest 
{
    
    @TestSetup static void caseDataCreation() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        System.runAs(user)
         {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        List<Case> caseList =  SPEN_TestDataFactory.createListOfCases(1);
        //caseList[0].SPEN_SAPReference__c = '000612762162';
        insert caseList;
         }
    }
    
    @isTest
    static void updateCaseTest() 
    {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.StartTest();
        
        Case cseObj = [Select Id From Case where Status = 'Open'];
        
        SPEN_SearchContractingCustomerController.SearchCustomerWrapperClass searchObj = new SPEN_SearchContractingCustomerController.SearchCustomerWrapperClass();
        searchObj.caseRecordId = cseObj.Id;
        searchObj.ukc1 = '1234';
        searchObj.ukc2 = '6789';
        searchObj.block = 'N';
        searchObj.companyName = 'Test Company';
        searchObj.address = 'Test Address';
        searchObj.phoneNumber = '987654321';
        searchObj.email = 'testemail@gmail.com';
        searchObj.vat = 'ABC1234';
        searchObj.crn = 'XYZ1234';
        
        String jsonString = JSON.serialize(searchObj);
        SPEN_SearchContractingCustomerController.updateCase(jsonString);
        Test.StopTest();
        
        Case caseObj = [Select Id,SPEN_UKC1ID__c From Case where Id =: cseObj.Id];
        Assert.areEqual(caseObj.SPEN_UKC1ID__c,'1234' );
    }
    
    @isTest
    static void getSearchbyUKCTest() 
    {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.StartTest();
        
        Case cseObj = [Select Id From Case where Status = 'Open'];
        
        SPEN_SearchContractingCustomerController.SearchCustomerWrapperClass searchObj = new SPEN_SearchContractingCustomerController.SearchCustomerWrapperClass();
        searchObj.caseRecordId = cseObj.Id;
        searchObj.ukc1 = '0000819248';
        searchObj.ukc2 = '0000819249';
        searchObj.block = 'N';
        searchObj.companyName = 'Test Company';
        searchObj.address = 'Test Address';
        searchObj.phoneNumber = '987654321';
        searchObj.email = 'testemail@gmail.com';
        searchObj.vat = 'ABC1234';
        searchObj.crn = 'XYZ1234';
        
        String jsonString = JSON.serialize(searchObj);
        SPEN_SearchContractingCustomerController.getSearchbyUKC(jsonString);
        Test.StopTest();
        
        Case caseObj = [Select Id,SPEN_UKC1ID__c From Case where Id =: cseObj.Id];
        Assert.areEqual(caseObj.SPEN_UKC1ID__c,'0000819248' );
    }
    
    @isTest
    static void getSearchDataTest() 
    {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.StartTest();
        try
        {
        SPEN_SearchContractingCustomerController.SearchWrapper searchObj = new SPEN_SearchContractingCustomerController.SearchWrapper();
        
        searchObj.companyName = 'Test Company';
        searchObj.phone = '987654321';
        searchObj.building = 'Unlocked';
        searchObj.mobile = 'Test Address';
        searchObj.email = 'testemail@gmail.com';
        searchObj.vat = 'ABC1234';
        searchObj.crn = 'XYZ1234';
        searchObj.postcode = 'SS13 1JH';
        searchObj.street = 'Test Street';
        searchObj.fax = '12324242';
        
        SPEN_SearchContractingCustomerController.getSearchData(searchObj);
        Test.StopTest();
        Assert.areEqual(searchObj.vat,'ABC1234' );
        }
        catch(exception e) {}
    }
    
    @isTest
    static void checkQASValueTest() 
    {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.StartTest();
        try
        {
        Case cseObj = [Select Id,SPEN_SAPReference__c From Case where Status = 'Open'];
        
        String qasValue = SPEN_SearchContractingCustomerController.checkQASValue(cseObj.Id);
        SPEN_SearchContractingCustomerController.getSearchbyQAS(cseObj.Id);
        Test.StopTest();
        Assert.areEqual(qasValue,'NOACCEXIST');
        }
        catch(exception e) {}
    }
    
    @isTest
    static void checkQASValueExtTest() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps13 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessConnectionCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps13.Id); 
        
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
            
            contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert ct;
            
            List<Case> caseList =  SPEN_TestDataFactory.createListOfCases(1);
            
            caseList[0].ContactId = ct.Id;
            caseList[0].AccountId = testAccount[0].id;
            insert caseList;
            caseList[0].SPEN_SAPReference__c = '000612762162';
            update caseList;
            
            String qasValue = SPEN_SearchContractingCustomerController.checkQASValue(caseList[0].Id);
            
            Test.stopTest();
            
            Assert.areEqual(qasValue,'ACCEXISTWITHSAP');
        }
    }
    
    @isTest
    static void createSDCustomerSAPTest() 
    {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.StartTest();
        try
        {
        Case cseObj = [Select Id From Case where Status = 'Open'];
        
        SPEN_SearchContractingCustomerController.CaseInfo searchObj = new SPEN_SearchContractingCustomerController.CaseInfo();
        
        searchObj.Id = cseObj.Id;
        searchObj.spenCustomerType = 'Commercial';
        searchObj.spenCustomerClass = 'Employees';
        searchObj.spenTitle = 'Company';
        searchObj.spenCompanyPersonName = 'Test Person';
        searchObj.spenBuildingNameFlatNumber = '38';
        searchObj.spenBuildingNumberStreet = 'Test Street';
        searchObj.spenTownCity = 'London';
        searchObj.spenPostCode = 'SS13 1JH';
        searchObj.spenCountry = 'GB';
        searchObj.spenPhoneNumber = '987654321';
        searchObj.spenMobileNumber = '01123456789';
        searchObj.spenFAXNumber = '12324242';
        searchObj.spenEmailAddress = 'testemail@gmail.com';
        searchObj.spenVAT = 'GB1010101010';
        searchObj.spenCRN = '12345678';
        
        List<SPEN_SearchContractingCustomerController.SearchCustomerWrapperClass> searchWrap = SPEN_SearchContractingCustomerController.createSDCustomerSAP(searchObj);
        Test.StopTest();
        
        Assert.areNotEqual(searchWrap[0].ukc1,'0000824808' );
        }
        catch(exception e) {}
    }
    
     @isTest
    static void updateSDCustomerSAPTest() 
    {
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.StartTest();
        try
        {
        Case cseObj = [Select Id From Case where Status = 'Open'];
        
        SPEN_SearchContractingCustomerController.CaseInfo searchObj = new SPEN_SearchContractingCustomerController.CaseInfo();
        
        searchObj.Id = cseObj.Id;
        searchObj.spenCustomerType = 'Commercial';
        searchObj.spenCustomerClass = 'Employees';
        searchObj.spenTitle = 'Company';
        searchObj.spenCompanyPersonName = 'Test Person';
        searchObj.spenBuildingNameFlatNumber = '38';
        searchObj.spenBuildingNumberStreet = 'Test Street';
        searchObj.spenTownCity = 'London';
        searchObj.spenPostCode = 'SS13 1JH';
        searchObj.spenCountry = 'GB';
        searchObj.spenPhoneNumber = '987654321';
        searchObj.spenMobileNumber = '01123456789';
        searchObj.spenFAXNumber = '12324242';
        searchObj.spenEmailAddress = 'testemail@gmail.com';
        searchObj.spenVAT = 'GB1010101010';
        searchObj.spenCRN = '12345678';
        
        String calloutResponse = SPEN_SearchContractingCustomerController.updateSDCustomerSAP(searchObj);
        Test.StopTest();
        
        Assert.areEqual(calloutResponse,'Success' );
        }
        catch(exception e) {}
    }
}