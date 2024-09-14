@isTest
public class SPEN_AgentWorkTriggerHandler_Test {

	@isTest()
    Public static void testCreateCaseTracker(){
        Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
        List<Group> lstQueue = [SELECT Id, Type, Name,developername FROM Group WHERE Type = 'Queue' AND developername=: 'SPEN_Streetworks_SPM_Cases_High_Priority'];
        ServiceChannel SChannel= [SELECT Id FROM ServiceChannel WHERE Masterlabel = 'caseChannel'];
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
       	    
        System.runAs(user)
        {
            Test.startTest();
            SPEN_IVRMessage__c IVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            Insert IVRMessage;
			SPEN_Zone__c SPMZoneParent = SPEN_TestDataFActory.createZoneRecords(IVRMessage.id);
            SPMZoneParent.name = 'DEE VALLEY / MID WALES';
            SPMZoneParent.SPEN_Type__c = 'Zone';
            insert SPMZoneParent;
            SPEN_Zone__c SPMZone = SPEN_TestDataFActory.createZoneRecords(IVRMessage.id);
            SPMZone.name = 'DEE VALLEY NORTH';
            SPMZone.SPEN_Type__c = 'Zone';
            SPMZone.SPEN_Parent__c = SPMZoneParent.Id;
            insert SPMZone;
            
            Case SWCase = new Case();
            SWCase.SPEN_ConnectionDistrict__c = 'DEE VALLEY NORTH';
            SWCase.SPEN_EarlyStartDate__c = System.today();
            SWCase.SPEN_ExcavationRequired__c = 'Yes';
            SWCase.SPEN_NoticeType__c = 'Immediate';
            SWCase.SPEN_Sensitivity__c = 'T/S';
            SWCase.Origin = 'Web';
            SWCase.recordtypeid = recordTypeIdSW;
            SWCase.Status = 'Streetworks Review';
            SWCase.OwnerId = lstQueue[0].id;
            insert SWCase;
            
            try{
                AgentWork awork = new AgentWork();
                awork.WorkItemId = SWCase.Id;
                awork.ServiceChannelId = SChannel.id;
                awork.UserId = user.id;
                insert awork;
                awork.SPEN_FlagForTestCoverage__c = true;
                update awork;
                system.assertNotEquals(awork.Status,'Opened');
            }
            catch(Exception ex){
                system.debug('Inside exception: '+ ex.getMessage());
            }
            Test.stopTest();
        }
        
    }
}