/**
* @description       : Test class for SurveyInviationLinkRedirection
* @author            : Govind Rawani
* @group             : 
* @last modified on  : 10-05-2024
* @last modified by  : govind.kumar.rawani@accenture.com
**/
@isTest(SeeAllData=true)
public class SurveyInviationLinkRedirectionTest {
    
    @isTest
    public static void testSurveyInviationLinkRedirectionTest(){
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
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_SurveyAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        Id communityId = [select Id from Network where Name = 'SPEN Survey'].Id;
        System.runAs(user){
            Test.startTest();
            SPEN_SurveyUtility.createSurveyInvitation(communityId,null,'testSMSName','SMS','Faults',false,false,null,null,null,null);
            //String communityId, String surveyId, String name, String channel, String type, boolean anonymousresponse, boolean guestUserResponse, Id caseId, Id incidentId, Id participantId
			Survey Surveyrec = [Select Id,Name from Survey where Name = 'Net Promoter Score'];
		    SurveyInvitation sInv = new SurveyInvitation();
            sInv.CommunityId = communityId;
            sInv.Name = 'SI-' + 'name';
            sInv.SPEN_SurveyChannel__c = null;
            sInv.SPEN_Type__c = null;
            sInv.OptionsCollectAnonymousResponse = false;
            sInv.OptionsAllowGuestUserResponse = true;
            sInv.SurveyId = Surveyrec.Id;
            sInv.SPEN_Case__c = null;
            sInv.SPEN_Incident__c = null;
            sInv.ParticipantId = null;
            insert sInv;
            
    		List<SurveyInvitation> sList=[SELECT Id, UUID,InvitationLink from SurveyInvitation where id =:sInv.id];
            PageReference pageRef = Page.ShortInvitationLink;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('UUID',String.valueOf(sList[0].UUID));
            SurveyInviationLinkRedirection sr=new SurveyInviationLinkRedirection();
           	PageReference page= SurveyInviationLinkRedirection.surveyUrlRedirection();
            System.assert(page!= null, 'Its not null');
            Test.stopTest();
    }
    }
    
    @isTest
    public static void testSurveyInviationLinkRedirectionTest2(){
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
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_SurveyAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet zone = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_Zone_RU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = zone.Id);
        Id communityId = [select Id from Network where Name = 'SPEN Survey'].Id;
        System.runAs(user){
            Test.startTest();
            SPEN_SurveyUtility.createSurveyInvitation(communityId,null,'testSMSName','SMS','Faults',false,false,null,null,null,null);
            //String communityId, String surveyId, String name, String channel, String type, boolean anonymousresponse, boolean guestUserResponse, Id caseId, Id incidentId, Id participantId
          Survey Surveyrec = [Select Id,Name from Survey where Name = 'Net Promoter Score'];
            SurveyInvitation sInv = new SurveyInvitation();
            sInv.CommunityId = communityId;
            sInv.Name = 'SI-' + 'name';
            sInv.SPEN_SurveyChannel__c = null;
            sInv.SPEN_Type__c = null;
            sInv.OptionsCollectAnonymousResponse = false;
            sInv.OptionsAllowGuestUserResponse = true;
            sInv.SurveyId = Surveyrec.Id;
            sInv.SPEN_Case__c = null;
            sInv.SPEN_Incident__c = null;
            sInv.ParticipantId = null;
            insert sInv;
            
    		List<SurveyInvitation> sList=[SELECT Id, UUID,InvitationLink from SurveyInvitation where id =:sInv.id];
            PageReference pageRef = Page.ShortInvitationLink;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('UUID','1234567');
            SurveyInviationLinkRedirection sr=new SurveyInviationLinkRedirection();
           	PageReference page= SurveyInviationLinkRedirection.surveyUrlRedirection();
            System.assert(page!= null, 'Its not null');
            Test.stopTest();
        
    }
    }
}