global class APC22_BatchMonitoring_Schedular implements Schedulable {
    public void execute(SchedulableContext sc)
        {
            APC22_BatchMonitoring bc= new APC22_BatchMonitoring();	
            bc.sendmail();
        }
}