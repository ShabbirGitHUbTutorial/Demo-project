@IsTest
public class SPEN_AbortBatch_TEST 
{
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = SPEN_TestdataSelector.getPermissionSet('SPEN_CommunicationSchedulerAccessCRU');
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = SPEN_TestdataSelector.getPermissionSet('SPEN_ContactAccessCRU');
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = SPEN_TestdataSelector.getPermissionSet('SPEN_Zone_CRU');
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user)
        {
            Test.startTest();
            SPEN_ConfigurableSettings__c cs2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            insert cs2;
            SPEN_ConfigurableSettings__c cs1 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelayForMessagingTask');
            insert cs1;
            SPEN_ConfigurableSettings__c cs3 =SPEN_TestDataFactory.createConfigSetting(1,'OnDemandMessageDelayForMessagingTask');
            insert cs3;
            Test.stopTest();
        
        }
    }
    @IsTest
    @SuppressWarnings('PMD.SOQLSelectorPattern')
    private static void testAbortBatchexecute()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            List<SPEN_PSR__c> psralert=SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psralert[0].SPEN_Contact__c=con.Id;
            insert psralert;
            List<Id> psrList=new List<Id>();
            
            psrList.add(psralert[0].Id);
            List<SPEN_CommunicationScheduler__c> comList=new List<SPEN_CommunicationScheduler__c>();
            
            Datetime scTime=System.now().addDays(1);
            
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            
            cron=second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
            SPEN_SchedulableVoiceAlertClass sVA = new SPEN_SchedulableVoiceAlertClass(psrList,'Voice Alert',scTime);
            
            ID jobid = System.schedule('scheduledVoiceAlert '+System.now(), cron, sVA);
            //Create messaging task
            List<SPEN_MessagingTask__c> sMsgtask = new List<SPEN_MessagingTask__c>();
            SPEN_MessagingTask__c sMsgtask1 = new SPEN_MessagingTask__c();
            sMsgtask1.SPEN_Status__c='New';   
            insert sMsgtask1;
            sMsgtask.add(sMsgtask1);
            
            List<Incident> inci = new List<Incident>();
            Incident inci1 = new Incident();
            Inci1.Subject='Test new subject real time';   
            insert inci1;
            Inci.add(inci1);
            
            SPEN_CommunicationScheduler__c c1=new SPEN_CommunicationScheduler__c();
            //c1.Name='Sample com';
            c1.SPEN_BatchJobId__c=jobid; 
            c1.SPEN_MessagingTaskId__c=sMsgtask1.id;
            c1.SPEN_Action__c='Send SMS to PSR';
            c1.SPEN_IncidentId__c=Inci1.id;
            c1.SPEN_Message__c='Test';
            c1.SPEN_ScheduledDateTime__c=DateTime.newInstance(1997, 1, 31, 10, 8, 16);
            c1.SPEN_Status__c='Not Started';
            comList.add(c1);
            insert comList;
            
            SPEN_AbortBatch.inputVariables inp=new SPEN_AbortBatch.inputVariables();
            inp.comSchedule=comList;
            SPEN_AbortBatch.abortJob(new List<SPEN_AbortBatch.inputVariables>{inp});
            if(sMsgtask1!=null && sMsgtask1.id!=null){
                SPEN_CommunicationScheduler__c comSch=[Select id,SPEN_Status__c from SPEN_CommunicationScheduler__c where SPEN_MessagingTaskId__c=:sMsgtask1.id limit 1];
                Assert.areEqual(comSch.SPEN_Status__c,'Cancelled'); 
            }
            Test.stopTest();
        }
    }
    @IsTest
    @SuppressWarnings('PMD.SOQLSelectorPattern')
    private static void testAbortBatchexecuteNeg()
    {
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            List<SPEN_PSR__c> psralert=SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psralert[0].SPEN_Contact__c=con.Id;
            insert psralert;
            List<Id> psrList=new List<Id>();
            
            psrList.add(psralert[0].Id);
            List<SPEN_CommunicationScheduler__c> comList=new List<SPEN_CommunicationScheduler__c>();
            
            Datetime scTime=System.now().addDays(1);
            
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            
            cron=second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
            SPEN_SchedulableVoiceAlertClass sVA = new SPEN_SchedulableVoiceAlertClass(psrList,'Voice Alert',scTime);
            
            ID jobid = System.schedule('scheduledVoiceAlert '+System.now(), cron, sVA);
            //Create messaging task
            List<SPEN_MessagingTask__c> sMsgtask = new List<SPEN_MessagingTask__c>();
            SPEN_MessagingTask__c sMsgtask1 = new SPEN_MessagingTask__c();
            sMsgtask1.SPEN_Status__c='New';   
            insert sMsgtask1;
            sMsgtask.add(sMsgtask1);
            
            List<Incident> inci = new List<Incident>();
            Incident inci1 = new Incident();
            Inci1.Subject='Test new subject real time';   
            insert inci1;
            Inci.add(inci1);
            
            SPEN_CommunicationScheduler__c c1=new SPEN_CommunicationScheduler__c();
            //c1.Name='Sample com';
            c1.SPEN_BatchJobId__c=jobid; 
            c1.SPEN_MessagingTaskId__c=sMsgtask1.id;
            c1.SPEN_Action__c='Send SMS to PSR';
            c1.SPEN_IncidentId__c=Inci1.id;
            c1.SPEN_Message__c='Test';
            c1.SPEN_ScheduledDateTime__c=DateTime.newInstance(1997, 1, 31, 10, 8, 16);
            c1.SPEN_Status__c='Not Started';
            comList.add(c1);
            insert comList;
            
            SPEN_AbortBatch.inputVariables inp=new SPEN_AbortBatch.inputVariables();
            inp.comSchedule=comList;
            try{
                SPEN_AbortBatch.abortJob(new List<SPEN_AbortBatch.inputVariables>());
            }catch(Exception e){
                 Assert.isTrue(e!=null);
            }
            if(sMsgtask1!=null && sMsgtask1.id!=null){
                SPEN_CommunicationScheduler__c comSch=[Select id,SPEN_Status__c from SPEN_CommunicationScheduler__c where SPEN_MessagingTaskId__c=:sMsgtask1.id limit 1];
                Assert.isTrue(comSch.SPEN_Status__c!='Cancelled');
            }
            Test.stopTest();
        }
    }
}