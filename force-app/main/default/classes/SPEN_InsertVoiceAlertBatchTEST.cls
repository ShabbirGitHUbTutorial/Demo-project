@IsTest
public class SPEN_InsertVoiceAlertBatchTEST {
    @IsTest
    private static void testVoiceAlertBatch()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
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
			List<SPEN_VoiceAlert__c> alertList=SPEN_TestDataFactory.createVoiceAlertrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert alertList;
            Datetime scTime=System.now().addDays(1);
            
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            
            cron=second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
            SPEN_InsertVoiceAlertBatch obj=new SPEN_InsertVoiceAlertBatch(psrList,'Voice Alert');
            Database.executeBatch(obj);
            Assert.isNotNull(obj);
            SPEN_InsertVoiceAlertBatch obj1=new SPEN_InsertVoiceAlertBatch(psrList,'Voice Alert',scTime);
            Database.executeBatch(obj1);
            Assert.isNotNull(obj1);
            Test.stopTest();
        }
    }
}