@isTest
public class APC22_BatchMonitoring_Test {
    @testSetup public static void setup(){
        AOBatchMonitoringRecipient__c emailrec=new AOBatchMonitoringRecipient__c();
        emailrec.EmailId__c='t.e.s.t..@adecco.com';
        emailrec.Name='test';
        insert emailrec;
        datetime dts=system.now();
        integer dds=dts.dayGmt();
        datetime dt=system.now().addDays(2);
        integer dd=dt.dayGmt();
        integer mm=dt.monthGmt();
        integer yyyy=dt.yearGmt();
        String Cron='0 0 7'+' '+dds+'-'+dd+' '+mm+' '+'?'+' '+yyyy;
		system.debug('cron'+Cron);        
        APC22_BatchMonitoring_Schedular bm=new APC22_BatchMonitoring_Schedular();
        System.Schedule('Test',Cron,bm);
        
    }
    @isTest 
    private static void testBatchMSchedulerClass(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        APC22_BatchMonitoring_Schedular evsch=new APC22_BatchMonitoring_Schedular();
        System.schedule('Batch MonitoringTest',CRON_EXP,evsch);
        System.assertNotEquals(evsch, null);
        Test.stopTest();
    }
    @isTest
    private static void testSendmail(){
        Test.startTest();
        List<AOBatchMonitoringRecipient__c> toEmailId=[Select EmailId__c,Name FROM AOBatchMonitoringRecipient__c  LIMIT 1];
        system.debug('toEmailId'+toEmailId);
         APC22_BatchMonitoring ev=new APC22_BatchMonitoring();
         ev.sendmail();
        ev.addNewEmail();
        ev.removeEmail();
         Integer emailbefore = Limits.getEmailInvocations();
        system.debug('emailbefore'+emailbefore);
        system.assertEquals(emailbefore,Limits.getEmailInvocations(),0);
        Test.stopTest();
    }
    @isTest 
    private static void testBatchEnddateSchedulerClass(){
        Test.startTest();
        String CRON_EXP = '0 0 * * * ?'; 
        APC23_BatchSchEnddateSchedular evsch=new APC23_BatchSchEnddateSchedular();
        System.schedule('Batch MonitoringTest',CRON_EXP,evsch);
        System.assertNotEquals(evsch, null);
        Test.stopTest();
    }
    @isTest
    private static void testsendenddateemail(){
        Test.startTest();
        List<AOBatchMonitoringRecipient__c> toEmailId=[Select EmailId__c,Name FROM AOBatchMonitoringRecipient__c  LIMIT 1];
        APC22_BatchMonitoring bm=new APC22_BatchMonitoring();
        bm.sendenddateemail();
        Integer emailbefore = Limits.getEmailInvocations();
        system.assertEquals(emailbefore,Limits.getEmailInvocations(),0);
        Test.stopTest();
        
    }
}