/**
* @description       : Test class for SPEN_GetAffectedPremiseQueueableClass
* @author            : Rahul Kumar
* @group             : 
* @last modified on  : 22-11-2023
* @last modified by  : rahul.dd.kumar@accenture.com
**/
@isTest
public class SPEN_GetAffectedPremiseQueueClassTest {
	@testSetup 
    static void dataSetup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        System.runAs(user){
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
            
        Incident inc2 = SPEN_TestDataFactory.createListofIncidents(1)[0];        
        inc2.Status = 'New';
        inc2.SPEN_IncidentCategory__c = 'HV';
        inc2.Subject = 'Testing2';
        inc2.SPEN_IncidentType__c = 'HV_N';
        inc2.SPEN_GetAffectedPremisesScheduled__c = true;
        inc2.SPEN_Outage_State__c ='Confirmed';
        inc2.SPEN_IncidentReference__c = 'INCD-00001';
        insert inc2;
         inc2.SPEN_Outage_State__c ='Planned';
         update inc2;
        }
    }
    @isTest 
    private static void testAffectedPremiseQueue(){
        User u= [Select id FROM User where IsActive=true LIMIT 1];
        System.runAs(u){
            Incident inc  = [select id, SPEN_GetAffectedPremisesScheduled__c, SPEN_IncidentStatus__c,SPEN_IncidentType__c,SPEN_IncidentReference__c from Incident where SPEN_IncidentReference__c = 'INCD-00001' LIMIT 1];
             String reqStr = '<soap:Body><SDIFIncidentScopeChanged  xmlns="SDIF"><IncidentScopeChangedStc><IncidentReference>'+inc.SPEN_IncidentReference__c+'</IncidentReference><Calls><CallID>k0000303dCALL</CallID><CallReference>TestCases</CallReference></Calls></IncidentScopeChangedStc></SDIFIncidentScopeChanged ></soap:Body>';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/Incidents';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueOf(reqStr);
            RestContext.request = req;
            RestContext.response= res;
            Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
            
            Test.startTest();
        		SPEN_GetAffectedPremiseQueueableClass queueableJob = new SPEN_GetAffectedPremiseQueueableClass(inc.SPEN_IncidentReference__c);
       		    System.enqueueJob(queueableJob);
            	Assert.areEqual(inc.SPEN_GetAffectedPremisesScheduled__c, true);
        	Test.stopTest();
        }
    }
}