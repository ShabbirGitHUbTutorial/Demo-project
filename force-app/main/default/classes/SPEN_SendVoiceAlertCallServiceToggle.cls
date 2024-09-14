@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class SPEN_SendVoiceAlertCallServiceToggle {
    @AuraEnabled(cacheable=true)
    public static Id alertServiceToggle(Id recId, String vcAlertTemplt,Boolean incPSRCheckbox,Boolean incCaseCheckbox,Boolean incAllCustCheckbox){
        Id jobId;
        /*try
        {
            Incident Inc=[select id,(select id,SPEN_CustomerMobileNumberFormula__c,SPEN_RelatedCustomerFormula__c,SPEN_PSRCheckFormula__c from Impacted_Premises__r where SPEN_PSRCheckFormula__c=True),(select id from cases__r) from Incident where id= :recId];
            List<SPEN_ImpactedPremise__c> ImPLst=new List<SPEN_ImpactedPremise__c>();
            List<Case> CaseLst=new List<Case>();
            if(!inc.Impacted_Premises__r.isEmpty()){
                ImPLst.addALL(inc.Impacted_Premises__r);
            }
            if(!inc.cases__r.isEmpty()){
                CaseLst.addALL(inc.cases__r);
            }
            ////ImPLst.add(inc.Impacted_Premises__r);
           // //CaseLst.add(inc.cases__r);
            Id jobId;
            List<SPEN_IVROperatingHours__c> Listivr = [SELECT Id,SPEN_isActive__c, SPEN_isDaily__c,SPEN_StartTime__c, SPEN_EndTime__c,SPEN_RestrictStartDate__c, 
                                                       SPEN_RestrictEndDate__c FROM SPEN_IVROperatingHours__c
                                                       WHERE SPEN_isActive__c = true AND RecordType.Name = 'Outbound Contact Hours'];
            for(SPEN_IVROperatingHours__c ivr : Listivr){
                If(ivr.SPEN_isDaily__c){
                    If(ivr.SPEN_StartTime__c < ivr.SPEN_EndTime__c)
                    {
                        If((system.now().time()<ivr.SPEN_StartTime__c && system.now().time()<ivr.SPEN_EndTime__c) || (system.now().time()>ivr.SPEN_StartTime__c && system.now().time()>ivr.SPEN_EndTime__c))
                        {  
                            if(!ImPLst.IsEmpty() && IncPSRCheckbox){
                                for(SPEN_ImpactedPremise__c spi:ImPLst){
                                    if(spi.SPEN_PSRCheckFormula__c){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchPSRToggle(recId,vcAlertTemplt));
                                    }
                                }
                            }
                            if(!CaseLst.IsEmpty() && IncCaseCheckbox){
                                jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchCaseToggle(recId,vcAlertTemplt));
                            }
                            if(Inc.Id!=Null && IncAllCustCheckbox){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchAllCusToggle(recId,vcAlertTemplt));
                            }
                        }                        
                    }
                    else if(ivr.SPEN_EndTime__c < ivr.SPEN_StartTime__c)
                    {
                        if(system.now().time()<ivr.SPEN_StartTime__c && system.now().time()>ivr.SPEN_EndTime__c)
                        {
                            if(!ImPLst.IsEmpty() && IncPSRCheckbox){
                                for(SPEN_ImpactedPremise__c spi:ImPLst){
                                    if(spi.SPEN_PSRCheckFormula__c){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchPSRToggle(recId,vcAlertTemplt));
                                    }
                                }
                            }
                            if(!CaseLst.IsEmpty() && IncCaseCheckbox){
                                jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchCaseToggle(recId,vcAlertTemplt));
                            }
                            if(Inc.Id!=Null && IncAllCustCheckbox){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchAllCusToggle(recId,vcAlertTemplt));
                            }
                        }
                        
                    }
                    else
                    {
                        if(!ImPLst.IsEmpty() && IncPSRCheckbox){
                                for(SPEN_ImpactedPremise__c spi:ImPLst){
                                    if(spi.SPEN_PSRCheckFormula__c){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchPSRToggle(recId,vcAlertTemplt));
                                    }
                                }
                            }
                            if(!CaseLst.IsEmpty() && IncCaseCheckbox){
                                jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchCaseToggle(recId,vcAlertTemplt));
                            }
                            if(Inc.Id!=Null && IncAllCustCheckbox){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchAllCusToggle(recId,vcAlertTemplt));
                            }
                    }
                }
                else {
                    system.debug('In main else of is daily');
                    If(system.now()<ivr.SPEN_RestrictStartDate__c || system.now()>ivr.SPEN_RestrictEndDate__c){
                        system.debug('In daily false ----'+'----'+ivr.SPEN_isDaily__c+'----'+system.now().time()+'----'+ivr.SPEN_RestrictStartDate__c+'----'+ivr.SPEN_RestrictEndDate__c);
                        //SPEN_InsertVoiceAlertBatch insertVABatch = new SPEN_InsertVoiceAlertBatch(recId,vcAlertTemplt);
                        if(!ImPLst.IsEmpty() && IncPSRCheckbox){
                                for(SPEN_ImpactedPremise__c spi:ImPLst){
                                    if(spi.SPEN_PSRCheckFormula__c){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchPSRToggle(recId,vcAlertTemplt));
                                    }
                                }
                            }
                            if(!CaseLst.IsEmpty() && IncCaseCheckbox){
                                jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchCaseToggle(recId,vcAlertTemplt));
                            }
                            if(Inc.Id!=Null && IncAllCustCheckbox){
                                    jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatchAllCusToggle(recId,vcAlertTemplt));
                            }
                    }
                }
            }*/
            return jobId; 
        /*}
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }*/
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean scheduleAlertServiceToggle(Id recId, String vcAlertTemplt, DateTime scTime,Boolean incPSRCheckbox,Boolean incCaseCheckbox,Boolean incAllCustCheckbox)
    {
        Boolean isInOutboundContactHours = false;
        /*try{
            system.debug('recId');
            system.debug('vcAlertTemplt:'+vcAlertTemplt);
            system.debug('scTime:'+scTime);
            system.debug('IncId:'+recId);
            system.debug('After call from button');
            
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            
            cron=second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
            
            
            List<SPEN_IVROperatingHours__c> Listivr = [SELECT Id,SPEN_isActive__c, SPEN_isDaily__c,SPEN_StartTime__c, SPEN_EndTime__c,SPEN_RestrictStartDate__c, 
                                                       SPEN_RestrictEndDate__c FROM SPEN_IVROperatingHours__c
                                                       WHERE SPEN_isActive__c = true AND RecordType.Name = 'Outbound Contact Hours'];
            system.debug('scTime.time()'+ scTime.time());
            
            for(SPEN_IVROperatingHours__c ivr:Listivr){
                system.debug('IsDaily:'+ivr.SPEN_isDaily__c+'SPEN_StartTime__c-----'+ivr.SPEN_StartTime__c+'SPEN_EndTime__c----'+ivr.SPEN_EndTime__c);
                If(ivr.SPEN_isDaily__c){
                    system.debug('In Is daily if');
                    If(ivr.SPEN_StartTime__c < ivr.SPEN_EndTime__c)
                    {
                        system.debug('start time less than end time');
                        If((scTime.time()<ivr.SPEN_StartTime__c && scTime.time()<ivr.SPEN_EndTime__c) || (scTime.time()>ivr.SPEN_StartTime__c && scTime.time()>ivr.SPEN_EndTime__c))
                            //If((system.now().time()<ivr.SPEN_StartTime__c && system.now().time()>ivr.SPEN_EndTime__c))
                        {
                            system.debug('In if ----'+'----'+ivr.SPEN_isDaily__c+'----'+system.now().time()+'----'+ivr.SPEN_StartTime__c+'----'+ivr.SPEN_EndTime__c);
                            SPEN_SchedulableVoiceAlertClassToggle sVA = new SPEN_SchedulableVoiceAlertClassToggle(recId,vcAlertTemplt,scTime,IncPSRCheckbox,IncCaseCheckbox,IncAllCustCheckbox);
                            
                            ID jobid = System.schedule('scheduledVoiceAlert'+System.now(), cron, sVA);
                            CronTrigger ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id = :jobid];
                            SPEN_CommunicationScheduler__c comScheduler =new SPEN_CommunicationScheduler__c();
                            comScheduler.SPEN_CommunicationSchedulerType__c = 'Voice alert';
                            comScheduler.SPEN_BatchJobId__c = jobid;
                            comScheduler.SPEN_BatchName__c = ct.CronJobDetail.Name;
                            comScheduler.SPEN_Status__c = 'Scheduled';
                            comScheduler.SPEN_ScheduledDateTime__c = scTime;
                            insert comScheduler;
                        }                        
                    }
                    else if(ivr.SPEN_EndTime__c < ivr.SPEN_StartTime__c)
                    {
                        system.debug('end time less than start time');
                        if((scTime.time()<ivr.SPEN_StartTime__c && scTime.time()>ivr.SPEN_EndTime__c) || Test.isRunningTest())
                        {
                            system.debug('In else if ----'+'----'+ivr.SPEN_isDaily__c+'----'+system.now().time()+'----'+ivr.SPEN_StartTime__c+'----'+ivr.SPEN_EndTime__c);
                            SPEN_SchedulableVoiceAlertClassToggle sVA = new SPEN_SchedulableVoiceAlertClassToggle(recId,vcAlertTemplt,scTime,IncPSRCheckbox,IncCaseCheckbox,IncAllCustCheckbox);
                            
                            ID jobid = System.schedule('scheduledVoiceAlert '+System.now(), cron, sVA);
                            CronTrigger ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id = :jobid];
                            SPEN_CommunicationScheduler__c comScheduler =new SPEN_CommunicationScheduler__c();
                            comScheduler.SPEN_CommunicationSchedulerType__c = 'Voice alert';
                            comScheduler.SPEN_BatchJobId__c = jobid;
                            comScheduler.SPEN_BatchName__c = ct.CronJobDetail.Name;
                            comScheduler.SPEN_Status__c = 'Scheduled';
                            comScheduler.SPEN_ScheduledDateTime__c = scTime;
                            insert comScheduler;
                        }
                        
                    }
                    else
                    {
                        system.debug('In else if ----'+'----'+ivr.SPEN_isDaily__c+'----'+system.now().time()+'----'+ivr.SPEN_StartTime__c+'----'+ivr.SPEN_EndTime__c);
                        SPEN_SchedulableVoiceAlertClassToggle sVA = new SPEN_SchedulableVoiceAlertClassToggle(recId,vcAlertTemplt,scTime,IncPSRCheckbox,IncCaseCheckbox,IncAllCustCheckbox);
                        
                        ID jobid = System.schedule('scheduledVoiceAlert '+System.now(), cron, sVA);
                        CronTrigger ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id = :jobid];
                        SPEN_CommunicationScheduler__c comScheduler =new SPEN_CommunicationScheduler__c();
                        comScheduler.SPEN_CommunicationSchedulerType__c = 'Voice alert';
                        comScheduler.SPEN_BatchJobId__c = jobid;
                        comScheduler.SPEN_BatchName__c = ct.CronJobDetail.Name;
                        comScheduler.SPEN_Status__c = 'Scheduled';
                        comScheduler.SPEN_ScheduledDateTime__c = scTime;
                        insert comScheduler;
                    }
                }
                else {
                    system.debug('In main else of is daily');
                    If(scTime<ivr.SPEN_RestrictStartDate__c || scTime>ivr.SPEN_RestrictEndDate__c){
                        system.debug('In daily false ----'+'----'+ivr.SPEN_isDaily__c+'----'+system.now().time()+'----'+ivr.SPEN_RestrictStartDate__c+'----'+ivr.SPEN_RestrictEndDate__c);
                        SPEN_SchedulableVoiceAlertClassToggle sVA = new SPEN_SchedulableVoiceAlertClassToggle(recId,vcAlertTemplt,scTime,IncPSRCheckbox,IncCaseCheckbox,IncAllCustCheckbox);
                        
                        ID jobid = System.schedule('scheduledVoiceAlert '+System.now(), cron, sVA);
                        CronTrigger ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id = :jobid];
                        SPEN_CommunicationScheduler__c comScheduler =new SPEN_CommunicationScheduler__c();
                        comScheduler.SPEN_CommunicationSchedulerType__c = 'Voice alert';
                        comScheduler.SPEN_BatchJobId__c = jobid;
                        comScheduler.SPEN_BatchName__c = ct.CronJobDetail.Name;
                        comScheduler.SPEN_Status__c = 'Scheduled';
                        comScheduler.SPEN_ScheduledDateTime__c = scTime;
                        insert comScheduler;
                    }
                }
            }*/
            return isInOutboundContactHours;
        /*}
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
            throw ex;
        }*/
    }
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id batchJobId){
        AsyncApexJob jobInfo; //= [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchJobId];
        return jobInfo;
    }

}