/*
	@Author:: Rajat Mishra
	@Date  :: 20/11/2023
	@Description:: Test class for SPEN_EmailToJobCreationHelper,SPEN_LandNorthEmailtoJobHandler,
					SPEN_LandSouthEmailtoJobHandler class.
*/
@isTest
public class SPEN_EmailToJobCreationHelper_Test {
	@isTest
    static void testEmailService() {

        // Create a test email message
        Messaging.InboundEmail testEmail = new Messaging.InboundEmail();
        testEmail.subject = 'Test Email';
        testEmail.fromName = 'Test User';
        testEmail.fromAddress = 'test@example.com';
        testEmail.plainTextBody = 'This is a test email message.';
        testEmail.htmlBody = '<p>This is a test email message.</p>';

        // Simulate binary attachment
        Messaging.Inboundemail.BinaryAttachment binaryAttachment = new Messaging.Inboundemail.BinaryAttachment();
        binaryAttachment.fileName = 'TestAttachment.pdf';
        binaryAttachment.body = Blob.valueOf('Attachment content');
        testEmail.binaryAttachments = new List<Messaging.Inboundemail.BinaryAttachment>();
        testEmail.binaryAttachments.add(binaryAttachment);

        // Create an instance of the email service handler
        SPEN_LandNorthEmailtoJobHandler emailServiceNorthHandler = new SPEN_LandNorthEmailtoJobHandler();
		SPEN_LandSouthEmailtoJobHandler emailServiceSouthHandler = new SPEN_LandSouthEmailtoJobHandler();
        SPEN_LVClaimsEmailtoJobHandler emailServiceLVClaimsHandler = new SPEN_LVClaimsEmailtoJobHandler();
        
        // Call the email service handler
        Test.startTest();
        //Messaging.InboundEmailResult result = SPEN_EmailToJobCreationHelper.CreateJobfromEmailService(testEmail, null,'LandNorth');
        Messaging.InboundEmailResult resultNorth = emailServiceNorthHandler.handleInboundEmail(testEmail, null);
        Messaging.InboundEmailResult resultSouth = emailServiceSouthHandler.handleInboundEmail(testEmail, null);
        Messaging.InboundEmailResult resultLVClaims = emailServiceLVClaimsHandler.handleInboundEmail(testEmail, null);
        
        Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
        Test.stopTest();

        // Verify that the service successfully processes the email
        System.assertEquals(true, resultNorth.success);
        System.assertEquals(true, resultSouth.success);
        System.assertEquals(true, resultLVClaims.success);
        
    }
}