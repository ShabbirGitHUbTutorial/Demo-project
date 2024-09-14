/* File Name: SPEN_PlanningTaskCreationInvocable 
 * Description: The given code is a global class named SPEN_PlanningTaskCreationInvocable to create job milestone as Planning Task for a job milestone which is marked as in progress.
 * Author: ajay.chandraferi 
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Oct-10-2023     Ajay Chandraferi      Initial version
 *
 * Additional Information:
 * ESC-179 : Capture and report on field-level information on the planning records. 
 */
global class SPEN_PlanningTaskCreationInvocable {
    
    global static BusinessHours businessHourObj;
    global static SPEN_Job_Milestone__c jobMilestone;
   // global static SPEN_CreatePlanningTaskRequest req;
    
    @InvocableMethod(label = 'Planning Task Creation' description = 'Returns planning task as job milestones record')
    global static list <SPEN_CreatePlanningTaskResult> createPlanningTaskMilestones(list<SPEN_CreatePlanningTaskRequest> milestoneReq) {
        list <SPEN_CreatePlanningTaskResult> oMilestoneResult = new list <SPEN_CreatePlanningTaskResult> ();
        if (!milestoneReq.isEmpty()) {
            list <SPEN_Job_Milestone__c> planningTaskToBeInserted = new list<SPEN_Job_Milestone__c>();
            businessHourObj = [SELECT Id FROM BusinessHours WHERE name = 'Connection Business Hours'];                
            for(SPEN_CreatePlanningTaskRequest req : milestoneReq){                
                jobMilestone = req.jobmilestoneObj;
                SPEN_CreatePlanningTaskResult res = new SPEN_CreatePlanningTaskResult();            
                res.planningTaskResult = new list<SPEN_Job_Milestone__c>(); 
                if(req.wcmPlanningtasks != null){                
                    for(SPEN_WorkCategoryMilestone__c wcmPlanningTask : req.wcmPlanningtasks){
                        SPEN_Job_Milestone__c currPlanningTask = new SPEN_Job_Milestone__c();
                        fieldsAssignment(wcmPlanningTask, currPlanningTask, system.today());
                        res.planningTaskResult.add(currPlanningTask);
                        planningTaskToBeInserted.add(currPlanningTask);
                    }                    
                }
                oMilestoneResult.add(res);   
            }   
            if(planningTaskToBeInserted!= null && planningTaskToBeInserted.size() > 0){
                insert planningTaskToBeInserted;
            }                  
        }
        return oMilestoneResult;
    }
    
    global static void fieldsAssignment(SPEN_WorkCategoryMilestone__c wcmObj, SPEN_Job_Milestone__c newJobMilestone,Date planStartDate){   
        newJobMilestone.SPEN_Job__c =  jobMilestone.SPEN_Job__c;        
        newJobMilestone.SPEN_Milestone_Type__c= wcmObj.SPEN_Milestone_Type__c ;
        newJobMilestone.SPEN_Milestone__c = wcmObj.SPEN_Milestone__c;
        newJobMilestone.SPEN_Parent_Milestone__c = wcmObj.id;
        newJobMilestone.SPEN_ParentJobMilestone__c = jobMilestone.id;
        newJobMilestone.SPEN_ReasonforCreation__c = 'Predefined'; 
        newJobMilestone.SPEN_Delay_Start_Days__c = wcmObj.SPEN_DelayStart__c ;
        newJobMilestone.SPEN_Planned_lead_time_Days__c = wcmobj.SPEN_LeadTime__c ;       
        newJobMilestone.SPEN_Status__c ='New';
        Integer addInitialDays = 0;        
        if(wcmObj.SPEN_DelayStart__c != null){
            addInitialDays += Integer.valueOf(wcmObj.SPEN_DelayStart__c);                      
        }                  
        Integer addEndDateDays = addInitialDays+ Integer.valueOf(wcmObj.SPEN_LeadTime__c);
        if(businessHourObj != null){            
            DateTime startDate = SPEN_BusinessDaysCalculationUtil.addDays((Datetime) planStartDate, addInitialDays,businessHourObj.Id );            
            newJobMilestone.SPEN_Planned_Start_Date__c = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
            DateTime endDate = SPEN_BusinessDaysCalculationUtil.addDays((Datetime) planStartDate, addEndDateDays,businessHourObj.Id );               
            newJobMilestone.SPEN_Planned_End_Date__c = Date.newInstance(endDate.year(), endDate.month(), endDate.day());
        }else{
            newJobMilestone.SPEN_Planned_Start_Date__c = planStartDate.addDays(addInitialDays);
            newJobMilestone.SPEN_Planned_End_Date__c = planStartDate.addDays(addEndDateDays);
        }
    }
    global class SPEN_CreatePlanningTaskRequest {        
        @InvocableVariable(required = true)
        global SPEN_Job_Milestone__c jobmilestoneObj;       
        @InvocableVariable
        global List<SPEN_WorkCategoryMilestone__c> wcmPlanningtasks;
    }
    global class SPEN_CreatePlanningTaskResult {                
        @InvocableVariable
        global list < SPEN_Job_Milestone__c > planningTaskResult;        
    }
    
    
}