@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_ContactPremises_Test 
{
    @IsTest
    private static void testContactPremises()
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
            Test.startTest();
            List<SPEN_ContactPremise__c> conPremList = new List<SPEN_ContactPremise__c>();
            Map<Id,SPEN_ContactPremise__c> conPremMap = new Map<Id,SPEN_ContactPremise__c>();

            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
            insert premiseList;            
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            Contact conRec= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
          	conRec.SPEN_CustomerID__c='SB__002';
            conRec.MobilePhone = '07123456799';
            conRec.FirstName = 'John';
            conRec.LastName = 'Doe';
            conRec.Phone = '01234567891';
            insert conRec;
                
            /*Contact conRec1= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
           	conRec1.SPEN_CustomerID__c='SB__004';
            conRec1.MobilePhone = '07123456788';
            conRec1.FirstName = 'John vish';
            conRec1.LastName = 'Doe';
            conRec1.Phone = '01234567898';
            insert conRec1;*/
            
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_PremisePrimaryContact__c = true;
            conpremise.SPEN_Role__c = 'Customer';
			conPremList.add(conpremise);
            
            SPEN_ContactPremise__c conPremiseRec = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[1].Id);
            conPremiseRec.SPEN_ExternalId__c='1234';
            conPremiseRec.SPEN_Role__c = 'Alternative Contact';
            //conPremiseRec.SPEN_PremisePrimaryContact__c = false;
            conPremList.add(conPremiseRec);
            insert conPremList; 
            try{
                SPEN_ContactPremise__c conPremiseRec2 = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[1].Id);
            	conPremiseRec2.SPEN_ExternalId__c='1238';
            	conPremiseRec2.SPEN_PremisePrimaryContact__c = false;
                conPremiseRec2.SPEN_Role__c = 'Alternative Contact';
            	conPremList.add(conPremiseRec2);  
            	insert conPremiseRec2;
                //conPremMap.put(conPremiseRec2.Id, conPremiseRec2);
            	//conPremiseRec2.SPEN_RelatedContact__c = conRec.Id;
            	//conPremiseRec2.SPEN_PremisePrimaryContact__c = true;
          		//update conPremiseRec2;
            }catch(Exception exp){
                Assert.isTrue(exp!=null);
            }
            
            Boolean checkForExisting = SPEN_ContactPremises.checkForExistingConPremRecord(con.Id, premiseList[0].Id);
            Boolean checkForDoublePrimary = SPEN_ContactPremises.checkForDoublePrimaryContact(premiseList[0].Id, true);
            
            //SPEN_ContactPremiseTriggerHandler conPremTrigHandler = new SPEN_ContactPremiseTriggerHandler();
            //conPremTrigHandler.validateBeforeInsert(conPremList);
            
            conPremMap.put(conPremiseRec.Id, conPremiseRec);
            conPremiseRec.SPEN_RelatedContact__c = conRec.Id;
            conPremiseRec.SPEN_PremisePrimaryContact__c = true;
            conPremiseRec.SPEN_Role__c = 'Premise Owner';
            update conPremiseRec;
            conPremMap.put(conpremise.Id, conpremise);
            //conpremise.SPEN_RelatedContact__c = conRec.Id;
            conpremise.SPEN_PremisePrimaryContact__c = false;
            conpremise.SPEN_Role__c = 'Premise Owner';
            update conpremise;
            //conPremTrigHandler.validateBeforeUpdate(conPremMap,conPremList);
            
            Assert.areEqual(False, checkForExisting);
            Test.stopTest();
        }
    }
    @IsTest
    private static void testContactPremisesUpdate()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user)
        {
            Test.startTest();
            List<SPEN_ContactPremise__c> conPremList = new List<SPEN_ContactPremise__c>();
            Map<Id,SPEN_ContactPremise__c> conPremMap = new Map<Id,SPEN_ContactPremise__c>();

            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
            insert premiseList;            
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            Contact conRec= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
          	conRec.SPEN_CustomerID__c='SB__002';
            conRec.MobilePhone = '07123456799';
            conRec.FirstName = 'John';
            conRec.LastName = 'Doe';
            conRec.Phone = '01234567891';
            insert conRec;
                
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_PremisePrimaryContact__c = true;
            conpremise.SPEN_Role__C = 'Customer';
			conPremList.add(conpremise);
            
            /*SPEN_ContactPremise__c conPremiseRec = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[1].Id);
            conPremiseRec.SPEN_ExternalId__c='1234';
            //conPremiseRec.SPEN_PremisePrimaryContact__c = false;
            conPremList.add(conPremiseRec);*/
            insert conPremList; 
            try{
                conpremise.SPEN_RelatedContact__c = conRec.Id;
            	update conpremise;
            	}
            catch(Exception exp){
                Assert.isTrue(exp!=null);

            }
            Boolean checkForExisting = SPEN_ContactPremises.checkForExistingConPremRecord(con.Id, premiseList[0].Id);
            Assert.areEqual(False, checkForExisting);
            Test.stopTest();
        }
    }
    
    
}