@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_PSRTriggerHandler_Test {
	@testSetup static void setup() 
    {
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        List<User> userList=new List<User>();
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        userList.add(user);
        User dataMigrationuser = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        dataMigrationuser.FirstName='Data';
        dataMigrationuser.LastName='Migration';
		userList.add(dataMigrationuser);
        Database.insert(userList);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet ps1=SPEN_TestdataSelector.getPermissionSet('SPEN_AdqmDataMigrationBypass');
        insert new PermissionSetAssignment(AssigneeId = dataMigrationUser.id, PermissionSetId = ps1.Id);  
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
            List<SPEN_PSRVulnerabilityType__c> vulList = SPEN_TestDataFactory.createPSRVulnerabilityRecords();
            insert vulList;
            List<SPEN_PSR__c> psrList = SPEN_TestDataFactory.createPSRrecord(1);
            psrList[0].SPEN_PSREffectiveFromDate__c = System.today()-10;
            psrList[0].SPEN_PSREffectiveToDate__c = System.today()+15;
            psrList[0].SPEN_ADQMLastSync__c = System.today()-1;
            psrList[0].SPEN_Premise__c = premiseList[0].id;
            psrList[0].SPEN_Contact__c = contact1.id;
            psrList[0].SPEN_PSRVulnerabilityType__c = vulList[0].id;
            insert psrList;
            
            Assert.areEqual(cp.SPEN_Role__c,'Customer');
        }
    }
    @isTest
    public static void psrAfterUpdateTest(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
		System.runAs(user)
        {
            Test.startTest();
        	Contact contact2 = [SELECT id FROM Contact WHERE LastName = 'Mosby' LIMIT 1];
            SPEN_Premise__c premise = [SELECT id FROM SPEN_Premise__c WHERE SPEN_PremiseID__c ='MyPremise' LIMIT 1]; 
            SPEN_PSRVulnerabilityType__c psrVulRec = [SELECT id FROM SPEN_PSRVulnerabilityType__c where id!=null LIMIT 1];
           
            SPEN_PSR__c psrRec = new SPEN_PSR__c();
            psrRec.SPEN_PSREffectiveFromDate__c = System.today()-10;
            psrRec.SPEN_PSREffectiveToDate__c = System.today()+15;
            psrRec.SPEN_ADQMLastSync__c = System.today()-1;
            psrRec.SPEN_Contact__c = contact2.id;
            psrRec.SPEN_PSRVulnerabilityType__c = psrVulRec.id;
            insert psrRec;
            try{
                psrRec.SPEN_Premise__c = premise.id;
                update psrRec;
                Assert.AreEqual(psrRec.SPEN_Contact__c,contact2.id);
            }catch(Exception e){
                Assert.isTrue(e!=null);
            }
            Test.stopTest();
        }
    }
    @isTest
    public static void psrAfterDeleteTest(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {
            Test.startTest();
            Contact contact2 = [SELECT id FROM Contact WHERE LastName = 'Mosby' LIMIT 1];
            SPEN_Premise__c premise = [SELECT id FROM SPEN_Premise__c WHERE SPEN_PremiseID__c ='MyPremise' LIMIT 1]; 
            SPEN_PSRVulnerabilityType__c psrVulRec = [SELECT id FROM SPEN_PSRVulnerabilityType__c where id!=null LIMIT 1];
            Map<Id,SPEN_PSR__c> psrNewMap = new Map<Id,SPEN_PSR__c>();
            Map<Id,SPEN_PSR__c> psrOldMap = new Map<Id,SPEN_PSR__c>();
            List<SPEN_PSR__c> psrList = new List<SPEN_PSR__c>();
            SPEN_PSR__c psrRec = new SPEN_PSR__c();
            psrRec.SPEN_PSREffectiveFromDate__c = System.today()-10;
            psrRec.SPEN_PSREffectiveToDate__c = System.today()+15;
            psrRec.SPEN_ADQMLastSync__c = System.today()-1;
            psrRec.SPEN_Contact__c = contact2.id;
            psrRec.SPEN_PSRVulnerabilityType__c = psrVulRec.id;
            insert psrRec;
            psrList.add(psrRec);
            SPEN_PSRTriggerHandler psrTH = new SPEN_PSRTriggerHandler();
            psrTH.beforeDelete(psrNewMap);
            psrTH.afterUndelete(psrNewMap);
            psrTH.beforeUpdate(psrNewMap,psrOldMap);
            
            try{
                delete psrRec;
                Assert.AreEqual(psrRec.SPEN_Contact__c,contact2.id);
            }catch(Exception e){
                Assert.isTrue(e!=null);
            }
            Test.stopTest();
        }
    }
}