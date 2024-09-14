@isTest
public class SPEN_IncidentQueueableClass_Test 
{
	@isTest
    private static void testme()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
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
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cSeting;
            SPEN_ConfigurableSettings__c cSeting1= SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cSeting1;
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            
             
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
            
            List<SPEN_IVROperatingHours__c> vAOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            vAOprHrList[0].RecordTypeId = iVRVARecTypeId;
            vAOprHrList[0].SPEN_isActive__c = true;
            vAOprHrList[0].SPEN_isDaily__c = true;
            vAOprHrList[0].SPEN_StartTime__c = system.now().time() - 10;
            vAOprHrList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert vAOprHrList;
            
            List<Case> cs = SPEN_TestDataFactory.createListOfCases(3); 
            cs[0].Origin = 'Web';
            cs[0].Status = 'Restored';
            cs[1].Origin = 'Web';
            cs[1].Status = 'Restored';
            cs[2].Origin = 'Web';
            cs[2].Status = 'Restored';
            insert cs;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(cs[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='HV_S';
            inc.SPEN_IncidentStatus__c = 'Awaiting';
            insert inc;
            
            Incident inc1 = SPEN_TestDataFactory.createIncidents(cs[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc1.subject = 'Test Incident1';
            inc1.ParentIncidentId = inc.Id;
            inc1.SPEN_IncidentType__c='SP';
            inc1.SPEN_IncidentStatus__c = 'Awaiting';
            insert inc1;
            
            cs[2].SPEN_Incident__c = inc.Id;
            cs[0].SPEN_Incident__c = inc1.Id;
            
            cs[0].SPEN_PreferredMethodofContact__c = 'T';
            cs[0].SPEN_CallerMobileTelephone__c = '+448888334455';
            cs[0].SPEN_AdditionalCaller__c = true;
            update cs;

            List<String> cRef = new List<String>();
            cRef.add(cs[0].id);
            cRef.add(cs[1].id);
            cRef.add(cs[2].id);
            
                    
            Assert.isNotNull(inc1);
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void testScopeChanged() 
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        
        User u = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        u.FirstName = 'Dropped ';
        u.LastName = 'Outbound Task User';
        insert u;
        
		System.runAs(user)
        {            
            SPEN_ConfigurableSettings__c cs1 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'CreationBatchDelay');
            insert cs1;
            SPEN_ConfigurableSettings__c cS2 = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'GetAffectedPremiseINCType');
            insert cS2;
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            
            Id recTypeId = Schema.SObjectType.Incident.getRecordTypeInfosByName().get('SPEN Incident').getRecordTypeId();
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = 'I001';
            incdnt.SPEN_IncidentType__c = 'LV';
            incdnt.SPEN_IncidentReference__c = 'LV';
            incdnt.recordtypeId = recTypeId;
            insert incdnt;
            
            List<Case> testCase3 = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase3[0].Origin = 'Web';
            testCase3[0].ContactId=con.Id;
            testCase3[0].SPEN_Incident__c = incdnt.id;
            insert testCase3;

            String reqStr = '<soap:Body><SDIFIncidentScopeChanged  xmlns="SDIF"><IncidentScopeChangedStc><IncidentReference>'+incdnt.SPEN_IncidentReference__c+'</IncidentReference><Calls><CallID>k0000303dCALL</CallID><CallReference>'+testCase3[0].Id+'</CallReference></Calls></IncidentScopeChangedStc></SDIFIncidentScopeChanged ></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            
            List<String> strList = new List<String>();
            
            SPEN_IntegrationXMLNodes.SoapBodyNode incidentPowerOn = new SPEN_IntegrationXMLNodes.SoapBodyNode();
            strList = req.requestBody.toString().split('<soap:Body>');
            String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', ''); 
            String soapString = newStr.replaceAll('soap:', '');
            String soapNoNullString = soapString.replaceAll('xsi:nil=\"true\"', '');
            incidentPowerOn.load(soapNoNullString); 
            
            SPEN_SyncIncidentDetailsWrapper.RequestBody createWrapper = (SPEN_SyncIncidentDetailsWrapper.RequestBody) System.JSON.deserialize(JSON.serialize(incidentPowerOn), SPEN_SyncIncidentDetailsWrapper.RequestBody.class);
			//system.debug('createWrapper '+ createWrapper);
            
            Test.startTest();
            for(SPEN_SyncIncidentDetailsWrapper.sdifIncidentScopeChanged incScopeCngd: createWrapper.sdifIncidentScopeChanged)
            {
                SPEN_IncidentQueueableClass incQueueableClass = new SPEN_IncidentQueueableClass(incScopeCngd);
                System.enqueueJob(incQueueableClass); 
            }
            Assert.isNotNull(incdnt);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testMethodBlackOut()
    {
       	Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        
        User u = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        u.FirstName = 'Dropped ';
        u.LastName = 'Outbound Task User';
        insert u;
        
		System.runAs(user)
        {   
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            Test.startTest();
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cSeting;
            SPEN_ConfigurableSettings__c cSeting1= SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cSeting1;
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cS2;
            
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
            iVRORecList[0].SPEN_StartTime__c = system.now().time().addHours(10);
            iVRORecList[0].SPEN_EndTime__c = system.now().time().addHours(23);
            Insert iVRORecList;
            
            List<SPEN_IVROperatingHours__c> vAOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,ivrList[0].id,message.id);
            vAOprHrList[0].RecordTypeId = iVRVARecTypeId;
            vAOprHrList[0].SPEN_isActive__c = true;
            vAOprHrList[0].SPEN_isDaily__c = true;
            Insert vAOprHrList;
            
            List<Case> cs = SPEN_TestDataFactory.createListOfCases(3); 
            cs[0].Origin = 'Web';
            cs[0].Status = 'Restored';
            cs[1].Origin = 'Web';
            cs[1].Status = 'Restored';
            cs[2].Origin = 'Web';
            cs[2].Status = 'Restored';
            insert cs;
            
            Incident inc = SPEN_TestDataFactory.createIncidents(cs[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc.SPEN_IncidentType__c='HV_S';
            inc.SPEN_IncidentStatus__c = 'Awaiting';
            insert inc;
            
            Incident inc1 = SPEN_TestDataFactory.createIncidents(cs[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            inc1.subject = 'Test Incident1';
            inc1.ParentIncidentId = inc.Id;
            inc1.SPEN_IncidentType__c='SP';
            inc.SPEN_IncidentStatus__c = 'Awaiting';
            insert inc1;
            
            cs[2].SPEN_Incident__c = inc.Id;
            cs[0].SPEN_Incident__c = inc1.Id;
            
            cs[0].SPEN_PreferredMethodofContact__c = 'H';
            cs[0].SPEN_CallerTelephone__c = '+448888334455';
            cs[0].SPEN_AdditionalCaller__c = true;
            update cs;

            List<String> cRef = new List<String>();
            cRef.add(cs[0].id);
            cRef.add(cs[1].id);
            cRef.add(cs[2].id);
            
                    
            Assert.isNotNull(inc1);
            Test.stopTest();
        }
    }
}