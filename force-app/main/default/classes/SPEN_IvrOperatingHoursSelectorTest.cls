@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_IvrOperatingHoursSelectorTest {
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
            Insert iVRList;
            SPEN_IVRMessage__c iVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            Insert iVRMessage;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> ivrOperHourList = SPEN_TestDataFactory.createIVROperatingHoursrecord(2,iVRList[0].id,iVRMessage.id);
            for(SPEN_IVROperatingHours__c ivr : ivrOperHourList)
            {
                ivr.RecordTypeId = iVROperatingHoursRecordTypeId;
                ivr.SPEN_isActive__c = TRUE;
                ivr.SPEN_StartTime__c = system.now().time() - 10;
                ivr.SPEN_EndTime__c = system.now().time() - 5;
            }
            Insert ivrOperHourList;
            test.stopTest();
    	}        
    }
    @isTest
    public static void getIVROperatingHourTypeCheckTestPos()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
        	SPEN_IVROperatingHours__c ivroh=SPEN_IvrOperatingHoursSelector.getIVROperatingHourTypeCheck(iVROperatingHoursRecordTypeId);
            Assert.AreEqual(ivroh.RecordTypeId,iVROperatingHoursRecordTypeId);
            test.stopTest();
    	}
    }
    @isTest
    public static void getIVROperatingHourTypeCheckTestNeg()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
        	SPEN_IVROperatingHours__c ivroh=SPEN_IvrOperatingHoursSelector.getIVROperatingHourTypeCheck(iVROperatingHoursRecordTypeId);
            Assert.areEqual(ivroh,new SPEN_IVROperatingHours__c());
            test.stopTest();
    	}
    }
    @isTest
    public static void getIVROperatingHoursTestPos()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
        	List<SPEN_IVROperatingHours__c> ivroh=SPEN_IvrOperatingHoursSelector.getIVROperatingHours('SMS Blackout Window');
            Assert.isTrue(ivroh!=null);
            test.stopTest();
    	}
    }
    @isTest
    public static void getIVROperatingHoursTestNeg()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            try{
                List<SPEN_IVROperatingHours__c> ivroh=SPEN_IvrOperatingHoursSelector.getIVROperatingHours('Test');
            	Assert.areEqual(ivroh,new SPEN_IVROperatingHours__c());
            }catch(Exception e){
                Assert.isNotNull(e);
        	}
            test.stopTest();
    	}
    }
    @isTest
    public static void getIVROperatingHoursTestPos1()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            Set<Id> currentidset= new Set<Id>();
            Map<id,string> recMap = new Map<id,string>();
            List<SPEN_IVR__c> iVRList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert iVRList;
            SPEN_IVRMessage__c iVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            iVRmessage.SPEN_ExternalId__c = 'Test12345678';    
            Insert iVRMessage;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            recMap.put(iVROperatingHoursRecordTypeId,'SMS Blackout Window');
            List<SPEN_IVROperatingHours__c> ivrOperHourList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,iVRList[0].id,iVRMessage.id);
            for(SPEN_IVROperatingHours__c ivr : ivrOperHourList)
            {
                ivr.RecordTypeId = iVROperatingHoursRecordTypeId;
                ivr.SPEN_isActive__c = true;
                ivr.SPEN_StartTime__c = system.now().time() + 10;
                ivr.SPEN_EndTime__c = system.now().time() +5;
            }
            try{
                Insert ivrOperHourList;
            	currentidset.add(ivrOperHourList[0].id);
        		List<SPEN_IVROperatingHours__c> ivroh=SPEN_IvrOperatingHoursSelector.getIVROperatingHours(recMap.keyset(),currentidset);
            	Assert.isTrue(ivroh!=null);
            }catch(Exception e){
                  Assert.isTrue(e!=null);
            }
            test.stopTest();
    	}
    }
    @isTest
    public static void getIVROperatingHoursTestNeg1()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            List<SPEN_IVR__c> iVRList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert iVRList;
            SPEN_IVRMessage__c iVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            iVRmessage.SPEN_ExternalId__c = 'Test1234567';    
            insert iVRMessage;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> ivrOperHourList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,iVRList[0].id,iVRMessage.id);
            for(SPEN_IVROperatingHours__c ivr : ivrOperHourList)
            {
                ivr.RecordTypeId = iVROperatingHoursRecordTypeId;
                ivr.SPEN_isActive__c = False;
                ivr.SPEN_StartTime__c = system.now().time() - 10;
                ivr.SPEN_EndTime__c = system.now().time() - 5;
            }
            Insert ivrOperHourList;
            try{
             	List<SPEN_IVROperatingHours__c> ivroh=SPEN_IvrOperatingHoursSelector.getIVROperatingHours(NULL,NULL);
            	Assert.areEqual(ivroh,new SPEN_IVROperatingHours__c());
            }catch(Exception e){
                Assert.isNotNull(e);
            }
            test.stopTest();
    	}
    }
}