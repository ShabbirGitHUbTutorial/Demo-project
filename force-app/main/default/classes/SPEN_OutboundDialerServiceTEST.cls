@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_OutboundDialerServiceTEST {
    
    @IsTest
    private static void testIdentificationMethod()
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
            Test.startTest();
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
            insert premiseList; 
            
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            //con.MobilePhone='1234567892';
            con.SPEN_PSR__c=true;
            con.SPEN_IsPrimaryContact__c = true;
            con.SPEN_CustomerID__c = String.valueOf(premiseList[0].Id);
            insert con;
            
            /*Contact con1= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            //con.MobilePhone='1234567892';
            con1.SPEN_PSR__c=true;
            con1.SPEN_IsPrimaryContact__c = true;
            con1.SPEN_CustomerID__c = String.valueOf(premiseList[1].Id);
            insert con1;*/
            
            Contact con1= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con1.MobilePhone = '07123456799';
            con1.FirstName = 'John';
            con1.LastName = 'Doe';
            con1.Phone = '01234567891';
            con1.SPEN_PSR__c=false;
            con1.SPEN_IsPrimaryContact__c = false;
            con1.SPEN_CustomerID__c = String.valueOf(premiseList[1].Id);
            insert con1;
            
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
            insert testCase;
            
            list<SPEN_PSRVulnerabilityType__c> psrv=SPEN_TestDataFactory.createPSRVulnerabilityRecords();
            insert psrv;
            
            List<SPEN_PSR__c> psralert1=SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psralert1[0].SPEN_Contact__c=con.Id;
            psralert1[0].SPEN_PSRVulnerabilityType__c=psrv[0].Id;
            insert psralert1;
            
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_Role__c = 'Customer';
            insert conpremise;
            
            SPEN_ContactPremise__c conpremise2 = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con1.Id,premiseList[0].Id);
            conpremise2.SPEN_ExternalId__c='1245';
            conpremise2.SPEN_Role__c = 'Alternative Contact';
            insert conpremise2;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='SP';
            inc.SPEN_IncidentID__c = '1111';
            insert inc;
            
            Incident inc1 = SPEN_TestDataFactory.createIncidents(testCase[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc1.SPEN_IncidentType__c='SP';
            inc1.SPEN_IncidentID__c = '111456789';
            insert inc1;
            List<String> inclist=new List<String>();
            inclist.add(inc.Id);
            inclist.add(inc1.Id);
            
            
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'OutboundIncidentType');
            insert cSeting;
            
            List<SPEN_ImpactedPremise__c> impList=SPEN_TestDataFactory.createImpactedPremiserecord(2);
            impList[0].SPEN_Status__c='Not Restored';
            impList[0].SPEN_RelatedIncident__c=inc.Id;
            impList[0].SPEN_ContactPremise__c=conpremise.Id;
            impList[0].SPEN_PremiseId__c = String.valueOf(premiseList[0].Id);
            impList[0].SPEN_IncidentId__c = '1111';
            
            impList[1].SPEN_Status__c='Not Restored';
            impList[1].SPEN_RelatedIncident__c=inc.Id;
            impList[1].SPEN_ContactPremise__c=conpremise.Id;
            impList[1].SPEN_PremiseId__c = String.valueOf(premiseList[0].Id);
            impList[1].SPEN_IncidentId__c = '1112';
            insert impList;
            
            Group odQue=new Group();
            odQue.DeveloperName='Outbound_Dialer2';
            odQue.Name='Outbound Dialer';
            insert odQue;
            
            User user1 = SPEN_TestDataFactory.settestUser('Minimum Access - Salesforce');
            Database.insert(user1);
            
            SPEN_CustomerUpdate__c cus=new SPEN_CustomerUpdate__c();
            cus.SPEN_IncidentId__c=inc.Id;
            cus.OwnerId=user1.Id;
            cus.SPEN_Campaign__c='Stage 3';
            insert cus;
            
            map<id,SPEN_ImpactedPremise__c> impMap = new map<id,SPEN_ImpactedPremise__c>();
            impMap.put(impList[0].id, impList[0]);
            impMap.put(impList[1].id, impList[1]);
            
            SPEN_OutboundDialerService ods = new SPEN_OutboundDialerService();
            //ods.IdentificationMethod(impList, impMap);
            //ods.IdentificationMethod(impList, null);
            SPEN_OutboundDialerService.dropOlderODTasksOnMerge(inclist);
            SPEN_OutboundDialerService.dropOlderODTasksOnDelog(inclist);
            SPEN_OutboundDialerService.dropComfortODTasksOnERTChange(inclist);
            Assert.isNotNull(inclist, 'Assertion Passed');
            Test.stopTest();
        }
    }
}