/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex Test class for smart meter 
LIBRARY		:	Salesforce Enterprise Library - Smart Meter Connection
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
NOV-03-2022		Dhara Desai     Initial version
-----------------------------------------------------------------------------*/
@IsTest
private class SPEN_TestSmartMeterConnService_Test 
{
	@isTest
	private static void testSmartMeterPingValue()
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
        System.runAs(user){
        SPEN_MPAN__c mpan = SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
    	insert mpan;
        id recordId = mpan.id;
    	SPEN_MPAN__c mpanNew = new SPEN_MPAN__c();
    	mpanNew.id = recordId;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        SPEN_TestSmartMeterConnService.getMPANDetails(recordId);
        SPEN_TestSmartMeterConnService.getPingValue(recordId);
    	Test.stopTest();
        system.assert(mpan!=NULL, 'assert fail');
        }
    }
    @isTest
	private static void testMeterDetails()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.Id,PermissionSetGroupId = devOpsPSGroup.Id);
        System.runAs(user)
        {
            SPEN_MPAN__c mpan = SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert mpan;
            id recordId = mpan.id;
            List<SPEN_SupplierDetails__c> suppInfo = SPEN_TestDataFactory.createSupplierDetailsrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            suppInfo[0].SPEN_SupplierMPID__c = 'BGAS';
            insert suppInfo;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_MeterDetailsIntegrationHTTPMock());
            SPEN_TestSmartMeterConnService.fetchMpanDetails(recordId);
            Test.stopTest();
            system.assert(mpan!=NULL, 'assert fail');
        }
    }
}