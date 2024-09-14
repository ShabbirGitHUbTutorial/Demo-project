@IsTest
public class SPEN_ZoneSelectorTEST 
{
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps1=SPEN_TestdataSelector.getPermissionSet('SPEN_PremiseAccessCRU');
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2=SPEN_TestdataSelector.getPermissionSet('SPEN_Zone_CRU');
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3=SPEN_TestdataSelector.getPermissionSet('SPEN_IncidentAccessCRU');
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
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
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            List<SPEN_iVRmessage__c> iVRmessageList=new List<SPEN_iVRmessage__c>();
            SPEN_iVRmessage__c iVRmessage = SPEN_TestDataFactory.createiVRmessage(1);
            iVRmessageList.add(iVRmessage);
            insert iVRmessageList;
            List<SPEN_Zone__c> zoneList=new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(iVRmessage.Id);
            zoneRegionRecord.SPEN_OverwriteToChild__c=true;
            zoneList.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(iVRmessage.Id);
            zoneList.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(iVRmessage.Id);
            zoneRecord.SPEN_ExternalId__c = 'XOXO';
            zoneList.add(zoneRecord);
            insert zoneList;
            List<SPEN_Zone__c> updatezoneList=new List<SPEN_Zone__c>();
            zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneDistrictRecord.SPEN_OverwriteToChild__c=true;
            updatezoneList.add(zoneDistrictRecord);
            zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            updatezoneList.add(zoneRecord);
			update updatezoneList;
            Incident inc = SPEN_TestDataFactory.createIncidents(NULL,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_OperatingZoneId__c = 'XOXO';
            insert inc;
            Test.stopTest();
        }
    }
    @IsTest
    private static void testgetZoneRecords()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {   
            Test.startTest();
            
            Set<Id> emptySet = new Set<Id>();
            Set<Id> zoneIds = new Set<Id>();
            
            set<string> zoneSet = new set<string>();
            zoneset.add('XOXO');
            SPEN_Zone__c district=SPEN_TestdataSelector.getZone('District');
            SPEN_Zone__c zone=SPEN_TestdataSelector.getZone('Zone');
            SPEN_Zone__c region=SPEN_TestdataSelector.getZone('Region');
			zoneIds.add(region.Id);
            zoneIds.add(district.Id);
            zoneIds.add(zone.Id);
            List<SPEN_Premise__c> premiselist=SPEN_TestDataFactory.createListOfPremise(2); 
            premiselist[0].SPEN_Zone__c=zone.Id;
            premiselist[1].SPEN_PremiseDistrict__c=district.Id;
            insert premiselist;
            SPEN_ZoneSelector.getZoneRecords(premiselist[0]);
            SPEN_ZoneSelector.getDistrictRecords(premiselist[1]);
            SPEN_ZoneSelector.getRegionRecords(premiselist[0]);
            SPEN_ZoneSelector.getRegionRecord();
            SPEN_ZoneSelector.getDistrictDetails(district.Id);
            SPEN_ZoneSelector.getZoneDetails(zone.Id);
            SPEN_ZoneSelector.getZoneRecordsByIds(zoneIds);
            SPEN_ZoneSelector.getZoneRecordsByIds(emptySet);
            SPEN_ZoneSelector.getZoneTownRecord(zone.Id);
            SPEN_ZoneSelector.getZoneRecordforInc(zoneSet);
            
            Assert.IsNotNull(premiselist[0].Id);      
            Test.stopTest();
        }
    }
    @IsTest
    private static void getChildrenZoneTest()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {   
            Test.startTest();
            SPEN_Zone__c region=SPEN_TestdataSelector.getZone('Region');
            List<SPEN_Zone__c> childZones=SPEN_ZoneSelector.getChildrenZone(new List<Id>{region.Id},'District');
            SPEN_Zone__c district=SPEN_TestdataSelector.getZone('District');
            List<SPEN_Zone__c> childZones2=SPEN_ZoneSelector.getChildrenZone(new List<Id>{region.Id},'Zone');
            Assert.IsNotNull(childZones);  
            Assert.IsNotNull(childZones2);      
            Test.stopTest();
        }
    }
}