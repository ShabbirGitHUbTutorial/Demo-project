@isTest
public class SPEN_JourneySLAUtilsTest {
	
    Public static Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
    Public static Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    @testSetup static void setup(){
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
    	Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        //creating User
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
    }
    
    @isTest
    public static void nrswaSLATest()
    { 
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1];
        System.runAs(usr)
        { 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        	List<case> cases=SPEN_TestDataFactory.createCaseRecords(1,recordTypeIdNRSWA);
            cases[0].SPEN_SPDSPMIndicator__c='SPM';
            cases[0].SPEN_NoticeType__c='Minor';
            insert cases;
            Test.stopTest();
            Case cseRec = [Select Id, SPEN_SLADueDate__c from Case where id=:cases[0].Id];
            System.assert(cseRec.SPEN_SLADueDate__c!=null);
        }
    }
    
    @isTest
    public static void swSLAMinorTest()
    { 
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1];
        System.runAs(usr)
        { 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        	List<case> cases=SPEN_TestDataFactory.createCaseRecords(1,recordTypeIdSW);
            cases[0].SPEN_SPDSPMIndicator__c='SPM';
            cases[0].SPEN_NoticeType__c='Minor';
            cases[0].SPEN_ExcavationRequired__c='No';
            cases[0].SPEN_EarlyStartDate__c=system.today();
            insert cases;
            Test.stopTest();
            Case cseRec = [Select Id, SPEN_SLADueDate__c from Case where id=:cases[0].Id];
            System.assert(cseRec.SPEN_SLADueDate__c!=null);
        }
    }
    
    @isTest
    public static void swSLASPDMinorTest()
    { 
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1];
        System.runAs(usr)
        { 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        	List<case> cases=SPEN_TestDataFactory.createCaseRecords(1,recordTypeIdSW);
            cases[0].SPEN_SPDSPMIndicator__c='SPD';
            cases[0].SPEN_NoticeType__c='Standard';
            cases[0].SPEN_Sensitivity__c='T/S';
            cases[0].SPEN_ProposedStartDate__c=Date.newInstance(2023,10,21);
            insert cases;
            Test.stopTest();
            Case cseRec = [Select Id, SPEN_SLADueDate__c from Case where id=:cases[0].Id];
            System.assert(cseRec.SPEN_SLADueDate__c!=null);
        }
    }
    
	@isTest
    public static void querySWSLATest()
    { 
        User usr= [SELECT id FROM USER WHERE IsActive=true LIMIT 1];
        System.runAs(usr)
        { 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        	List<case> cases=SPEN_TestDataFactory.createCaseRecords(1,recordTypeIdQuery);
            cases[0].SPEN_SPDSPMIndicator__c='SPM';
            cases[0].SPEN_Type__c='StreetWorks';
            cases[0].SPEN_Email_WI_Queue_Routing_Outcome__c='4 Hr SLA South';
            insert cases;
            Test.stopTest();
            Case cseRec = [Select Id, SPEN_SLADueDate__c from Case where id=:cases[0].Id];
            System.assert(cseRec.SPEN_SLADueDate__c!=null);
        }
    }
    
}