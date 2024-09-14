/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for SPEN_MessagingSessionService
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
1525  			messageSessionTest
-----------------------------------------------------------------------------*/
@isTest
public class SPEN_MessagingSessionService_TEST 
{	
	@IsTest
	private static void messageSessionTest()
	{
		Test.startTest();
		Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
		User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
		Database.insert(user);
		PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_ContactAccessCRU');//[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = SPEN_TestdataSelector.getPermissionSet('SPEN_PremiseAccessCRU');//[SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
		System.runAs(user)
		{   
			// DATA
			// Create Account
			List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test', 1);
			insert accRec;
			
			// DATA
			// Create Premise
			List<SPEN_Premise__c> premiseRec = SPEN_TestDataFactory.createListOfPremise(1);
			insert premiseRec;
			
			// DATA
			// Create Contact
			Contact conRec = SPEN_TestDataFactory.createContacts(accRec[0].Id, 1);
			conRec.SPEN_CustomerID__c = '1234';
			conRec.SPEN_Premise__c = premiseRec[0].Id;
			insert conRec;

			// DATA
			// Create Messaging User
			// TODO: Move to its own Selector Class
			MessagingChannel textChannel = new MessagingChannel();
            textChannel.DeveloperName = 'Text_Channel';
            textChannel.MessageType = 'Text';
            textChannel.MasterLabel = 'Text Channel';
            textChannel.MessagingPlatformKey = 'TestKey1234';
            insert textChannel;
			//MessagingChannel channel = [SELECT id FROM MessagingChannel WHERE MessageType =: 'Text' LIMIT 1];
			MessagingEndUser enduser = SPEN_TestDataFactory.createMessagingUser(1);
			enduser.ContactId = conRec.Id;
		   	enduser.MessagingChannelId = textChannel.Id;
			insert enduser;

			// DATA
			// Create Messaging Session
			MessagingSession message=SPEN_TestDataFactory.createMessagingSession(1);
			message.MessagingEndUserId = enduser.Id;
			message.MessagingChannelId = textChannel.Id;
			insert message;
			
			// TODO: This is a bad unit test; the corresponding method should be tested directly
			// TODO: Use the asset method with method
			Assert.areEqual(message.SPEN_MessagingUserPremise__c, enduser.Contact.SPEN_Premise__c);
		}

		Test.stopTest();
	}
}