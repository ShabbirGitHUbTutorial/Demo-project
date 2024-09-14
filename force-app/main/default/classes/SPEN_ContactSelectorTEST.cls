@IsTest
public class SPEN_ContactSelectorTEST 
{
    @IsTest
    private static void testcontactRecord()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);        
        System.runAs(user)
        {
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Assert.isNotNull(accRec, 'Account Record Passed');
            List<Contact> conList = new List<Contact>();
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_PSR__c = false;
            con.SPEN_IsPrimaryContact__c = true;
            con.SPEN_SpecificVulnerability__c=true;
            conList.add(con);
            
            Contact contRec= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            contRec.SPEN_PSR__c = true;
            contRec.SPEN_IsPrimaryContact__c = true;
            contRec.SPEN_CustomerID__c = 'A12345';
            conList.add(contRec);
            insert conList;
            
            Set<Id> contact=new Set<Id>();
            contact.add(conList[0].Id);
            
            Set<String> externalId = new Set<String>();
            externalId.add(conList[0].SPEN_CustomerID__c); 
            
            List<SPEN_VoiceAlert__c> voicealert=SPEN_TestDataFactory.createVoiceAlertrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            voicealert[0].SPEN_ContactId__c = conList[0].Id;
            insert voicealert;   
            Assert.isNotNull(voicealert, 'Voice Alert Passed');
            Set<Id> contactSet=new Set<Id>();
            contactSet.add(conList[1].Id);
            
            SPEN_ContactSelector.phoneNo(voicealert[0].Id);
            //SPEN_ContactSelector.getContact(conList[0].Id);
            SPEN_ContactSelector.setVulCon(contact);
            SPEN_ContactSelector.contactRecord(contact);
            SPEN_ContactSelector.getContactnonPsrlist(contact);
            SPEN_ContactSelector.getCntctFrADQM(contact);
            SPEN_ContactSelector.getContactsByCustomerId(externalId);
            SPEN_ContactSelector.getIdForSyncContactsBatchService(externalId);
            SPEN_ContactSelector.getContactForSyncContactsBatchService(externalId);
            SPEN_ContactSelector.getContactPsrlist(contactSet);
            SPEN_ContactSelector.getSyncFromADQMVal(con.Id);
            
            Assert.isNotNull(contact, 'Contact Passed');
            Test.stopTest();
        }
    }
}