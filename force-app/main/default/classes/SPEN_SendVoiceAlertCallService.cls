/*-----------------------------------------------------------------------------
DESCRIPTION :   Service Class to...
LIBRARY     :   SPEN
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
-----------------------------------------------------------------------------*/
public with sharing class SPEN_SendVoiceAlertCallService 
{
    @AuraEnabled(cacheable=true)
    public static Id alertService(List<Id> recId, String vcAlertTemplt)
    {
        Id jobId; 
        /*try 
        {
            /*List<SPEN_IVROperatingHours__c> Listivr = [SELECT Id,SPEN_isActive__c, SPEN_isDaily__c,SPEN_StartTime__c, SPEN_EndTime__c,SPEN_RestrictStartDate__c, 
                                                       SPEN_RestrictEndDate__c FROM SPEN_IVROperatingHours__c
                                                       WHERE SPEN_isActive__c = true AND RecordType.Name = 'Outbound Contact Hours'];
            for(SPEN_IVROperatingHours__c ivr : Listivr)
            {
                if(ivr.SPEN_isDaily__c){
                    if(ivr.SPEN_StartTime__c < ivr.SPEN_EndTime__c)
                    {
                        if((system.now().time()<ivr.SPEN_StartTime__c && system.now().time()<ivr.SPEN_EndTime__c) || (system.now().time()>ivr.SPEN_StartTime__c && system.now().time()>ivr.SPEN_EndTime__c))
                        {
                            jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatch(recId,vcAlertTemplt));                            
                        }                        
                    }
                    else if(ivr.SPEN_EndTime__c < ivr.SPEN_StartTime__c)
                    {
                        if(system.now().time()<ivr.SPEN_StartTime__c && system.now().time()>ivr.SPEN_EndTime__c)
                        {
                            jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatch(recId,vcAlertTemplt));                              
                        }
                        
                    }
                    else
                    {
                        jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatch(recId,vcAlertTemplt));   
                    }
                }
                else {
                    system.debug('In main else of is daily');
                    If(system.now()<ivr.SPEN_RestrictStartDate__c || system.now()>ivr.SPEN_RestrictEndDate__c){
                        system.debug('In daily false ----'+'----'+ivr.SPEN_isDaily__c+'----'+system.now().time()+'----'+ivr.SPEN_RestrictStartDate__c+'----'+ivr.SPEN_RestrictEndDate__c);
                        //SPEN_InsertVoiceAlertBatch insertVABatch = new SPEN_InsertVoiceAlertBatch(recId,vcAlertTemplt);
                        jobId = database.executeBatch(new SPEN_InsertVoiceAlertBatch(recId,vcAlertTemplt));
                    }
                }
            }*/
            return jobId; 
        /*}
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            return jobId; 
        }*/
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean scheduleAlertService(List<Id> recId, String vcAlertTemplt, DateTime scTime)
    {
        Boolean isInOutboundContactHours = false;
        /*try{
            /*system.debug('recId');
            system.debug('vcAlertTemplt:'+vcAlertTemplt);
            system.debug('scTime:'+scTime);
            system.debug('listOfIdPSR:'+recId);
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
                            SPEN_SchedulableVoiceAlertClass sVA = new SPEN_SchedulableVoiceAlertClass(recId,vcAlertTemplt,scTime);
                            
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
                            SPEN_SchedulableVoiceAlertClass sVA = new SPEN_SchedulableVoiceAlertClass(recId,vcAlertTemplt,scTime);
                            
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
                        SPEN_SchedulableVoiceAlertClass sVA = new SPEN_SchedulableVoiceAlertClass(recId,vcAlertTemplt,scTime);
                        
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
                        SPEN_SchedulableVoiceAlertClass sVA = new SPEN_SchedulableVoiceAlertClass(recId,vcAlertTemplt,scTime);
                        
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
            //throw ex;
            return isInOutboundContactHours;
        }*/
    }
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id batchJobId){
        AsyncApexJob jobInfo;// = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchJobId];
        return jobInfo;
    }
}