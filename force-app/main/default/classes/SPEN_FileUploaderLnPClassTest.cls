@isTest
public class SPEN_FileUploaderLnPClassTest {


    @isTest
    static void testCreateFolder() {
        // Test data setup
        List<String> jobid = new List<String>();
        List<SPEN_WorkCategory__c> listWC = new List<SPEN_WorkCategory__c>();
        List<SPEN_Job__c> listjobRec = new List<SPEN_Job__c>();
  
		SPEN_WorkCategory__c testWC = new SPEN_WorkCategory__c();
            testWC.Name='SPD-OHL New BUild/Re-Build Test';
        	testWC.SPEN_WorkCategoryTitle__c='OHL New Build / Re-build';
        	testWC.SPEN_LicenseArea__c='SPD';
        	testWC.SPEN_LeadTime__c=120;
        //insert testWC;
        SPEN_WorkCategory__c testWC2 = new SPEN_WorkCategory__c();
            testWC2.Name='SPM-OHL New BUild/Re-Build Test';
        	testWC2.SPEN_WorkCategoryTitle__c='OHL New Build / Re-build';
        	testWC2.SPEN_LicenseArea__c='SPM';
        	testWC2.SPEN_LeadTime__c=120;
        //insert testWC2;
        SPEN_WorkCategory__c testWC3 = new SPEN_WorkCategory__c();
            testWC3.Name='SPT-Change of Owner';
        	testWC3.SPEN_WorkCategoryTitle__c='Change of Owner';
        	testWC3.SPEN_LicenseArea__c='SPT';
        	testWC3.SPEN_LeadTime__c=120;
        //insert testWC3;
        listWC.add(testWC);
        listWC.add(testWC2);
        listWC.add(testWC3);
        insert listWC;
        SPEN_Job__c testJob = new SPEN_Job__c(Name = 'Test Job', SPEN_LicenseArea__c = 'SPD', SPEN_JobTitle__c = 'sharepoint test job');
		testJob.SPEN_Work_Category__c=testWC.SPEN_WorkCategoryTitle__c;
		testJob.SPEN_District__c='Lanarkshire';
		testJob.SPEN_BusinessArea__c='Land & Planning';
        insert testJob;
        SPEN_Job__c testJob2 = new SPEN_Job__c(Name = 'Test Job SPM', SPEN_LicenseArea__c = 'SPM', SPEN_JobTitle__c = 'sharepoint test job SPM');
		testJob2.SPEN_Work_Category__c=testWC2.SPEN_WorkCategoryTitle__c;
		testJob2.SPEN_District__c='Wirral';
		testJob2.SPEN_BusinessArea__c='Land & Planning';
        insert testJob2;
		system.debug('testJob2>>>>>>'+testJob2);
        SPEN_Job__c testJob3 = new SPEN_Job__c(Name = 'Test Job SPM', SPEN_LicenseArea__c = 'SPT', SPEN_JobTitle__c = 'sharepoint test job SPT');
		testJob3.SPEN_Work_Category__c=testWC3.SPEN_WorkCategoryTitle__c;
		testJob3.SPEN_District__c='Lanarkshire';
		testJob3.SPEN_BusinessArea__c='Land & Planning';
        insert testJob3;
		system.debug('testJob3>>>>>>'+testJob3);
        /*listjobRec.add(testJob);
        listjobRec.add(testJob2);
        listjobRec.add(testJob3);
        insert listjobRec;*/
        Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
		//Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassLnPHttpMock());
        // Test the createFolder method
        SPEN_FileUploaderLnPClass.FolderCreationInput testInput = new SPEN_FileUploaderLnPClass.FolderCreationInput();
        testInput.jobLicenseArea=testJob3.SPEN_LicenseArea__c;
        testInput.jobName=testJob3.Name;
        
        Test.startTest();
        SPEN_FileUploaderLnPClass.createFolder(new List<SPEN_FileUploaderLnPClass.FolderCreationInput>{testInput});
        Test.stopTest();

    }
    
    @isTest
    static void testCreateFolder2() {
        // Test data setup
        List<String> jobid = new List<String>();
        List<SPEN_WorkCategory__c> listWC = new List<SPEN_WorkCategory__c>();  
		SPEN_WorkCategory__c testWC = new SPEN_WorkCategory__c();
            testWC.Name='SPD-OHL New BUild/Re-Build Test';
        	testWC.SPEN_WorkCategoryTitle__c='OHL New Build / Re-build';
        	testWC.SPEN_LicenseArea__c='SPD';
        	testWC.SPEN_LeadTime__c=120;
        
        listWC.add(testWC);
        
        insert listWC;
        SPEN_Job__c testJob = new SPEN_Job__c(Name = 'Test Job', SPEN_LicenseArea__c = 'SPD', SPEN_JobTitle__c = 'sharepoint test job');
		testJob.SPEN_Work_Category__c=testWC.SPEN_WorkCategoryTitle__c;
		testJob.SPEN_District__c='Lanarkshire';
		testJob.SPEN_BusinessArea__c='Land & Planning';
        insert testJob;
        //Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
		Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassLnPHttpMock());
        // Test the createFolder method
        SPEN_FileUploaderLnPClass.FolderCreationInput testInput = new SPEN_FileUploaderLnPClass.FolderCreationInput();
        testInput.jobLicenseArea=testJob.SPEN_LicenseArea__c;
        testInput.jobName=testJob.Name;
        
        Test.startTest();
        SPEN_FileUploaderLnPClass.createFolder(new List<SPEN_FileUploaderLnPClass.FolderCreationInput>{testInput});
        Test.stopTest();

    }
    
    
    
}