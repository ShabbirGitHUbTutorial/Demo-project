/* File Name: SPEN_MilestoneCreationInvocable 
 * Description: The given code is a global class named SPEN_MilestoneCreation to create job milestone as per job work category when job status changed to live.
 * Author: ajay.chandraferi 
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Aug-02-2023     Ajay Chandraferi      Initial version
 *
 * Additional Information:
 * ESC-67 : Create predefined milestone on Job based on Work category on job
 */
global class SPEN_MilestoneCreationInvocable {

    /* @mapPartenWCMIdListChildWCMs 
        key : Id of SPEN_WorkCategory__c or SPEN_WorkCategoryMilestone__c
        value :  list of child SPEN_WorkCategoryMilestone__c
    */                  
    global static  map<Id, list<SPEN_WorkCategoryMilestone__c>> mapPartenWCMIdListChildWCMs = new map<Id, list<SPEN_WorkCategoryMilestone__c>>();       
    /* @mapWCMIdJobMilestone
        key : Id of SPEN_WorkCategoryMilestone__c
        value :  SPEN_Job_Milestone__c record to be created
    */                  
    global static map<Id, SPEN_Job_Milestone__c> mapWCMIdJobMilestone = new map<Id, SPEN_Job_Milestone__c>(); 
	global static SPEN_Job__c jobRecord;
    global static Boolean isJobUpdate;
	global static BusinessHours businessHourObj;
    global static SPEN_WorkCategoryMilestone__c selectedWCM;
    global static SPEN_CreateMilestoneRequest req;
    @InvocableMethod(label = 'Milestone Creation' description = 'Returns job record with milestones')
    global static List < SPEN_CreateMilestoneResult> createPredefinedMilestones(List <SPEN_CreateMilestoneRequest> milestoneReq) {
        List < SPEN_CreateMilestoneResult > oMilestoneResult = new List < SPEN_CreateMilestoneResult > ();
        if (!milestoneReq.isEmpty()) {
            businessHourObj = [SELECT Id FROM BusinessHours WHERE name = 'Connection Business Hours'];            
            req = milestoneReq[0];
            SPEN_CreateMilestoneResult res = new SPEN_CreateMilestoneResult();
            jobRecord = req.jobObj;
            res.jobResult = req.jobObj;
            res.milestonesResult = new list<SPEN_Job_Milestone__c>();
            switch on req.action {
                when 'Create' {
                    Id workCategoryId ;
                    isJobUpdate = false;
                    set<Id> setAssociatedWCIds = new set<Id>();
                    SPEN_WorkCategory__c jobCategoryObj ;
                    if(req.jobObj != null && req.jobObj.SPEN_WorkCategory__c!= null){ 

                        if(req.jobObj.SPEN_SubCategory__c != null){
                            workCategoryId = req.jobObj.SPEN_SubCategory__c;
                        }else{
                            workCategoryId = req.jobObj.SPEN_WorkCategory__c;
                        }                        
                        // get all work category milestones related to job work categories
                        if(workCategoryId != null){
                            SPEN_WorkCategory__c workCategoryObj = [select id, SPEN_ParentWorkCategory__c, SPEN_Description__c,SPEN_LicenseArea__c,Name 
                            FROM SPEN_WorkCategory__c WHERE id=:workCategoryId];
                            getWorkMilestoneHierarchy(workCategoryObj.id);
                            // Initiate Job milestones records to be created
                        	createJobMilestonesforWC(workCategoryObj);                            
                            if(isJobUpdate){
                               update jobRecord;                                
                            }
                          
                        }                          
                        // Create Job Milestones for Job Work category/Sub Category
                        if(mapWCMIdJobMilestone != null && mapWCMIdJobMilestone.size() > 0){
                            res.milestonesResult = mapWCMIdJobMilestone.values();
                        }
                	}
                }
                when 'Cancelled' {
                    SPEN_WorkCategory__c cancellationWC = [select id, SPEN_ParentWorkCategory__c, SPEN_Description__c,SPEN_LicenseArea__c,Name from SPEN_WorkCategory__c where Id = :System.Label.SPEN_WorkCategoryCancellationId];                    
                    Id workCategoryId ;
                    if(cancellationWC != null){                    
                        getWorkMilestoneHierarchy(cancellationWC.id);
                        // Initiate Job milestones records to be created
                    	createJobMilestonesforWC(cancellationWC);
                    }     
                    // Create Job Milestones for Job Work category
                    system.debug('mapWCMIdJobMilestone'+mapWCMIdJobMilestone);
                    if(mapWCMIdJobMilestone != null && mapWCMIdJobMilestone.size() > 0){                                              
                        res.milestonesResult =  mapWCMIdJobMilestone.values(); 
                    }               	
                }
                when 'CreateManualWCMilestones'{
                     if(req.jobObj != null && req.wcmObj!= null){ 
                     	getManualWorkMilestoneHierarchy(req.wcmObj.SPEN_WorkCategory__c, req.wcmObj.id);
                        List<SPEN_WorkCategoryMilestone__c> listWCMilestones = new list<SPEN_WorkCategoryMilestone__c>();
                        listWCMilestones.add(req.wcmObj);
                        req.wcmObj.SPEN_DelayStart__c = 0;
                     	createJobMilestonesforWCMs(listWCMilestones,true);                     
                     }
                     // Create Job Milestones for Job Work category/Sub Category
                    if(mapWCMIdJobMilestone != null && mapWCMIdJobMilestone.size() > 0){
                        res.milestonesResult = mapWCMIdJobMilestone.values();
                    }
                }
                when else{
                    
                }
            }
            oMilestoneResult.add(res);
                    
        } 
        return oMilestoneResult;
    }
    
                                                                                 
    global static void getWorkMilestoneHierarchy (Id workCatObjId){
    list<SPEN_WorkCategoryMilestone__c> listWCMs =  [Select id,SPEN_LeadTime__c,SPEN_Milestone__c,SPEN_DelayStart__c,
                    SPEN_ParentMilestone__c,SPEN_Milestone_Type__c,
                    SPEN_WorkCategory__c, SPEN_WorkCategory__r.Name,SPEN_JobMilestoneType__c
                    FROM SPEN_WorkCategoryMilestone__c WHERE SPEN_WorkCategory__c=:workCatObjId
                                                         AND SPEN_Predefined_Milestone__c= 'Yes'
                                                        AND SPEN_Milestone_Type__c IN:SPEN_ConstantData.MLIESTONETYPE_LIST 
                                                 ORDER BY SPEN_ParentMilestone__c DESC];
        if(listWCMs != null){
            populateWorkMilestoneHierarchy(listWCMs, null);
        } 		
    }
    
    global static void getManualWorkMilestoneHierarchy (Id workCatObjId, Id currentWCMId){
    list<SPEN_WorkCategoryMilestone__c> listWCMs =  [Select id,SPEN_LeadTime__c,SPEN_Milestone__c,SPEN_DelayStart__c,
                    SPEN_ParentMilestone__c,SPEN_Milestone_Type__c,
                    SPEN_WorkCategory__c, SPEN_WorkCategory__r.Name,SPEN_JobMilestoneType__c
                    FROM SPEN_WorkCategoryMilestone__c WHERE SPEN_WorkCategory__c=:workCatObjId AND SPEN_Milestone_Type__c != 'Planning task' ORDER BY SPEN_ParentMilestone__c DESC];

        if(listWCMs != null){
            populateWorkMilestoneHierarchy(listWCMs, currentWCMId);
        } 		
    }
    
                                                                                 
    global static void populateWorkMilestoneHierarchy (List<SPEN_WorkCategoryMilestone__c> lstWCMs, Id currentWCMId){       
        for(SPEN_WorkCategoryMilestone__c  wcm: lstWCMs){ 
            if(currentWCMId != null && currentWCMId == wcm.Id){
            	req.wcmObj = wcm;                
            }
            if(wcm.SPEN_ParentMilestone__c != null){
                List < SPEN_WorkCategoryMilestone__c > childWCMs = mapPartenWCMIdListChildWCMs.get(wcm.SPEN_ParentMilestone__c);
                if (childWCMs != null) {
                    childWCMs.add(wcm);
                } else {
                    childWCMs = new List <SPEN_WorkCategoryMilestone__c>();
                    childWCMs.add(wcm);
                    mapPartenWCMIdListChildWCMs.put(wcm.SPEN_ParentMilestone__c, childWCMs);
                }
            }else{
                List < SPEN_WorkCategoryMilestone__c > newListWCMs = mapPartenWCMIdListChildWCMs.get(wcm.SPEN_WorkCategory__c);
                if (newListWCMs != null) {
                    newListWCMs.add(wcm);
                } else {
                    newListWCMs = new list<SPEN_WorkCategoryMilestone__c>();
                    newListWCMs.add(wcm);
                    mapPartenWCMIdListChildWCMs.put(wcm.SPEN_WorkCategory__c,newListWCMs);
                }
            }
        }         
    }
    
    global static void createJobMilestonesforWCMs(List < SPEN_WorkCategoryMilestone__c > listWCMs){
        createJobMilestonesforWCMs(listWCMs, false);
    }
    global static void createJobMilestonesforWCMs(List < SPEN_WorkCategoryMilestone__c > listWCMs, Boolean isInitial){
        //collect all related child work category ids which is associated with job work category        
        list<SPEN_Job_Milestone__c> jobMilestonestobCreated = new list<SPEN_Job_Milestone__c>();
        SPEN_Job_Milestone__c planningMilestone ; 
        SPEN_Job_Milestone__c consentingMilestone ;
        Boolean isJobUpdatesNeeded = false;
        if(listWCMs != null){
            for(SPEN_WorkCategoryMilestone__c wcmObj : listWCMs){
                SPEN_Job_Milestone__c parentJobMilestone ;
                if(wcmObj.SPEN_ParentMilestone__c != null && !isInitial){                    
                    parentJobMilestone = mapWCMIdJobMilestone.get(wcmObj.SPEN_ParentMilestone__c);
                }
                SPEN_Job_Milestone__c jMilestone;
                if(req.Action == 'CreateManualWCMilestones'){
                    jMilestone = createJobMilestone(wcmObj,parentJobMilestone,req.plannedStartDate, 'New' );
                }else{
                    jMilestone = createJobMilestone(wcmObj,parentJobMilestone);
                    if(wcmObj.SPEN_JobMilestoneType__c == 'Planning' && jMilestone!= null){
                        planningMilestone = jMilestone;                        
                        isJobUpdatesNeeded = true;
                    }else if(wcmObj.SPEN_JobMilestoneType__c == 'Consenting' && jMilestone!= null){
                        consentingMilestone = jMilestone;
                        isJobUpdatesNeeded = true;                        
                    }
                }
                jobMilestonestobCreated.add(jMilestone);
                mapWCMIdJobMilestone.put(wcmObj.Id, jMilestone);  
                
            }
            insert jobMilestonestobCreated;
            if(isJobUpdatesNeeded){
                if(planningMilestone != null){
					jobRecord.SPEN_PlanningMilestone__c = planningMilestone.Id;
                }
                if(consentingMilestone != null){
					jobRecord.SPEN_ConsentingMilestone__c = consentingMilestone.Id;
                }
                isJobUpdate =true;
            }
            list<SPEN_WorkCategoryMilestone__c> listAllChildWCMs = new list<SPEN_WorkCategoryMilestone__c>();
            for(SPEN_WorkCategoryMilestone__c wcmObj : listWCMs){
                list<SPEN_WorkCategoryMilestone__c> listChildWCMs  =  mapPartenWCMIdListChildWCMs.get(wcmObj.Id);               
                if(listChildWCMs != null){
                    listAllChildWCMs.addAll(listChildWCMs);
                }
            }
            if(listAllChildWCMs != null && listAllChildWCMs.size() > 0){
                createJobMilestonesforWCMs(listAllChildWCMs);
            }
        }     
    }
    
    global static SPEN_Job_Milestone__c  createJobMilestone(SPEN_WorkCategoryMilestone__c wcmObj, SPEN_Job_Milestone__c parentJobMilestone){
        
        String status='In Progress';
        if(wcmObj.SPEN_DelayStart__c >0)
        {
            status='New';
        }
        return createJobMilestone(wcmobj,parentJobMilestone, System.today(), status);
    }
    
    global static SPEN_Job_Milestone__c  createJobMilestone(SPEN_WorkCategoryMilestone__c wcmObj, SPEN_Job_Milestone__c parentJobMilestone,  Date planStartDate, String ParentStatus){
        
        SPEN_Job_Milestone__c newJobMilestone = new SPEN_Job_Milestone__c();        
        newJobMilestone.SPEN_Job__c =  jobRecord.id ;        
        newJobMilestone.SPEN_Milestone_Type__c= wcmObj.SPEN_Milestone_Type__c ;
        newJobMilestone.SPEN_Milestone__c = wcmObj.SPEN_Milestone__c;
        newJobMilestone.SPEN_Parent_Milestone__c = wcmObj.id;
        newJobMilestone.SPEN_ReasonforCreation__c = 'Predefined';       
        if(parentJobMilestone!= null){
            newJobMilestone.SPEN_ParentJobMilestone__c = parentJobMilestone.id;
        }        
    
        
        newJobMilestone.SPEN_Delay_Start_Days__c = wcmObj.SPEN_DelayStart__c ;
        newJobMilestone.SPEN_Planned_lead_time_Days__c = wcmobj.SPEN_LeadTime__c ;         
        Integer addInitialDays = 0;
        if(parentJobMilestone != null){            
            planStartDate = parentJobMilestone.SPEN_Planned_End_Date__c;
            addInitialDays += 1;
            newJobMilestone.SPEN_Status__c ='New';
        }     
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
        if(parentJobMilestone == null){ 
            newJobMilestone.SPEN_Status__c = ParentStatus;
            if(wcmObj.SPEN_DelayStart__c==0)
            {
                newJobMilestone.SPEN_Actual_Start_Date__c = newJobMilestone.SPEN_Planned_Start_Date__c;
            }
            
        }  
        return newJobMilestone;
    }
    
    global static void createJobMilestonesforWC(SPEN_WorkCategory__c workCategory){
        List < SPEN_WorkCategoryMilestone__c > listWCMs = mapPartenWCMIdListChildWCMs.get(workCategory.id);
        if(listWCMs != null){
            createJobMilestonesforWCMs(listWCMs);            
        }       
    }
   
    global class SPEN_CreateMilestoneRequest {        
        @InvocableVariable(required = true)
        global String action;
        @InvocableVariable(required = true)
        global SPEN_Job__c jobObj;	
        @InvocableVariable
        global SPEN_WorkCategoryMilestone__c wcmObj;
        @InvocableVariable
        global Date plannedStartDate;
    }
    global class SPEN_CreateMilestoneResult {
        @InvocableVariable
        global SPEN_Job__c jobResult;        
        @InvocableVariable
        global list < SPEN_Job_Milestone__c > milestonesResult;        
    }
}