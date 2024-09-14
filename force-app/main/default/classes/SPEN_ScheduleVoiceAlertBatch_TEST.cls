@IsTest
public class SPEN_ScheduleVoiceAlertBatch_TEST {
    @IsTest
     private static void testVoiceAlertBatchexecute()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        System.runAs(user)
        {
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert con;
            List<SPEN_PSR__c> psralert=SPEN_TestDataFactory.createPSRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            psralert[0].SPEN_Contact__c=con.Id;
            insert psralert;
            List<Id> psrList=new List<Id>();
            psrList.add(psralert[0].Id);
            List<SPEN_VoiceAlert__c> voicealert=SPEN_TestDataFactory.createVoiceAlertrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert voicealert;
            Datetime scTime = Datetime.newInstance(2022, 12, 27, 13, 30, 30);
            
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            
            cron=second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            SPEN_ScheduleVoiceAlertBatch obj=new SPEN_ScheduleVoiceAlertBatch(psrList,'Voice Alert',scTime);
            Database.executeBatch(obj);
            Assert.isNotNull(obj);
            Test.stopTest();
            
        }
	}
    
}