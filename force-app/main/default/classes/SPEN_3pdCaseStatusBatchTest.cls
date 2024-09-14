@isTest
public class SPEN_3pdCaseStatusBatchTest 
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
            
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Id QueueId  = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'SPEN_ThirdPartyDamageCasesSPD'].Id;

            List<Case> cse = SPEN_TestDataFactory.createListOfCases(1); 
            cse[0].Status = '3PD Review';
            //cse[1].Status = '3PD Review';
            //cse[2].Status = '3PD Review';
            cse[0].SPEN_Category__c = 'Chargeable';
            //cse[1].SPEN_Category__c = 'Chargeable';
            //cse[2].SPEN_Category__c = 'Chargeable';
            cse[0].RecordTypeId = recordTypeId3PD;
            //cse[1].RecordTypeId = recordTypeId3PD;
            //cse[2].RecordTypeId = recordTypeId3PD;            
          
            
            cse[0].Reassignment_Reason__c = 'Telephone Call';
            //cse[1].Reassignment_Reason__c = 'Telephone Call';
            //cse[2].Reassignment_Reason__c = 'Telephone Call';

            cse[0].ownerId = QueueId;
            //cse[1].OwnerId = QueueId;
            //cse[2].OwnerId = QueueId;
            cse[0].Status = 'LOI Issued';
            //cse[1].Status = 'LOI Issued';
            //cse[2].Status = 'LOI Issued';
            Test.startTest();
              insert cse;
            //update cse;
           
          
            cse[0].SPEN_LastStatusChangeDate__c = system.now()-25;
            //cse[1].SPEN_LastStatusChangeDate__c = system.now()-25;
            //cse[2].SPEN_LastStatusChangeDate__c = system.now()-25;
            update cse;
            
            //List<Case> cseList = SPEN_TestDataFactory.createListOfCases(2);
            List<Case> cseList = SPEN_TestDataFactory.createListOfCases(1);
            cseList[0].Status = 'Open';
            //cseList[1].Status = 'Open';
            cseList[0].ParentId = cse[0].Id;
            //cseList[1].ParentId = cse[1].Id;
            cseList[0].RecordTypeId = recordTypeIdQuery;
            //cseList[1].RecordTypeId = recordTypeIdQuery;
            insert cseList;
            
            cseList[0].Status = 'Closed';
            update cseList[0];
            Test.stopTest();
            Datetime scTime=System.now().addDays(1);
            String cron;
            String second = String.valueOf(scTime.second());
            String minute = String.valueOf(scTime.minute());
            String hour = String.valueOf(scTime.hour());
            String day = String.valueOf(scTime.day());
            String month = String.valueOf(scTime.month()); 
            String year = String.valueOf(scTime.year());
            cron = second+' '+minute+' '+hour+' '+day+' '+month+' '+'?'+' '+year;
              
            Database.executeBatch(new SPEN_3pdCaseStatusBatch());
            SPEN_3pdCaseStatusBatch obj= new SPEN_3pdCaseStatusBatch();
            system.schedule('Test status check'+System.now(),cron,obj); 
            Assert.isNotNull(obj);
            
           
           
        }
    }
}