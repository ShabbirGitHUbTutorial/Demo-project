@isTest
public class SPEN_3pdMissingFormsBatchTest 
{
    @isTest
    private static void testMethod1()
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
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_ThirdPartyDamage).getRecordTypeId();
            //List<Case> cse = SPEN_TestDataFactory.createListOfCases(3);
            List<Case> cse = SPEN_TestDataFactory.createListOfCases(1);
            cse[0].RecordTypeId = recordTypeId3PD;
            //cse[1].RecordTypeId = recordTypeId3PD;
            //cse[2].RecordTypeId = recordTypeId3PD;
            cse[0].Status = 'Created';
            //cse[1].Status = 'Created';
            //cse[2].Status = 'Created';
			insert cse;
            
            Datetime scTime=System.now().addDays(1);
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            cron = second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
                        
            SPEN_3pdMissingFormsBatch obj= new SPEN_3pdMissingFormsBatch();
            system.schedule('Test status check'+System.now(),cron,obj); 
            Assert.isNotNull(obj);
            Test.stopTest();
        }
    }
}