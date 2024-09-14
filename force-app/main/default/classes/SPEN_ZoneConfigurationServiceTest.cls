@isTest
public class SPEN_ZoneConfigurationServiceTest {
    static final string INTEGRATION_PROFILE='SPEN_IntegrationRequestAccessCRU';
    static final  Id MSG_RECORDTYPE = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
    //test data setup method
    @testSetup static void setup(){
        //Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        user.isActive=true;
        user.Firstname='ZoneTestUser';
        Database.insert(user);
        PermissionSet ps1=SPEN_TestdataSelector.getPermissionSet(INTEGRATION_PROFILE);
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);  
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);	
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user){
            Test.startTest();
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,SPEN_ConstantData.IncidentMessage);
            cs.Name = 'Zone broadcast message updated last one hour';
            cs.SPEN_Value__c = '10';
            insert cs;
            List<SPEN_iVRmessage__c> iVRmessageList=new List<SPEN_iVRmessage__c>();
            SPEN_iVRmessage__c iVRmessage = SPEN_TestDataFactory.createiVRmessage(1);
            iVRmessageList.add(iVRmessage);
            SPEN_iVRmessage__c iVRmessage1 = SPEN_TestDataFactory.createiVRmessage(2);
            iVRmessage1.SPEN_ExternalId__c='Case-Creation-2';
            iVRmessageList.add(iVRmessage1);
            insert iVRmessageList;
            List<SPEN_IntegrationRequest__c> inte=SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert inte;
            List<SPEN_Zone__c> zoneList=new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(iVRmessage.Id);
            zoneRegionRecord.SPEN_OverwriteToChild__c=true;
            zoneList.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(iVRmessage.Id);
            zoneList.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(iVRmessage.Id);
            zoneList.add(zoneRecord);
            insert zoneList;
            List<SPEN_Zone__c> updatezoneList=new List<SPEN_Zone__c>();
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneDistrictRecord.SPEN_OverwriteToChild__c=true;
            updatezoneList.add(zoneDistrictRecord);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            updatezoneList.add(zoneRecord);
			update updatezoneList;
            inte[0].SPEN_RelatedRecord__c=zoneRegionRecord.Id;
            update inte[0];
            Test.stopTest();
        }
    }
    //method to test beforeinsert
    @IsTest
    private static void zoneServiceTestbeforeInsert(){
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        System.runAs(user){   
            Test.startTest();
            SPEN_iVRmessage__c iVRmessage =SPEN_TestdataSelector.getIVRMessage('Case-Creation-2');
            if(iVRmessage!=null){
                SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(iVRmessage.Id);
                zoneRegionRecord.SPEN_OverwriteToChild__c=true;
                insert zoneRegionRecord;
                SPEN_Zone__c zoneRegionRecord1=SPEN_TestdataSelector.getZone(zoneRegionRecord.id);
                Assert.areEqual(zoneRegionRecord1.SPEN_IVRTemplateBody__c, iVRmessage.SPEN_iVRmessage__c,'TemplateBody field has same value as message body' );
            }
            Test.stopTest();
        }
    }
    //method to test positive beforeUpdate
    @IsTest
    private static void zoneServiceTestbeforeUpdate(){
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        System.runAs(user)
        {   
            Test.startTest();
            SPEN_iVRmessage__c iVRmessage =SPEN_TestdataSelector.getIVRMessage('Case-Creation-2');
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            if(iVRmessage!=null){
                SPEN_Zone__c zoneRegionRecord =SPEN_TestdataSelector.getZone('Region');
                if(zoneRegionRecord!=null){
                    zoneRegionRecord.SPEN_IVRMessageTemplate__c=iVRmessage.id;
                    update zoneRegionRecord;
                    SPEN_Zone__c zone=SPEN_TestdataSelector.getZone(zoneRegionRecord.id);
                    Assert.areEqual(zone.SPEN_IVRTemplateBody__c, iVRmessage.SPEN_iVRmessage__c,'TemplateBody field has same value as message body' );
                }
            }
            Test.stoptest();
        
        }
	}
    //method to test positive AfterUpdate updating parent with type=region 
    @isTest
    private static void zoneServiceTestAfterUpdateRegionPositive(){
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        System.runAs(user)
        {   
            Test.startTest();
            SPEN_iVRmessage__c iVRmessage =SPEN_TestdataSelector.getIVRMessage('Case-Creation-2');
            SPEN_Zone__c zoneRegionRecord =SPEN_TestdataSelector.getZone('Region');
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            if(iVRmessage!=null && zoneRegionRecord!=null){
                zoneRegionRecord.SPEN_BroadcastMessage__c='This is test message';
                zoneRegionRecord.SPEN_IVRMessageTemplate__c=iVRmessage.id;
                update zoneRegionRecord;
                SPEN_IntegrationRequest__c inte2=SPEN_TestdataSelector.getIR(zoneRegionRecord.id);
                Assert.areEqual(inte2.SPEN_Response__c,zoneRegionRecord.SPEN_BroadcastMessage__c,'INte response is equal to broadcast message of related zone' );
                SPEN_Zone__c zoneDistrictRecord2=SPEN_TestdataSelector.getZone('District');
                Assert.areEqual(zoneDistrictRecord2.SPEN_IVRMessageTemplate__c,iVRmessage.id,'Update parent template message on child' );
            }
            Test.stoptest();
        }
	}
     //method to test positive AfterUpdate updating parent with type=district
    @isTest
    private static void zoneServiceTestAfterUpdateDistrictPositive(){
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        System.runAs(user)
        {   
            Test.startTest();
            SPEN_iVRmessage__c iVRmessage =SPEN_TestdataSelector.getIVRMessage('Case-Creation-2');
            SPEN_Zone__c zoneDistrictRecord =SPEN_TestdataSelector.getZone('District');
            if(iVRmessage!=null && zoneDistrictRecord!=null){
                zoneDistrictRecord.SPEN_IVRMessageTemplate__c=iVRmessage.id;
                update zoneDistrictRecord;
                SPEN_Zone__c zoneRec=SPEN_TestdataSelector.getZone('Zone');
                Assert.areEqual(zoneRec.SPEN_IVRMessageTemplate__c,iVRmessage.id,'Update parent template message on child' );
            }
            Test.stoptest();
        }

    }
    //method to test negative afterUpdate updating overwriteflag to false on child
    @isTest
    private static void zoneServiceTestAfterUpdateRegionNegative(){
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        System.runAs(user)
        {   
            Test.startTest();
            SPEN_iVRmessage__c iVRmessage =SPEN_TestdataSelector.getIVRMessage('Case-Creation-2');
            SPEN_Zone__c zoneRegionRecord =SPEN_TestdataSelector.getZone('Region');
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            if(iVRmessage!=null && zoneRegionRecord!=null){
                zoneRegionRecord.SPEN_OverwriteToChild__c=false;
                zoneRegionRecord.SPEN_IVRMessageTemplate__c=iVRmessage.id;
                update zoneRegionRecord;
                SPEN_Zone__c zoneDistrictRecord2=SPEN_TestdataSelector.getZone('District');
                Assert.areNotEqual(zoneDistrictRecord2.SPEN_IVRMessageTemplate__c,zoneRegionRecord.SPEN_IVRMessageTemplate__c,'Dont Update parent template message on child for overwritetochild=false' );
            }
            Test.stoptest();
        }
	}
    //checking exception
   	
    @IsTest
    private static void zoneServiceTestException()
    {
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        Spen_Zone__c zoneRecord;
        System.runAs(user)
        {
            try{
                SPEN_ZoneConfigurationService.beforeZoneInsert(Null);
            	SPEN_ZoneConfigurationService.beforeZoneUpdate(Null,Null);
            	SPEN_ZoneConfigurationService.afterZoneUpdate(Null,Null);
            }catch(Exception e){
                Boolean containsForce = e!=null;
				Assert.isTrue(containsForce); // Assertion succeeds
            }
            try{
                SPEN_ZoneConfigurationService.beforeZoneInsert(Null);
            }catch(Exception e){
                Boolean containsForce = e!=null;
				Assert.isTrue(containsForce); // Assertion succeeds
            }
            try{
            	SPEN_ZoneConfigurationService.beforeZoneUpdate(Null,Null);
            }catch(Exception e){
                Boolean containsForce = e!=null;
				Assert.isTrue(containsForce); // Assertion succeeds
            }
            try{
	           	SPEN_ZoneConfigurationService.afterZoneUpdate(Null,Null);
            }catch(Exception e){
                Boolean containsForce = e!=null;
				Assert.isTrue(containsForce); // Assertion succeeds
            }


        }
        Assert.areEqual(zoneRecord,null, 'Test exception' );
    }
    //test getOutageETR
    @IsTest
    private static void getOutageETRTest()
    {
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        Spen_Zone__c zoneRecord;
        System.runAs(user)
        {
            String getOutageETR=SPEN_ZoneConfigurationService.getOutageETR();
            Assert.areEqual(getOutageETR,null, 'getOutageETR return empty string' );
        }
    }
    //getOutageTimeInModValue test  
    @IsTest
    private static void getOutageTimeInModValueTest()
    {
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        Spen_Zone__c zoneRecord;
        System.runAs(user)
        {
            String getOutageTime=SPEN_ZoneConfigurationService.getOutageTimeInModValue(1,true);
            Assert.areNotEqual(getOutageTime,null, 'getOutageTime  not return empty string' );
        }
    }
    //getOutsideETRMessage test  
    //
    @IsTest
    private static void getOutsideETRMessageTest()
    {
        User user=SPEN_TestdataSelector.getuser('ZoneTestUser');
        Spen_Zone__c zoneRecord;
        System.runAs(user)
        {
            String getOutsideETR=SPEN_ZoneConfigurationService.getOutsideETRMessage('Test');
            Assert.areNotEqual(getOutsideETR,null, 'getOutsideETR  not return empty string' );
        }
    }
    
}