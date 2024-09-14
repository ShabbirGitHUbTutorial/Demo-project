@isTest
public class SPEN_BatchUtilTest 
{
	@isTest
    private static void testMethodUtil()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetGroupId = devOpsPSGroup.Id);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCustomerJourney'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Id QueueId  = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'SPEN_ThirdPartyDamageCasesSPD'].Id;

            List<Case> cse = SPEN_TestDataFactory.createListOfCases(1); 
            cse[0].Status = '3PD Review';
            cse[0].SPEN_Category__c = 'Chargeable';
            cse[0].RecordTypeId = recordTypeId3PD;
            insert cse;

            cse[0].Reassignment_Reason__c = 'Telephone Call';

            cse[0].ownerId = QueueId;
            cse[0].Status = 'LOI Issued';
            update cse;
            cse[0].SPEN_LastStatusChangeDate__c = system.now()-25;
            update cse;
            
            List<Case> cseList = SPEN_TestDataFactory.createListOfCases(1); 
            cseList[0].RecordTypeId = recordTypeIdQuery;
            cseList[0].Status = 'Open';
            cseList[0].ParentId = cse[0].Id;
            insert cseList;
            cseList[0].Status = 'Closed';
            update cseList;
            
            Datetime scTime=System.now().addDays(1);
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            cron = second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
                     
            SPEN_BatchUtil.scheduleBatch('SPEN_3pdCaseStatusBatch_Test', 'SPEN_3pdCaseStatusBatch');
            SPEN_BatchUtil.scheduleBatchWithCron('SPEN_3pdCaseStatusBatch_Test1', 'SPEN_3pdCaseStatusBatch', cron);
            Assert.isNotNull(cron);
            Test.stopTest();
        }
    }
}