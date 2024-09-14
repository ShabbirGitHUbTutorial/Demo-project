@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_AffectedPremiseBatchTest {
    @IsTest
    private static void testAffectedPremiseexecute()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps6.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps8 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps8.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_OutboundContactHoursCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
		insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());             
            Test.startTest();
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(1,'OutboundIncidentType');
            insert cs;
            SPEN_ConfigurableSettings__c cs1 = SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cs1;
            SPEN_ConfigurableSettings__c cs2 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'MessagingTaskType');       //Added Ayush 13 02 2023
            insert cs2;                                                                                                                                     //Added Ayush 13 02 2023
            SPEN_ConfigurableSettings__c cs3 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs3;
            SPEN_ConfigurableSettings__c cs4 =SPEN_TestDataFactory.createConfigSetting(1,'SPCaseOutcomeForMerge');
            insert cs4;
            SPEN_IVRMessage__c message = SPEN_TestDataFactory.createIVRMessage(1);
            message.SPEN_Purpose__c='Incident Created';
            message.Name='SMS – Single Premise – Network Fault';
            insert message;
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.Phone='01416140637';
            insert con;
            
            List<SPEN_Premise__c> premiselist=SPEN_TestDataFactory.createPremiseRecord('Premise','OX123',2);
            premiselist[1].SPEN_PremiseNumber__c = '234';
            insert premiselist;
            
            List<SPEN_PSR__c> psrlist = SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psrlist[0].SPEN_Contact__c = con.Id;                    
            psrlist[0].SPEN_Premise__c = premiselist[0].Id;
            insert psrlist;
               
            List<String> pnumList=new List<String>();
            pnumList.add(premiselist[0].SPEN_PremiseId__c);
            pnumList.add(premiselist[1].SPEN_PremiseId__c);
            Map<String,String> pMap=new Map<String,String>();
            pMap.put(premiselist[0].SPEN_PremiseNumber__c, 'OFFSUPPLY');
            pMap.put(premiselist[1].SPEN_PremiseNumber__c, 'RESTORED');

            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_Role__c = 'Customer';
            insert conpremise;
            
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(2); 
            testCase[0].Origin = 'Web';
            testCase[1].SPEN_IsMerge__c = True;       
            insert testCase;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_EstimatedRestorationTime__c=system.now();
            inc.SPEN_IncidentType__c='SP';
            inc.SPEN_IncidentID__c = 'I001';
            insert inc;
            
            Incident incdnt = new Incident(); 
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = 'I002';
            incdnt.ParentIncidentId = inc.Id;
            incdnt.SPEN_EstimatedRestorationTime__c = system.now();
            incdnt.SPEN_UpgradeDateTime__c = system.now()+5;           
            insert incdnt;
            
	        testCase[0].SPEN_Incident__c = incdnt.id;           
            testCase[0].SPEN_INCChangeTime__c = system.now();
            testCase[1].SPEN_Incident__c = incdnt.id;        
            update testCase;                                    
            
            List<SPEN_IntegrationRequest__c> intRequestRecord = SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            intRequestRecord[0].SPEN_Records__c = incdnt.SPEN_IncidentID__c;
            intRequestRecord[0].SPEN_RelatedRecord__c = incdnt.SPEN_IncidentID__c;
            insert intRequestRecord;
            
            SPEN_IncidentHistory__c incHis = new SPEN_IncidentHistory__c();
            incHis.SPEN_NewValue__c='Affected';
            insert incHis;
            
            List<SPEN_ImpactedPremise__c> impList=SPEN_TestDataFactory.createImpactedPremiserecord(2);
            impList[0].SPEN_RelatedIncident__c=incdnt.Id;
            impList[0].SPEN_ContactPremise__c=conpremise.Id;
            impList[0].SPEN_Status__c='Restored';
            insert impList;            
            
            Integer count = SPEN_TestDataFactoryConstants.SINGLE_REC;
            
            List<SPEN_IVR__c> iVRList = SPEN_TestDataFactory.createIVRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            Insert iVRList;
            
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,iVRList[0].id,message.id);
            for(SPEN_IVROperatingHours__c ivr : iVRORecList)
            {
                ivr.RecordTypeId = iVROperatingHoursRecordTypeId;
                ivr.SPEN_isActive__c = true;
                ivr.SPEN_isDaily__c = true;
                ivr.SPEN_StartTime__c = system.now().time() - 10;
                ivr.SPEN_EndTime__c = system.now().time() - 5;
            }
            Insert iVRORecList;
            
            SPEN_AffectedPremiseBatch obj= new SPEN_AffectedPremiseBatch(pMap,pnumList,incdnt,String.valueOf(system.now()),count+1,count);
            Database.executeBatch(obj);
            Assert.isNotNull(obj);
        }	     
    }
}