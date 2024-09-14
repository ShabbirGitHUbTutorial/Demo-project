/*-----------------------------------------------------------------------------
DESCRIPTION :   This class is written to create Test Data for test classes for LNP
AUTHOR      :   Rajat Mishra
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
Jul-18-2023     Rajat Mishra       Initial version

-----------------------------------------------------------------------------*/

@IsTest
public with sharing class SPEN_TestDataUtility {
    
    /**********************************************************************************************
* @Author:      Rajat Mishra
* @Date:        07/18/2023
* @Description: Method to specifically create Test User based on the Profile passed as parameter from test classes.   
***********************************************************************************************/
    public static User createuser(String profileName){
        User testUser=new  User();
        if(String.isNotBlank(profileName)){
            
            Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
            
            testUser= new User(Alias = 'standt',
                               Email='standarduser@testorg.com',
                               Username='standarduser@testorg.com.lnp',
                               LastName='stndrdUser',
                               TimeZoneSidKey='Europe/London',
                               LocaleSidKey='en_GB',
                               EmailEncodingKey='UTF-8',
                               ProfileId= p.Id,
                               LanguageLocaleKey='en_US');
        }
        return testUser;
    }
    
    /**********************************************************************************************
* @Author:      Rajat Mishra
* @Date:        07/18/2023
* @Description: Method to specifically create SFBG_WorkCategory__c record from test classes.   
***********************************************************************************************/    
    public static SPEN_WorkCategory__c createWorkCategoryRecord(){
        
        SPEN_WorkCategory__c wc = new SPEN_WorkCategory__c();       
        wc.Name = 'Test';
        insert wc;
        return wc;
    }

    public static SPEN_WorkCategory__c createWorkCategoryRecord(String description, String licenseArea){        
        SPEN_WorkCategory__c wc = new SPEN_WorkCategory__c();
        wc.SPEN_Description__c= description;
        wc.SPEN_LicenseArea__c = licenseArea;
        wc.Name = 'Test';
        wc.SPEN_WorkCategoryTitle__c='CCT Customer Contact Enquiry';
        wc.SPEN_LeadTime__c=1;
        insert wc;
        return wc;
    }
    
    /**********************************************************************************************************************
    * @Author:      Rajat Mishra
    * @Date:        07/18/2023
    * @Description: Method to specifically create List of Job(SPEN_Job__c) records based on parameter passed from test classes.   
    ***************************************************************************************************************************/ 
    public static List<SPEN_Job__c> createJobRecord(string jobstatus,String PlanningReq,Id workCategory,
                                                    String Description,Integer recCount){
                                                        List<SPEN_Job__c> testJob = new List<SPEN_Job__c>();
                                                        SPEN_Job__c job;
                                                        Integer i=0;
                                                        while(i< recCount){
                                                            job = new SPEN_Job__c();
                                                            job.SPEN_JobStatus__c = jobstatus;
                                                            //job.OwnerId =queueId ;
                                                            job.SPEN_PlanningRequired__c=PlanningReq;
                                                            job.SPEN_WorkCategory__c=workCategory;
                                                            job.SPEN_Description__c=Description;
                                                            testJob.add(job);
                                                            i++;
                                                        }
                                                        return testJob;
                                                    }
    
    /*************************************************************************
    * @Author:      Rajat Mishra
    * @Date:        07/18/2023
    * @Description: Method to specifically create Test record for group 
    ************************************************************************/    
    public static Group createtestGroup(String qName)
    {
        Group jobGroup= new Group();
        jobGroup.type='Queue';
        jobGroup.Name=qName;
        
        return jobGroup;
        
    }
    
    /*************************************************************************
    * @Author:      Rajat Mishra
    * @Date:        07/18/2023
    * @Description: Method to specifically create Test record for QueuesObject 
    ************************************************************************/    
    public static QueuesObject createQueueObj(Id QueueID,String SobjType)
    {
        QueuesObject qobj = new QueueSObject();
        qobj.QueueId=QueueID;
        qobj.SobjectType=SobjType;
        
        return qobj;
        
    }

     /**********************************************************************************************************************
    * @Author:      Ajay Chandraferi
    * @Date:        08/04/2023
    * @Description: Method to specifically create List of Job(SPEN_Job__c) records based on parameter passed from test classes.   
    ***************************************************************************************************************************/ 
    public static List<SPEN_WorkCategoryMilestone__c> createWorkCategoryMilestoneRecord(Id workcategory, String milestonetype,String predefine,
                Integer milestoneCount, Id parentWCM){
        List<SPEN_WorkCategoryMilestone__c> wcmlist = new List<SPEN_WorkCategoryMilestone__c>();
        SPEN_WorkCategoryMilestone__c wcm;
        Integer counter = 0;
        while(counter < milestoneCount){
            wcm = new SPEN_WorkCategoryMilestone__c();
            wcm.SPEN_LeadTime__c = counter+3;
            wcm.SPEN_Milestone__c = 'WCM_'+ workcategory + counter;
            wcm.SPEN_Milestone_Type__c = milestonetype;
           // wcm.SPEN_LandInterestMilestone__c = landInterestWCM;
            wcm.SPEN_ParentMilestone__c = parentWCM;
           // wcm.SPEN_PlanningMilestone__c = planningWCM;
            wcm.SPEN_WorkCategory__c = workcategory;
            wcm.SPEN_Predefined_Milestone__c = predefine;
            //job.OwnerId =queueId ;                                                            
            wcmlist.add(wcm);
            counter++;
        }
        return wcmlist;
    }
    
    /**********************************************************************************************************************
    * @Author:      Rajat Mishra
    * @Date:        08/15/2023
    * @Description: Method to specifically create List of Job MIlestone(SPEN_Job_Milestone__c) records based on parameter passed from test classes.   
    ***************************************************************************************************************************/ 
    
    public static List<SPEN_Job_Milestone__c> createJobMilestoneRecord(String plaMilestone,String Milestone,Id Jobobj,Id ParentJobId,
                                                    String landInterestMilestone,Integer ragYellow, Integer delayStartDays,Integer PlannedleadtimeDay,
                                                                       Date ParentEndDate,Date PlannedStartDate,Integer recCount,Boolean JMLevel){
                                                        List<SPEN_Job_Milestone__c> testJM = new List<SPEN_Job_Milestone__c>();
                                                        SPEN_Job_Milestone__c jobMS;
                                                        Integer i=0;
                                                        Boolean j=JMLevel;
                                                        while(i< recCount && j==JMLevel){
                                                            jobMS = new SPEN_Job_Milestone__c();
                                                            jobMS.SPEN_Job__c=Jobobj;
                                                            jobMS.SPEN_Milestone__c=Milestone;
                                                            jobMS.SPEN_Milestone_Type__c=landInterestMilestone;
                                                            jobMS.SPEN_RAG_Yellow__c=ragYellow;
                                                            jobMS.SPEN_ParentJobMilestone__c=ParentJobId;
                                                            jobMS.SPEN_Delay_Start_Days__c=delayStartDays;
                                                            jobMS.SPEN_Planned_lead_time_Days__c=PlannedleadtimeDay;
                                                            jobMS.SPEN_Planned_End_Date__c=ParentEndDate;
                                                            jobMS.SPEN_Planned_Start_Date__c=PlannedStartDate;
                                                            testJM.add(jobMS);
                                                            i++;
                                                        }
                                                        return testJM;
                                                    }


public static SPEN_DesignChecklistRequest__c createDesignChecklistRequestRecord(Id Job){        
        SPEN_DesignChecklistRequest__c dcr = new SPEN_DesignChecklistRequest__c();
        dcr.SPEN_Job__c=Job;
        dcr.SPEN_Status__c='Open';
        insert dcr;
        return dcr;
    }
    public static SPEN_DesignInformationTemplate__c createDesignInfoTemplateRec(String infoDetail){        
        SPEN_DesignInformationTemplate__c desInfTemp = new SPEN_DesignInformationTemplate__c();
        desInfTemp.SPEN_InformationDetail__c= infoDetail;
        desInfTemp.SPEN_DesignCategory__c ='TestDesignCategory';
        insert desInfTemp;
        return desInfTemp;
    }
    
    public static SPEN_CategoryDesignInformation__c createCategoryDesignInfo(Id workCategory, Id designInfoTemplate){        
        SPEN_CategoryDesignInformation__c catDesInfo = new SPEN_CategoryDesignInformation__c();
        catDesInfo.SPEN_WorkCategory__c= workCategory;
        catDesInfo.SPEN_DesignInformationTemplate__c= designInfoTemplate;
        insert catDesInfo;
        return catDesInfo;
    }
    
    public static SPEN_Land__c createLandRec(){        
        SPEN_Land__c landRec = new SPEN_Land__c();
        landRec.SPEN_Title__c = 'TestLandRec';
        insert landRec;
        return landRec;
    }

    public static SPEN_Condition__c createCondition(String landRight){        
        SPEN_Condition__c condRec = new SPEN_Condition__c();
        condRec.SPEN_LandInterest__c = LandRight;
        condRec.SPEN_Type__c = 'VEL0';
        condRec.SPEN_Unit__c = '2';
        insert condRec;
        return condRec;
    }
    
    public static SPEN_Land_Interest__c createLandIntRec(id Land, id Job){  
        Id landIntRecordTypeId = Schema.SObjectType.SPEN_Land_Interest__c.getRecordTypeInfosByName().get('Wayleave').getRecordTypeId();
        SPEN_Land_Interest__c landIntRec = new SPEN_Land_Interest__c();
        landIntRec.RecordTypeId = landIntRecordTypeId;
        landIntRec.SPEN_Land__c = Land;
        landIntRec.SPEN_Job__c = Job;
        landIntRec.SPEN_Land_Interest_Type__c='Owner';
        landIntRec.SPEN_ConsentType__c='Wayleave';
        landIntRec.SPEN_Contract_Start_Date__c=system.today();
        landIntRec.SPEN_Annual_Wayleave_Payment_Payable__c=system.today();
        insert landIntRec;
        return landIntRec;
    }
    
    public static SPEN_Planning__c createPlanningRec(String Status, Id job){        
        SPEN_Planning__c planningRec = new SPEN_Planning__c();
        planningRec.SPEN_Job__c = job;
        planningRec.SPEN_Status__c = Status;
        insert planningRec;
        return planningRec;
    }
    
    /**********************************************************************************************************************
    * @Author:      Anwesha Dey
    * @Date:        20/05/2024
    * @Description: Method to specifically create Vendor Account   
    ***************************************************************************************************************************/ 
    
    public static Account createVendorAccount()
    {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP RE Vendor').getRecordTypeId();
        Account vendorAccount=new Account();
        vendorAccount.SPEN_VendorNumber__c='12345';
        vendorAccount.Name='Test Account';
        vendorAccount.RecordTypeId=accountRecordTypeId;
        insert vendorAccount;
        return vendorAccount;
        
    }
    /**********************************************************************************************************************
    * @Author:      Anwesha Dey
    * @Date:        20/05/2024
    * @Description: Method to specifically create Vendor Land Contact   
    ***************************************************************************************************************************/ 
    public static SPEN_LandAssociation__c createVendorLandContact(Account vendorAccount, SPEN_Land__c land)
    {
        Id vendorLandContactRecordTypeId=Schema.SObjectType.SPEN_LandAssociation__c.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        SPEN_LandAssociation__c vendorLandContact=new SPEN_LandAssociation__c();
        vendorLandContact.RecordTypeId=vendorLandContactRecordTypeId;
        vendorLandContact.SPEN_Land__c=land.Id;
        vendorLandContact.SPEN_Vendor__c=vendorAccount.Id;
        vendorLandContact.SPEN_AssociationType__c='Owner';
        vendorLandContact.SPEN_Active__c=true;
        insert vendorLandContact;
        return vendorLandContact;
        
    }
    
}