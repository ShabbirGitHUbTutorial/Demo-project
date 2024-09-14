/*
	@Author:: Rajat Mishra
	@Date  :: 20/11/2023
	@Description:: Create job records through email as part of ESC-39, Updated the class logic as part of ESC-976
*/
public class SPEN_EmailToJobCreationHelper {

    public static Messaging.InboundEmailResult CreateJobfromEmailService(Messaging.inboundEmail email, Messaging.InboundEnvelope env, String emailService){
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        SPEN_JobStatusQueueConfig__mdt queueConfigObj;
        String queueName;
        ID queueId;
        String emailSource;
        if(emailService=='LandNorth'){
            queueConfigObj = SPEN_JobStatusQueueConfig__mdt.getInstance('SPEN_EmailNorthValue');
            queueName= queueConfigObj.SPENQueueName__c;
            emailSource='Email North';
        }else
        if(emailService=='LandSouth'){
            queueConfigObj = SPEN_JobStatusQueueConfig__mdt.getInstance('SPEN_EmailSouthValue');
            queueName= queueConfigObj.SPENQueueName__c; 
            emailSource='Email South';
            }else
         if(emailService=='LVClaims'){
            queueConfigObj = SPEN_JobStatusQueueConfig__mdt.getInstance('SPEN_EmailLVClaims');
            queueName= queueConfigObj.SPENQueueName__c; 
            emailSource='Email LV Claims';
            }
        if(String.isNotBlank(queueName)){
        	queueId = [SELECT Queue.Id FROM queuesobject WHERE Queue.DeveloperName=:queueName].Queue.Id;
        }else{
            queueId = UserInfo.getUserId();
        }
        
        try {
            // Create a new SPEN_Job__c record
            SPEN_Job__c newJob = new SPEN_Job__c(
                SPEN_JobTitle__c = email.subject.abbreviate(249),
                SPEN_Source__c=emailSource,
                SPEN_Description__c= 'Job created from Email',
                SPEN_JobStatus__c=queueConfigObj.SPENStatus__c,
                SPEN_CustomerEmail__c=email.fromAddress,
                SPEN_Customer__c=email.fromName,
        		OwnerId=queueId
                // Add other fields as needed
            );
            
            insert newJob;
            
            // Email-to-Job
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.Status = '4';
            emailMessage.Subject = email.subject;
            emailMessage.FromName = email.fromName;
            emailMessage.FromAddress = email.fromAddress;
            emailMessage.RelatedToId = newJob.Id;
            emailMessage.TextBody = email.plainTextBody;
            emailMessage.HtmlBody = email.htmlBody;
            insert emailMessage;
            
            // Attachments as Files
            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = binaryAttachment.fileName;
                    contentVersion.PathOnClient = binaryAttachment.fileName;
                    contentVersion.VersionData = binaryAttachment.body;
                    contentVersion.FirstPublishLocationId = newJob.Id; // Connect to the SPEN_Job__c record
                    contentVersions.add(contentVersion);
                }
                insert contentVersions;
            }

            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = 'An error occurred: ' + e.getMessage();
        }

        return result;

    }
}