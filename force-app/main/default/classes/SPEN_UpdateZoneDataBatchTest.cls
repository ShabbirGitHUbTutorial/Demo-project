/**
 * @description       : This class is called from SPEN_UpdateZoneDataController and it will update
 *                      the zone record based on externalId.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 12-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_UpdateZoneDataBatchTest {
    @isTest 
    private static void updateZoneRecordsTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
        System.runAs(user)
        { 
            Test.startTest();
            //Added for Assign IVR Message
            SPEN_IVRMessage__c testIVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            insert testIVRMessage;
			
            //Added for Assign IVR Message
            SPEN_Zone__c testRegion = SPEN_TestDataFactory.createZoneRegionRecords(testIVRMessage.Id);
            
            testRegion.SPEN_ExternalId__c = 'OZ03';
            insert testRegion;
            SPEN_Zone__c testDistrict = SPEN_TestDataFactory.createZoneDistrictRecords(testIVRMessage.Id);
            testDistrict.SPEN_Parent__c=testRegion.Id;
            testDistrict.SPEN_ExternalId__c = 'ZW11';
            insert testDistrict;
            SPEN_Zone__c testZone = SPEN_TestDataFactory.createZoneRecords(testIVRMessage.Id);
            testZone.SPEN_Parent__c = testDistrict.Id;
            testZone.SPEN_ExternalId__c = testRegion.Id;
            //insert testZone;
            List<SPEN_Zone__c> lstZone = new List<SPEN_Zone__c>();
            lstZone.add(testZone);
            Database.SaveResult []str = Database.insert(lstZone,false);
            Assert.areEqual(True, str[0].isSuccess());
            Map<String,String> mapZoneIdToZoneName = new Map<String,String>();
            mapZoneIdToZoneName.put(testZone.SPEN_ExternalId__c,testZone.SPEN_Parent__c);
            mapZoneIdToZoneName.put(testDistrict.SPEN_ExternalId__c,testDistrict.SPEN_Parent__c);
            mapZoneIdToZoneName.put(testRegion.SPEN_ExternalId__c,testRegion.SPEN_Parent__c);
            //SPEN_UpdateZoneDataBatch objBatch1 = new SPEN_UpdateZoneDataBatch();
            SPEN_UpdateZoneDataBatch objBatch = new SPEN_UpdateZoneDataBatch(mapZoneIdToZoneName);
            Database.executeBatch(objBatch);
                
            Test.stopTest(); 
        }
    }
    
}