@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_IVRSelectorTest {
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        System.runAs(user)
        {
            test.startTest();
        	List<SPEN_IVR__c> iVRList = SPEN_TestDataFactory.createIVRrecord(1);
            iVRList[0].SPEN_ExternalId__c='test1234';
            iVRList[0].SPEN_CallGroup__c='PSR';
            Insert iVRList;
            test.stopTest();
    	}        
    }
    @isTest
    public static void getIVRTestPos()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            List<String> externalIdSet=new List<String>();
            externalIdSet.add('test1234');
        	List<SPEN_IVR__c> ivr=SPEN_IVRSelector.getIvrSelector(externalIdSet);
            Assert.AreEqual(ivr[0].SPEN_CallGroup__c,'PSR');
            test.stopTest();
    	}
    }
    @isTest
    public static void getIVRTestNeg()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            List<String> externalIdSet=new List<String>();
        	List<SPEN_IVR__c> ivr=SPEN_IVRSelector.getIvrSelector(externalIdSet);
            Assert.AreEqual(ivr.size(),0);
            test.stopTest();
    	}
    }
}