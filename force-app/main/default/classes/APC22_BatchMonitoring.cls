public without sharing class APC22_BatchMonitoring {
    
    public List<AOBatchMonitoringRecipient__c> emails {get;set;}
    public Id emailId{get;set;}
    public Datetime querytime = System.now().addHours(-24);
    public Datetime schquerytime = System.now().addHours(-1);
    public DateTime currentTime = System.now();
    public DateTime endTimeTracker = System.now().addDays(16);
    public String newEmail {get;set;}
    public  PageReference addNewEmail(){
        
            if(newEmail != null){
                AOBatchMonitoringRecipient__c evM=new 	AOBatchMonitoringRecipient__c(name=newEmail,EmailId__c=newEmail);
                insert evM;
            }
            newEmail='';
            getBatchMonitoringEmailIds();
            return null;
        } 
    public PageReference removeEmail(){
        if(emailId != null){
            AOBatchMonitoringRecipient__c evM=[Select Id
                                                from AOBatchMonitoringRecipient__c
                                                where Id=: emailId
                                                LIMIT 1];
            delete evM;
        }
        emailId=null;
        getBatchMonitoringEmailIds();
        return null;
    } 
    public APC22_BatchMonitoring(){
        getBatchMonitoringEmailIds();
    }
    Public List<Asyncapexjob> queryres
    {
        get{
            // getting data from AssyncApexjob object/
            return [Select ApexClass.Name, MethodName,JobType,ExtendedStatus,createddate,CompletedDate,TotalJobItems,NumberOfErrors,status
                    from AsyncApexJob
                    Where 
                    (JobType ='ScheduledApex' and createddate> :querytime and completeddate<= :schquerytime and Status='failed')
                    OR
                    (Jobtype in ('BatchApex') and completeddate> :querytime and completeddate<= :currentTime and Status in ('Failed','Completed'))
                    Order by NumberOfErrors desc,status desc
                    limit 999
                   ];
        }
        set;
    }
    Public List<CronTrigger > query
    {
        get
        {
            return [select CronJobDetail.Name, CronJobDetail.Jobtype, EndTime , createdby.name, TimesTriggered
                    from CronTrigger where CronJobDetail.Jobtype in ('9','7') and endtime not in (null) and endtime<= :endTimeTracker and endtime>= :currentTime
                   order by endtime
                   limit 999];
        }
        set;
    }
    
    public void getBatchMonitoringEmailIds() {
        emails= [Select EmailId__c
                 FROM AOBatchMonitoringRecipient__c
                 LIMIT 20];
        
    }
    
    public void sendmail(){
        List<String> toEmailId=new List<String>();
        for(AOBatchMonitoringRecipient__c aoEmailId : [Select EmailId__c FROM AOBatchMonitoringRecipient__c LIMIT 20]) {
            toEmailId.add(aoEmailId.EmailId__c);
        }
        if(toEmailId.size()>0){
            EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE Name ='BatchMonitoringTemplate'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            List<OrgWideEmailAddress> alertSender=[SELECT Id 
                                                   FROM OrgWideEmailAddress 
                                                   WHERE Address ='no.reply@adeccogroup.com' limit 1];
            if(alertSender != null && alertSender.size()>0){
                email.setOrgWideEmailAddressId(alertSender[0].Id);
            }
            //EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE Name ='BatchMonitoringTemplate'];
            email.setTemplateId(et.id);
            email.setSubject(et.subject);
            email.setHTMLBody(et.Body);
            email.setTargetObjectId(Userinfo.getUserId());
            email.setToAddresses(toEmailId);
            email.setTreatTargetObjectAsRecipient(false);
            email.setSaveAsActivity(false);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        }
    }
    public void sendenddateemail(){
        List<String> toEmail=new List<String>();
        for(AOBatchMonitoringRecipient__c aoEmailId : [Select EmailId__c FROM AOBatchMonitoringRecipient__c LIMIT 20]) {
            toEmail.add(aoEmailId.EmailId__c);
        }
         if(!query.isempty() && query.size()>0 && toEmail.size()>0){
             EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE Name ='BatchSchEndDateTracker'];
             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
             List<OrgWideEmailAddress> alertSender=[SELECT Id 
                                                   FROM OrgWideEmailAddress 
                                                   WHERE Address ='no.reply@adeccogroup.com' limit 1];
            if(alertSender != null && alertSender.size()>0){
                email.setOrgWideEmailAddressId(alertSender[0].Id);
            }
            //EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE Name ='BatchMonitoringTemplate'];
            email.setTemplateId(et.id);
            email.setSubject(et.subject);
            email.setHTMLBody(et.Body);
            email.setTargetObjectId(Userinfo.getUserId());
            email.setToAddresses(toEmail);
            email.setTreatTargetObjectAsRecipient(false);
            email.setSaveAsActivity(false);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        }
         }
}