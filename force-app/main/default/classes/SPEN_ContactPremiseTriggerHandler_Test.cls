@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_ContactPremiseTriggerHandler_Test {
    @testSetup static void setup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
  		System.runAs(user)
        {   
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact contact1= SPEN_TestDataFactory.createContacts(accRec[0].Id,1);
            contact1.SPEN_CustomerID__c = 'CustomerID1';
            contact1.LastName = 'White';
            insert contact1;
            
            Contact contact2= SPEN_TestDataFactory.createContacts(accRec[0].id,1);
            contact2.SPEN_CustomerID__c = 'CustomerID_2';
            contact2.LastName = 'WhiteNew';
            insert contact2;
            
            Contact contact3= SPEN_TestDataFactory.createContacts(accRec[0].Id,1);
            contact3.SPEN_CustomerID__c = 'CustomerID2';
            contact3.LastName = 'Mosby';
            insert contact3;
            
            
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(1);
            premiseList[0].SPEN_PremiseID__c = 'MyPremise';
            insert premiseList;
            
            List<SPEN_Premise__c> premiseList2 = SPEN_TestDataFactory.createListOfPremise(1);
            premiseList2[0].SPEN_PremiseID__c = 'MyPremise2';
            insert premiseList2;
            
            SPEN_ContactPremise__c cp = SPEN_TestDataFactory.createContactPremises(1,contact1.id,premiseList2[0].id);
            cp.SPEN_PremisePrimaryContact__c = true;
            cp.SPEN_Role__c = 'Customer';
            insert cp;
            Assert.areEqual(cp.SPEN_Role__c,'Customer');
        }
    }
	 @IsTest
    public static void testBeforeContext()
    {
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1]; 
        Contact contact1 = [SELECT id FROM Contact WHERE LastName = 'WhiteNew' LIMIT 1];
        Contact contact2 = [SELECT id FROM Contact WHERE LastName = 'Mosby' LIMIT 1];
        SPEN_Premise__c premise = [SELECT id FROM SPEN_Premise__c WHERE SPEN_PremiseID__c ='MyPremise' LIMIT 1];
  		System.runAs(usr)
        {   
            Test.startTest();
            SPEN_ContactPremise__c cp = SPEN_TestDataFactory.createContactPremises(1,contact1.id,premise.id);
            cp.SPEN_PremisePrimaryContact__c = true;
            cp.SPEN_Role__c = 'PSR Contact (Alternative)';
            insert cp;
            try{
                cp.SPEN_RelatedContact__c = contact2.id;
                update cp;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Only 1 primary contact') ? true : false;
                Assert.areEqual(expectedExceptionThrown, true);
            } 
            Test.stopTest();
        }
    }
     @IsTest
    public static void testAfterContext()
    {
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1]; 
        Contact contact1 = [SELECT id FROM Contact WHERE LastName = 'WhiteNew' LIMIT 1];
        SPEN_Premise__c premise = [SELECT id FROM SPEN_Premise__c WHERE SPEN_PremiseID__c ='MyPremise' LIMIT 1];
  		System.runAs(usr)
        {   
            Test.startTest();
            SPEN_ContactPremise__c cp = SPEN_TestDataFactory.createContactPremises(1,contact1.id,premise.id);
            cp.SPEN_PremisePrimaryContact__c = true;
            cp.SPEN_Role__c = 'PSR Contact';
            insert cp;
            Contact updatedContact =[SELECT id,SPEN_CustomerID__c FROM Contact WHERE LastName = 'WhiteNew' LIMIT 1];
            Assert.areEqual('CustomerID_2', updatedContact.SPEN_CustomerID__c);
            Test.stopTest();
        }
    }
     @IsTest
    public static void testBeforeContext2()
    {  
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1]; 
        Contact contact1 = [SELECT id FROM Contact WHERE LastName = 'White' LIMIT 1];
        Contact contact2 = [SELECT id FROM Contact WHERE LastName = 'Mosby' LIMIT 1];
        SPEN_Premise__c premise = [SELECT id FROM SPEN_Premise__c WHERE SPEN_PremiseID__c ='MyPremise' LIMIT 1];
  		System.runAs(usr)
        {   
            Test.startTest();
            SPEN_ContactPremise__c cp2 = SPEN_TestDataFactory.createContactPremises(1,contact2.id,premise.id);
            cp2.SPEN_PremisePrimaryContact__c = true;
            cp2.SPEN_Role__c = 'Customer';
            insert cp2;
             try{
            	cp2.SPEN_RelatedContact__c =contact2.id ;
                cp2.SPEN_Role__c = 'Premise Owner';
                update cp2;
             }
             catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Contact Premise record for this contact already exists') ? true : false;
                Assert.areEqual(expectedExceptionThrown, true);
            } 
            Test.stopTest();
        }
    }
    
     @IsTest
    public static void testBeforeContext3()
    {  
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1]; 
        Contact contact1 = [SELECT id FROM Contact WHERE LastName = 'White' LIMIT 1];
        Contact contact2 = [SELECT id FROM Contact WHERE LastName = 'Mosby' LIMIT 1];
        SPEN_Premise__c premise = [SELECT id FROM SPEN_Premise__c WHERE SPEN_PremiseID__c ='MyPremise' LIMIT 1];
  		System.runAs(usr)
        {   
            Test.startTest();
            SPEN_ContactPremise__c cp2 = SPEN_TestDataFactory.createContactPremises(1,contact2.id,premise.id);
            cp2.SPEN_PremisePrimaryContact__c = true;
            cp2.SPEN_Role__c = 'Customer';
            insert cp2;
             try{
            	cp2.SPEN_RelatedContact__c =contact2.id ;
                cp2.SPEN_Role__c = 'Alternative Contact';
                update cp2;
             }
             catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('There is Contact Premise record presents with the same role') ? true : false;
                Assert.areEqual(expectedExceptionThrown, true);
            } 
            Test.stopTest();
        }
    }
}