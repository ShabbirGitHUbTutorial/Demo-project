public without sharing class APC21_ChartController {
    //Select LicenseDefinitionKey, MasterLabel, Name, TotalLicenses, UsedLicenses from UserLicense where MasterLabel IN ('Salesforce','Customer Community Plus')
    public TabData fs {get;set;}
    public TabData ds {get;set;}
    public TabData sfLicn {get;set;}
    public TabData commLicn {get;set;}
    public TabData wfemail {get;set;}
    public TabData apiReq {get;set;}
    public TabData async {get;set;}
    public TabData flexjob {get;set;}
    public TabData workflow {get;set;}
    public TabData singleEmail {get;set;}
    public List<TabData> lims {get;set;}
    public static String mailbody='';
    public static String mailbody2='';
    public List<EventMonitoring__c> evnts {get;set;}
    public List<AOEventMonitoringRecipients__c> emails {get;set;}
    public Id emailId{get;set;}
    
    public String newEmail {get;set;}
    //Certification Expiry Notification
    public String expiryStatus {get;set;}
	public Certificate_Notification_Setting__c certInfo {get;set;}
    
    public PageReference removeEmail(){
        if(emailId != null){
            AOEventMonitoringRecipients__c evM=[Select Id
                                                from AOEventMonitoringRecipients__c
                                                where Id=: emailId
                                                LIMIT 1];
            delete evM;
        }
        emailId=null;
        getEventMonitoringEmailIds();
        return null;
    } 
    // Certification Expiry Notification
    public void getCertificatinConfiguration(){
        certInfo = Certificate_Notification_Setting__c.getOrgDefaults();
        Boolean b = FetchOrgCertificate.getORGCertificate(false);
        expiryStatus = (b == true) ? 'Yes' : 'No';
    }
   public PageReference saveCertconfig(){
       if(certInfo.First_Notification__c <= certInfo.Second_Notification__c){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Certificate_First_Notification_Error));
       }else if(certInfo.Second_Notification__c <= certInfo.Third_Notification__c){
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,string.format(Label.Certificate_Second_Notification_Error, new String[]{String.valueOf(Integer.valueOf(certInfo.Third_Notification__c))})));
       }else{
           try{
               update certInfo;
           }catch(Exception e){
               throw e;
           }
           PageReference pageRef = new pageReference('/apex/VFP21_EM_Charts'); 
           pageRef.setRedirect(true);
           return pageRef; 
       }
       return null;
   }
    public PageReference addNewEmail(){
        try{
            if(newEmail != null){
                AOEventMonitoringRecipients__c evM=new AOEventMonitoringRecipients__c(name=newEmail,EmailId__c=newEmail);
                insert evM;
            }
            newEmail='';
            getEventMonitoringEmailIds();
            return null;
        }catch(exception e){
            throw e;
        }
        
    } 
    public APC21_ChartController(){
        getEventMonitoringEmailIds();
        getFileStorage();
        getDataStorage();
        getSFLicenseUsage();
        getAPIUsage();
        getWorkflowEmailUsage();
        getCommLicenseUsage();
        getAsyncUsage();
        getWorkflowUsage();
        getFlexJobUsage();
        getSingleEmailUsage();
        lims =new List<TabData>();
        lims.add(fs);
        lims.add(ds);
        lims.add(sfLicn);
        lims.add(apiReq);
        lims.add(commLicn);
        lims.add(async);
        lims.add(flexjob);
        lims.add(workflow);
        lims.add(wfemail);
        lims.add(singleEmail);
        getEventMonitoring();
        getCertificatinConfiguration();
    }
    public PageReference testAction(){
        for(EventMonitoring__c ev: evnts){
            if(ev.Name.contains('Data Storage')){
                Map<String,decimal> res=calculateDataStorage();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
                
            }else if(ev.Name.contains('File Storage')){
                Map<String,decimal> res=calculateFileStorage();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
                
            }else if(ev.Name.contains('Salesforce License')){
                Map<String,decimal> res=calculateSFLIcence();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
                
            }else if(ev.Name.contains('Daily API')){
                Map<String,decimal> res=calculateAPIRequest();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
                
            }else if(ev.Name.contains('Community License')){
                Map<String,decimal> res=calculateCommunityLIcence();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
                
            } else if(ev.Name.contains('Async Apex Job')){
                Map<String,decimal> res=calculateAsyncUsage();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
                
            } else if(ev.Name.contains('Hourly TimeBased Workflow Limit')){
                Map<String,decimal> res=calculateWorkflowUsage();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);           
                
            } else if(ev.Name.contains('ApexFlex Limit')){
                Map<String,decimal> res=calculateApexFlexJobUsage();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);           
                
            } else if(ev.Name.contains('Single Email Limit')){
                Map<String,decimal> res=calculatesSingleEmailLimit();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);           
                
            } else if(ev.Name.contains('Daily Workflow Emails')){
                Map<String,decimal> res=calculateWorkflowEmailUsage();
                ev.Total__c=res.get('total');
                ev.Usage__c=res.get('usage');
                ev.Consumption__c=res.get('usageP').setScale(2);
            }
        }
        try{
            update evnts;
        }catch(Exception e){
            system.debug('exception: '+ e);
        }
        return null;
    }
    public class TabData{
        public String name { get; set; }
        public String usage { get; set; }
        public String total { get; set; }
        public String consumption { get; set; }
        public String threshold {get;set;}
        
        public TabData(String name,String usage,String total,String consumption, String threshold){
            this.name=name;
            this.usage=usage;
            this.total=total;
            this.consumption=consumption;
            this.threshold=threshold;
        }
    }
    public void getEventMonitoring() {
        evnts= [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c
                FROM EventMonitoring__c
                LIMIT 10];
        
    }
    public void getEventMonitoringEmailIds() {
        emails= [Select EmailId__c
                 FROM AOEventMonitoringRecipients__c
                 LIMIT 20];
        
    }
    public PageReference saveEvent(){
        update evnts;
        return null;
    }
    
    // Wrapper class
    public class PieWedgeData {
        
        public String name { get; set; }
        public decimal data { get; set; }
        
        public PieWedgeData(String name, decimal data) {
            this.name = name;
            this.data = data;
        }
    } 
    
     public List<PieWedgeData> getWorkflowEmailUsage(){
         Map<String,decimal> res=calculateWorkflowEmailUsage();
        
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Usage  '+res.get('usage'), res.get('usageP')));
        data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage')), (100-res.get('usageP'))));
        return data;
    }
    
    private Map<String,decimal> calculateWorkflowEmailUsage() {
        Decimal workflowemailThreshold;
        for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Single Email Limit']){
                   workflowemailThreshold = ev.Threshhold_Limit__c;
        }
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        System.OrgLimit dataStorageLimit = limitsMap.get('DailyWorkflowEmails');
        decimal dsUsage = dataStorageLimit.getValue();
        decimal dstotal = dataStorageLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', dsUsage);
        res.put('total', dstotal);
        res.put('usageP', (dsUsage*100)/dstotal);
        res.put('threshold', workflowemailThreshold);
        wfemail = new TabData('Workflow Email Usage', (dsUsage+''), (dstotal +' '), ((((dsUsage*100)/dstotal).setScale(2))+' %'), (workflowemailThreshold+''));
        mailbody = mailbody + TBL_ROW_DT_START_TAG +wfemail.name + TBL_ROW_DT_MID_TAG +wfemail.usage+ TBL_ROW_DT_MID_TAG +wfemail.total+ TBL_ROW_DT_MID_TAG +wfemail.consumption+TBL_ROW_DT_MID_TAG+wfemail.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2 = TBL_ROW_DT_START_TAG +wfemail.name + TBL_ROW_DT_MID_TAG +wfemail.usage+ TBL_ROW_DT_MID_TAG +wfemail.total+ TBL_ROW_DT_MID_TAG +wfemail.consumption+TBL_ROW_DT_MID_TAG+wfemail.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    
        
    public List<PieWedgeData> getSingleEmailUsage() {
         Map<String,decimal> res=calculatesSingleEmailLimit();
      List<PieWedgeData> data = new List<PieWedgeData>(); 
      data.add(new PieWedgeData('Usage  '+res.get('usage')+'', res.get('usageP')));
      data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage'))+'', (100-res.get('usageP'))));
      return data;
    }
    
    public Map<String,decimal> calculatesSingleEmailLimit() {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        Decimal singleEmailThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Single Email Limit']){
                   singleEmailThreshold = ev.Threshhold_Limit__c;
         }
        System.OrgLimit singleEmailLimit = limitsMap.get('SingleEmail');
        decimal singleEmailUsage = singleEmailLimit.getValue();
        decimal singleEmailtotal = singleEmailLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', singleEmailUsage);
        res.put('total', singleEmailtotal);
        res.put('usageP', (singleEmailUsage*100)/singleEmailtotal);
        res.put('threshold', singleEmailThreshold);
        singleEmail = new TabData('Single Email Limit', (singleEmailUsage+''), (singleEmailtotal +''), (((singleEmailUsage*100)/singleEmailtotal).setScale(2)+' %'), (singleEmailThreshold+''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +singleEmail.name + TBL_ROW_DT_MID_TAG +singleEmail.usage+ TBL_ROW_DT_MID_TAG +singleEmail.total+ TBL_ROW_DT_MID_TAG +singleEmail.consumption+TBL_ROW_DT_MID_TAG+ singleEmail.threshold + TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +singleEmail.name + TBL_ROW_DT_MID_TAG +singleEmail.usage+ TBL_ROW_DT_MID_TAG +workflow.total+ TBL_ROW_DT_MID_TAG +singleEmail.consumption+TBL_ROW_DT_MID_TAG+ singleEmail.threshold + TBL_ROW_DT_END_TAG;
        return res;
    }
	
    public List<PieWedgeData> getWorkflowUsage() {
         Map<String,decimal> res=calculateWorkflowUsage();
      List<PieWedgeData> data = new List<PieWedgeData>(); 
      data.add(new PieWedgeData('Usage  '+res.get('usage')+'', res.get('usageP')));
      data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage'))+'', (100-res.get('usageP'))));
      return data;
    }
        
    public Map<String,decimal> calculateWorkflowUsage() {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        Decimal workflowUsageThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Hourly TimeBased Workflow Limit']){
                   workflowUsageThreshold = ev.Threshhold_Limit__c;
         }
        System.OrgLimit workFlowLimit = limitsMap.get('HourlyTimeBasedWorkflow');
        decimal workflowUsage = workFlowLimit.getValue();
        decimal workflowtotal = workFlowLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', workflowUsage);
        res.put('total', workflowtotal);
        res.put('usageP', (workflowUsage*100)/workflowtotal);
        res.put('threshold', workflowUsageThreshold);
        workflow = new TabData('Hourly TimeBased Workflow Limit', (workflowUsage+''), (workflowtotal +''), (((workflowUsage*100)/workflowtotal).setScale(2)+' %'), (workflowUsageThreshold+''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +workflow.name + TBL_ROW_DT_MID_TAG +workflow.usage+ TBL_ROW_DT_MID_TAG +workflow.total+ TBL_ROW_DT_MID_TAG +workflow.consumption+TBL_ROW_DT_MID_TAG+workflow.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +workflow.name + TBL_ROW_DT_MID_TAG +workflow.usage+ TBL_ROW_DT_MID_TAG +workflow.total+ TBL_ROW_DT_MID_TAG +workflow.consumption+TBL_ROW_DT_MID_TAG+workflow.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    public list<PieWedgeData> getFlexJobUsage() {
      Map<String,decimal> res=calculateApexFlexJobUsage();
      List<PieWedgeData> data = new List<PieWedgeData>(); 
      data.add(new PieWedgeData('Usage  '+res.get('usage')+'', res.get('usageP')));
      data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage'))+'', (100-res.get('usageP'))));
      return data;
    }
    
	 private Map<String,decimal> calculateApexFlexJobUsage() {
         AggregateResult[] apexFlexCount = [SELECT COUNT(Id)countId FROM AsyncApexJob WHERE Status = 'Holding'];
           Decimal apexFlexThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'ApexFlex Limit']){
                   apexFlexThreshold = ev.Threshhold_Limit__c;
         }
        decimal flexUsage =0;
        decimal flextotal =100;
       
        flexUsage = (decimal) apexFlexCount[0].get('countId');
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', flexUsage);
        res.put('total', flextotal);
        res.put('usageP', (flexUsage*100)/flextotal);
        res.put('threshold', apexFlexThreshold);
        flexjob = new TabData('ApexFlex Limit', (flexUsage+''), (flextotal +''), (((flexUsage*100)/flextotal).setScale(2)+' %'), (apexFlexThreshold +''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +flexjob.name + TBL_ROW_DT_MID_TAG +flexjob.usage+ TBL_ROW_DT_MID_TAG +flexjob.total+ TBL_ROW_DT_MID_TAG +flexjob.consumption+TBL_ROW_DT_MID_TAG+flexjob.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +flexjob.name + TBL_ROW_DT_MID_TAG +flexjob.usage+ TBL_ROW_DT_MID_TAG +flexjob.total+ TBL_ROW_DT_MID_TAG +flexjob.consumption+TBL_ROW_DT_MID_TAG+flexjob.threshold+ TBL_ROW_DT_END_TAG;
        return res;
       
     } 
    
    public List<PieWedgeData> getAsyncUsage() {
        Map<String,decimal> res=calculateAsyncUsage();
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Usage '+res.get('usage')+'', res.get('usageP')));
        data.add(new PieWedgeData('Free '+(res.get('total')-res.get('usage'))+'', (100-res.get('usageP'))));
        return data;
    }
    private Map<String,decimal> calculateAsyncUsage() {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
            Decimal asyncThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Async Apex Job']){
                   asyncThreshold = ev.Threshhold_Limit__c;
         }
        System.OrgLimit asyncLimit = limitsMap.get('DailyAsyncApexExecutions');
        decimal AsyncUsage = asyncLimit.getValue();
        decimal Asyntotal = asyncLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', AsyncUsage);
        res.put('total', Asyntotal);
        res.put('usageP', (AsyncUsage*100)/Asyntotal);
        res.put('threshold', (asyncThreshold));
        async = new TabData('Async Apex Job', (AsyncUsage+''), (Asyntotal +''), (((AsyncUsage*100)/Asyntotal).setScale(2)+' %'), (asyncThreshold+ ''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +async.name + TBL_ROW_DT_MID_TAG +async.usage+ TBL_ROW_DT_MID_TAG +async.total+ TBL_ROW_DT_MID_TAG +async.consumption+TBL_ROW_DT_MID_TAG+async.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +async.name + TBL_ROW_DT_MID_TAG +async.usage+ TBL_ROW_DT_MID_TAG +async.total+ TBL_ROW_DT_MID_TAG +async.consumption+TBL_ROW_DT_MID_TAG+async.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    
    public List<PieWedgeData> getFileStorage() {
        Map<String,decimal> res=calculateFileStorage();
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Usage  '+res.get('usage')+' MB', res.get('usageP')));
        data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage'))+' MB', (100-res.get('usageP'))));
        return data;
    }
    private Map<String,decimal> calculateFileStorage() {
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
          Decimal fileStorgeThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'File Storage Usage (MB)']){
                   fileStorgeThreshold = ev.Threshhold_Limit__c;
         }
        System.OrgLimit fileStorageLimit = limitsMap.get('FileStorageMB');
        decimal flUsage = fileStorageLimit.getValue();
        decimal fltotal = fileStorageLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', flUsage);
        res.put('total', fltotal);
        res.put('usageP', (flUsage*100)/fltotal);
        res.put('threshold',(fileStorgeThreshold));
        fs = new TabData('File Storage Usage (MB)', (flUsage+' MB'), (fltotal +' MB'), (((flUsage*100)/fltotal).setScale(2)+' %'), (fileStorgeThreshold + ''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +fs.name + TBL_ROW_DT_MID_TAG +fs.usage+ TBL_ROW_DT_MID_TAG +fs.total+ TBL_ROW_DT_MID_TAG +fs.consumption+TBL_ROW_DT_MID_TAG+fs.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +fs.name + TBL_ROW_DT_MID_TAG +fs.usage+ TBL_ROW_DT_MID_TAG +fs.total+ TBL_ROW_DT_MID_TAG +fs.consumption+TBL_ROW_DT_MID_TAG+fs.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }   
    
    public List<PieWedgeData> getDataStorage() {
        Map<String,decimal> res=calculateDataStorage();
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Usage  '+res.get('usage')+' MB', res.get('usageP')));
        data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage'))+' MB', (100-res.get('usageP'))));
        return data;
    }
    private Map<String,decimal> calculateDataStorage() {
        
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        Decimal dtThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Data Storage Usage (MB)']){
                   dtThreshold = ev.Threshhold_Limit__c;
         }
        System.OrgLimit dataStorageLimit = limitsMap.get('DataStorageMB');
        decimal dsUsage = dataStorageLimit.getValue();
        decimal dstotal = dataStorageLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', dsUsage);
        res.put('total', dstotal);
        res.put('usageP', (dsUsage*100)/dstotal);
        res.put('threshold', dtThreshold);
        ds = new TabData('Data Storage Usage (MB)', (dsUsage+' MB'), (dstotal +' MB'), (((dsUsage*100)/dstotal).setScale(2)+' %'), (dtThreshold  + ''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +ds.name + TBL_ROW_DT_MID_TAG +ds.usage+ TBL_ROW_DT_MID_TAG +ds.total+ TBL_ROW_DT_MID_TAG +ds.consumption+TBL_ROW_DT_MID_TAG+ds.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +ds.name + TBL_ROW_DT_MID_TAG +ds.usage+ TBL_ROW_DT_MID_TAG +ds.total+ TBL_ROW_DT_MID_TAG +ds.consumption+TBL_ROW_DT_MID_TAG+ds.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    public List<PieWedgeData> getAPIUsage() {
        Map<String,decimal> res=calculateAPIRequest();
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Usage  '+res.get('usage')+' ', res.get('usageP')));
        data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage'))+' ', (100-res.get('usageP'))));
        return data;
    }
    private Map<String,decimal> calculateAPIRequest() {
        
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();
        Decimal apiThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Daily API Usage']){
                   apiThreshold = ev.Threshhold_Limit__c;
         }
        System.OrgLimit dataStorageLimit = limitsMap.get('DailyApiRequests');
        decimal dsUsage = dataStorageLimit.getValue();
        decimal dstotal = dataStorageLimit.getLimit();
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', dsUsage);
        res.put('total', dstotal);
        res.put('usageP', (dsUsage*100)/dstotal);
        res.put('threshold',apiThreshold);
        apiReq = new TabData('Daily API Usage', (dsUsage+''), (dstotal +' '), ((((dsUsage*100)/dstotal).setScale(2))+' %'), (apiThreshold+''));
        mailbody = mailbody + TBL_ROW_DT_START_TAG +apiReq.name + TBL_ROW_DT_MID_TAG +apiReq.usage+ TBL_ROW_DT_MID_TAG +apiReq.total+ TBL_ROW_DT_MID_TAG +apiReq.consumption+TBL_ROW_DT_MID_TAG+apiReq.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2 = TBL_ROW_DT_START_TAG +apiReq.name + TBL_ROW_DT_MID_TAG +apiReq.usage+ TBL_ROW_DT_MID_TAG +apiReq.total+ TBL_ROW_DT_MID_TAG +apiReq.consumption+TBL_ROW_DT_MID_TAG+apiReq.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    
    public List<PieWedgeData> getSFLicenseUsage() {
        Map<String,decimal> res=calculateSFLIcence();
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Usage  '+res.get('usage'), res.get('usageP')));
        data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage')), (100-res.get('usageP'))));
        return data;
    }
    private Map<String,decimal> calculateSFLIcence(){
        List<UserLicense> sfLic=[Select LicenseDefinitionKey, MasterLabel, Name, TotalLicenses, UsedLicenses
                                 from UserLicense
                                 where MasterLabel ='Salesforce'
                                 LIMIT 1];
        Decimal sfLicThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Salesforce License Usage']){
                   sfLicThreshold = ev.Threshhold_Limit__c;
         }
        decimal dsUsage = sfLic[0].UsedLicenses;
        decimal dstotal = sfLic[0].TotalLicenses;
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', dsUsage);
        res.put('total', dstotal);
        res.put('usageP', ((dsUsage*100)/dstotal).setScale(2));
        res.put('threshold',sfLicThreshold);
        sfLicn = new TabData('Salesforce License Usage', (dsUsage+''), (dstotal +''), (((dsUsage*100)/dstotal).setScale(2)+' %' ), (sfLicThreshold+''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +sfLicn.name + TBL_ROW_DT_MID_TAG +sfLicn.usage+ TBL_ROW_DT_MID_TAG +sfLicn.total+ TBL_ROW_DT_MID_TAG +sfLicn.consumption +TBL_ROW_DT_MID_TAG+sfLicn.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +sfLicn.name + TBL_ROW_DT_MID_TAG +sfLicn.usage+ TBL_ROW_DT_MID_TAG +sfLicn.total+ TBL_ROW_DT_MID_TAG +sfLicn.consumption +TBL_ROW_DT_MID_TAG+ sfLicn.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    //Line No 468, 471, 472 are commented out for Certificate Exp Monioting as there are no community licences in this org
    public List<PieWedgeData> getCommLicenseUsage() {
        //Map<String,decimal> res=calculateCommunityLIcence();
        
        List<PieWedgeData> data = new List<PieWedgeData>();
        //data.add(new PieWedgeData('Usage  '+res.get('usage'), res.get('usageP')));
        //data.add(new PieWedgeData('Free  '+(res.get('total')-res.get('usage')), (100-res.get('usageP'))));
        return data;
    }
    private Map<String,decimal> calculateCommunityLIcence(){
       // List<UserLicense> sfLic=[Select LicenseDefinitionKey, MasterLabel, Name, TotalLicenses, UsedLicenses from UserLicense where MasterLabel like '%Community%' LIMIT 10];
        AggregateResult[] groupedResultsSum = [Select SUM(TotalLicenses)totalusage
                                               from UserLicense
                                               where MasterLabel like '%Community%'];
        
         Decimal commLicThreshold;
         for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c where Name = 'Community License']){
                   commLicThreshold = ev.Threshhold_Limit__c;
         }
        decimal dsUsage =0;
        decimal dstotal =0;
//        integer size=[Select Id From User Where Profile.UserLicense.LicenseDefinitionKey LIKE 'PID_Customer_Community%' AND
//                      isActive= true].size();
        AggregateResult[] groupedResultsCount = [Select Count(Id)reccount
                                                 From User
                                                 Where Profile.UserLicense.LicenseDefinitionKey LIKE 'PID_Customer_Community%'
                                                 AND isActive= true];
/*        
        for(UserLicense lic : sfLic){
            //dsUsage += sfLic[0].UsedLicenses;
            dstotal += sfLic[0].TotalLicenses;
        }
*/
        dstotal = (decimal) groupedResultsSum[0].get('totalusage');
        dsUsage = (decimal) groupedResultsCount[0].get('reccount');
        Map<String,decimal> res=new Map<String,decimal>();
        res.put('usage', dsUsage);
        res.put('total', dstotal);
        res.put('usageP', (dsUsage*100)/dstotal);
        res.put('threshold', commLicThreshold);
        commLicn = new TabData('Community License Usage', (dsUsage+''), (dstotal +''), (((dsUsage*100)/dstotal).setScale(2)+' %'), (commLicThreshold+''));
        mailbody=mailbody + TBL_ROW_DT_START_TAG +commLicn.name + TBL_ROW_DT_MID_TAG +commLicn.usage+ TBL_ROW_DT_MID_TAG +commLicn.total+ TBL_ROW_DT_MID_TAG +commLicn.consumption+TBL_ROW_DT_MID_TAG+commLicn.threshold+ TBL_ROW_DT_END_TAG;
        mailbody2= TBL_ROW_DT_START_TAG +commLicn.name + TBL_ROW_DT_MID_TAG +commLicn.usage+ TBL_ROW_DT_MID_TAG +commLicn.total+ TBL_ROW_DT_MID_TAG +commLicn.consumption+TBL_ROW_DT_MID_TAG+commLicn.threshold+ TBL_ROW_DT_END_TAG;
        return res;
    }
    
    public static void sendEmail(){
        mailbody=HEADER_START_TAG+System.Label.CountryTitle +'|' +UserInfo.getOrganizationId() + TBL_START_TAG + 'Name' + TBL_ROW_HD_MID_TAG + 'Usage' + TBL_ROW_HD_MID_TAG + 'Total'+ TBL_ROW_HD_MID_TAG + 'Consumption' + TBL_ROW_HD_MID_TAG + 'Threshold' + TBL_ROW_HD_END_TAG;
        List<String> toEmailId=new List<String>();
        for(AOEventMonitoringRecipients__c aoEmailId : [Select EmailId__c FROM AOEventMonitoringRecipients__c LIMIT 20]) {
            toEmailId.add(aoEmailId.EmailId__c);
        }  
        if(toEmailId.size()>0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toEmailId);
            email.setSaveAsActivity(false);
            APC21_ChartController pc=new APC21_ChartController();
            email.setHtmlBody(mailbody);
            email.setSubject(System.Label.DailyMonitoring+system.now());
            List<OrgWideEmailAddress> alertSender=[SELECT Id 
                                                   FROM OrgWideEmailAddress 
                                                   WHERE Address =: Label.OrgWideEmail limit 1];
            if(alertSender != null && alertSender.size()>0){
                email.setOrgWideEmailAddressId(alertSender[0].Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
           
    }
    
    private static final String HEADER_START_TAG = '<h2 style="color:Purple;background:yellow;"><u>';
    private static final String TBL_START_TAG = '</u></h2><br/><table style="width:100%" border="1"><tr><th>';
    private static final String TBL_ROW_HD_START_TAG = '<tr><th>';
    private static final String TBL_ROW_HD_MID_TAG = '</th><th>';
    private static final String TBL_ROW_HD_END_TAG = '</th></tr>';
    private static final String TBL_ROW_DT_START_TAG = '<tr><td>';
    private static final String TBL_ROW_DT_MID_TAG = '</td><td>';
    private static final String TBL_ROW_DT_END_TAG = '</td></tr>';
    private static final String TBL_END_TAG = '</table><BR/><hr>';
    private static final String HEADER_START_TAG_P = '<h2 style="color:White;background:red;"><u>';
    
    
    public static void sendPriorityEmail(String evntName,String mailHTMLBody){
        List<String> toEmailId=new List<String>();
        for(AOEventMonitoringRecipients__c aoEmailId : [Select EmailId__c FROM AOEventMonitoringRecipients__c LIMIT 20]) {
            toEmailId.add(aoEmailId.EmailId__c);
        }
        if(toEmailId.size()>0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toEmailId);
            email.setSaveAsActivity(false);
            email.setEmailPriority('Highest');
            APC21_ChartController pc=new APC21_ChartController();
            email.setHtmlBody(mailHTMLBody);
            email.setSubject(System.Label.PriorityMonitoring+evntName+'|'+system.now());
            List<OrgWideEmailAddress> alertSender=[SELECT Id 
                                                   FROM OrgWideEmailAddress 
                                                   WHERE Address =: Label.OrgWideEmail limit 1];
            if(alertSender != null && alertSender.size()>0){
                email.setOrgWideEmailAddressId(alertSender[0].Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
          
    }
    
    public void priorityCheck(){
        String textbody=HEADER_START_TAG_P+System.Label.CountryTitle +'|' +UserInfo.getOrganizationId() + TBL_START_TAG + 'Name' + TBL_ROW_HD_MID_TAG + 'Usage' + TBL_ROW_HD_MID_TAG + 'Total'+ TBL_ROW_HD_MID_TAG + 'Consumption' + TBL_ROW_HD_MID_TAG + 'Threshold' +  TBL_ROW_HD_END_TAG;
        for(EventMonitoring__c ev: [Select Name, isActive__c, total__c, usage__c, consumption__c, Threshhold_Limit__c FROM EventMonitoring__c LIMIT 10]){
            if(ev.Name.contains('Data Storage')){
                Map<String,decimal> res=calculateDataStorage();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.label.DSEvent,(textbody+mailbody2));
                }
            }else if(ev.Name.contains('File Storage')){
                Map<String,decimal> res=calculateFileStorage();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail( System.Label.FSEvent ,(textbody+mailbody2));
                }
            }else if(ev.Name.contains('Salesforce License')){
                Map<String,decimal> res=calculateSFLIcence();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.SLEvent,(textbody+mailbody2));
                }
            }else if(ev.Name.contains('Daily API')){
                Map<String,decimal> res=calculateAPIRequest();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.APIEvent ,(textbody+mailbody2));
                }
            }else if(ev.Name.contains('Community License')){
                Map<String,decimal> res=calculateCommunityLIcence();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.CommLicense ,(textbody+mailbody2));
                }
            } else if(ev.Name.contains('Async Apex Job')){
                Map<String,decimal> res=calculateAsyncUsage();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.AsyncApex ,(textbody+mailbody2));
                }
            } else if(ev.Name.contains('Hourly TimeBased Workflow Limit')){  
                Map<String,decimal> res=calculateWorkflowUsage();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.WorkflowLimit ,(textbody+mailbody2));
                }
            } else if(ev.Name.contains('ApexFlex Limit')){     
                Map<String,decimal> res=calculateApexFlexJobUsage();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.ApexFlexLimit ,(textbody+mailbody2));
                }
            } else if(ev.Name.contains('Single Email Limit')){     
                Map<String,decimal> res=calculatesSingleEmailLimit	();
                if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                    sendPriorityEmail(System.Label.SingleEmailLimit ,(textbody+mailbody2));
                }
            } else if(ev.Name.contains('Daily Workflow Emails')){
                Map<String,decimal> res=calculateWorkflowEmailUsage();
                 if(ev.isActive__c && ev.Threshhold_Limit__c <= res.get('usageP').setScale(2)){
                sendPriorityEmail(System.Label.WorkflowEmailLimit ,(textbody+mailbody2));
                }
            }
           
        }
    }
}