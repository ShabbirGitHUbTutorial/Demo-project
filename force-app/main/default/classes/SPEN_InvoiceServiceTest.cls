@IsTest
public with sharing class SPEN_InvoiceServiceTest 
{
	@IsTest
    private static void insertInvoiceTest() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        system.debug('devOpsPSGroup'+devOpsPSGroup);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_InvoiceAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            ID caseThirdPartyDamageRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            Case cse = new Case();
           	cse.Status ='Created';
            cse.RecordTypeId = caseThirdPartyDamageRTId;
            insert cse;
                        
            List<SPEN_Invoice__c> testInvoice = SPEN_TestDataFactory.createInvoices(cse.Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testInvoice;
            
            List<SPEN_Invoice__c> testInvoice1 = SPEN_TestDataFactory.createInvoices(cse.Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            testInvoice1[0].SPEN_InvoicedOutcome__c = 'Re-issued';
            insert testInvoice1;
            
            System.assertEquals(testInvoice1[0].SPEN_InvoicedOutcome__c, 'Re-issued');
            Test.stopTest();
        }
    }
}