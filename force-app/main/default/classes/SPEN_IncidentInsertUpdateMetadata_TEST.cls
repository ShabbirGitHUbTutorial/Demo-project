/*-------------------------------------------------------------------------------------------------------------------
DESCRIPTION: UNIT TEST CLASS FOR SPEN_IncidentInsertUpdateMetadata.apxc and SPEN_PushTopicController.apxc classes
AUTHOR                      VERSION       	 DATE       		Details
Sheker Kulkacherla            1            23/11/2022         CRMD-440 View Current Reactive Incidents
----------------------------------------------------------------------------------------------------------------*/
@isTest
global class SPEN_IncidentInsertUpdateMetadata_TEST {
	@isTest
     public static void getIncidentData(){
         
         SPEN_IncidentAutomaticRefresh__mdt incRecord = [SELECT SPEN_Channel__c,SPEN_IsActive__c from SPEN_IncidentAutomaticRefresh__mdt LIMIT 1];     
          Test.startTest();
          SPEN_IncidentInsertUpdateMetadata.getChannel();
          System.assertEquals('IncidentInsertAndUpdates', incRecord.SPEN_Channel__c);
          System.assertEquals(true, incRecord.SPEN_IsActive__c);
          Test.stopTest();
    }
}