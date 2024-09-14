global with sharing class SPEN_SchedulableVoiceAlertClass implements Schedulable
{
    List<Id> psrIdLst=new List<Id>();
    String vcAlertMessage;
    datetime scheduleTime;
    
    public SPEN_SchedulableVoiceAlertClass(List<Id> psrId,String vcAlertTemplt,datetime scTime)
    {
        psrIdLst=psrId;
        vcAlertMessage=vcAlertTemplt;
		scheduleTime = scTime;
    }

    global void execute(SchedulableContext SC) 
    {
		SPEN_ScheduleVoiceAlertBatch scheduleBatch = new SPEN_ScheduleVoiceAlertBatch(psrIdLst,vcAlertMessage,scheduleTime);
       	Database.executeBatch(scheduleBatch);
    }
}