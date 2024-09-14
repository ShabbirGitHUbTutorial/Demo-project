@isTest
public class APC21_ChartController_Test {

    @isTest
    private static void  check(){
        AOEventMonitoringRecipients__c acp = new AOEventMonitoringRecipients__c();
        acp.EmailId__c = 'asp@asp.com' ;
        acp.Name = 'susee';
        insert acp;
        
        List<EventMonitoring__c> evnts=new List<EventMonitoring__c>();
        evnts.add(new EventMonitoring__c(Name='Data Storage',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
        evnts.add(new EventMonitoring__c(Name='File Storage',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
        evnts.add(new EventMonitoring__c(Name='Salesforce License',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
        evnts.add(new EventMonitoring__c(Name='Daily API',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
        evnts.add(new EventMonitoring__c(Name='Community License',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
		evnts.add(new EventMonitoring__c(Name='Async Apex Job',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
		evnts.add(new EventMonitoring__c(Name='Hourly TimeBased Workflow Limit',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
		evnts.add(new EventMonitoring__c(Name='ApexFlex Limit',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
		evnts.add(new EventMonitoring__c(Name='Single Email Limit',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
		evnts.add(new EventMonitoring__c(Name='Daily Workflow Emails',Total__c=100.0,Usage__c=90.0,Consumption__c=90.0));
        insert evnts;
		        
        Test.startTest();
        APC21_ChartController apc21=new APC21_ChartController();
        apc21.newEmail='aasdsd@et.cvb';
        apc21.addNewEmail();
        //apc21.emailId='aasdsd@ert.cvb';
        apc21.removeEmail();
        
        APC21_ChartController.sendEmail();
        APC21_ChartController pc=new APC21_ChartController();
        pc.priorityCheck();
        pc.testAction();
        APC21_ChartController.sendPriorityEmail('evntName', 'qweryui');
        System.assertNotEquals(pc, null);
        Test.stopTest();
    }
    
    @isTest 
    private static void testEventMSchedulerClass(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        APC21_EM_Scheduler evsch=new APC21_EM_Scheduler();
        System.schedule('Hourly Batch EventsMonitoringTest',CRON_EXP,evsch);
        System.assertNotEquals(evsch, null);
        Test.stopTest();
    }
    
    @isTest 
    private static void testEventMPSchedulerClass(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        APC21_EMP_Scheduler evsch=new APC21_EMP_Scheduler();
        System.schedule('Hourly Batch EventsMonitoring PriorityTest',CRON_EXP,evsch);
        System.assertNotEquals(evsch, null);
        Test.stopTest();
    }
}