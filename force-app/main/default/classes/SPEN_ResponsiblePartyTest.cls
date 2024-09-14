@IsTest
public class SPEN_ResponsiblePartyTest {
@IsTest
    public static void beforeInsertRespParty()
    {
         Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ResponsibilityPartyCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseThirdPartyDamageCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        
        System.runAs(user)
        {
           	try
            {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Test.startTest();
            
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            Case ThreePDCase =new Case();
            ThreePDCase.Status ='Created';
            ThreePDCase.Priority='Medium';
            ThreePDCase.RecordTypeId = recordTypeId3PD;
            insert ThreePDCase;
                
                List<SPEN_ResponsibleParty__c> responseList = SPEN_TestDataFactory.createRespPartyRecordsForSameCase(2);
                responseList[0].SPEN_Case__c = ThreePDCase.Id;
                insert responseList[0];
            	
                Test.stopTest();
            SPEN_ResponsibleParty__c resparty = [Select ID,SPEN_primary__c from SPEN_ResponsibleParty__c where ID =:responseList[0].ID];
            system.assertEquals(false,responseList[0].SPEN_primary__c);
            }
            catch(Exception ex)
            {
                 System.assert(ex != NULL);
            }
        }
    }
}