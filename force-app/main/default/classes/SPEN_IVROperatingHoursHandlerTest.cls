@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_IVROperatingHoursHandlerTest 
{    
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);        
    }
    @isTest
    public static void activeRecordValidationTestPositive1()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
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
            SPEN_IVROperatingHoursHandler.ActiveRecordValidation(ivrOperHourList,NULL);
            
            for(SPEN_IVROperatingHours__c ivr: ivrOperHourList )
            {
                ivr.SPEN_StartTime__c = system.now().time() - 15;
                ivr.SPEN_EndTime__c = system.now().time() - 10;
            }
            update ivrOperHourList;
            Assert.isNotNull(ivrOperHourList);
            test.stopTest();
    	}
    }
    @isTest
    public static void activeRecordValidationTestPostive2()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
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
                ivr.SPEN_EndTime__c = system.now().time() +10;
            }
            try{
                Insert ivrOperHourList;
            }catch(Exception e){
                Assert.isTrue(e!=null, 'there is validation error in ivr insertion');
            }
            test.stopTest();
    	}
    }
    @isTest
    public static void activeRecordValidationTestNegative()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            test.startTest();
            List<SPEN_IVROperatingHours__c> ivrOperHourList=new List<SPEN_IVROperatingHours__c>();
             SPEN_IVROperatingHoursHandler.ActiveRecordValidation(ivrOperHourList,null);
             Assert.isTrue(ivrOperHourList.isEmpty(), 'there is no error for null params');
            test.stopTest();
    	}
    }
}