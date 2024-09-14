public class AP231_EventMonitoringScheduler implements Schedulable{
   /**
	*  Method will call main method of MonitoringEventsTypes class
	*  @name execute
	*  @param (1)- SchedulableContext
	*  @return Void
	*  @throws NA
	*/
    public void execute(SchedulableContext ctx) {
       AP230_MonitoringEventsTypes.callingMethod();
    }
}