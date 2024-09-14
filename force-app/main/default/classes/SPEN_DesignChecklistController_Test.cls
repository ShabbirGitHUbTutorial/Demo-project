/*----------------------------------------------------------------------------
DESCRIPTION :   Test class for SPEN_DesignChecklistController
AUTHOR      :   Rajat Kumar mishra
VERSION     :   1.0
HISTORY     :
Date            Author              	Comment
Sep-01-2023     Rajat Kumar mishra      Initial version
-----------------------------------------------------------------------------*/ 
@isTest
public class SPEN_DesignChecklistController_Test {
	
    public static testMethod void designCheckLIstTest(){
        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
		System.runAs(u){
			
			Test.startTest();
            SPEN_WorkCategory__c wc = SPEN_TestDataUtility.createWorkCategoryRecord('Test WC','SPD');
            List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Draft','Yes',wc.Id,'create job through Email',1);
            job[0].SPEN_LicenseArea__c = 'SPD';
            job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
            job[0].SPEN_District__c='Lanarkshire';
            job[0].SPEN_BusinessArea__c='Finance';
            Database.insert(job);
			Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
            SPEN_DesignChecklistRequest__c dcrequest=SPEN_TestDataUtility.createDesignChecklistRequestRecord(job[0].id);
            List<SPEN_DesignChecklistRequest__c> dcr=SPEN_DesignChecklistController.getDCRList(job[0].id);
            SPEN_DesignChecklistRequest__c dcrlist=SPEN_DesignChecklistController.getDCR(dcr[0].id);
            List<SPEN_DesignInformation__c> lstDI=SPEN_DesignChecklistController.getDesignInformationsRelatedToDCR(dcrlist.id,null);
			Test.stopTest(); 
			
		}
    }
}