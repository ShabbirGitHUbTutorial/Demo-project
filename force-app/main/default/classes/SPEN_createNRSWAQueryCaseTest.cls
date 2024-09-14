@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_createNRSWAQueryCaseTest {
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAS(user){
            List<Incident> lstInct = SPEN_TestDataFactory.createListofIncidents(1);
            lstInct[0].SPEN_IncidentCategory__c = 'SP';
            lstInct[0].SPEN_IncidentID__c = '123';
            lstInct[0].SPEN_IncidentReference__c = 'INCD-588323-k';
            insert lstInct;
            
            SPEN_ResourceDetail__c redRecord = new SPEN_ResourceDetail__c();
            redRecord.SPEN_Company__c = 'MORRISON';
            redRecord.SPEN_Comment__c = 'test';
            redRecord.SPEN_ResourceName__c = 'sfdc';
            //redRecord.SPEN_EventDate__c = '2023-07-27T12:45:35.000+01:00';
            redRecord.SPEN_EventDate__c = System.now();
            redRecord.SPEN_Incident__c = lstInct[0].Id;
            redRecord.SPEN_Event__c = 'Arrival On Site';
            insert redRecord;
        }
    }
    @isTest
    public static void createNRSWAQueryCaseTestPositive(){
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
       List<SPEN_ResourceDetail__c> resourceDetail=[Select id,SPEN_ResourceName__c,SPEN_Comment__c,SPEN_Event__c,SPEN_EventDate__c,SPEN_Incident__c from SPEN_ResourceDetail__c where id!=null];
       SPEN_createNRSWAQueryCase.createNRSWAQueryCase(resourceDetail);
      Case nrswacase=[Select id from case where recordType.developername='SPEN_Query' and SPEN_type__c='NRSWA'];
      Assert.isTrue(nrswacase!=null);
    }
    @isTest
    public static void createNRSWAQueryCaseTestNegative(){
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
       List<SPEN_ResourceDetail__c> resourceDetail;//[Select id,SPEN_ResourceName__c,SPEN_Comment__c,SPEN_Event__c,SPEN_Incident__c from SPEN_ResourceDetail__c];
       SPEN_createNRSWAQueryCase.createNRSWAQueryCase(resourceDetail);
        try{
            Case nrswacase=[Select id from case where recordType.developername='SPEN_Query' and SPEN_type__c='NRSWA'];
        }catch(Exception e){
             Assert.isTrue(e!=null);
        }
    }
}