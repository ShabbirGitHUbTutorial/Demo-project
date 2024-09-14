/*----------------------------------------------------------------------------
DESCRIPTION :   Test class for SPEN_PlanningTaskCreationInvocable
AUTHOR      :   Ajay Chandraferi
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0
HISTORY     :
Date            Author                  Comment
Oct-16-2023     Ajay Chandraferi        Initial version (ESC-179)
-----------------------------------------------------------------------------*/ 
@isTest
private class SPEN_PlanningTaskCreationInvocableTest{
    
    public static testMethod void planningtaskCreationTest(){        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
        System.runAs(u){
            Date ParentEnddate;
            Boolean Isleevel = true;
            SPEN_WorkCategory__c wc = SPEN_TestDataUtility.createWorkCategoryRecord('Test WC','SPD');
            Id parentId ;
            List<SPEN_WorkCategoryMilestone__c> parentWCMs = SPEN_TestDataUtility.createWorkCategoryMilestoneRecord(wc.id,'Planning','Yes',2, parentId);
            Database.insert(parentWCMs);
            if(parentWCMs!= null){
                List<SPEN_WorkCategoryMilestone__c> ChildWCMs = SPEN_TestDataUtility.createWorkCategoryMilestoneRecord(wc.id,'Planning Task','Yes',2, parentWCMs[0].id );
                Database.insert(ChildWCMs);
            }
            List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Draft','Yes',wc.Id,'create job through Email',1);
            job[0].SPEN_LicenseArea__c = 'SPD';
            job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
            job[0].SPEN_District__c='Lanarkshire';
            job[0].SPEN_BusinessArea__c='Finance';
            Database.insert(job);            
            Test.startTest();
				Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
                List<SPEN_MilestoneCreationInvocable.SPEN_CreateMilestoneRequest> milestoneReq = new List<SPEN_MilestoneCreationInvocable.SPEN_CreateMilestoneRequest>();
                SPEN_MilestoneCreationInvocable.SPEN_CreateMilestoneRequest req = new SPEN_MilestoneCreationInvocable.SPEN_CreateMilestoneRequest();                    
                SPEN_Job__c jobObj = [select id, SPEN_SubCategory__c, SPEN_WorkCategory__c from SPEN_Job__c  where id =: job[0].id];
                req.jobObj = jobObj ;
                req.action = 'Create';
                milestoneReq.add(req);
                List<SPEN_MilestoneCreationInvocable.SPEN_CreateMilestoneResult> mResult = SPEN_MilestoneCreationInvocable.createPredefinedMilestones(milestoneReq);                      
            Test.stopTest();                
            system.assertNotEquals(mResult[0].milestonesResult, null, 'Job Milestones not inserted') ;            
            List<SPEN_Job_Milestone__c> jobMilestonesInserted = [SELECT ID FROM SPEN_Job_Milestone__c where SPEN_Job__c =:job[0].id and SPEN_Milestone_Type__c = 'Planning Task'];           
        }
    }      
}