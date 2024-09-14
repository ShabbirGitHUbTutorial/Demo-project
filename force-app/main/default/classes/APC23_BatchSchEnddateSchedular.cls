global class APC23_BatchSchEnddateSchedular implements Schedulable {
    public void execute(SchedulableContext sc)
        {
            APC22_BatchMonitoring bc= new APC22_BatchMonitoring();	
            bc.sendenddateemail();
        }
}