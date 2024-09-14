@IsTest
public with sharing class SPEN_EmployeeSelectorTest 
{
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_AccountCRU');//[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_AccountCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user){
            test.startTest();
            List<SPEN_Employee__c> empList=SPEN_TestDataFactory.createEmployeeRecords(1);
            insert empList;
            test.stopTest();
    	}        
    }

    @IsTest
    public static void getStreetWorkContractorTest(){
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        System.runAs(user){
            Test.startTest();
            //Positive
            List<SPEN_Employee__c> emp=SPEN_EmployeeSelector.getEmployeeFromEmail(new List<String>{'test1@test.com'});
            Assert.isTrue(emp.size()==1);
            //Negative
            emp=SPEN_EmployeeSelector.getEmployeeFromEmail(new List<string>());
			Assert.isTrue(emp.size()==0);
            //Negative
            List<SPEN_Employee__c> emp1=SPEN_EmployeeSelector.getEmployeeFromEmail(new List<String>{'test12@test.com'});
            Assert.isTrue(emp1.size()==0);
            //catch
            list<String> nullList;
            List<SPEN_Employee__c> emp11=SPEN_EmployeeSelector.getEmployeeFromEmail(nullList);
            Assert.isTrue(emp11.size()==0);
            Test.stopTest();
        }
    }

}