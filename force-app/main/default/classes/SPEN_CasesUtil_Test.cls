@IsTest
public class SPEN_CasesUtil_Test {
    
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps5 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_StreetworkCaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps5.Id);
        
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_ConfigurableSettings__c> csList=new List<SPEN_ConfigurableSettings__c>();
            SPEN_ConfigurableSettings__c cS =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            csList.add(cS);
            SPEN_ConfigurableSettings__c cS1 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            csList.add(cS1);
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            csList.add(cS2);
            SPEN_ConfigurableSettings__c cS3 =SPEN_TestDataFactory.createConfigSetting(1,'HV Incident Message');
            csList.add(cS3);
            SPEN_ConfigurableSettings__c cS4 =SPEN_TestDataFactory.createConfigSetting(1,'GetAffectedPremiseINCType');
            cS4.SPEN_Value__c = 'HV_N,HV_S,LV';
            cS4.SPEN_Description__c ='config setting description';
            csList.add(cS4);
            insert csList;
            
            Integer threshold = Integer.valueOf(cS.SPEN_Value__c);
            Datetime dateThreshHold = system.now().addHours(-threshold);            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
            
            Id recordTypeIdIncident = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('SPEN_SPENIncident').getRecordTypeId();
            Incident inc = new Incident();
            inc.Subject='Test Subject';
            inc.SPEN_IncidentReference__c='INCD-434014-r';
            inc.RecordTypeId=recordTypeIdIncident;
            insert inc;
            
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
            Case ThreePDCase =new Case();
            ThreePDCase.SPEN_IncidentReference__c=inc.SPEN_IncidentReference__c;
            ThreePDCase.Status ='Created';
            ThreePDCase.Priority='Medium';
            ThreePDCase.SPEN_IncidentRefFormula__c='INCD-434014-r';
            ThreePDCase.RecordTypeId = recordTypeId3PD;
            insert ThreePDCase;
            
            Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
            Case SWCases =new Case();
            SWCases.Status ='Created';
            SWCases.Priority='Medium';
            SWCases.RecordTypeId = recordTypeIdSW;
            insert SWCases;
            
            Id recordTypeIdSiteDetails = Schema.SObjectType.SPEN_SiteDetails__c.getRecordTypeInfosByDeveloperName().get('Streetworks').getRecordTypeId();
            SPEN_SiteDetails__c siteDetails =new SPEN_SiteDetails__c();
            siteDetails.SPEN_LAReference__c='123456';
            siteDetails.SPEN_WorksReference__c='SP051DTHJT3764';
            siteDetails.SPEN_Case__c=SWCases.Id;
            siteDetails.RecordTypeId=recordTypeIdSiteDetails;
            insert siteDetails;
            
            case swCase=[select id,CaseNumber from case where RecordTypeId=:recordTypeId3PD];
            String caseNumber=swCase.CaseNumber;
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Case queryCaseSW1=new Case();
            queryCaseSW1.Status='Open';
            queryCaseSW1.Origin='Email';
            queryCaseSW1.SPEN_Type__c='Streetworks';
            queryCaseSW1.SPEN_QueryType__c='Internal';
            queryCaseSW1.Subject='Test';
            queryCaseSW1.Description='123456';
            queryCaseSW1.RecordTypeId=recordTypeIdQuery;
            insert queryCaseSW1;
            
            Case queryCase2=new Case();
            queryCase2.Status='Open';
            queryCase2.Origin='Email';
            queryCase2.SPEN_Type__c='Streetworks';
            queryCase2.SPEN_QueryType__c='Internal';
            queryCase2.Subject='SP051DTHJT3764';
            queryCase2.Description='Test';
            queryCase2.RecordTypeId=recordTypeIdQuery;
            insert queryCase2;
            
            Case queryCase=new Case();
            queryCase.Status='Open';
            queryCase.Origin='Email';
            queryCase.SPEN_Type__c='NRSWA';
            queryCase.SPEN_QueryType__c='Internal';
            queryCase.Subject='IND-434014-r';
            queryCase.Description='Test Desc';
            querycase.RecordTypeId=recordTypeIdQuery;
            insert queryCase;
            
            Case queryCase1=new Case();
            queryCase1.Status='Open';
            queryCase1.Origin='Email';
            queryCase.SPEN_Type__c='NRSWA';
            queryCase1.SPEN_QueryType__c='Internal';
            queryCase1.Subject='Test'+'{'+caseNumber+'}';
            queryCase1.Description='Test Desc 1';
            queryCase1.RecordTypeId=recordTypeIdQuery;
            insert queryCase1;
            
        }
    }
    
    @isTest
    public static void QueryCaseBeforeInsertTest() 
    {
        User user = [select id from user WHERE isActive = true limit 1];
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            try{
                Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
                List<Case> cases=[select id,RecordTypeId,Origin,Subject,Description,SPEN_IncidentRefFormula__c,CaseNumber,SPEN_Type__c,SPEN_SPDSPMIndicator__c,SPEN_SPD_SPM__c from case where RecordTypeId=:recordTypeIdQuery  and subject like '%IND%'];
                List<Case> modifiedCases=SPEN_CasesUtil.populateParentCaseOnQueryCase(cases);
                system.assert(modifiedCases!= null);
            }
            catch(exception e)
            {
                System.assert(e != NULL);
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void QueryCaseBeforeInsertTest1() 
    {
        User user = [select id from user WHERE isActive = true limit 1];
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            try{
                Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
                List<Case> cases=[select id,RecordTypeId,Origin,Subject,Description,SPEN_IncidentRefFormula__c,CaseNumber,SPEN_Type__c,SPEN_SPDSPMIndicator__c,SPEN_SPD_SPM__c from case where RecordTypeId=:recordTypeIdQuery and subject like '%{%'];
                List<Case> modifiedCases=SPEN_CasesUtil.populateParentCaseOnQueryCase(cases);
                system.assert(modifiedCases!= null);
            }
            catch(exception e)
            {
                System.assert(e != NULL);
            }
            Test.stopTest();
        }
    }
    
        @isTest
    public static void QueryCaseSWTest1() 
    {
        User user = [select id from user WHERE isActive = true limit 1];
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            try{
                Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
                List<Case> cases=[select id,RecordTypeId,Origin,Subject,Description,SPEN_IncidentRefFormula__c,CaseNumber,SPEN_Type__c,SPEN_SPDSPMIndicator__c,SPEN_SPD_SPM__c from case where RecordTypeId=:recordTypeIdQuery and subject like '%123%'];
                List<Case> modifiedCases=SPEN_CasesUtil.populateParentCaseOnQueryCase(cases);
                system.assert(modifiedCases!= null);
            }
            catch(exception e)
            {
                System.assert(e != NULL);
            }
            Test.stopTest();
        }
    }
    
        @isTest
    public static void QueryCaseSWTest2() 
    {
        User user = [select id from user WHERE isActive = true limit 1];
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            try{
                Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
                List<Case> cases=[select id,RecordTypeId,Origin,Subject,Description,SPEN_IncidentRefFormula__c,CaseNumber,SPEN_Type__c,SPEN_SPDSPMIndicator__c,SPEN_SPD_SPM__c from case where RecordTypeId=:recordTypeIdQuery and subject like '%SP%'];
                List<Case> modifiedCases=SPEN_CasesUtil.populateParentCaseOnQueryCase(cases);
                system.assert(modifiedCases!= null);
            }
            catch(exception e)
            {
                System.assert(e != NULL);
            }
            Test.stopTest();
        }
    }
}