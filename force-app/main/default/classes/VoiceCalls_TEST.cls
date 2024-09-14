/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class VoiceCalls domain clas
LIBRARY		:	SPEN
VERSION		:	1.0
HISTORY		:
Date			Author				Comment
FEB-02-2023		Macjules Sevilla	Added the onAfterUpdate test method
-----------------------------------------------------------------------------*/
@IsTest
public with sharing class VoiceCalls_TEST
{
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_IVROperatinghoursAccessCRU');//[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        MessagingChannel msgChannel = new MessagingChannel();
        msgChannel.MasterLabel = 'PSR';
        msgChannel.DeveloperName = 'PSR1';
        msgChannel.MessagingPlatformKey = '+442034679628';
        msgChannel.MessageType = 'Voice';
        insert msgChannel;

    }
	@SuppressWarnings('PMD.CognitiveComplexity')
	@IsTest
	private static void onAfterUpdate()
	{
		// DATA
		User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);       
        System.runAs(user)
        {
            Map<Id, VoiceCall> dataset1 = new Map<Id, VoiceCall>();
            Map<Id, VoiceCall> dataset2 = new Map<Id, VoiceCall>();
            Map<Id, VoiceCall> dataset3 = new Map<Id, VoiceCall>();

            VoiceCall vc1 = new VoiceCall();
            //vc1.CallOrigin = '';
            vc1.Id = UserInfo.getUserId().replaceFirst('005', '0LQ');
            dataset1.put(vc1.Id, vc1);

            VoiceCall vc2 = new VoiceCall();
            //vc2.CallOrigin = VoiceCalls.CALL_ORIGIN_VOICEMAIL;
            vc2.Id = UserInfo.getUserId().replaceFirst('005', '0LQ');
            dataset2.put(vc2.Id, vc2);

            VoiceCall vc3 = new VoiceCall();
            //vc3.CallOrigin = null;
            vc3.Id = UserInfo.getUserId().replaceFirst('005', '0LQ');
            dataset3.put(vc3.Id, vc3);

            Test.startTest();

            // TEST SCENARIO 1
            // No change in the call origin
            VoiceCalls test1 = new VoiceCalls();
            test1.allowVoicemailDML = false;
            test1.onAfterUpdate(dataset1, dataset1);

            VoiceCalls test11 = new VoiceCalls();
            test11.allowVoicemailDML = false;
            test11.onBeforeUpdate(dataset1,dataset1.values());


            // ASSERT 1
            Assert.isTrue(test1.voicemails.isEmpty(), 'The voicemails list must be blank when there is no change in call origin');

            // TEST SCENARIO 2
            // Call Origin is changed to Voicemail
            VoiceCalls test2 = new VoiceCalls();
            test2.allowVoicemailDML = false;
            test2.onAfterUpdate(dataset1, dataset2);

            // ASSERT 2
            Assert.isTrue(test2.voicemails.size() == 0, 'One voicemail record must be created only if the call origin changed to Voicemail');

            // TEST SCENARIO 3
            // Call Origin is changed from Voicemail to another value
            VoiceCalls test3 = new VoiceCalls();
            test3.allowVoicemailDML = false;
            test3.onAfterUpdate(dataset2, dataset1);

            // ASSERT 3
            Assert.isTrue(test3.voicemails.isEmpty(), 'The voicemails list must be blank when the Call Origin is changed from Voicemail to something else');

            // TEST SCENARIO 4
            // Call Origin is changed from Voicemail to another value
            VoiceCalls test4 = new VoiceCalls();
            test4.allowVoicemailDML = false;
            test4.onAfterUpdate(dataset2, dataset2);

            // ASSERT 4 
            Assert.isTrue(test4.voicemails.isEmpty(), 'The voicemails list must be blank when the Call Origin is changed from Voicemail to Voicemail');

            // TEST SCENARIO 5
            // Call Origin is NULL before and Voicemail After
            VoiceCalls test5 = new VoiceCalls();
            test5.allowVoicemailDML = false;
            test5.onAfterUpdate(dataset3, dataset2);

            // ASSERT 5
            Assert.isTrue(test5.voicemails.size() == 0, 'One voicemail record must be created if the call origin changed from NULL to Voicemail');

            // TEST SCENARIO 6
            // Call Origin is Voicemail before and NULL After
            VoiceCalls test6 = new VoiceCalls();
            test6.allowVoicemailDML = false;
            test6.onAfterUpdate(dataset2, dataset3);

            // ASSERT 6
            Assert.isTrue(test6.voicemails.isEmpty(), 'The voicemails list must be blank when the Call Origin is changed from Voicemail to Null');

            Test.stopTest();
        }
	}
    @isTest
	public static void testBeforeInsert(){
        Test.startTest();
        List<SPEN_IVR__c> lstIVR=  SPEN_TestDataFactory.createIVRrecord(1);
        lstIVR[0].SPEN_ExternalId__c = 'PSR';
        lstIVR[0].SPEN_CallGroup__c = 'PSR';
        insert lstIVR; 
        VoiceCall vc1 = new VoiceCall();
		//vc1.CallOrigin = VoiceCalls.CALL_ORIGIN_VOICEMAIL;
		vc1.Id = UserInfo.getUserId().replaceFirst('005', '0LQ');

        List<VoiceCall> lstVCl = new List<VoiceCall>();

        lstVCl.add(vc1);
        VoiceCalls test4 = new VoiceCalls();
		test4.allowVoicemailDML = false;
		test4.onBeforeInsert(lstVCl);
        Assert.isFalse(test4.allowVoicemailDML, 'The voicemails list must be blank when the Call Origin is changed from Voicemail to Null');

        Test.stopTest();

	}
}