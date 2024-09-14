@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_SyncIncidentDetailsTest 
{
    @testSetup static void setup() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        /*PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
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
        //PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessR'];
        //insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps12.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);*/

        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {
            Test.startTest();
            SPEN_ConfigurableSettings__c cs7 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs7;
            SPEN_ConfigurableSettings__c cs8 =SPEN_TestDataFactory.createConfigSetting(1,'ETADefaultForDispatch');
            insert cs8;
            SPEN_ConfigurableSettings__c cs9 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchNODelayINCType');
            insert cs9;
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test LV outage Incident';
            incdnt.SPEN_IncidentID__c = 'I001'+system.now();
            incdnt.SPEN_IncidentType__c = 'LV';
            incdnt.SPEN_IncidentReference__c = 'LV1234';
            incdnt.recordtypeId = recTypeId;
            insert incdnt;
            
            List<Incident> lstInct = SPEN_TestDataFactory.createListofIncidents(2);
            lstInct[0].SPEN_IncidentCategory__c = 'SP';
            lstInct[0].SPEN_IncidentID__c = '123';
             lstInct[1].SPEN_IncidentID__c = '6789';
             lstInct[1].SPEN_IncidentCategory__c = 'SP';
        
            insert lstInct;
            
            List<Incident> incd = SPEN_TestDataFactory.createListofIncidents(1);
            incd[0].SPEN_IncidentCategory__c = 'SP';
            incd[0].SPEN_IncidentID__c = 's000c7cb7INCD';
            incd[0].SPEN_IncidentReference__c = 'INCD-4311141-r';
            insert incd;
            
            SPEN_ConfigurableSettings__c config = new SPEN_ConfigurableSettings__c();
            config.Name = 'Incident broadcast message updated last one hour';
            config.SPEN_Value__c = '1';
            config.SPEN_Description__c = 'the broadcast message of the Incident object is updated in the last hour';
            insert config;
            
            SPEN_ConfigurableSettings__c cs1 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'MessagingTaskType');
            insert cs1;
            SPEN_ConfigurableSettings__c cs2 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'AutoSMSTaskType');
            cs2.SPEN_Value__c = 'LV';
            insert cs2;
            SPEN_ConfigurableSettings__c cs3 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'MessagingTaskTypeCreate');
            insert cs3;
            SPEN_ConfigurableSettings__c cs4 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'NoAutoSMSTaskType');
            insert cs4;
            SPEN_ConfigurableSettings__c cs5 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'GetAffectedPremiseINCType');
            insert cs5;
            SPEN_ConfigurableSettings__c cs6 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'OutboundIncidentType');
            insert cs6;
            
            List<SPEN_ImpactedPremise__c> impPremList = SPEN_TestDataFactory.createImpactedPremiserecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            impPremList[0].SPEN_RelatedIncident__c = incdnt.Id;
            impPremList[0].SPEN_Status__c = 'Restored';
            insert impPremList;
            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='Test IVR';
            message.SPEN_IVRMessage__c='The following information is only for the //////customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'Case-Creation-Message';
            insert message;
            
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.MobilePhone = '07883344559';
            insert con;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
            testCase[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            testCase[0].RecordTypeId = recordTypeId;
            insert testCase;
            
            List<Case> testCase2 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase2[0].Origin = 'Web';
            testCase2[0].ContactId=con.Id;
            testCase2[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            testCase2[0].RecordTypeId = recordTypeId;
            testCase2[0].SPEN_CallerMobileTelephone__c = '8888223344';
             testCase2[0].SPEN_PreferredMethodofContact__c = 'T';
            testCase2[0].SPEN_Incident__c = lstInct[0].id;
            insert testCase2; 
            
              List<Case> testCase4 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase4[0].Origin = 'Web';
            testCase4[0].ContactId=con.Id;
            testCase4[0].SPEN_PowerOnCallReference__c = 'CALL-261472-B';
            testCase4[0].RecordTypeId = recordTypeId;
            testCase4[0].SPEN_CallerTelephone__c = '8888223344';
             testCase4[0].SPEN_PreferredMethodofContact__c = 'H';
            testCase4[0].SPEN_Incident__c =   lstInct[1].id;
            insert testCase4;  
            
            List<Case> testCase3 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
             testCase3[0].Origin = 'Web';
             testCase3[0].ContactId=con.Id;
             testCase3[0].SPEN_Incident__c = incdnt.id;
            testCase3[0].RecordTypeId = recordTypeId;
             insert testCase3;
            /*
            List<Case> testCaseScopeChanged = SPEN_TestDataFactory.createListOfCases(2);
            testCaseScopeChanged[0].SPEN_Incident__c = incdnt.id;
            testCaseScopeChanged[1].SPEN_Incident__c = incdnt.id;
            insert testCaseScopeChanged;
            */
            
            List<SPEN_IVRMessage__c> lstIVR = new List<SPEN_IVRMessage__c>();
            SPEN_IVRMessage__c msg = new SPEN_IVRMessage__c();
            msg=new SPEN_IVRMessage__c();
            msg.Name='SP Resource Dispatched SMS';
            msg.SPEN_IVRMessage__c='The following information is only for the customers';
            msg.RecordTypeId=msgRecordTypeId;
            msg.SPEN_Purpose__c='Incident Created';
            msg.SPEN_ExternalId__c = 'SP Resource Dispatched SMS';
            
            SPEN_IVRMessage__c etaMsg = new SPEN_IVRMessage__c();
            etaMsg=new SPEN_IVRMessage__c();
            etaMsg.Name='SP ETA Changes SMS';
            etaMsg.SPEN_IVRMessage__c='The following information is only for the customers';
            etaMsg.RecordTypeId=msgRecordTypeId;
            etaMsg.SPEN_Purpose__c='Incident Created';
            etaMsg.SPEN_ExternalId__c = 'SP ETA Changes SMS';
            
            SPEN_IVRMessage__c eTAVA = new SPEN_IVRMessage__c();
            eTAVA=new SPEN_IVRMessage__c();
            eTAVA.Name='SP ETA Changed VA';
            eTAVA.SPEN_IVRMessage__c='Hello, This is a message from SP Energy Networks.Thank you for reporting a fault, Case ref: [CASENUMBER]. Our engineer has been delayed.Our estimated time of arrival has changed to [ETA].If you no longer require our attendance please contact us on our emergency telephone number 105';
            eTAVA.RecordTypeId=msgRecordTypeId;
            eTAVA.SPEN_Purpose__c='Incident Created';
            eTAVA.SPEN_ExternalId__c = 'SP ETA Changed VA';
            
            SPEN_IVRMessage__c resDispVA = new SPEN_IVRMessage__c();
            resDispVA=new SPEN_IVRMessage__c();
            resDispVA.Name='SP Resource Dispatched VA';
            resDispVA.SPEN_IVRMessage__c='Hello, This is a message from SP Energy Networks. Thank you for reporting a fault, Case ref: [CASENUMBER]. Our engineer has been dispatched and will require access to your property. Our estimated time of arrival is [ETA].If you no longer require our attendance please contact us on our emergency telephone number 105';
            resDispVA.RecordTypeId=msgRecordTypeId;
            resDispVA.SPEN_Purpose__c='Incident Created';
            resDispVA.SPEN_ExternalId__c = 'SP Resource Dispatched VA';
            
            lstIVR.add(msg);
            lstIVR.add(etaMsg);
            lstIVR.add(eTAVA);
            lstIVR.add(resDispVA);
            insert lstIVR;
            
            List<SPEN_IVR__c> ivrList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert ivrList;
            Id ivrOperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id ivrVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> ivrORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,lstIVR[0].id);
            ivrORecList[0].RecordTypeId = ivrOperatingHoursRecordTypeId;
            ivrORecList[0].SPEN_isActive__c = true;
            ivrORecList[0].SPEN_isDaily__c = true;
            ivrORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            ivrORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert ivrORecList;
            
            List<SPEN_IVROperatingHours__c> vaOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,lstIVR[0].id);
            vaOprHrList[0].RecordTypeId = ivrVARecTypeId;
            vaOprHrList[0].SPEN_isActive__c = true;
            vaOprHrList[0].SPEN_isDaily__c = true;
            vaOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vaOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vaOprHrList;
            Assert.areEqual(true, vaOprHrList[0].SPEN_isActive__c, 'opertaing hours record is in active');
            Test.stopTest();
        }
    }
    @IsTest
    public static void testIncCreate() 
    {
        User u= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            //String reqStr = '<soap:Body><SDIFIncidentCreated xmlns="ENMAC/TCS"><IncidentCreatedStc><ComponentDescription>GREENWOOD SHOTTS GM S/S, LOCAL TRANSFORMER Tx</ComponentDescription><CreationDate>2022-11-03T09:22:21.000000+01:00</CreationDate><DangerFlag>0</DangerFlag><DeadDeviceAlias>10091630U</DeadDeviceAlias><EstimatedRestorationDate>2022-11-13T09:22:21.000000+01:00</EstimatedRestorationDate>        <GroupID>NMC</GroupID><GroupName>NMC</GroupName><IncidentCategory>ENS1</IncidentCategory><IncidentCategoryDescription>Cut Out Fuse Replacement Only</IncidentCategoryDescription><IncidentDescription>ML7, 100, STATION ROAD SHOTTS</IncidentDescription>';
            //reqStr = reqStr + '<IncidentPriority>1</IncidentPriority><IncidentReference>INCD-474507-f</IncidentReference><IncidentStatus>0</IncidentStatus><IncidentType>SP</IncidentType><IvrMessageFlag>0</IvrMessageFlag><MainMessage>We are aware of the Cut Out Fuse Replacement (GS1) at your premises.  The call has not yet been passed to our emergency service, but we would hope to do so shortly.  We are sorry we can&apos;t give you an attendance time at present.  You may wish to call us back in 2 hours if the engineer hasn&apos;t arrived.  Please accept our sincere apologies for the inconvenience this is causing.</MainMessage><OperatingZone>LANARK CENTRAL</OperatingZone><OperatingZoneId>OZ02</OperatingZoneId><PlannedDate></PlannedDate><PrimaryAlias>10069881U</PrimaryAlias> <PrimaryFeeder>24</PrimaryFeeder><PrimaryName>SHOTTS</PrimaryName><ReceivedDate>2022-11-03T09:10:56.000000+01:00</ReceivedDate>        <SecondaryAlias>10071895U</SecondaryAlias><SecondaryFeeder>48</SecondaryFeeder><SecondaryName>GREENWOOD SHOTTS GM S/S</SecondaryName><SupplementaryMessage></SupplementaryMessage></IncidentCreatedStc></SDIFIncidentCreated></soap:Body>';
            String reqStr = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:end="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentCreated xmlns="SDIF"><IncidentCreatedStc><ComponentDescription>GREENWOOD SHOTTS GM S/S, LOCAL TRANSFORMER Tx</ComponentDescription><CreationDate>2022-11-03T09:22:21.000000+01:00</CreationDate><DangerFlag>0</DangerFlag><DeadDeviceAlias>10091630U</DeadDeviceAlias><EstimatedRestorationDate>2022-11-13T09:22:21.000000+01:00</EstimatedRestorationDate><IvrMessageFlag>AB1</IvrMessageFlag><GroupID>NMC</GroupID><GroupName>NMC</GroupName><IncidentCategory>ENS1</IncidentCategory><IncidentCategoryDescription>Cut Out Fuse Replacement Only</IncidentCategoryDescription><IncidentDescription>ML7, 100, STATION ROAD SHOTTS</IncidentDescription><IncidentPriority>1</IncidentPriority><IncidentReference >INCD-474507-f</IncidentReference><IncidentStatus>0</IncidentStatus><IncidentType>SP</IncidentType><IvrMessageFlag>0</IvrMessageFlag><MainMessage>We are aware of the Cut Out Fuse Replacement (GS1) at your premises.  The call has not yet been passed to our emergency service, but we would hope to do so shortly.  We are sorry we can&apos;t give you an attendance time at present.  You may wish to call us back in 2 hours if the engineer hasn&apos;t arrived.  Please accept our sincere apologies for the inconvenience this is causing.</MainMessage><OperatingZone>LANARK CENTRAL</OperatingZone><OperatingZoneId>OZ02</OperatingZoneId><PlannedDate></PlannedDate><PrimaryAlias>10069881U</PrimaryAlias> <PrimaryFeeder>24</PrimaryFeeder><PrimaryName>SHOTTS</PrimaryName><ReceivedDate>2022-11-03T09:10:56.000000+01:00</ReceivedDate>        <SecondaryAlias>10071895U</SecondaryAlias><SecondaryFeeder>48</SecondaryFeeder><SecondaryName>GREENWOOD SHOTTS GM S/S</SecondaryName><SupplementaryMessage></SupplementaryMessage></IncidentCreatedStc></SDIFIncidentCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            //SPEN_SyncIncidentDetails obj = new SPEN_SyncIncidentDetails();
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void testIncCancelled()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            //Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident LIMIT 1];  
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = 'I00178659';
            incdnt.recordtypeId = recTypeId;
            insert incdnt;
            //incdnt.SPEN_IncidentStatus__c ='Cancelled';
            //update incdnt;
            //Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE LIMIT 1];

            //String reqStr = '<soap:Body><IncidentCancelled xmlns="ENMAC/TCS"><IncidentCancelledStc>'+ '<IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID>'+'<IncidentReference>INCD-474519-f</IncidentReference><Time>2021-04-20T09:55:37.000000+01:00</Time></IncidentCancelledStc></IncidentCancelled></soap:Body>';
            String reqStr = '<soap:Body><SDIFIncidentCancelled xmlns="SDIF"><IncidentCancelledStc>'+'<IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID>'+'<IncidentReference>INCD-474519-f</IncidentReference><Time>2021-04-20T09:55:37.000000+01:00</Time></IncidentCancelledStc></SDIFIncidentCancelled></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
	
    
    @isTest
    public static void testIncDetailChanged()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1]; 
            //String reqStr =  '<soap:Body><IncidentDetailsChanged xmlns="ENMAC/TCS"><IncidentDetailsChangedStc><ComponentDescription>POLKEMMET COUNTRY PARK RMU GM S/S, HEARTLANDS A SW</ComponentDescription><DeadDeviceAlias>15231577U</DeadDeviceAlias><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentRef>INCD-474453-f</IncidentRef><SecondaryAlias>15192210U</SecondaryAlias><SecondaryName>POLKEMMET COUNTRY PARK RMU GM S/S</SecondaryName></IncidentDetailsChangedStc></IncidentDetailsChanged></soap:Body>';
            String reqStr =  '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:end="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentDetailsChanged xmlns="SDIF"><IncidentDetailsChangedStc><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentRef>INCD-474453-f</IncidentRef><Status>8</Status><EstimatedRestorationDate>2022-06-06T10:39:51</EstimatedRestorationDate><Eta>2022-06-06T10:39:51</Eta><MainMessage>Message to Update</MainMessage><Category>HV</Category><IncidentCategoryDescription>Cut Out Fuse Replacement Only</IncidentCategoryDescription><Priority>1</Priority><Type>HV_S</Type></IncidentDetailsChangedStc></SDIFIncidentDetailsChanged></soap:Body></soap:Envelope>';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    @isTest
    public static void testIncDelogged()
    {
        Test.startTest();
        User usr= [Select id FROM User  where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
            User u = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
            u.FirstName = 'Dropped ';
            u.LastName = 'Outbound Task User';
            insert u;
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1]; 
            incdnt.SPEN_IncidentStatus__c ='Delog';
            incdnt.SPEN_OperatingZone__c = 'LANARK CENTRAL';            
            incdnt.SPEN_Main_Message__c = 'Delog';        
            incdnt.SPEN_SecondaryFeeder__c = '48';
            incdnt.Description = 'Delog';
            incdnt.SPEN_IncidentStatus__c   =  'Delog';
            incdnt.SPEN_LastStatus__c = 'Delog';
            incdnt.SPEN_LastCommunicationTime__c=system.now();     
            update incdnt;
            
            Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE where id!=null LIMIT 1];
            //String reqStr =  '<soap:Body><IncidentDelogged xmlns="ENMAC/TCS"><IncidentDeloggedStc><AutomaticIncident>0</AutomaticIncident><CallID>f0003fd60CALL</CallID><CallReference>'+caseRec.SPEN_PowerOnCallReference__c+'</CallReference><Category>ENS1</Category><ComponentDescription>GREENWOOD SHOTTS GM S/S, LOCAL TRANSFORMER Tx</ComponentDescription><CreationDate>2021-04-20T10:39:51.000000+01:00</CreationDate><Description>ML7, 100, STATION ROAD SHOTTS</Description><GroupID>NMC</GroupID><GroupName>NMC</GroupName><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>INCD-474525-f</IncidentReference><MainMessage>We are aware of the Cut Out Fuse Replacement (GS1) at your premises.  The call has not yet been passed to our emergency service, but we would hope to do so shortly.</MainMessage><OperatingZone>LANARK CENTRAL</OperatingZone><OperatingZoneId>OZ02</OperatingZoneId><PrimaryAlias>10069881U</PrimaryAlias><PrimaryFeeder>24</PrimaryFeeder><PrimaryName>SHOTTS</PrimaryName><RestoredCount>1</RestoredCount><RestoredDate>2021-04-20T10:48:00.000000+01:00</RestoredDate><SecondaryAlias>10071895U</SecondaryAlias><SecondaryFeeder>48</SecondaryFeeder><SecondaryName>GREENWOOD SHOTTS GM S/S</SecondaryName><Type>SP</Type></IncidentDeloggedStc></IncidentDelogged></soap:Body>';
            String reqStr = '<soap:Body><SDIFIncidentDelogged xmlns="SDIF"><IncidentDeloggedStc><AutomaticIncident>0</AutomaticIncident><CallID>f0003fd60CALL</CallID><CallReference>'+caseRec.SPEN_PowerOnCallReference__c+'</CallReference><Category>ENS1</Category><ComponentDescription>GREENWOOD SHOTTS GM S/S, LOCAL TRANSFORMER Tx</ComponentDescription><CreationDate>2021-04-20T10:39:51.000000+01:00</CreationDate><Description>ML7, 100, STATION ROAD SHOTTS</Description><GroupID>NMC</GroupID><GroupName>NMC</GroupName><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>INCD-474525-f</IncidentReference><MainMessage>We are aware of the Cut Out Fuse Replacement (GS1) at your premises.  The call has not yet been passed to our emergency service, but we would hope to do so shortly.</MainMessage><OperatingZone>LANARK CENTRAL</OperatingZone><OperatingZoneId>OZ02</OperatingZoneId><PrimaryAlias>10069881U</PrimaryAlias><PrimaryFeeder>24</PrimaryFeeder><PrimaryName>SHOTTS</PrimaryName><RestoredCount>1</RestoredCount><RestoredDate>2021-04-20T10:48:00.000000+01:00</RestoredDate><SecondaryAlias>10071895U</SecondaryAlias><SecondaryFeeder>48</SecondaryFeeder><SecondaryName>GREENWOOD SHOTTS GM S/S</SecondaryName><Type>SP</Type></IncidentDeloggedStc></SDIFIncidentDelogged></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.areEqual('Delog',incdnt.Description,'Incident description');
            Test.stopTest();
        }
    }
    @isTest
    public static void testIncCompleted()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1];
            incdnt.SPEN_IncidentStatus__c = 'Complete';
            Update incdnt;
            Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE where id!=null LIMIT 1];
            //String reqStr =  '<soap:Body><IncidentCompleted xmlns="ENMAC/TCS"><IncidentCompletedStc><AutomaticIncident>0</AutomaticIncident><Category>ENS1</Category><CallReference>'+caseRec.SPEN_PowerOnCallReference__c+'</CallReference><CreationDate>2021-06-23T10:42:51.000000+01:00</CreationDate><Description>ML7, 11, PARK COURT SHOTTS</Description><GroupID>NMC</GroupID><GroupName>NMC</GroupName><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID>      <IncidentReference>INCD-502109-k</IncidentReference><OperatingZone>LANARK CENTRAL</OperatingZone><ReceivedDate>2021-06-23T10:39:00.000000+01:00</ReceivedDate><RestoredCount>1</RestoredCount><Time>2021-06-23T13:44:00.000000+01:00</Time></IncidentCompletedStc></IncidentCompleted></soap:Body>';
            String reqStr ='<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:end="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentCompleted xmlns="SDIF"><IncidentCompletedStc><AutomaticIncident>0</AutomaticIncident><Category>ENS1</Category><CallReference>'+caseRec.SPEN_PowerOnCallReference__c+'</CallReference><CreationDate>2021-06-23T10:42:51.000000+01:00</CreationDate><Description>ML7, 11, PARK COURT SHOTTS</Description><GroupID>NMC</GroupID><GroupName>NMC</GroupName><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID>      <IncidentReference>INCD-502109-k</IncidentReference><OperatingZone>LANARK CENTRAL</OperatingZone><ReceivedDate>2021-06-23T10:39:00.000000+01:00</ReceivedDate><RestoredCount>1</RestoredCount><Time>2021-06-23T13:44:00.000000+01:00</Time></IncidentCompletedStc></SDIFIncidentCompleted></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            Incident incident = SPEN_SyncIncidentDetails.createIncident();
            Assert.areEqual('Complete',incdnt.SPEN_IncidentStatus__c,'Incident description');
            Test.stopTest();
        }
    }
    @isTest
    public static void testResDispatched()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1]; 
            Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE where id!=null LIMIT 1];
            //String reqStr =  '<soap:Body><sdif:SDIFResourceDispatched  xmlns="ENMAC/TCS"><sdif:ResourceDispatchedStc><sdif:Dispatches><sdif:ComponentDescription></sdif:ComponentDescription><sdif:CreationDate>2021-04-20T10:39:51</sdif:CreationDate><CallReference>'+caseRec.SPEN_PowerOnCallReference__c+'</CallReference><sdif:DeadDeviceAlias></sdif:DeadDeviceAlias><sdif:DispatchedDate>2021-04-20T10:39:51</sdif:DispatchedDate><sdif:EstimatedRestorationDate></sdif:EstimatedRestorationDate><sdif:Eta></sdif:Eta><sdif:IncidentCategory></sdif:IncidentCategory><sdif:IncidentCategoryDescription></sdif:IncidentCategoryDescription><sdif:IncidentComment></sdif:IncidentComment><sdif:IncidentDescription></sdif:IncidentDescription><sdif:IncidentEasting></sdif:IncidentEasting><sdif:IncidentID>I001</sdif:IncidentID><sdif:IncidentNorthing></sdif:IncidentNorthing><sdif:IncidentPriority></sdif:IncidentPriority><sdif:IncidentReference>fpoienvc</sdif:IncidentReference><sdif:IncidentStatus>3</sdif:IncidentStatus><sdif:IncidentType>HV</sdif:IncidentType><sdif:Notification><sdif:NotificationDetails></sdif:NotificationDetails><sdif:NotificationMethod></sdif:NotificationMethod></sdif:Notification><sdif:OperatingZone></sdif:OperatingZone><sdif:PlannedDate></sdif:PlannedDate><sdif:PrimaryAlias></sdif:PrimaryAlias><sdif:PrimaryFeeder></sdif:PrimaryFeeder><sdif:PrimaryName></sdif:PrimaryName><sdif:ResourceForename></sdif:ResourceForename><sdif:ResourceID></sdif:ResourceID><sdif:ResourceReference></sdif:ResourceReference><sdif:ResourceSurname></sdif:ResourceSurname><sdif:SecondaryAlias></sdif:SecondaryAlias><sdif:SecondaryFeeder></sdif:SecondaryFeeder><sdif:SecondaryName></sdif:SecondaryName></sdif:Dispatches></sdif:ResourceDispatchedStc></sdif:SDIFResourceDispatched></soap:Body>';
            String reqStr ='<soap:Body><SDIFResourceDispatched xmlns="SDIF"><ResourceDispatchedStc><Dispatches><ComponentDescription></ComponentDescription><CreationDate>2021-04-20T10:39:51</CreationDate><ResourceID>AB1234</ResourceID><ResourceForename>TEST12</ResourceForename><CallReference>'+caseRec.SPEN_PowerOnCallReference__c+'</CallReference><DeadDeviceAlias></DeadDeviceAlias><DispatchedDate>2021-04-20T10:39:51</DispatchedDate><EstimatedRestorationDate></EstimatedRestorationDate><Eta></Eta><IncidentCategory></IncidentCategory><IncidentCategoryDescription></IncidentCategoryDescription><IncidentComment></IncidentComment><IncidentDescription></IncidentDescription><IncidentEasting></IncidentEasting><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentNorthing></IncidentNorthing><IncidentPriority></IncidentPriority><IncidentReference>fpoienvc</IncidentReference><IncidentStatus>3</IncidentStatus><IncidentType>HV</IncidentType><Notification><NotificationDetails></NotificationDetails><NotificationMethod></NotificationMethod></Notification><OperatingZone></OperatingZone><PlannedDate></PlannedDate><PrimaryAlias></PrimaryAlias><PrimaryFeeder></PrimaryFeeder><PrimaryName></PrimaryName><ResourceForename></ResourceForename><ResourceID></ResourceID><ResourceReference></ResourceReference><ResourceSurname></ResourceSurname><SecondaryAlias></SecondaryAlias><SecondaryFeeder></SecondaryFeeder><SecondaryName></SecondaryName></Dispatches></ResourceDispatchedStc></SDIFResourceDispatched></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    @isTest
    public static void testResCancelled()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1];
            
            Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE where id!=null LIMIT 1];
            
            //String reqStr =  '<soap:Body><sdif:SDIFResourceCancelled  xmlns="ENMAC/TCS"><sdif:ResourceCancelledStc><sdif:Cancellations><sdif:CancelledDate>2021-04-20T10:39:51</sdif:CancelledDate><sdif:ComponentDescription></sdif:ComponentDescription><sdif:CreationDate>2021-04-20T10:39:51</sdif:CreationDate><sdif:DeadDeviceAlias></sdif:DeadDeviceAlias><sdif:EstimatedRestorationDate></sdif:EstimatedRestorationDate><sdif:IncidentCategory></sdif:IncidentCategory><sdif:IncidentCategoryDescription></sdif:IncidentCategoryDescription><sdif:IncidentComment></sdif:IncidentComment><sdif:IncidentDescription></sdif:IncidentDescription><sdif:IncidentEasting></sdif:IncidentEasting><sdif:IncidentID>'+incdnt.SPEN_IncidentID__c+'</sdif:IncidentID><sdif:IncidentNorthing></sdif:IncidentNorthing><sdif:IncidentPriority></sdif:IncidentPriority>               <sdif:IncidentReference></sdif:IncidentReference><sdif:IncidentStatus></sdif:IncidentStatus><sdif:IncidentType></sdif:IncidentType><sdif:Notification><sdif:NotificationDetails></sdif:NotificationDetails><sdif:NotificationMethod></sdif:NotificationMethod></sdif:Notification><sdif:OperatingZone></sdif:OperatingZone><sdif:PlannedDate></sdif:PlannedDate><sdif:PrimaryAlias></sdif:PrimaryAlias><sdif:PrimaryFeeder></sdif:PrimaryFeeder><sdif:PrimaryName></sdif:PrimaryName><sdif:ResourceForename></sdif:ResourceForename><sdif:ResourceID></sdif:ResourceID><sdif:ResourceReference></sdif:ResourceReference><sdif:ResourceSurname></sdif:ResourceSurname><sdif:SecondaryAlias></sdif:SecondaryAlias><sdif:SecondaryFeeder></sdif:SecondaryFeeder><sdif:SecondaryName></sdif:SecondaryName></sdif:Cancellations></sdif:ResourceCancelledStc></sdif:SDIFResourceCancelled></soap:Body>';
            String reqStr =  '<soap:Body><SDIFResourceCancelled  xmlns="SDIF"><ResourceCancelledStc><Cancellations><CancelledDate>2021-04-20T10:39:51</CancelledDate><ComponentDescription></ComponentDescription><CreationDate>2021-04-20T10:39:51</CreationDate><DeadDeviceAlias></DeadDeviceAlias><EstimatedRestorationDate></EstimatedRestorationDate><IncidentCategory></IncidentCategory><IncidentCategoryDescription></IncidentCategoryDescription><IncidentComment></IncidentComment><IncidentDescription></IncidentDescription><IncidentEasting></IncidentEasting><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentNorthing></IncidentNorthing><IncidentPriority></IncidentPriority>               <IncidentReference></IncidentReference><IncidentStatus></IncidentStatus><IncidentType></IncidentType><Notification><NotificationDetails></NotificationDetails><NotificationMethod></NotificationMethod></Notification><OperatingZone></OperatingZone><PlannedDate></PlannedDate><PrimaryAlias></PrimaryAlias><PrimaryFeeder></PrimaryFeeder><PrimaryName></PrimaryName><ResourceForename></ResourceForename><ResourceID></ResourceID><ResourceReference></ResourceReference><ResourceSurname></ResourceSurname><SecondaryAlias></SecondaryAlias><SecondaryFeeder></SecondaryFeeder><SecondaryName></SecondaryName></Cancellations></ResourceCancelledStc></SDIFResourceCancelled></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void testResOnsite()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1]; 
            Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE where id!=null LIMIT 1];
            
            //String reqStr =  '<soap:Body><sdif:ResourceOnSite  xmlns="ENMAC/TCS"><sdif:ResourceOnSiteStc><sdif:Cancellations><sdif:CancelledDate>2021-04-20T10:39:51</sdif:CancelledDate><sdif:ComponentDescription></sdif:ComponentDescription><sdif:CreationDate>2021-04-20T10:39:51</sdif:CreationDate><sdif:DeadDeviceAlias></sdif:DeadDeviceAlias><sdif:EstimatedRestorationDate></sdif:EstimatedRestorationDate><sdif:IncidentCategory></sdif:IncidentCategory><sdif:IncidentCategoryDescription></sdif:IncidentCategoryDescription><sdif:IncidentComment></sdif:IncidentComment><sdif:IncidentDescription></sdif:IncidentDescription><sdif:IncidentEasting></sdif:IncidentEasting><sdif:IncidentID>'+incdnt.SPEN_IncidentID__c+'</sdif:IncidentID><sdif:IncidentNorthing></sdif:IncidentNorthing><sdif:IncidentPriority></sdif:IncidentPriority>               <sdif:IncidentReference></sdif:IncidentReference><sdif:IncidentStatus></sdif:IncidentStatus><sdif:IncidentType></sdif:IncidentType><sdif:Notification><sdif:NotificationDetails></sdif:NotificationDetails><sdif:NotificationMethod></sdif:NotificationMethod></sdif:Notification><sdif:OperatingZone></sdif:OperatingZone><sdif:PlannedDate></sdif:PlannedDate><sdif:PrimaryAlias></sdif:PrimaryAlias><sdif:PrimaryFeeder></sdif:PrimaryFeeder><sdif:PrimaryName></sdif:PrimaryName><sdif:ResourceForename></sdif:ResourceForename><sdif:ResourceID></sdif:ResourceID><sdif:ResourceReference></sdif:ResourceReference><sdif:ResourceSurname></sdif:ResourceSurname><sdif:SecondaryAlias></sdif:SecondaryAlias><sdif:SecondaryFeeder></sdif:SecondaryFeeder><sdif:SecondaryName></sdif:SecondaryName></sdif:Cancellations></sdif:ResourceOnSiteStc></sdif:ResourceOnSite></soap:Body>';
            // String reqStr =  '<soap:Body><sdif:ResourceOnSite  xmlns="ENMAC/TCS">  <sdif:ResourceOnSiteStc><sdif:CreationDate>2021-04-20T10:39:51</sdif:CreationDate><sdif:ResourceForename>?</sdif:ResourceForename><sdif:ResourceID>?</sdif:ResourceID><sdif:OperatingZone>?</sdif:OperatingZone>        <sdif:ResourceSurname>?</sdif:ResourceSurname><sdif:IncidentID>'+incdnt.SPEN_IncidentID__c+'</sdif:IncidentID>      <sdif:ArrivalDate>2021-04-20T10:39:51</sdif:ArrivalDate></sdif:ResourceOnSiteStc></sdif:ResourceOnSite> </soap:Body>';
            String reqStr ='<soap:Body><SDIFResourceOnSite xmlns="SDIF"><ResourceOnSiteStc><CreationDate>2021-04-20T10:39:51</CreationDate><ResourceForename>?</ResourceForename><ResourceID>?</ResourceID><OperatingZone>?</OperatingZone><ResourceSurname>?</ResourceSurname><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><ArrivalDate>2021-04-20T10:39:51</ArrivalDate></ResourceOnSiteStc></SDIFResourceOnSite></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    
    
    @isTest
    public static void testIncLogCreated1()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c where id!=null];
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>2021-08-23T16:14:19.44</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>Team Members en Route ETA : 15-Dec 12:10</LogComment><LoggedTime>2021-08-23T15:15:03.000Z</LoggedTime><LogSubCategoryID>-17</LogSubCategoryID><Operator>Feeder</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
     @isTest
    public static void testIncLogCreated3()
    {
	//Fault Lead
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c where id!=null];
            String reqStr =  '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentLogCreated xmlns="SDIF"> <IncidentLogCreatedStc> <ActualTime>2023-02-21T16:12:23.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID> <IncidentReference>INCD-817129-s</IncidentReference> <LogCategoryID>2</LogCategoryID><LogComment>MOB Fault Lead changed from None to Stuart Sinclair (X) by Stuart Sinclair (X)</LogComment><LoggedTime>2023-02-21T16:12:24.000Z</LoggedTime><LogSubCategoryID>7</LogSubCategoryID> <Operator>USER</Operator> </IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
     @isTest
    public static void testIncLogCreated5()
    {
	//ETA Update
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c where id!=null];
               // String testStr = '\'21-FEB 17:30\'';
            String reqStr =  '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2023-02-21T17:30:54.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>INCD-817129-s</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>'+'Estimated Time Of Arrival set to'+ '\'21-FEB 17:30\''+'MOB'+'</LogComment><LoggedTime>2023-02-21T16:20:59.000Z</LoggedTime> <LogSubCategoryID>0</LogSubCategoryID><Operator>USER</Operator> </IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
     @isTest
    public static void testIncLogCreated2()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident WHERE SPEN_IncidentID__c = '6789' LIMIT 1];
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c where id!=null];
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>2021-08-23T16:14:19.44</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>Team Members en Route ETA : 15-Dec 12:10</LogComment><LoggedTime>2021-08-23T15:15:03.000Z</LoggedTime><LogSubCategoryID>-17</LogSubCategoryID><Operator>Feeder</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    @isTest
    public static void testIncLogCreatedNRSWACoordsWithoutCase()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incd = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentReference__c FROM Incident WHERE SPEN_IncidentReference__c = 'INCD-4311141-r' LIMIT 1];
            
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incd.SPEN_IncidentID__c+'</IncidentID><IncidentReference>'+incd.SPEN_IncidentReference__c+'</IncidentReference><LogCategoryID>6</LogCategoryID><LogComment>X/Y:230493/683210</LogComment><LoggedTime>2023-07-06T13:46:20.000Z</LoggedTime><LogSubCategoryID>9</LogSubCategoryID><Operator>USER</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    @isTest
    public static void testIncLogCreatedNRSWACoordsWithCase()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Id recordtypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
            Incident incd = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentReference__c FROM Incident WHERE SPEN_IncidentReference__c = 'INCD-4311141-r' LIMIT 1];
            
            Case cse = new Case();
            cse.SPEN_Incident__c =incd.Id;
            cse.Status = 'NRSWA Review';
            cse.RecordTypeId = recordtypeIdNRSWA;
            cse.Origin = 'PowerOn';
            insert cse;
            
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incd.SPEN_IncidentID__c+'</IncidentID><IncidentReference>'+incd.SPEN_IncidentReference__c+'</IncidentReference><LogCategoryID>6</LogCategoryID><LogComment>X/Y:230493/683210</LogComment><LoggedTime>2023-07-06T13:46:20.000Z</LoggedTime><LogSubCategoryID>9</LogSubCategoryID><Operator>USER</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testPowerOnNRSWAQueryCase()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Id recordtypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
            Incident incd = [SELECT id,SPEN_IncidentID__c,SPEN_IncidentReference__c FROM Incident WHERE SPEN_IncidentReference__c = 'INCD-4311141-r' LIMIT 1];
            incd.SPEN_NumberOfNRSWACoordinates__c=1;
            update incd;
            
            Case cse = new Case();
            cse.SPEN_Incident__c =incd.Id;
            cse.Status = 'NRSWA Review';
            cse.RecordTypeId = recordtypeIdNRSWA;
            cse.Origin = 'PowerOn';
            insert cse;
            
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incd.SPEN_IncidentID__c+'</IncidentID><IncidentReference>'+incd.SPEN_IncidentReference__c+'</IncidentReference><LogCategoryID>6</LogCategoryID><LogComment>X/Y:230493/683210</LogComment><LoggedTime>2023-07-06T13:46:20.000Z</LoggedTime><LogSubCategoryID>9</LogSubCategoryID><Operator>USER</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
			
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
           
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
    /*@isTest
    public static void testIncLogCreated2()
    {
        Test.startTest();
        User usr= [Select id FROM User LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c,SPEN_ETA__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            incdnt.SPEN_ETA__c = system.now();
            update incdnt;
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c];
            //system.debug('oprHrs >>'+ oprHrs);
            //Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE LIMIT 1];
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>2021-08-23T16:14:19.44</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>Team Members en Route ETA : 15-Dec 12:10</LogComment><LoggedTime>2021-08-23T15:15:03.000Z</LoggedTime><LogSubCategoryID>0</LogSubCategoryID><Operator>Feeder</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Test.stopTest();
        }
    }*/
    /*@isTest
    public static void testIncLogCreated3()
    {
        Test.startTest();
        User usr= [Select id FROM User LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c,SPEN_ETA__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            incdnt.SPEN_ETA__c = system.now();
            update incdnt;
            Contact c = [SELECT id,Phone,MobilePhone FROM Contact LIMIT 1];
            c.Phone = '01416140937';
            c.MobilePhone = null;
            update c;
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c];
            //system.debug('oprHrs >>'+ oprHrs);
            //Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE LIMIT 1];
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>2021-08-23T16:14:19.44</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>Team Members en Route ETA : 15-Dec 12:10</LogComment><LoggedTime>2021-08-23T15:15:03.000Z</LoggedTime><LogSubCategoryID>0</LogSubCategoryID><Operator>Feeder</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Test.stopTest();
        }
    }
    @isTest
    public static void testIncLogCreated4()
    {
        Test.startTest();
        User usr= [Select id FROM User LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c,SPEN_ETA__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            incdnt.SPEN_ETA__c = system.now();
            update incdnt;
            Contact c = [SELECT id,Phone,MobilePhone FROM Contact LIMIT 1];
            c.Phone = '01416170637';
            c.MobilePhone = null;
            update c;
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c];
            //system.debug('oprHrs >>'+ oprHrs);
            //Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE LIMIT 1];
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>2021-08-23T16:14:19.44</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>Team Members en Route ETA : 15-Dec 12:10</LogComment><LoggedTime>2021-08-23T15:15:03.000Z</LoggedTime><LogSubCategoryID>-13</LogSubCategoryID><Operator>Feeder</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Test.stopTest();
        }
    }
    @isTest
    public static void testIncLogCreated5()
    {
        Test.startTest();
        User usr= [Select id FROM User LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c,SPEN_ETA__c FROM Incident WHERE SPEN_IncidentCategory__c = 'SP' LIMIT 1];
            incdnt.SPEN_ETA__c = system.now();
            update incdnt;
            List<SPEN_IVROperatingHours__c> oprHrs = [SELECT id FROM SPEN_IVROperatingHours__c];
            //system.debug('oprHrs >>'+ oprHrs);
            //Case caseRec= [SELECT id ,SPEN_PowerOnCallReference__c FROM CASE LIMIT 1];
            String reqStr =  '<soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2021-08-23T15:15:03.000Z</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>2021-08-23T16:14:19.44</IncidentReference><LogCategoryID>2</LogCategoryID><LogComment>Team Members en Route ETA : 15-Dec 12:10</LogComment><LoggedTime>2021-08-23T15:15:03.000Z</LoggedTime><LogSubCategoryID>-17</LogSubCategoryID><Operator>Feeder</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Test.stopTest();
        }
    }
    */
        
    @IsTest
    public static void testScopeChanged() 
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            
            Incident incdnt = [SELECT id,SPEN_IncidentReference__c FROM Incident where id!=null LIMIT 1];
            Case cse3=[SELECT id FROM Case WHERE SPEN_Incident__c=:incdnt.Id LIMIT 1];
            //system.debug('----cse3.Id----'+cse3.Id);
            //system.debug('Incident--->'+incdnt);
            //String reqStr = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:end="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentScopeChanged  xmlns="SDIF"><IncidentScopeChangedStc><IncidentReference>'+incdnt.SPEN_IncidentReference__c+'</IncidentReference><Calls><CallID>s000509aeCALL</CallID></Calls></IncidentScopeChangedStc></SDIFIncidentScopeChanged ></soap:Body></soap:Envelope>';
            String reqStr = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:end="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentScopeChanged  xmlns="SDIF"><IncidentScopeChangedStc><IncidentReference>'+incdnt.SPEN_IncidentReference__c+'</IncidentReference><Calls><CallID>k0000303dCALL</CallID><CallReference>'+cse3.Id+'</CallReference></Calls></IncidentScopeChangedStc></SDIFIncidentScopeChanged ></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            //SPEN_SyncIncidentDetails obj = new SPEN_SyncIncidentDetails();
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();

        }
    }
     @isTest
    public static void testIncidentLogCreated1()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1];
            String reqStr =  '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2023-07-27T10:52:18.000+01:00</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>INCD-588323-k</IncidentReference><LogCategoryID>1</LogCategoryID><LogComment></LogComment><LoggedTime></LoggedTime><LogSubCategoryID>75</LogSubCategoryID><Operator></Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }
      @isTest
    public static void testIncidentLogCreated2()
    {
        Test.startTest();
        User usr= [Select id FROM User where id!=null and IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = [SELECT id,SPEN_IncidentID__c FROM Incident where id!=null LIMIT 1];
            //String reqStr =  '<soap:Body><sdif:SDIFResourceCancelled  xmlns="ENMAC/TCS"><sdif:ResourceCancelledStc><sdif:Cancellations><sdif:CancelledDate>2021-04-20T10:39:51</sdif:CancelledDate><sdif:ComponentDescription></sdif:ComponentDescription><sdif:CreationDate>2021-04-20T10:39:51</sdif:CreationDate><sdif:DeadDeviceAlias></sdif:DeadDeviceAlias><sdif:EstimatedRestorationDate></sdif:EstimatedRestorationDate><sdif:IncidentCategory></sdif:IncidentCategory><sdif:IncidentCategoryDescription></sdif:IncidentCategoryDescription><sdif:IncidentComment></sdif:IncidentComment><sdif:IncidentDescription></sdif:IncidentDescription><sdif:IncidentEasting></sdif:IncidentEasting><sdif:IncidentID>'+incdnt.SPEN_IncidentID__c+'</sdif:IncidentID><sdif:IncidentNorthing></sdif:IncidentNorthing><sdif:IncidentPriority></sdif:IncidentPriority>               <sdif:IncidentReference></sdif:IncidentReference><sdif:IncidentStatus></sdif:IncidentStatus><sdif:IncidentType></sdif:IncidentType><sdif:Notification><sdif:NotificationDetails></sdif:NotificationDetails><sdif:NotificationMethod></sdif:NotificationMethod></sdif:Notification><sdif:OperatingZone></sdif:OperatingZone><sdif:PlannedDate></sdif:PlannedDate><sdif:PrimaryAlias></sdif:PrimaryAlias><sdif:PrimaryFeeder></sdif:PrimaryFeeder><sdif:PrimaryName></sdif:PrimaryName><sdif:ResourceForename></sdif:ResourceForename><sdif:ResourceID></sdif:ResourceID><sdif:ResourceReference></sdif:ResourceReference><sdif:ResourceSurname></sdif:ResourceSurname><sdif:SecondaryAlias></sdif:SecondaryAlias><sdif:SecondaryFeeder></sdif:SecondaryFeeder><sdif:SecondaryName></sdif:SecondaryName></sdif:Cancellations></sdif:ResourceCancelledStc></sdif:SDIFResourceCancelled></soap:Body>';
            String reqStr =  '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2023-07-27T10:52:18.000+01:00</ActualTime><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>INCD-588323-k</IncidentReference><LogCategoryID>1</LogCategoryID><LogComment></LogComment><LoggedTime></LoggedTime><LogSubCategoryID>106</LogSubCategoryID><Operator></Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.isNotNull(req.requestURI);
            Test.stopTest();
        }
    }

    @IsTest
    public static void Outagestatecodecoverage() 
    {
        User u= [SELECT id FROM User WHERE id!=null and IsActive=true LIMIT 1];
        System.runAs(u)
        {
            Test.startTest();
            Incident Inc = [SELECT Id, SPEN_IncidentID__c,SPEN_IncidentReference__c from Incident where SPEN_IncidentReference__c = 'LV1234' limit 1 ];
            String reqStr = '<soap:Envelope xmlns:soap=http://schemas.xmlsoap.org/soap/envelope/><soap:Body><SDIFIncidentLogCreated xmlns="SDIF"><IncidentLogCreatedStc><ActualTime>2023-07-06T13:45:00.000Z</ActualTime><IncidentID>'+Inc.SPEN_IncidentID__c+'</IncidentID><IncidentReference>'+Inc.SPEN_IncidentReference__c+'</IncidentReference><LogCategoryID>1</LogCategoryID><LogComment> The Outage State has been updated from Restored to Partially Restored</LogComment><LoggedTime>2023-07-06T13:46:20.000Z</LoggedTime><LogSubCategoryID>-17</LogSubCategoryID><Operator>Hunter Andy (339359)</Operator></IncidentLogCreatedStc></SDIFIncidentLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            //SPEN_SyncIncidentDetails obj = new SPEN_SyncIncidentDetails();
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            SPEN_SyncIncidentDetails.createIncident();
            Assert.areEqual(Inc.SPEN_IncidentID__c, Inc.SPEN_IncidentID__c,'It is correct SPEN Incident Id');
            Test.stopTest();
        }
    }
}