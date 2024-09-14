/*************************************************************************
@Author: Shubhi Vijayvergia
@Date: 07/19/2023
<<<<<<< HEAD
@purpose: Test class for SPEN_BlockOutWindowPeriodClassTest // 
=======
@purpose: Test class for SPEN_BlockOutWindowPeriodClassTest 
>>>>>>> UAT
*************************************************************************************/
@isTest
public class SPEN_BlockOutWindowPeriodClassTest{

    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated'){
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        User u = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        u.FirstName = 'Dropped ';
        u.LastName = 'Outbound Task User';
        insert u;
        System.runAs(user)
        {
            Test.startTest();
            List<SPEN_ConfigurableSettings__c> csList=new List<SPEN_ConfigurableSettings__c>();
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            csList.add(cSeting);
            SPEN_ConfigurableSettings__c cSeting1= SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            csList.add(cSeting1);
            SPEN_ConfigurableSettings__c cSeting2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            csList.add(cSeting2);
            insert csList;
            Test.stopTest();
        }
    }
	// when blockout window is in past
	@isTest
    public static void checkBlackoutWindowPeriodTest1(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){  
            Test.startTest();
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
        	List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id iVRVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            iVRORecList[0].RecordTypeId = iVROperatingHoursRecordTypeId;
            iVRORecList[0].SPEN_isActive__c = true;
            iVRORecList[0].SPEN_isDaily__c = true;
            iVRORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            iVRORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert iVRORecList;
            Boolean result=SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod('SMS Blackout Window');
            Assert.AreEqual(result,true);
            Test.stopTest();
        }
        
    }
	// when blockout window is in future
	@isTest
    public static void checkBlackoutWindowPeriodTest2(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){  
            Test.startTest();
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
        	List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id iVRVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            iVRORecList[0].RecordTypeId = iVROperatingHoursRecordTypeId;
            iVRORecList[0].SPEN_isActive__c = true;
            iVRORecList[0].SPEN_isDaily__c = true;
            iVRORecList[0].SPEN_StartTime__c = system.now().time() + 10;
            iVRORecList[0].SPEN_EndTime__c = system.now().time() + 15;
            Insert iVRORecList;
            Boolean result=SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod('SMS Blackout Window');
            Assert.AreEqual(result,true);
            Test.stopTest();
        }
        
    }
	
    // when currently in blockout window
	@isTest
    public static void checkBlackoutWindowPeriodTest3(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){  
            Test.startTest();
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
        	List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id iVRVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            iVRORecList[0].RecordTypeId = iVROperatingHoursRecordTypeId;
            iVRORecList[0].SPEN_isActive__c = true;
            iVRORecList[0].SPEN_isDaily__c = true;
            iVRORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            iVRORecList[0].SPEN_EndTime__c = system.now().time() + 5;
            Insert iVRORecList;
            Boolean result=SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod('SMS Blackout Window');
            Assert.AreEqual(result,true);
            Test.stopTest();
        }
    }
   //negative test case
    @isTest
    public static void checkBlackoutWindowPeriodNegativeTest(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user){  
            Test.startTest();
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
        	List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id iVRVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            iVRORecList[0].RecordTypeId = iVROperatingHoursRecordTypeId;
            iVRORecList[0].SPEN_isActive__c = true;
            iVRORecList[0].SPEN_isDaily__c = true;
            iVRORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            iVRORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert iVRORecList;
            Boolean result=SPEN_BlockOutWindowPeriodClass.checkBlackoutWindowPeriod('');
            Assert.AreEqual(result,false);
            Test.stopTest();
        }
    }

}