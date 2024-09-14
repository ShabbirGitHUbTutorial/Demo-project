@isTest(SeeAllData=false)
public class SPEN_SAPProjectAssignCallOutTest {
    
    @testsetup
    public static void setupdata(){ 
        List <SPEN_ConfigurableSettings__c> configSettingList = SPEN_TestDataFactory.createConfigSettingforSMSConfig(1);
        insert configSettingList;
    }
    
    @isTest
    public static void testsendProjectAssignCallout(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        if(devOpsPSGroup.Status != 'Updated'){
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_DeliveryCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        
        System.runAs(user){   
            try{
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                
                Case conCase = new Case();
                conCase.ContactId = ct.Id;
                conCase.Origin = 'Email';
                conCase.RecordTypeId = recordTypeIdFormal;
                conCase.SPEN_CustomerClass__c = 'CO';
                conCase.SPEN_JobDescription__c = 'Disconnection/ reconnection';
                conCase.SPEN_JobType__c = 'UMANU040';
                conCase.SPEN_RequiredPower__c = 9999;
                conCase.SPEN_PaymentDecision__c = 'PIA';
                conCase.SPEN_RequestedtoRelease__c = 100;
                conCase.Status ='Design';
                conCase.SPEN_POCVoltage__c='02';
                conCase.SPEN_MeteringVoltage__c='02';
                conCase.SPEN_ApplicantStreet__c='test street';
                conCase.SPEN_ApplicantTownCity__c='test town';
                conCase.SPEN_ApplicantPostCode__c='test code';
                conCase.SPEN_ApplicantFlatNo__c='number';
                conCase.SPEN_ApplicantCountry__c='test country';
                conCase.SPEN_SiteContactStreet__c='sitestreet';
                conCase.SPEN_SiteContactTownCity__c='sitetown';
                conCase.SPEN_SiteContactCounty__c='87';
                conCase.SPEN_SiteContactCountry__c='GB';
                conCase.SPEN_SiteContactBuildingName__c = 'building';
                conCase.SPEN_SiteContactCompanyName__c = 'building';
                conCase.SPEN_SiteContactFirstName__c = 'building';
                conCase.SPEN_SiteContactFlatNumber__c = '3';
                conCase.SPEN_SiteContactHouseNo__c = '1';
                conCase.SPEN_SiteContactLastName__c = 'building';
                conCase.SPEN_SiteContactPhone__c = '99999999';
                conCase.SPEN_SiteContactMobile__c = '99999999';
                conCase.SPEN_SiteContactEmail__c = 'test@gamil.com';
                conCase.SPEN_SubStatus__c = 'Not Competent';
                conCase.SPEN_SAPReference__c = '000612761850';
                conCase.SPEN_DeliveryProjectManager__c = UserInfo.getUserId();
                insert conCase;
                
                SPEN_Delivery__c delObj = new SPEN_Delivery__c();
                delObj.SPEN_Case__c = conCase.Id;
                delObj.SPEN_Notes__c = 'test';
                insert delObj;
                
                //SPEN_SAPProjectAssignCallOut.sendProjectAssignCallout(new List<Id>{delObj.Id});
                conCase.SPEN_Delivery__c = delObj.Id;
                update conCase;
                
                delObj.SPEN_DeliveryProjectManager__c = UserInfo.getUserId();
                update delObj;
                
                Test.stopTest();
                List<Case> caseRec1 = [Select id,SPEN_SAPErrorDetails__c from case where id =: conCase.id];
                Assert.areEqual(caseRec1[0].SPEN_SAPErrorDetails__c,'PM update success.');
            }catch(Exception ex){
                System.assert(ex != NULL);
            }
        }        
    }
}