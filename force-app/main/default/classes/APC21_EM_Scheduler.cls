global class APC21_EM_Scheduler implements Schedulable{
   /**
	*  Method will call sendEmail method of APC21_ChartController class
	*  @name execute
	*  @param (1)- SchedulableContext
	*  @return Void
	*  @throws NA


String CRON_EXP = '0 0 5 * * ?'; 
APC21_EM_Scheduler evsch=new APC21_EM_Scheduler();
System.schedule('Daily EventsMonitoring',CRON_EXP,evsch);
*/
    global void execute(SchedulableContext ctx) {
        APC21_ChartController.sendEmail();
    }
}