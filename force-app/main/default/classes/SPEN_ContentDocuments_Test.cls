@IsTest
public class SPEN_ContentDocuments_Test {
    

    @IsTest
    public static void testJobDeleteContentDocumentLink()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAMELNPUSER);
        PermissionSetGroup externaluserPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_LnP_ExternalUser');
        
        UserRole externalRole = SPEN_TestDataFactory.createExternalUserRole('testExternalRole','External Distribution');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAMELNPUSER);
        user.UserRoleId = externalRole.Id;
        Database.insert(user);
        if (externaluserPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(externaluserPSGroup.Id);
        }
        PermissionSetAssignment externaluserAssign = new PermissionSetAssignment();
        externaluserAssign.AssigneeId = user.Id;
        externaluserAssign.PermissionSetGroupId = externaluserPSGroup.Id;
        insert externaluserAssign; 
        System.runAs(user) {
       
        SPEN_WorkCategory__c wc = SPEN_TestDataUtility.createWorkCategoryRecord('Test WC','SPD');
        SPEN_DesignInformationTemplate__c desInfTemp= SPEN_TestDataUtility.createDesignInfoTemplateRec('testDesignInfoTemplateData');
        SPEN_CategoryDesignInformation__c catDesInfo = SPEN_TestDataUtility.createCategoryDesignInfo(wc.Id,desInfTemp.Id);       
        List<SPEN_WorkCategoryMilestone__c> parentWCMs = SPEN_TestDataUtility.createWorkCategoryMilestoneRecord(wc.id,'Planning','Yes',2, null);
        Database.insert(parentWCMs);
        if(parentWCMs!= null){
            List<SPEN_WorkCategoryMilestone__c> ChildWCMs = SPEN_TestDataUtility.createWorkCategoryMilestoneRecord(wc.id,'Planning','Yes',3, parentWCMs[0].id );
            Database.insert(ChildWCMs);
        }
        List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Draft','Yes',wc.Id,'create job through Email',1);
        job[0].SPEN_LicenseArea__c = 'SPD';
        job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
        job[0].SPEN_District__c='Lanarkshire';
        job[0].SPEN_BusinessArea__c='Finance';
        job[0].SPEN_CircuitID__c='CI001';
        job[0].SPEN_CustomerType__c='Network';
        job[0].SPEN_ControlNumber__c='CN001';
        job[0].SPEN_OSGridReference__c='897654,987654';
        job[0].SPEN_JobTitle__c = 'CreatedJob#1';  
        job[0].Name = 'CreatedJob#1'; 
        Database.insert(job);
        Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
            Test.startTest();
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'TestContent',
                PathOnClient = 'Testdoc.csv',
                VersionData = Blob.valueOf('TestContent'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink cdli = New ContentDocumentLink();
            cdli.LinkedEntityId = job[0].Id;
            cdli.ContentDocumentId = documents[0].Id;
            cdli.shareType = 'V';
            Database.SaveResult sr = Database.insert(cdli, false);
            
            job[0].SPEN_JobStatus__c='Review';
            update job[0];            

            Database.DeleteResult dr = Database.delete(documents[0], false);
            System.assertEquals(false,dr.isSuccess());

            Test.stopTest();
        }
    }
}