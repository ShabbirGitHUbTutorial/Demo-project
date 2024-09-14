@isTest
public class SPEN_IncidentReparentBatch_Test 
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
        /*
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zoneAccess = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_CRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zoneAccess.Id);     
		*/        
		System.runAs(user)
        {
            Test.startTest();
            SPEN_ConfigurableSettings__c cSeting= SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            insert cSeting;
            SPEN_ConfigurableSettings__c cSeting1= SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            insert cSeting1;
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            
             
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the //////customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
            
            List<SPEN_IVR__c> iVRList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert iVRList;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            Id iVRVARecTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('VA Blackout Window').getRecordTypeId();
            
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,iVRList[0].id,message.id);
            iVRORecList[0].RecordTypeId = iVROperatingHoursRecordTypeId;
            iVRORecList[0].SPEN_isActive__c = true;
            iVRORecList[0].SPEN_isDaily__c = true;
            iVRORecList[0].SPEN_StartTime__c = system.now().time() - 10;
            iVRORecList[0].SPEN_EndTime__c = system.now().time() - 5;
            Insert iVRORecList;
            
            List<SPEN_IVROperatingHours__c> vAOprHrList = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,iVRList[0].id,message.id);
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
            //inc1.SPEN_IncidentType__c='HV_S';
            inc.SPEN_IncidentStatus__c = 'Awaiting';
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
            
            SPEN_IncidentReparentBatch obj= new SPEN_IncidentReparentBatch(inc,cRef);
            Database.executeBatch(obj);
            Assert.isNotNull(obj);
            Test.stopTest();
        }
    }
}