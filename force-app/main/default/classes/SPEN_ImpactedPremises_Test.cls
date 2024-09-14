@isTest
public class SPEN_ImpactedPremises_Test 
{
    @testSetup static void setup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        //User testUser = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        //user.isActive=true;
        User testUser = new User(LastName = 'test user 1', 
                             Username = 'test.user.'+System.currentTimeMillis()+'@example.com', 
                             Email = 'test.1@example.com', 
                             Alias = 'testu1', 
                             TimeZoneSidKey = 'GMT', 
                             LocaleSidKey = 'en_GB', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             ProfileId = profileId,
                             isActive=true,
                             LanguageLocaleKey = 'en_US');    
        Database.insert(testUser);
        List<PermissionSetAssignment> psaList=new list<PermissionSetAssignment>();
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        psaList.add(new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id));
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        psaList.add(new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps3.Id));
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
         psaList.add(new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps4.Id));
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps5.Id));
        PermissionSet ps6 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps6.Id));
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps7.Id));
        PermissionSet ps8 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ImpactedPremiseCRU'];
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps8.Id));
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps9.Id));
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_OutboundContactHoursCRU']; 
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps10.Id));
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MessageTemplateCRU'];
        psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps11.Id));
        PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        psaList.add(  new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps12.Id));
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
		psaList.add( new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = zoneAccess.Id));
        insert psaList;
        User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name =:SPEN_TestDataFactoryConstants.PROFILENAME ) AND isActive = true LIMIT 1];
        System.runAs(u1)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_ConfigurableSettings__c> csList=new List<SPEN_ConfigurableSettings__c>();
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'OutboundIncidentType');
            cSeting.SPEN_Value__c='HV_N,HV_S,LV';
			csList.add(cSeting);
            SPEN_ConfigurableSettings__c CS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            CS2.SPEN_Value__c='15';
			csList.add(CS2);
            SPEN_ConfigurableSettings__c CS3 =SPEN_TestDataFactory.createConfigSetting(1,'SPCaseOutcomeForMerge');
            cs3.SPEN_Value__c='ENS1,NSOS,NOS4,NOS2';
            csList.add(CS3);
            SPEN_ConfigurableSettings__c CS4 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            CS4.SPEN_Value__c='HV_N,HV_S,LV';
            csList.add(CS4);
            SPEN_ConfigurableSettings__c CS5 =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            CS5.SPEN_Value__c='1';
            csList.add(CS5);
            insert csList;

            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.SPEN_PSR__c=true;
            con.SPEN_PreferredMethodofContact__c = 'T';
            insert con;
            
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            premiseList[0].SPEN_PremiseID__c='Test1234';
            insert premiseList; 
            
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_Role__c ='Customer';
            insert conpremise; 
            
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            List<Incident> incdnt = SPEN_TestDataFactory.createListofIncidents(2);
            incdnt[0].SPEN_IncidentID__c = 'I001';
            incdnt[0].SPEN_IncidentCategory__c = 'HV';
            incdnt[0].recordtypeId = recTypeId;
            incdnt[1].SPEN_IncidentCategory__c = 'SP';
            incdnt[0].SPEN_IncidentStatus__c='Merged';
            incdnt[0].SPEN_UpgradeDateTime__c=System.now();
            //incdnt[0].SPEN_ResourceID__c='m0000004eR';
            insert incdnt;
            List<Case>  caseList = SPEN_TestDataFactory.createListOfCases(2);
            caseList[0].SPEN_Incident__c = incdnt[1].id;
            caseList[1].SPEN_Incident__c = incdnt[0].id; 
            caseList[1].SPEN_IsMerge__c = true;      
            caseList[1].SPEN_AddressPremise__c = premiseList[0].id;      
            Insert caseList;
            List<SPEN_ImpactedPremise__c> impList=SPEN_TestDataFactory.createImpactedPremiserecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
			/*impList[0].SPEN_RelatedIncident__c=incdnt[1].Id;   
            impList[0].SPEN_ContactPremise__c=conpremise.Id;
            impList[0].SPEN_MergeDateTime__c=System.now();
            impList[0].SPEN_IsETRChange__c=true;
            impList[0].SPEN_ETRChangeTime__c=System.now();
            */
            impList[0].SPEN_isMerged__c=true;
            impList[0].SPEN_IncidentId__c=incdnt[0].SPEN_IncidentID__c;
            impList[0].SPEN_PremiseId__c=premiseList[0].SPEN_PremiseID__c;
    		impList[0].SPEN_Status__c='Restored';
            impList[0].SPEN_Estimated_Restoration_Time__c=System.now();
            insert impList;
            
            SPEN_IVRMessage__c SMSIVR =SPEN_TestDataFactory.createIVRMessage(SPEN_TestDataFactoryConstants.SINGLE_REC);
            SMSIVR.Name = 'SMS – Single Premise – Network Fault';
            SMSIVR.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert SMSIVR;
            
            SPEN_IVRMessage__c VAIVR =SPEN_TestDataFactory.createIVRMessage(SPEN_TestDataFactoryConstants.SINGLE_REC);
            VAIVR.Name= 'Single Premise Network Fault VA';
            VAIVR.SPEN_ExternalId__c= 'Single Premise Network Fault VA';
            insert VAIVR;
            
            List<SPEN_IVR__c> IVRList = SPEN_TestDataFactory.createIVRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            Insert IVRList;
            
            Id IVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> IVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,IVRList[0].id,SMSIVR.id);
            //for(SPEN_IVROperatingHours__c ivr : IVRORecList)
            //{
                IVRORecList[0].RecordTypeId = IVROperatingHoursRecordTypeId;
                IVRORecList[0].SPEN_isActive__c = true;
                IVRORecList[0].SPEN_isDaily__c = true;
                IVRORecList[0].SPEN_StartTime__c = system.now().time() - 10;
                IVRORecList[0].SPEN_EndTime__c = system.now().time() - 5;
           // }
            
            Insert IVRORecList;
            
        }
    }
    @isTest
    public static void testBeforeInsertBulk(){
        User u= [Select id FROM User where IsActive=true LIMIT 1];
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(10);
            insert premiseList; 
            //Contact con=[Select id from contact where accountId!=null limit 1];
            /*List<SPEN_ContactPremise__c> conPremiseList=new List<SPEN_ContactPremise__c>();
            for(SPEN_Premise__c pr:premiseList){
                SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con.Id,pr.Id);
                conpremise.SPEN_ExternalId__c='1244'+system.now();
                conpremise.SPEN_Role__c ='Customer';
                conPremiseList.add(conpremise);
            }
            insert conPremiseList; */
            
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            List<Incident> incdntList = SPEN_TestDataFactory.createListofIncidents(10);
            for(Integer i=0;i<incdntList.size();i++){
                incdntList[i].SPEN_IncidentID__c = 'I001'+system.now()+i;
                incdntList[i].SPEN_IncidentCategory__c = 'HV';
                incdntList[i].recordtypeId = recTypeId;
                incdntList[i].SPEN_IncidentStatus__c='Merged';
                incdntList[i].SPEN_UpgradeDateTime__c=System.now();
                incdntList[i].SPEN_isUpgrade__c=true;
                incdntList[i].SPEN_IncidentID__c='INCTest00'+i+system.now();
            }
            incdntList[0].SPEN_ResourceID__c='m0000004eR';
            incdntList[1].SPEN_ResourceArrivalDate__c=System.Today();
            incdntList[2].SPEN_EstimatedRestorationTime__c=System.now();
            insert incdntList;
            List<Case>  caseList = SPEN_TestDataFactory.createListOfCases(2);
            caseList[0].SPEN_Incident__c = incdntList[1].id;
            caseList[0].SPEN_IsMerge__c = true;      
            caseList[0].SPEN_AddressPremise__c = premiseList[1].id; 
            caselist[1].SPEN_CaseCategoryOutcome__c='ENS1';
            caseList[1].SPEN_Incident__c = incdntList[0].id; 
            caseList[1].SPEN_IsMerge__c = true;      
            caseList[1].SPEN_AddressPremise__c = premiseList[0].id; 
            caselist[1].SPEN_CaseCategoryOutcome__c='ENS1';
            caselist[1].origin='Web';
            Insert caseList;
            //Integer i=0;
            Test.stopTest();
            List<SPEN_ImpactedPremise__c> impList=SPEN_TestDataFactory.createImpactedPremiserecord(10);
            for(Integer j=0;j<impList.size();j++){
                impList[j].SPEN_isMerged__c=true;
                impList[j].SPEN_IncidentId__c=incdntList[j].SPEN_IncidentID__c;
                impList[j].SPEN_PremiseId__c=premiseList[j].SPEN_PremiseID__c;
                impList[j].SPEN_ExternalId__c=impList[j].SPEN_PremiseId__c+'-'+impList[j].SPEN_IncidentId__c;
                impList[j].SPEN_Status__c='Restored';
            }
            impList[0].SPEN_Status__c='Not Restored';
            insert impList;
            List<SPEN_ImpactedPremise__c> upimpList=new List<SPEN_ImpactedPremise__c>();
            impList[0].SPEN_Status__c='Restored';
            impList[1].SPEN_Status__c='Not Restored';
            impList[0].SPEN_Estimated_Restoration_Time__c=System.now();
            upimpList.add(impList[0]);
            upimpList.add(impList[1]);
            update upimpList;
            Assert.isTrue(impList[0].SPEN_IncidentId__c==incdntList[0].SPEN_IncidentID__c); 
        }

    }
    
    @isTest
    public static void testCreateSMS()
    {
        User u = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name =:SPEN_TestDataFactoryConstants.PROFILENAME ) AND isActive = true LIMIT 1];
        system.runAs(u)
        {
            Test.startTest();
            SPEN_ImpactedPremise__c ImpPremise= [SELECT id,SPEN_RelatedIncident__c,SPEN_ContactPremise__r.SPEN_RelatedContact__r.SPEN_PSR__c,SPEN_RelatedIncident__r.SPEN_IncidentStatus__c,SPEN_RelatedIncident__r.SPEN_IncidentCategory__c,SPEN_RelatedCustomerFormula__c,SPEN_CustomerMobileNumberFormula__c,SPEN_PreferredMethodofContactFormula__c,SPEN_CustomerTelephoneNumberFormula__c FROM SPEN_ImpactedPremise__c LIMIT 1];
            Incident inc = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentCategory__c FROM Incident WHERE SPEN_IncidentCategory__c = 'HV' LIMIT 1 ];
            ImpPremise.SPEN_RelatedIncident__c = inc.id;
            update ImpPremise;
            Test.stopTest();
        }
    }
    @isTest
    public static void testMethod2()
    {
        User u = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name =:SPEN_TestDataFactoryConstants.PROFILENAME ) AND isActive = true LIMIT 1];
        system.runAs(u)
        {
            Test.startTest();
            SPEN_ImpactedPremise__c ImpPremise= [SELECT id,SPEN_RelatedIncident__c FROM SPEN_ImpactedPremise__c LIMIT 1];
            Incident inc = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentCategory__c FROM Incident WHERE SPEN_IncidentCategory__c = 'HV' LIMIT 1 ];
            SPEN_IVROperatingHours__c oprHr = [SELECT id,SPEN_StartTime__c,SPEN_EndTime__c FROM SPEN_IVROperatingHours__c LIMIT 1];
            oprHr.SPEN_StartTime__c = system.now().time() - 5;
            oprHr.SPEN_EndTime__c = system.now().time() - 10;
            update oprHr;
            ImpPremise.SPEN_RelatedIncident__c = inc.id;
            update ImpPremise;
            Test.stopTest();
        }
    }
    
    /*@isTest
    public static void testMethod3()
    {
        User u = [SELECT id FROM user LIMIT 1];
        system.runAs(u)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Contact con = [Select Id,SPEN_PreferredMethodofContact__c from Contact limit 1];
            con.SPEN_PreferredMethodofContact__c = 'H';
            update con;
            
            SPEN_ImpactedPremise__c ImpPremise= [SELECT id,SPEN_RelatedIncident__c FROM SPEN_ImpactedPremise__c LIMIT 1];
            Incident inc = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentCategory__c FROM Incident WHERE SPEN_IncidentCategory__c = 'HV' LIMIT 1 ];
            SPEN_IVROperatingHours__c oprHr = [SELECT id,SPEN_StartTime__c,SPEN_EndTime__c FROM SPEN_IVROperatingHours__c LIMIT 1];
            oprHr.SPEN_StartTime__c = system.now().time() - 5;
            oprHr.SPEN_EndTime__c = system.now().time() - 10;
            update oprHr;
            ImpPremise.SPEN_RelatedIncident__c = inc.id;
            update ImpPremise;
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testMethod4()
    {
        User u = [SELECT id FROM user LIMIT 1];
        system.runAs(u)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ImpactedPremise__c ImpPremise= [SELECT id,SPEN_RelatedIncident__c FROM SPEN_ImpactedPremise__c LIMIT 1];
            Incident inc = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentCategory__c FROM Incident WHERE SPEN_IncidentCategory__c = 'HV' LIMIT 1 ];
            SPEN_IVROperatingHours__c oprHr = [SELECT id,SPEN_StartTime__c,SPEN_EndTime__c FROM SPEN_IVROperatingHours__c LIMIT 1];
            SPEN_Premise__c prem = [Select id from SPEN_Premise__c LIMIT 1];		
            
            Account accRec = [SELECT id FROM Account LIMIT 1];
            Contact con1= SPEN_TestDataFactory.createContacts(accRec.Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con1.SPEN_PSR__c=true;
            con1.SPEN_PreferredMethodofContact__c = 'H';
            con1.FirstName = 'A';
            con1.LastName = 'B';
            con1.SPEN_CustomerID__c = '222';
            insert con1;
            
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,con1.Id,prem.Id); ///
            conpremise.SPEN_ExternalId__c='2345';
            conpremise.SPEN_Role__c = 'PSR Contact';
            insert conpremise;
            
            Test.startTest();
            ImpPremise.SPEN_ContactPremise__c = conpremise.id;
            ImpPremise.SPEN_RelatedIncident__c = inc.id;
            update ImpPremise;
            Test.stopTest();
        }
    }
    @isTest
    public static void testMethod5()
    {
        User u = [SELECT id FROM user LIMIT 1];
        system.runAs(u)
        {
            Test.startTest();
            SPEN_ImpactedPremise__c ImpPremise= [SELECT id,SPEN_RelatedIncident__c FROM SPEN_ImpactedPremise__c LIMIT 1];
            Incident inc = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentCategory__c FROM Incident WHERE SPEN_IncidentCategory__c = 'HV' LIMIT 1 ];
            SPEN_IVROperatingHours__c oprHr = [SELECT id,SPEN_StartTime__c,SPEN_EndTime__c FROM SPEN_IVROperatingHours__c LIMIT 1];
            oprHr.SPEN_StartTime__c = system.now().time() + 10;
            oprHr.SPEN_EndTime__c = system.now().time() - 5;
            update oprHr;
            ImpPremise.SPEN_RelatedIncident__c = inc.id;
            update ImpPremise;
            Test.stopTest();
        }
    }*/
    
    @isTest
    public static void testblackoutperiod()
    {
        User u = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name =:SPEN_TestDataFactoryConstants.PROFILENAME ) AND isActive = true AND alias='testu1' LIMIT 1];
        system.runAs(u)
        {
            SPEN_ImpactedPremises.checkBlackoutWindowPeriod('SMS Blackout Window');
            Assert.isNotNull(u);
        }
        
    }
    
}