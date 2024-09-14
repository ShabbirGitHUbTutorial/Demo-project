/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for MessagingEndUserSelector
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
219  			selectByIds
-----------------------------------------------------------------------------*/
@IsTest
public class SPEN_MessagingEndUserSelector_TEST 
{
	@IsTest
	private static void selectByIds()
	{
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
        	/*User testUser = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        	Database.insert(testUser); 
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MessagingTaskCRU']; 
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps1.Id);
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU']; 
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps2.Id);
            PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU']; 
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps3.Id);*/
            System.runAs(user){
            Test.startTest();
            
            // DATA
            // TODO: Move this to its own Selector class
            MessagingChannel textChannel = new MessagingChannel();
            textChannel.DeveloperName = 'Text_Channel';
            textChannel.MessageType = 'Text';
            textChannel.MasterLabel = 'Text Channel';
            textChannel.MessagingPlatformKey = 'TestKey1234';
            insert textChannel;
            MessagingChannel channel = [SELECT id FROM MessagingChannel WHERE MessageType =: 'Text' LIMIT 1];
            MessagingEndUser meguser = SPEN_TestDataFactory.createMessagingUser(SPEN_TestDataFactoryConstants.SINGLE_REC);
            meguser.MessagingChannelId = channel.Id;
            insert meguser;
            
            // NORMAL SCENARIO
            // With matching result
            List<MessagingEndUser> resultNormal = SPEN_MessagingEndUserSelector.selectByIds(new Set<Id> { meguser.Id });
            Assert.isTrue(resultNormal.size() > 0, 'There must be result returned in this query');
            
            // NEGATIVE SCENARIO 1 of 2
            // With blank parameter
            List<MessagingEndUser> resultBlank = SPEN_MessagingEndUserSelector.selectByIds(new Set<Id> { });
            Assert.isTrue(resultBlank.size() == 0, 'There must not be a result returned in this query');
            
            // NEGATIVE SCENARIO 2 of 2
            // With null parameter
            List<MessagingEndUser> resultNull = SPEN_MessagingEndUserSelector.selectByIds(null);
            Assert.isTrue(resultNull.size() == 0, 'There must not be a result returned in this query');
            
            Test.stopTest();
        }
	}
}