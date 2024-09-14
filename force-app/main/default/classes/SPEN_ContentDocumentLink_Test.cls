@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_ContentDocumentLink_Test {
    @IsTest
    public static void testContentDocumentLink()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {
            Test.startTest();
            List<SPEN_MessagingTask__c> sMsgtask = new List<SPEN_MessagingTask__c>();
            SPEN_MessagingTask__c sMsgtask1 = new SPEN_MessagingTask__c();
            sMsgtask1.SPEN_Status__c='New';   
            insert sMsgtask1;
            sMsgtask.add(sMsgtask1);
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.csv',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title='Test'];
            ContentDocumentLink cdli = New ContentDocumentLink();
            cdli.LinkedEntityId = sMsgtask1.id;
            cdli.ContentDocumentId = documents[0].Id;
            cdli.shareType = 'V';
            insert cdli;
            Assert.IsNotNull(sMsgtask1);
            Test.stopTest();
        }
    }

     @IsTest
    public static void testJobContentDocumentLink()
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
        List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Review','Yes',wc.Id,'create job through Email',1);
        job[0].SPEN_LicenseArea__c = 'SPD';
        job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
        job[0].SPEN_District__c='Lanarkshire';
        job[0].SPEN_BusinessArea__c='Finance';
        job[0].SPEN_CircuitID__c='CI001';
        job[0].SPEN_CustomerType__c='Network';
        job[0].SPEN_ControlNumber__c='CN001';
        job[0].SPEN_OSGridReference__c='897654,987554';
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
            System.assertEquals(false,sr.isSuccess());
            Test.stopTest();
        }
    }
    
     @IsTest
    public static void testLIContentDocumentLink()
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
        SPEN_Land__c landRec= SPEN_TestDataUtility.createLandRec();
        SPEN_Land_Interest__c landIntRec = SPEN_TestDataUtility.createLandIntRec(landRec.Id,job[0].Id);
           
            Test.startTest();
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'TestContentLI',
                PathOnClient = 'TestdocLI.csv',
                VersionData = Blob.valueOf('TestContentLI'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink cdli = New ContentDocumentLink();
            cdli.LinkedEntityId = landIntRec.Id;
            cdli.ContentDocumentId = documents[0].Id;
            cdli.shareType = 'V';
            Database.SaveResult sr = Database.insert(cdli, false);
            System.assertEquals(false,sr.isSuccess());
            Test.stopTest();
        }
    }
    
     @IsTest
    public static void testPlanningContentDocumentLink()
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
        List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Draft','Yes',wc.Id,'create job through Email',1);
        job[0].SPEN_LicenseArea__c = 'SPD';
        job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
        job[0].SPEN_District__c='Lanarkshire';
        job[0].SPEN_BusinessArea__c='Finance';
        job[0].SPEN_CircuitID__c='CI001';
        job[0].SPEN_CustomerType__c='Network';
        job[0].SPEN_ControlNumber__c='CN001';
        job[0].SPEN_OSGridReference__c='897654,987655';
        job[0].SPEN_JobTitle__c = 'CreatedJob#1';  
        job[0].Name = 'CreatedJob#1'; 
        Database.insert(job);
		Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
        SPEN_Planning__c planningRec= SPEN_TestDataUtility.createPlanningRec('Draft',job[0].Id);
            
            Test.startTest();
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'TestContentLI',
                PathOnClient = 'TestdocLI.csv',
                VersionData = Blob.valueOf('TestContentLI'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            ContentDocumentLink cdli = New ContentDocumentLink();
            cdli.LinkedEntityId = planningRec.Id;
            cdli.ContentDocumentId = documents[0].Id;
            cdli.shareType = 'V';
            Database.SaveResult sr = Database.insert(cdli, false);
            System.assertEquals(false,sr.isSuccess());
            Test.stopTest();
        }
    }
    
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

            Database.DeleteResult dr = Database.delete(cdli, false);
            System.assertEquals(false,dr.isSuccess());

            Test.stopTest();
        }
    }

}