global class APC21_EMP_Scheduler implements Schedulable{
   /**
	*  Method will call priorityCheck method of APC21_ChartController class
	*  @name execute
	*  @param (1)- SchedulableContext
	*  @return Void
	*  @throws NA

String CRON_EXP = '0 0 18 * * ?'; 
APC21_EMP_Scheduler evsch=new APC21_EMP_Scheduler();
System.schedule('Hourly Batch EventsMonitoring Priority',CRON_EXP,evsch);
*/
    global void execute(SchedulableContext ctx) {
        APC21_ChartController pc=new APC21_ChartController();
        pc.priorityCheck();
    }

}