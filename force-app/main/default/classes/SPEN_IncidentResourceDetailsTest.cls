@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_IncidentResourceDetailsTest {
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    Public static Id recordTypeIdNrswa = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
    @testSetup static void setup(){
        Group queueSPDId = new SPEN_GroupsSelector().selectByQueueName('SPEN_NRSWASPD');
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAS(user){
            Test.startTest();
            List<Incident> lstInct = SPEN_TestDataFactory.createListofIncidents(1);
            lstInct[0].SPEN_IncidentCategory__c = 'SP';
            lstInct[0].SPEN_IncidentID__c = '123';
            insert lstInct;
            
            SPEN_ResourceDetail__c redRecord = new SPEN_ResourceDetail__c();
            redRecord.SPEN_Company__c = 'MORRISON';
            redRecord.SPEN_Comment__c = 'test';
            redRecord.SPEN_ResourceName__c = 'sfdc';
            //redRecord.SPEN_EventDate__c = '2023-07-27T12:45:35.000+01:00';
            redRecord.SPEN_EventDate__c = System.now();
            redRecord.SPEN_Incident__c = lstInct[0].Id;
            redRecord.SPEN_Event__c = 'Cancelled';
            insert redRecord;
            
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Case nrswaCase = new Case();
            nrswaCase.RecordTypeId = recordTypeIdQuery;
            nrswaCase.Origin = 'PowerOn';
            nrswaCase.Status = 'Open';
            nrswaCase.SPEN_Type__c = 'Query';
            //nrswaCase.SPEN_QueryReason__c = 'Resource - Cancelled';
            nrswaCase.SPEN_Incident__c = lstInct[0].Id;
            nrswaCase.SPEN_IncidentReference__c = lstInct[0].SPEN_IncidentReference__c;
            nrswaCase.SPEN_SPDSPMIndicator__c = lstInct[0].SPEN_Zone__r.SPEN_SPD_SPM__c;
            nrswaCase.OwnerId = queueSPDId.Id;
            insert nrswaCase;
            Assert.areEqual('Open',  nrswaCase.Status, 'case status value');
            Test.stopTest();
        }
    }
    @isTest
    public static void testResourceDetails(){
        Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
        Test.startTest();
        User usr= [Select id FROM User WHERE IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = 'I001';
            incdnt.SPEN_IncidentType__c = 'LV';
            incdnt.SPEN_IncidentReference__c = 'LV';
            insert incdnt;
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = recordTypeIdNrswa;
            caseRec.Origin = 'Phone';
            caseRec.Status = 'Open';
            caseRec.SPEN_Incident__c = incdnt.Id;
            caseRec.SPEN_IncidentReference__c = incdnt.SPEN_IncidentReference__c;
            caseRec.SPEN_SPDSPMIndicator__c = incdnt.SPEN_Zone__r.SPEN_SPD_SPM__c;
            insert caseRec;
            
            String reqStr = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap=http://schemas.xmlsoap.org/soap/envelope/><soap:Body><SDIFIncidentLabourLogCreated  xmlns="SDIF"><IncidentLabourLogCreatedStc><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>'+incdnt.SPEN_IncidentReference__c+'</IncidentReference><LogCategoryID>2</LogCategoryID><LogSubCategoryID>-11</LogSubCategoryID><LoggedTime>2023-10-13T13:14:41.000+01:00</LoggedTime><Company>MORRISONS</Company><EventDate>2023-10-13T13:14:41.000+01:00</EventDate><DispatchedDate>2023-10-13T13:14:38.000+01:00</DispatchedDate><CompletionDate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance " xsi:nil="true"/><Operator>Morrisons, Morrisons ()</Operator><ResourceName>double codes</ResourceName><LogComment>Arrival On Site Time set to </LogComment></IncidentLabourLogCreatedStc></SDIFIncidentLabourLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/ResourceDetails';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;        
            SPEN_IncidentResourceDetails.incidentRecordUpdate();
            Assert.areEqual('Open',  caseRec.Status, 'case status value');
            Test.stopTest();
        }
    }
    @isTest
    public static void testResourceDetailsOnSite(){
        Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
        Test.startTest();
        User usr= [Select id FROM User WHERE IsActive=true LIMIT 1];
        System.runAs(usr)
        {
            Incident incdnt = new Incident();
            incdnt.Subject = 'Test HV Incident';
            incdnt.SPEN_IncidentID__c = 'I001';
            incdnt.SPEN_IncidentType__c = 'LV';
            incdnt.SPEN_IncidentReference__c = 'LV';
            insert incdnt;
            
            Case caseRec = new Case();
            caseRec.RecordTypeId = recordTypeIdNrswa;
            caseRec.Origin = 'Phone';
            caseRec.Status = 'Open';
            caseRec.SPEN_Incident__c = incdnt.Id;
            caseRec.SPEN_IncidentReference__c = incdnt.SPEN_IncidentReference__c;
            caseRec.SPEN_SPDSPMIndicator__c = incdnt.SPEN_Zone__r.SPEN_SPD_SPM__c;
            insert caseRec;
            
            String reqStr = '<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap=http://schemas.xmlsoap.org/soap/envelope/><soap:Body><SDIFIncidentLabourLogCreated  xmlns="SDIF"><IncidentLabourLogCreatedStc><IncidentID>'+incdnt.SPEN_IncidentID__c+'</IncidentID><IncidentReference>'+incdnt.SPEN_IncidentReference__c+'</IncidentReference><LogCategoryID>2</LogCategoryID><LogSubCategoryID>-1</LogSubCategoryID><LoggedTime>2023-10-13T13:14:41.000+01:00</LoggedTime><Company>MORRISONS</Company><EventDate>2023-10-13T13:14:41.000+01:00</EventDate><DispatchedDate>2023-10-13T13:14:38.000+01:00</DispatchedDate><CompletionDate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance " xsi:nil="true"/><Operator>Morrisons, Morrisons ()</Operator><ResourceName>double codes</ResourceName><LogComment>Arrival On Site Time set to </LogComment></IncidentLabourLogCreatedStc></SDIFIncidentLabourLogCreated></soap:Body></soap:Envelope>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/ResourceDetails';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;           	
            SPEN_IncidentResourceDetails.incidentRecordUpdate();
            Assert.areEqual('Open',  caseRec.Status, 'case status value');
            Test.stopTest();
        }
    }
}