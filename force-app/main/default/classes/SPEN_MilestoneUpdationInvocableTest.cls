/*----------------------------------------------------------------------------
DESCRIPTION :   Test class for SPEN_MilestoneUpdationInvocable
AUTHOR      :   Rajat mishra
VERSION     :   1.0
HISTORY     :
Date            Author              	Comment
Aug-15-2023     Rajat mishra      Initial version
-----------------------------------------------------------------------------*/ 

@isTest
public class SPEN_MilestoneUpdationInvocableTest {
    
    public static testMethod void jobMilestoneUpdationTest(){
        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
		System.runAs(u){
            
            SPEN_WorkCategory__c wc = SPEN_TestDataUtility.createWorkCategoryRecord('Test WC','SPD');
			List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Draft','Yes',wc.Id,'create job through Email',1);
            job[0].SPEN_LicenseArea__c = 'SPD';
            job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
            job[0].SPEN_District__c='Lanarkshire';
            job[0].SPEN_BusinessArea__c='Finance';
			Database.insert(job);
            Id parentId;
            Date parentEndDate=system.today()+5;
            Date plannedStartDay= system.today()+1;
            List<SPEN_Job_Milestone__c> jobMS = SPEN_TestDataUtility.createJobMilestoneRecord('Yes','TestJM',job[0].Id,parentId,'Yes',2,0,1,parentEndDate,plannedStartDay,1,True);
            Database.insert(jobMS);
            jobMS[0].SPEN_Status__c='Completed';
            jobMS[0].SPEN_Planned_Start_Date__c=System.Today();
            jobMS[0].SPEN_Actual_Start_Date__c=System.Today()+1;
            jobMS[0].SPEN_Planned_End_Date__c=System.Today()+4;
            jobMS[0].SPEN_Actual_End_Date__c=System.Today()+4;
            Database.update(jobMS);
			
			List<SPEN_Job_Milestone__c> parentJMs = SPEN_TestDataUtility.createJobMilestoneRecord('Yes','TestJM0',job[0].Id,jobMS[0].id,'Yes',2,2,1,parentEndDate,plannedStartDay,1,True);
			Database.insert(parentJMs);
			if(parentJMs!= null){
				List<SPEN_Job_Milestone__c> ChildJMs = SPEN_TestDataUtility.createJobMilestoneRecord('Yes','TestJM1',job[0].Id,parentJMs[0].id,'Yes',2,1,0,parentEndDate,plannedStartDay,1,True );
                Database.insert(ChildJMs);
                if(ChildJMs!= null){
                    List<SPEN_Job_Milestone__c> ChildofChildJMs = SPEN_TestDataUtility.createJobMilestoneRecord('Yes','TestJM2',job[0].Id,ChildJMs[0].id,'Yes',2,0,2,parentEndDate,plannedStartDay,1,False );
                	Database.insert(ChildofChildJMs);
                }
			}
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
				List<SPEN_MilestoneUpdationInvocable.SPEN_CreateMilestoneRequest> milestoneReq = new List<SPEN_MilestoneUpdationInvocable.SPEN_CreateMilestoneRequest>();
				SPEN_MilestoneUpdationInvocable.SPEN_CreateMilestoneRequest req = new SPEN_MilestoneUpdationInvocable.SPEN_CreateMilestoneRequest();					
				SPEN_Job_Milestone__c jobObjMil = [select id,SPEN_Status__c, SPEN_Job__c,SPEN_Actual_Start_Date__c,SPEN_Actual_End_Date__c,SPEN_Planned_End_Date__c,SPEN_Planned_Start_Date__c
                                                   ,SPEN_Planned_lead_time_Days__c,SPEN_Delay_Start_Days__c,SPEN_ParentJobMilestone__c from SPEN_Job_Milestone__c  where Id =: jobMS[0].id];
            	
            	req.jobMilestoneObj = jobObjMil ;
				req.action = 'Update';
				milestoneReq.add(req);
				List<SPEN_MilestoneUpdationInvocable.SPEN_CreateMilestoneResult> mResult = SPEN_MilestoneUpdationInvocable.UpdateChildMilestones(milestoneReq);
            	
			Test.stopTest();                
			system.assertNotEquals(mResult[0].milestonesResult, null, 'Job Milestones not Updated') ;
			
		}
        
        
    }	

}