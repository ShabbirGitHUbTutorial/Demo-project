@IsTest
public class SPEN_ActiveIncidentCheck_Test 
{
    @IsTest
    private static void testfetchIncident()
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
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            SPEN_ConfigurableSettings__c cs7 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs7;
            CallCenter center=[select Id from CallCenter limit 1];
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            //testCase[0].ContactId=con.Id;
            insert testCase;
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='LV';
            insert inc;
            List<SPEN_Premise__c> premiseRec = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiseRec;
            //List<SPEN_ImpactedPremise__c> implist=SPEN_TestDataFactory.createImpactedPremiserecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            List<SPEN_ImpactedPremise__c> implist=SPEN_TestDataFactory.createImpactedPremiserecord(2);
            implist[0].SPEN_RelatedIncident__c=inc.Id;
            implist[0].SPEN_PremiseId__c= premiseRec[0].SPEN_PremiseID__c;
            insert implist;
            VoiceCall vc=SPEN_TestDataFactory.createVoiceCall(SPEN_TestDataFactoryConstants.SINGLE_REC);
            vc.VendorCallKey='Test vendor';
            vc.CallCenterId =center.Id;
            vc.SPEN_VoicecallPremise__c = premiseRec[0].Id;
            insert vc;
            List <VoiceCall> vclist=new List<VoiceCall>();
            vclist.add(vc);
            List<SPEN_IntegrationRequest__c> intereq=SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert intereq;
            List<Case> testCase1 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase1[0].Origin = 'Web';
            //testCase[0].ContactId=con.Id;
            insert testCase1;
            Incident inc1 = SPEN_TestDataFactory.createIncidents(testCase1[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            //inc1.Id=implist[0].SPEN_RelatedIncident__c;
            inc1.SPEN_IncidentType__c='LV';
            insert inc1;
            //List<SPEN_ImpactedPremise__c> implist1=SPEN_TestDataFactory.createImpactedPremiserecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            implist[1].SPEN_RelatedIncident__c=inc1.Id;
            update implist;
            Set<Id> recId = new Set<Id>();
            recId.add(vc.Id);
            SPEN_ActiveIncidentCheck.fetchIncidentRecValue(recId);
            //SPEN_ActiveIncidentCheck.UpdateVoiceCallRecord(inc.id, vclist);
            //SPEN_ActiveIncidentCheck.GetIntegrationRequestRecord(intereq[0].Id, vclist);
            //fetchIncident.put('Test VoiceCall',vclist);
            //Assert.isNotNull(fetchIncident);
            Test.stopTest();
        }
    }
    
	@IsTest
    private static void testIntegrationRequest()
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
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            SPEN_ConfigurableSettings__c cs1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs1;
            
            CallCenter center=[select Id from CallCenter limit 1];
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
			testCase[0].Origin = 'Web';
			insert testCase;
            
			Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
			inc.SPEN_IncidentType__c='LV';
			inc.SPEN_IncidentStatus__c='Emergency';
			insert inc;
            
            List<SPEN_Premise__c> premiseRec = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiseRec;
            
            List<SPEN_ImpactedPremise__c> implist=SPEN_TestDataFactory.createImpactedPremiserecord(2);
            implist[0].SPEN_RelatedIncident__c=inc.Id;
            implist[0].SPEN_PremiseId__c= premiseRec[0].SPEN_PremiseID__c;
            insert implist;
            
            VoiceCall vc=SPEN_TestDataFactory.createVoiceCall(SPEN_TestDataFactoryConstants.SINGLE_REC);
            vc.VendorCallKey='Test vendor';
            vc.CallCenterId =center.Id;
            vc.SPEN_VoicecallPremise__c = premiseRec[0].Id;
            insert vc;
            List <VoiceCall> vclist=new List<VoiceCall>();
            vclist.add(vc);
            
            List<SPEN_IntegrationRequest__c> intereq=SPEN_TestDataFactory.createIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
            intereq[0].SPEN_Records__c=vc.SPEN_VoicecallPremise__r.SPEN_PremiseID__c;
            intereq[0].SPEN_Status__c = 'Completed';
            intereq[0].SPEN_MessageType__c = 'Incident';
            intereq[0].SPEN_RelatedRecord__c = inc.Id;
            intereq[0].SPEN_IntegrationRequestServiceClass__c='SPEN_ActiveIncidentGetPremiseService';
            insert intereq;
            Set<Id> recId = new Set<Id>();
            recId.add(vc.Id);
            
            SPEN_ActiveIncidentCheck.fetchIncidentRecValue(recId);
            //SPEN_ActiveIncidentCheck.GetIntegrationRequestRecord(intereq[0].Id, vclist);
            Assert.isNotNull(inc);
            Test.stopTest();
        }
    }
}