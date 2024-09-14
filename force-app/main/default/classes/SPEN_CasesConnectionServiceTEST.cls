/*-----------------------------------------------------------------------------
DESCRIPTION :   Test Class for Case Connection Service 
AUTHOR      :   Akshay Pandit

HISTORY     :
Date            Author              Comment
June-09-2023     Akshay Pandit         Initial version
-----------------------------------------------------------------------------*/
@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_CasesConnectionServiceTEST {
    @IsTest
    public static void updateBMSOMSTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessConnectionCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_BusinessMarketSegmentConnectionCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
        PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
        PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
        PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);
        PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseConnectionsAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);
        PermissionSet ps12 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactConnectionsAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps12.Id);
        PermissionSet ps13 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseConnectionsAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps13.Id);
        System.runAs(user){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Map<id,Contact> oldmap = new Map<id,Contact>();
            Map<id,Contact> newmap = new Map<id,Contact>();
            Test.startTest();
            
            List<SPEN_BusinessMarketSegmentRule__c> bmsLst = new List<SPEN_BusinessMarketSegmentRule__c>(); 
            SPEN_BusinessMarketSegmentRule__c bms1 = new SPEN_BusinessMarketSegmentRule__c(SPEN_JobType__c='UMANU022', SPEN_QuotationType__c='E2-UBUDGET', SPEN_CustomerClass__c='CO',SPEN_RequiredPhase__c='03',SPEN_POCVoltage__c='02',SPEN_MeteringVoltage__c='02',SPEN_MinimumPlotsNumber__c=0,SPEN_MaximumPlotsNumber__c=10,SPEN_MinimumLoad__c=1000.00,SPEN_MaximunLoad__c=9999.00,SPEN_BusinessMarketSegment__c='DIVERBUD1000',SPEN_OfgemMarketSegment__c='LVSSA',SPEN_NoofDaysforGSDueDate__c=20,SPEN_IsActive__c=TRUE);
            
            SPEN_BusinessMarketSegmentRule__c bms2 = new SPEN_BusinessMarketSegmentRule__c(SPEN_JobType__c='UMANU022', SPEN_QuotationType__c='E2-UBUDGET', SPEN_CustomerClass__c='CO',SPEN_RequiredPhase__c='03',SPEN_POCVoltage__c='02',SPEN_MeteringVoltage__c='02',SPEN_MinimumPlotsNumber__c=0,SPEN_MaximumPlotsNumber__c=10,SPEN_MinimumLoad__c=0.00,SPEN_MaximunLoad__c=999.00,SPEN_BusinessMarketSegment__c='DIVERBUD900',SPEN_OfgemMarketSegment__c='LVSSB',SPEN_NoofDaysforGSDueDate__c=10,SPEN_IsActive__c=TRUE);
            
            bmsLst.add(bms1);
            bmsLst.add(bms2);
            //bmsLst.add(bms3);
            insert bmsLst;
            
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            testAccount[0].BillingCity='SouthC';
            testAccount[0].BillingCountry='UK';
            testAccount[0].BillingGeocodeAccuracy=NULL;
            testAccount[0].BillingLatitude=NULL;
            testAccount[0].BillingLongitude=NULL;
            testAccount[0].BillingPostalCode='PO5';
            testAccount[0].BillingState=NULL;
            testAccount[0].BillingStreet='Saint Vincent Road Portsmouth'; 
            insert testAccount;
            Id recTypeId2=[select Id from RecordType where DeveloperName='SPEN_ContactConnectionsCRM'].Id;
            Id recTypeId3=[select Id from RecordType where DeveloperName='SPEN_Contact'].Id;
            Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            ct.RecordTypeId=recTypeId2;
            
            oldmap.put(ct.id, ct);
            insert ct;
            Id recTypeId=[select Id from RecordType where DeveloperName='SPEN_BudgetConnectionEnquiry'].Id;
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_SendtoPowerOn__c = true;
            cse.SPEN_CallerInitials__c = ct.Salutation;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.SPEN_CallerTitle__c = ct.Suffix;
            cse.status='Restored';
            cse.RecordTypeId=recTypeId;
            cse.SPEN_JobDescription__c='Diversion';
            cse.SPEN_JobType__c='UMANU022';
            cse.SPEN_ConnectionType__c='NOR';
            cse.SPEN_CustomerRequestClass__c='E0-UNCOMASI';
            cse.SPEN_QuotationType__c='E2-UBUDGET';	
            cse.SPEN_CustomerClass__c='CO';
            cse.SPEN_RequiredPhase__c='03';
            cse.SPEN_POCVoltage__c='02';
            cse.SPEN_MeteringVoltage__c='02';
            cse.SPEN_RequiredPower__c=99;
            cse.SPEN_ApplicantStreet__c='test street';
            cse.SPEN_ApplicantTownCity__c='test town';
            cse.SPEN_ApplicantPostCode__c='test code';
            cse.SPEN_ApplicantFlatNo__c='number';
            cse.SPEN_ApplicantCountry__c='test country';
            cse.SPEN_SiteContactStreet__c='sitestreet';
            cse.SPEN_SiteContactTownCity__c='sitetown';
            cse.SPEN_SiteContactPostCode__c='sitecode';
            cse.SPEN_SiteContactCountry__c='GB';
            cse.SPEN_PaymentDecision__c='STG';
            cse.AccountId= testAccount[0].id;
            
            Contact ctnew = new Contact();
            ctnew.AccountId = testAccount[0].id;
            ctnew.Salutation = 'Mr.';
            ctnew.MobilePhone = '07123456789';
            ctnew.FirstName = 'Akshay';
            ctnew.Phone = '01234567890';
            ctnew.LastName = 'Pandit';
            ctnew.Suffix = 'AP';
            ctnew.SPEN_CustomerID__c = 'SB_001';
            ctnew.RecordTypeId=recTypeId3;
            insert ctnew;
            
            Case cs = new Case();
            cs.ContactId = ctnew.Id;
            cs.SPEN_SendtoPowerOn__c = true;
            cs.SPEN_CallerInitials__c = ct.Salutation;
            cs.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cs.SPEN_CallerName__c = ct.Name;
            cs.SPEN_CallerTelephone__c = ct.Phone;
            cs.SPEN_CallerTitle__c = ct.Suffix;
            cs.status='Restored';
            cs.RecordTypeId=recTypeId;
			cse.SPEN_JobDescription__c='Diversion';
            cse.SPEN_JobType__c='UMANU022';
            cse.SPEN_ConnectionType__c='NOR';
            cse.SPEN_CustomerRequestClass__c='E0-UNCOMASI';
            cse.SPEN_QuotationType__c='E2-UBUDGET';	
            cse.SPEN_CustomerClass__c='CO';
            cse.SPEN_RequiredPhase__c='03';
            cse.SPEN_POCVoltage__c='02';
            cse.SPEN_MeteringVoltage__c='02';
            cse.SPEN_RequiredPower__c=1009;            
            cs.SPEN_ApplicantStreet__c='test street1';
            cs.SPEN_ApplicantTownCity__c='test town1';
            cs.SPEN_ApplicantPostCode__c='test code1';
            cs.SPEN_ApplicantFlatNo__c='number1';
            cs.SPEN_ApplicantCountry__c='test country1';
            cs.AccountId= testAccount[0].id;
            
            List<Id> cseIds = new List<Id>();
            cseIds.add(cs.id);
            cseIds.add(cse.Id);
            List<Case> cseIns = new List<Case>{cse,cs};
                Database.SaveResult[] saveRes = Database.insert(cseIns);
            
            Contact upContact = [SELECT Id,AccountId,Salutation,MobilePhone,FirstName,LastName,Name,Phone,Suffix FROM Contact WHERE Id =:ctnew.Id];
            upContact.MobilePhone = '07123456789';
            upContact.FirstName = 'Akshay';
            upContact.Phone = '01234567890';
            upContact.LastName = 'Pandit';
            upContact.Suffix = 'AP';
            newmap.put(upContact.id, upContact);
            Database.SaveResult saveRes1 = Database.update(upContact);
            List<Case> upcse = [SELECT Id,ContactId,SPEN_CallerInitials__c,SPEN_CallerMobileTelephone__c,SPEN_CallerName__c,SPEN_CallerTelephone__c,SPEN_UKC1ID__c,SPEN_UKC2ID__c,SPEN_CCCompanyName__c,SPEN_CallerTitle__c,status,SPEN_AdditionalCaller__c,SPEN_JobType__c, SPEN_QuotationType__c, SPEN_CustomerClass__c,SPEN_RequiredPhase__c,SPEN_POCVoltage__c,SPEN_MeteringVoltage__c,SPEN_RequiredPower__c FROM Case WHERE Id =:cse.Id];
            
            SPEN_Plot__c plot=new SPEN_Plot__c(SPEN_CaseRecord__c=cse.Id);
			plot.SPEN_HeatingTypeDescription__c='36';
            Insert plot;
            
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiseList; 
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,ctnew.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c = '1234';
            conpremise.SPEN_Role__c = 'Customer';
            insert conpremise;
            List<Id> conpremList=new List<Id>();
            conpremList.add(conpremise.Id);
            List<Id> lstContactIds = new List<Id>();
            lstContactIds.add(upContact.id);
            lstContactIds.add(ct.id);
            lstContactIds.add(ctnew.id);
                
            system.assert(testAccount.size()>0, 'assert fail');
            SPEN_CasesConnectionService.UpdateBMSOMS(cseIns);
            SPEN_CasesConnectionService.updateAddressInfo(cseIns,lstContactIds);
            SPEN_CasesConnectionService.callSAPCalloutBeforeCompetent(cseIds);
            SPEN_CasesConnectionService.updatePaymentDecision(cseIns);
            Test.stopTest();
        }
    }


}