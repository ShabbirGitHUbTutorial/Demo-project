@isTest
private class AP230_MonitoringEventsTypes_Test {
    
    @isTest
    private static void callingMethodTesting(){
        Test.startTest();
        AP230_MonitoringEventsTypes.callingMethod();
        System.assertNotEquals(AP230_MonitoringEventsTypes.getDataExport(),null);
        Test.stopTest();
    }
    
    @isTest 
    private static void testEventSchedulerClass(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        AP231_EventMonitoringScheduler evsch=new AP231_EventMonitoringScheduler();
        System.schedule('Hourly Batch Schedule job Test',CRON_EXP,evsch);
        System.assertNotEquals(AP230_MonitoringEventsTypes.getEventConfigurationMonitoring(),null);
        Test.stopTest();
    }
    
    @isTest private static void insertAdminUser(){
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'Samuel',
                          lastname='XXXX',
                          Alias='Samuel',
                          email = 'samuelXXXXX@sfevent.com',
                          username= 'samuelXXXXX@sfevent.com.v', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        Test.startTest();
        insert u;
        Test.stopTest();
    }
    
    @isTest private static void updateAdminUser(){
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'Samuel',
                          lastname='XXXX',
                          Alias='Samuel',
                          email = 'samuelXXXXX@sfevent.con',
                          username= 'samuelXXXXX@sfevent.con.v', 
                          profileId= p.id, 
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        Test.startTest();
        insert u;
        u.isActive=false;
        update u;
        u.isActive=true;
        update u;
        Test.stopTest();
    }
}