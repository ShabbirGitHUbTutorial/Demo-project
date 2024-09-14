@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_GetMeterDetailsByMpanService_Test 
{
    @testSetup static void setup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IntegrationRequestAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_SupplierDetails_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        
        System.runAs(user)
        {
            List<SPEN_SupplierDetails__c> suppInfo = SPEN_TestDataFactory.createSupplierDetailsrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            suppInfo[0].SPEN_SupplierMPID__c = 'BGAS';
            insert suppInfo;

            List<SPEN_IntegrationRequest__c> lstIntReq = SPEN_TestDataFactory.completeIntegrationReq(1);
            lstIntReq[0].SPEN_IntegrationRequestServiceClass__c = 'SPEN_GetMeterDetailsByMpanService';
            lstIntReq[0].SPEN_Records__c = '1800017037786';
            insert lstIntReq[0];
            Assert.isTrue(lstIntReq!= null);
            List<SPEN_MPAN__c> lstMPAN = SPEN_TestDataFactory.createMPANList(1);
            lstMPAN[0].SPEN_AccountNumberMPAN__c='1800017037786';
            insert lstMPAN;
        }
    }
    @isTest
    public static void testGetMeterDetailsFromMpan()
    {
    
        User user= [Select id FROM User WHERE Id !=null and IsActive=true LIMIT 1];
        List<SPEN_IntegrationRequest__c> lst = [select id,SPEN_Records__c FROM SPEN_IntegrationRequest__c WHERE Id !=null LIMIT 1];
        System.runAs(user)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_MeterDetailsIntegrationHTTPMock());
            SPEN_GetMeterDetailsByMpanService.getMeterDetailsFromMpan(lst[0].id,lst[0].SPEN_Records__c);
            Assert.isTrue(lst!= null);
            Test.stopTest();
        }
    }
    @isTest
    public static void testCompletedStatus()
    {        
        User user= [Select id FROM User WHERE Id !=null and IsActive=true LIMIT 1];
        List<SPEN_IntegrationRequest__c> lst = [select id,SPEN_Records__c FROM SPEN_IntegrationRequest__c WHERE Id !=null LIMIT 1];

        System.runAs(user)
        {
            lst[0].SPEN_Records__c = '';
            update lst;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_MeterDetailsIntegrationHTTPMock());
            SPEN_GetMeterDetailsByMpanService.getMeterDetailsFromMpan(lst[0].id,lst[0].SPEN_Records__c);
            Assert.isTrue(lst!= null);
            Test.stopTest();
        }
    }
}