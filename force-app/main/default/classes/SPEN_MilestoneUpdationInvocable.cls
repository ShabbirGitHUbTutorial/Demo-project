/* File Name: SPEN_MilestoneCreationInvocable 
 * Description: The given code is a global class named SPEN_MilestoneUpdationInvocable to update job milestone as per job milestone based on different conditions.
 * Author: ajay.chandraferi 
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Aug-14-2023     Ajay Chandraferi      Initial version
 *
 * Additional Information:
 * ESC-103 : updation on milestone
 */
global class SPEN_MilestoneUpdationInvocable {

    /* @mapParentJMIdListChildJMs 
        key : Id of SPEN_Job__c or SPEN_JobMilestone__c
        value :  list of child SPEN_JobMilestone__c
    */                  
    global static  map<Id, list<SPEN_Job_Milestone__c>> mapParentJMIdListChildJMs = new map<Id, list<SPEN_Job_Milestone__c>>();       
    /* @mapJMIdJobMilestone
        key : Id of SPEN_JobMilestone__c
        value :  SPEN_Job_Milestone__c record to be updated
    */                  
    global static map<Id, SPEN_Job_Milestone__c> mapJMIdJobMilestone = new map<Id, SPEN_Job_Milestone__c>(); 
	global static Integer deltaDelayDays;
	global static BusinessHours businessHourObj;
    @InvocableMethod(label = 'Milestone Updation' description = 'Returns job record with milestones')
    global static List < SPEN_CreateMilestoneResult> UpdateChildMilestones(List <SPEN_CreateMilestoneRequest> milestoneReq) {
        List < SPEN_CreateMilestoneResult > oMilestoneResult = new List < SPEN_CreateMilestoneResult > ();
        if (!milestoneReq.isEmpty()) {
            businessHourObj = [SELECT Id FROM BusinessHours WHERE name = 'Connection Business Hours'];            
            SPEN_CreateMilestoneRequest req = milestoneReq[0];
            SPEN_CreateMilestoneResult res = new SPEN_CreateMilestoneResult();           
            switch on req.action {
                when 'Update' {
                    if(req.jobMilestoneObj != null){                          
                        getJobMilestoneHierarchy(req.jobMilestoneObj.SPEN_Job__c);
                        //  Job milestones records to be updated
                        updateChildMilestonesforJM(req.jobMilestoneObj, req.jobConsentingMilestoneId);
                    }  
                        
                    // Update child Job Milestones for job milestone
                    if(mapJMIdJobMilestone != null && mapJMIdJobMilestone.size() > 0){                                              
                        list<SPEN_Job_Milestone__c> listChilJMstobeUpdated=  mapJMIdJobMilestone.values();                        
                        update listChilJMstobeUpdated;
                        res.milestonesResult = listChilJMstobeUpdated;
                    } 
                }
            } 
            oMilestoneResult.add(res);
                    
        } 
        return oMilestoneResult;
    }
    
    
    global static void getJobMilestoneHierarchy (Id jobObjId ){
        for(SPEN_Job_Milestone__c  jm: [Select id,SPEN_Actual_End_Date__c,SPEN_Actual_Start_Date__c,SPEN_Delay_Start_Days__c,SPEN_Job__c,
                    SPEN_Milestone__c,SPEN_ParentJobMilestone__c,SPEN_Planned_End_Date__c,SPEN_Planned_lead_time_Days__c,SPEN_Planned_Start_Date__c,SPEN_Status__c
                    FROM SPEN_Job_Milestone__c WHERE SPEN_Job__c =:jobObjId AND SPEN_Milestone_Type__c != 'Planning task' ORDER BY SPEN_ParentJobMilestone__c DESC]){ 
            if(jm.SPEN_ParentJobMilestone__c != null){
                List < SPEN_Job_Milestone__c > childJMs = mapParentJMIdListChildJMs.get(jm.SPEN_ParentJobMilestone__c);
                if (childJMs != null) {
                    childJMs.add(jm);
                } else {
                    childJMs = new List <SPEN_Job_Milestone__c>();
                    childJMs.add(jm);
                    mapParentJMIdListChildJMs.put(jm.SPEN_ParentJobMilestone__c, childJMs);
                }
            }else{
                List < SPEN_Job_Milestone__c > newListJMs = mapParentJMIdListChildJMs.get(jm.SPEN_Job__c);
                if (newListJMs != null) {
                    newListJMs.add(jm);
                } else {
                    newListJMs = new list<SPEN_Job_Milestone__c>();
                    newListJMs.add(jm);
                    mapParentJMIdListChildJMs.put(jm.SPEN_ParentJobMilestone__c,newListJMs);
                }
            }            
        }        
    }   

    global static void updateChildMilestonesforJM(SPEN_Job_Milestone__c currentJM, String consentingMilestoneId){
        // Get Delay Period of existing Job MIlestone on Initial Level                                
        List < SPEN_Job_Milestone__c > listJMs = mapParentJMIdListChildJMs.get(currentJM.id);
        if(listJMs != null){
            updateChildMilestonesforJMs(listJMs,currentJM.SPEN_Actual_End_Date__c,true, consentingMilestoneId);            
        }   
    }

    global static void updateChildMilestonesforJMs(List < SPEN_Job_Milestone__c > listJMs, Date parentEndDate, Boolean isInitiatedLevel, String cMilestoneId){
              
        if(listJMs != null){                        
            for(SPEN_Job_Milestone__c jmObj : listJMs){ 
                if(String.isBlank(cMilestoneId) ||jmObj.Id != cMilestoneId){
                    Boolean isChildReplanRequired  = updateJobMilestone(jmObj,parentEndDate, isInitiatedLevel);
                    mapJMIdJobMilestone.put(jmObj.Id, jmObj);
                    if(isChildReplanRequired){
                        list<SPEN_Job_Milestone__c> listChildJMs  =  mapParentJMIdListChildJMs.get(jmObj.Id);                     
                         updateChildMilestonesforJMs(listChildJMs,jmObj.SPEN_Planned_End_Date__c,false,cMilestoneId);
                    } 
                }
               
            }
        }        
    }

   
    
    global static Boolean updateJobMilestone(SPEN_Job_Milestone__c newJobMilestone, Date parentEndDate, Boolean isInitiatedLevel){
        // Update Planned End Date and Actual StartDate 
        Boolean needChildReplanning = false;
        
        if(isInitiatedLevel && newJobMilestone.SPEN_Delay_Start_Days__c==0){
            newJobMilestone.SPEN_Status__c ='In Progress';                  
            newJobMilestone.SPEN_Actual_Start_Date__c = parentEndDate;
            if(newJobMilestone.SPEN_Planned_Start_Date__c != newJobMilestone.SPEN_Actual_Start_Date__c){
                needChildReplanning = true;
                Integer addEndDateDays = Integer.valueOf(newJobMilestone.SPEN_Planned_lead_time_Days__c);
                if(businessHourObj != null){
                    DateTime endDate = SPEN_BusinessDaysCalculationUtil.addDays((Datetime) newJobMilestone.SPEN_Actual_Start_Date__c, addEndDateDays,businessHourObj.Id );               
                    newJobMilestone.SPEN_Planned_End_Date__c = Date.newInstance(endDate.year(), endDate.month(), endDate.day());
                }else{
                    newJobMilestone.SPEN_Planned_End_Date__c = newJobMilestone.SPEN_Actual_Start_Date__c.addDays(addEndDateDays); 
                }
            }                        
        }else{             
            
            if(parentEndDate != null){
                
                Integer addInitialDays = 1;
                if(newJobMilestone.SPEN_Delay_Start_Days__c != null){
                    addInitialDays += Integer.valueOf(newJobMilestone.SPEN_Delay_Start_Days__c);                    
                }
                Integer addEndDateDays = Integer.valueOf(newJobMilestone.SPEN_Planned_lead_time_Days__c);
                Date oldPlannedEndDate =  newJobMilestone.SPEN_Planned_End_Date__c;
                if(businessHourObj != null){   
                    DateTime startDate = SPEN_BusinessDaysCalculationUtil.addDays((Datetime) parentEndDate, addInitialDays,businessHourObj.Id );            
                    newJobMilestone.SPEN_Planned_Start_Date__c = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    DateTime endDate = SPEN_BusinessDaysCalculationUtil.addDays(startDate, addEndDateDays,businessHourObj.Id );               
                    newJobMilestone.SPEN_Planned_End_Date__c = Date.newInstance(endDate.year(), endDate.month(), endDate.day());
                }else{
                    newJobMilestone.SPEN_Planned_Start_Date__c = parentEndDate.addDays(addInitialDays);
                    newJobMilestone.SPEN_Planned_End_Date__c =  newJobMilestone.SPEN_Planned_Start_Date__c.addDays(addEndDateDays);
                } 
                if(oldPlannedEndDate != newJobMilestone.SPEN_Planned_End_Date__c ){
                    needChildReplanning = true;
                }
            } 
                
        } 
        return needChildReplanning;
    }
    
    
   
    global class SPEN_CreateMilestoneRequest {        
        @InvocableVariable(required = true)
        global String action;
        @InvocableVariable(required = true)
        global SPEN_Job_Milestone__c jobMilestoneObj;	
        @InvocableVariable(required = false)
        global String jobConsentingMilestoneId;
    }
    global class SPEN_CreateMilestoneResult {
               
        @InvocableVariable
        global list < SPEN_Job_Milestone__c > milestonesResult;        
    }
}