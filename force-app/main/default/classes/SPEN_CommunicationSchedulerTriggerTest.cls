/**
 * @description       : Apex test class to cover SPEN_CommunicationSchedulerTrigger and its related service class
 * @author            : rahul.dd.kumar@accenture.com
 * @group             : 
 * @last modified on  : 03-06-2023
 * @last modified by  : 
**/
@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
private class SPEN_CommunicationSchedulerTriggerTest {
    @testSetup static void setup() {
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
            SPEN_ConfigurableSettings__c cs =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
           	cs.SPEN_Value__c = '15';
            insert cs;
            SPEN_ConfigurableSettings__c cs3 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert cs3;
            SPEN_CommunicationScheduler__c scheduler = SPEN_TestDataFactory.createCommunicationSchedulerRecord(1)[0];
            insert scheduler;
            
        }
    }
         @isTest
        private static void testGetDelayedMinutes(){
             User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
         System.runAs(u){
             SPEN_ConfigurableSettings__c batchDelayInMinutes = [SELECT Id, SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='CreationBatchDelayForMessagingTask' Limit 1];
       		  Integer delayMinutes = Integer.valueOf(batchDelayInMinutes.SPEN_Value__c);
             
           	SPEN_CommunicationScheduler__c comm = [select id, SPEN_Creation_Batch_Delay__c from SPEN_CommunicationScheduler__c limit 1];
              System.assertNotEquals(comm.SPEN_Creation_Batch_Delay__c, NULL, 'Com batch delay has delay time');
        	}
        }
        
}