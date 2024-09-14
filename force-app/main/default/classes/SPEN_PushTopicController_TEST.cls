/*-------------------------------------------------------------------------------------------------------------------
DESCRIPTION: UNIT TEST CLASS FOR SPEN_PushTopicController.apxc class
AUTHOR                      VERSION       	 DATE       		Details
Sheker Kulkacherla            1            24/11/2022         CRMD-440 View Current Reactive Incidents
----------------------------------------------------------------------------------------------------------------*/
@isTest
public class SPEN_PushTopicController_TEST {
    @isTest
    public static void getPushTopicsTest(){
        
        PushTopic pTopic = SPEN_TestDataFactory.createPushTopicRecord();
        SPEN_PushTopicController.getPushTopics();
        Test.startTest();
        System.assertEquals(true, pTopic.NotifyForOperationCreate);
        Test.stopTest();
    }
}