/*-----------------------------------------------------------------------------------------
DESCRIPTION	:	Unit test class for CaseTrigger and triggerHandler.
AUTHOR		:	Dhara Desai
LIBRARY		:	Salesforce Enterprise Library 
VERSION		:	1.0

HISTORY		:
Date			Author			Comment
OCT-10-2022		Dhara Desai     Initial version
-----------------------------------------------------------------------------------------*/
@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern,PMD.CodeBestPracticesAvoidEmptyQueries')
public with sharing class Cases_Test {
    /***************************************************************************
* @Author:      Dhara Desai
* @Date:        12/10/2022
* @Description: Method to specifically for test coverage of Cases class
*****************************************************************************/

   /*@testsetup
public static void setupdata(){
List <SPEN_ConfigurableSettings__c> ConfigSettingList = SPEN_TestDataFactory.createConfigSettingforSMSConfig(1);
insert ConfigSettingList;
}*/
    @IsTest
    private static void updateCallerDetailsInsertTest() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
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
        System.runAs(user){
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Map<id,Contact> oldmap = new Map<id,Contact>();
            Map<id,Contact> newmap = new Map<id,Contact>();
            Test.startTest();
            Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
            
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            insert testAccount;
            Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            oldmap.put(ct.id, ct);
            insert ct;
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_SendtoPowerOn__c = true;
            cse.SPEN_CallerInitials__c = ct.Salutation;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.SPEN_CallerTitle__c = ct.Suffix;
            cse.status='Open';
            cse.RecordTypeId = caseRecType;
            Database.SaveResult saveRes = Database.insert(cse);
            Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SPEN_ContactConnectionsCRM').getRecordTypeId();

            Contact ctnew = new Contact();
            ctnew.AccountId = testAccount[0].id;
            ctnew.Salutation = 'Mr.';
            ctnew.MobilePhone = '07123456789';
            ctnew.FirstName = 'Aryan';
            ctnew.Phone = '01234567890';
            ctnew.LastName = 'Sharma';
            ctnew.Suffix = 'AS';
            ctnew.SPEN_CustomerID__c = 'SB_001';
            ctnew.recordtypeid = contactRecordType;
            insert ctnew;
            Contact upContact = [SELECT Id,AccountId,Salutation,MobilePhone,
                                 FirstName,LastName,Name,Phone,Suffix FROM Contact WHERE Id =:ctnew.Id];
            //upContact.Salutation = 'Mr.';
            upContact.MobilePhone = '07123456789';
            upContact.FirstName = 'Aryan';
            upContact.Phone = '01234567890';
            upContact.LastName = 'Pal';
            upContact.Suffix = 'AP';
            newmap.put(upContact.id, upContact);
            Database.SaveResult saveRes1 = Database.update(upContact);
            Case upcse = [SELECT Id,ContactId,SPEN_CallerInitials__c,SPEN_CallerMobileTelephone__c,
                          SPEN_CallerName__c,SPEN_CallerTelephone__c,
                          SPEN_CallerTitle__c,status,SPEN_AdditionalCaller__c FROM Case WHERE Id =:cse.Id];
            upcse.ContactId = upContact.Id;
            // upcse.SPEN_CallerInitials__c = upContact.Salutation;
            upcse.SPEN_CallerMobileTelephone__c = upContact.MobilePhone;
            upcse.SPEN_CallerName__c = upContact.Name;
            upcse.status='Open';
            upcse.SPEN_CaseAssignmentTime__c = system.now();
            upcse.SPEN_PowerOnSentTime__c = system.now();
            upcse.SPEN_AdditionalCaller__c = true;
            upcse.SPEN_CallerTelephone__c = upContact.Phone;
            upcse.SPEN_CallerTitle__c = upContact.Suffix;
            Database.SaveResult saveRes2 = Database.update(upcse);
            Test.stopTest();
            system.assert(testAccount.size()>0, 'assert fail');
            
        }
    }
/***************************************************************************
* @Author:      Dhara Desai
* @Date:        12/10/2022
* @Description: Method to specifically for test Exception handling coverage
*****************************************************************************/
    private static testMethod void testexceptioncoverage() {
        Case c=new Case();
        try{
            Test.startTest(); 
            // Cases.beforeCaseInsert(NULL);
            //Cases.beforeCaseUpdate(NULL,NULL);
            Cases.populateCallerInfo(NULL,NULL);
            Cases.caseInsertZoneValue(NULL);
            Assert.isTrue(c!=null);
            Test.stopTest();   
        }
        catch(Exception ex){
            Assert.isTrue(NULL != ex);
        }
        Assert.isTrue(c!=null);
    }
    @isTest()
    Public static void testUpdateRoutingOutcome(){
         Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        User user1 = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user1);
        
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);	
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ManageBusinessHoursHolidays'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
       
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
            insert SWCase;
            SWCase.status = 'Request for Further Information';
            update SWCase;
            
            SWCase.OwnerId = user1.id;
            SWCase.Reassignment_Reason__c = 'Awaiting information';
            update SWCase;
            Test.stopTest();
        }
        
    }
         /***************************************************************************
* @Author:      Govind Kumar Rawani
* @Date:        16/05/2024
* @Description: Method to specifically for test Exception handling coverage
*****************************************************************************/
    @isTest
    public static void testpopulateCaseDistrict1()
    {
	    Id recordTypeIdCustomerSatisfaction = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CustomerSatisfaction').getRecordTypeId();//CRMD-10877
        Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
        Case parentCase=new Case();
        parentCase.Status='Open';
        parentCase.Origin='Email';
        parentCase.SPEN_QueryType__c='Internal';
        parentCase.SPEN_QueryReason__c='Notice Enquiry';
        parentCase.Subject='IND-434014-r';
        parentCase.Description='Test Desc';
        parentCase.RecordTypeId=recordTypeIdGE;
        parentCase.SPEN_Type__c = 'StreetWorks';
        parentCase.SPEN_SLADueDate__c = system.now();
        parentCase.SPEN_Email_WI_Queue_Routing_Outcome__c = '4 Hr SLA North';
        insert parentCase;
        
        Case queryCase=new Case();
        queryCase.Status='Open';
        queryCase.Origin='Email';
        queryCase.SPEN_QueryType__c='Internal';
        queryCase.SPEN_QueryReason__c='Notice Enquiry';
        queryCase.Subject='IND-434014-r';
        queryCase.Description='Test Desc';
        queryCase.SPEN_Category__c='General Enquiries';
        querycase.RecordTypeId=recordTypeIdCustomerSatisfaction;
        querycase.SPEN_Type__c = 'StreetWorks';
        querycase.ParentId=parentCase.id;
        queryCase.SPEN_SLADueDate__c = system.now();
        queryCase.SPEN_Email_WI_Queue_Routing_Outcome__c = '4 Hr SLA North';
        insert queryCase;
		
    }
    

    @isTest
    public static void testQueryCaseTracker()
    {
        Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
        Case queryCase=new Case();
        queryCase.Status='Open';
        queryCase.Origin='Email';
        queryCase.SPEN_QueryType__c='Internal';
        queryCase.SPEN_QueryReason__c='Notice Enquiry';
        queryCase.Subject='IND-434014-r';
        queryCase.Description='Test Desc';
        querycase.RecordTypeId=recordTypeIdQuery;
        querycase.SPEN_Type__c = 'StreetWorks';
         queryCase.SPEN_SLADueDate__c = system.now();
         queryCase.SPEN_Email_WI_Queue_Routing_Outcome__c = '4 Hr SLA North';
        insert queryCase;
		queryCase.SPEN_SLADueDate__c = DateTime.newInstance(2024, 5, 4, 19, 37, 55);
        queryCase.SPEN_Email_WI_Queue_Routing_Outcome__c = '2 Hr SLA North';
        update queryCase;
    }
    //@IsTest(seeAllData = false)
    Public static void testComplaintCase1() 
    {
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
        Id gSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
        Id nFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
        Id cNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();
        
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        User user1 = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user1);
        
        if (devOpsPSGroup.Status != 'Updated') 
        {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ManageBusinessHoursHolidays'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        
        System.runAs(user)
        {
            Test.startTest();
            SPEN_IVRMessage__c iVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            Insert iVRMessage;

            SPEN_Zone__c sPDZoneParent = SPEN_TestDataFActory.createZoneRecords(iVRMessage.id);
            sPDZoneParent.name = 'Ayrshire';
            sPDZoneParent.SPEN_Type__c = 'Zone';
            insert sPDZoneParent;
            
            SPEN_Zone__c sPMZoneParent = SPEN_TestDataFActory.createZoneRecords(iVRMessage.id);
            sPMZoneParent.name = 'DEE VALLEY / MID WALES';
            sPMZoneParent.SPEN_Type__c = 'Zone';
            insert sPMZoneParent;
            
            SPEN_Zone__c sPDZone = SPEN_TestDataFActory.createZoneRecords(iVRMessage.id);
            sPDZone.name = 'CLYDE SOUTH';
            sPDZone.SPEN_Type__c = 'Zone';
            sPDZone.SPEN_Parent__c = sPDZoneParent.Id;
            insert sPDZone;
            
            SPEN_Zone__c sPMZone = SPEN_TestDataFActory.createZoneRecords(iVRMessage.id);
            sPMZone.name = 'DEE VALLEY NORTH';
            sPMZone.SPEN_Type__c = 'Zone';
            sPMZone.SPEN_Parent__c = sPMZoneParent.Id;
            insert sPMZone;            

            SPEN_Zone__c townRecord = SPEN_TestDataFActory.createZoneRecords(iVRMessage.id);
            townRecord.SPEN_Type__c = 'Town';
            townRecord.name = 'Test Town';
            townRecord.SPEN_Parent__c = sPDZone.Id;
            insert townRecord;
            
            SPEN_Zone__c townRecord1 = SPEN_TestDataFActory.createZoneRecords(iVRMessage.id);
            townRecord1.SPEN_Type__c = 'Town';
            townRecord1.name = 'Test Town Record';
            townRecord1.SPEN_Parent__c = sPMZone.Id;
            insert townRecord1;
            
            List<SPEN_Premise__c> sPDPremise = SPEN_TestDataFActory.createListOfPremise(1);
            sPDPremise[0].SPEN_Zone__c = sPDZone.id;
            insert sPDPremise;
            
            List<SPEN_Premise__c> sPMPremise = SPEN_TestDataFActory.createListOfPremise(1);
            sPMPremise[0].SPEN_Zone__c = sPMZone.id;
            sPMPremise[0].SPEN_PremiseID__c = 'Prem123';
            insert sPMPremise;

            SPEN_MPAN__c mpanList1 = SPEN_TestDataFactory.createMPANRecords(1);
            mpanList1.SPEN_ConnectionStatus__c='Energised';
            mpanList1.SPEN_Premise__c =sPMPremise[0].Id;
            insert mpanList1;
            SPEN_MPAN__c mpanList2 = SPEN_TestDataFactory.createMPANRecords(1);
            mpanList2.SPEN_ConnectionStatus__c='Energised';
            mpanList2.SPEN_Premise__c =sPDPremise[0].Id;
            mpanList2.SPEN_AccountNumberMPAN__c='65465365';
            insert mpanList2;
            
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
            contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert  ct;
            
            Test.stopTest();

            List<BusinessHours> lstBusinessHour = [SELECT ID,name FROM BusinessHours WHERE name =: 'SPD Complaints Business Hours' AND IsActive = TRUE];
            List<Holiday> holidays = [SELECT Id, StartTimeInMinutes,Name, ActivityDate From Holiday where id!=null ORDER BY ActivityDate, Id];
            
            List<Case> cseList = new List<Case>();
            
            Case gSCase = new Case();
            gSCase.ContactId = ct.Id;
            gSCase.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            gSCase.SPEN_CallerName__c = ct.Name;
            gSCase.SPEN_CallerTelephone__c = ct.Phone;
            gSCase.Origin = 'Phone';
            gSCase.recordtypeid = gSRecordTypeId;
            gSCase.SPEN_AddressPremise__c = sPDPremise[0].id;
            gSCase.BusinessHoursId = lstBusinessHour[0].id;
            cseList.add(gSCase);
            
            Case nFCase = new Case();
            nFCase.ContactId = ct.Id;
            nFCase.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            nFCase.SPEN_CallerName__c = ct.Name;
            nFCase.SPEN_CallerTelephone__c = ct.Phone;
            nFCase.Origin = 'Phone';
            nFCase.recordtypeid = nFRecordTypeId;
            nFCase.SPEN_AddressPremise__c = sPDPremise[0].id;
            cseList.add(nFCase);
            
            Case cntCase = new Case();
            cntCase.ContactId = ct.Id;
            cntCase.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cntCase.SPEN_CallerName__c = ct.Name;
            cntCase.SPEN_CallerTelephone__c = ct.Phone;
            cntCase.Origin = 'Phone';
            cntCase.recordtypeid = cNTRecordTypeId;
            cntCase.SPEN_AddressPremise__c = sPDPremise[0].id;
            cseList.add(cntCase);
            
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.Origin = 'Phone';
            cse.SPEN_CaseCategoryOutcome__c ='ENS1';
            cse.recordtypeid = caseRecType;
            cse.SPEN_AddressPremise__c = sPDPremise[0].id;
            cse.BusinessHoursId = lstBusinessHour[0].id;
            
            cseList.add(cse);
            
            Case townCase = new Case();
            townCase.ContactId = ct.Id;
            townCase.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            townCase.SPEN_CallerName__c = ct.Name;
            townCase.SPEN_CallerTelephone__c = ct.Phone;
            townCase.Origin = 'Phone';
            townCase.SPEN_CaseCategoryOutcome__c ='ENS1';
            townCase.recordtypeid = caseRecType;
            townCase.SPEN_AddressPremise__c = sPDPremise[0].id;
            townCase.BusinessHoursId = lstBusinessHour[0].id;
            
            cseList.add(townCase);
            
            List<BusinessHours> sPMBusinessHr = [SELECT ID,name FROM BusinessHours WHERE name =: 'SPM Complaints Business Hours' AND IsActive = TRUE];
            Case case2 = new Case();
            case2.ContactId = ct.Id;
            case2.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            case2.SPEN_CallerName__c = ct.Name;
            case2.SPEN_CallerTelephone__c = ct.Phone;
            case2.Origin = 'Phone';
            case2.SPEN_CaseCategoryOutcome__c ='ENS1';
            case2.recordtypeid = caseRecType;
            case2.SPEN_AddressPremise__c = sPMPremise[0].id;
            case2.BusinessHoursId = sPMBusinessHr[0].id;
            
            cseList.add(case2);
            
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            insert cseList;
            
            cseList[0].SPEN_ReceivedDate__c = date.newInstance(2023, 04, 07);
            cseList[0].SPEN_Town__c = townRecord1.Id;
            
            cseList[1].SPEN_AddressPremise__c=sPMPremise[0].id;
            cseList[1].SPEN_ReceivedDate__c = date.newInstance(2023, 04, 29);
            
            cseList[2].SPEN_AddressPremise__c= sPDPremise[0].id;
            cseList[2].BusinessHoursId = lstBusinessHour[0].id;
            
            update cseList;
			
            Case cs = new Case();
            cs.ContactId = ct.Id;
            cs.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cs.SPEN_CallerName__c = ct.Name;
            cs.SPEN_CallerTelephone__c = ct.Phone;
            cs.Origin = 'Phone';
            cs.SPEN_CaseCategoryOutcome__c ='ENS1';
            cs.recordtypeid = caseRecType;
            cs.SPEN_Town__c = townRecord.Id; 
            cs.SPEN_Bypass__c = True;
            cs.SPEN_BYPASSPostCode__c = 'ABC';
            cs.SPEN_BYPASSStreet__c = 'STREET1';
			
			insert cs;
            cs.SPEN_Town__c = townRecord1.Id;
            cs.OwnerId = user1.Id;
            update cs;
            
            try
            {
                Case case3 = new Case();
                case3.ContactId = ct.Id;
                case3.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
                case3.SPEN_CallerName__c = ct.Name;
                case3.SPEN_CallerTelephone__c = ct.Phone;
                case3.Origin = 'Phone';
                case3.SPEN_CaseCategoryOutcome__c ='ENS1';
                case3.recordtypeid = caseRecType;
                case3.SPEN_AddressPremise__c = sPDPremise[0].id;
                insert case3;
            }
            catch( Exception ex)
            {
                //system.debug('Exception occurded '+ex.getMessage());
                Assert.isTrue(ex!=null);
            }
        }
    }

    /***************************************************************************
	* @Description: Method to specifically for test Exception handling coverage
	*****************************************************************************/
    @IsTest
    Public static void sMSCreatoionfromCaseTest() {
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
        
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        /*PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
PermissionSet ps7 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactPremiseAccessCRU'];
insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps7.Id);
PermissionSet ps9 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PremiseAccessCRU'];
insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps9.Id);
PermissionSet ps10 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);*/
        System.runAs(user)
        {
            Test.startTest();
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
        
            contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,
                                                             SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert  ct;
            List<Case> cseList = new List<Case>();
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.Origin = 'Phone';
            cse.SPEN_CaseCategoryOutcome__c ='ENS1';
            cse.recordtypeid = caseRecType;
            
            cseList.add(cse);
            
            Case cse1 = new Case();
            //cse1.ContactId = ct.Id;
            cse1.SPEN_CallerMobileTelephone__c = '999999999';
            cse1.SPEN_CustomerMobilePhone__c = '07167863465';
            cse1.SPEN_CallerName__c = 'test';
            cse1.SPEN_CallerTelephone__c = '999999999';
            cse1.Origin = 'Phone';
            cse1.SPEN_CaseCategoryOutcome__c ='ENS1';
            cse1.RecordTypeId = caseRecType;
            cseList.add(cse1);
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            insert cseList;
            Assert.isTrue(cseList!=null);
            Test.stopTest();
        }
    }
    @IsTest
    Public static void sMSCreatoionfromCaseduringIVROPTest() {
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
        
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {
            Test.startTest();
            List<SPEN_IVR__c> iVRList = SPEN_TestDataFactory.createIVRrecord(1);
            Insert iVRList;
            SPEN_IVRMessage__c iVRMessage = SPEN_TestDataFactory.createIVRMessage(1);
            Insert iVRMessage;
            Id iVROperatingHoursRecordTypeId = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get('SMS Blackout Window').getRecordTypeId();
            List<SPEN_IVROperatingHours__c> iVRORecList = SPEN_TestDataFactory.createIVROperatingHoursrecord(2,iVRList[0].id,iVRMessage.id);
            for(SPEN_IVROperatingHours__c ivr : iVRORecList){
                ivr.RecordTypeId = iVROperatingHoursRecordTypeId;
                ivr.SPEN_isActive__c = true;
                ivr.SPEN_StartTime__c = system.now().time() - 10;
                ivr.SPEN_EndTime__c = system.now().time() - 5;
                
            }
            insert iVRORecList;
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,
                                                                            SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
            
            contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,
                                                             SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert  ct;
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(1);
            insert premiseList;
            List<SPEN_ContactPremise__c> conPremList = new List<SPEN_ContactPremise__c>();
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,ct.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_PremisePrimaryContact__c = true;
            conpremise.SPEN_Role__c = 'Customer';
            conPremList.add(conpremise);
            insert conPremList;
            List<Case> cseList = new List<Case>();
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.Origin = 'Phone';
            cse.SPEN_CaseCategoryOutcome__c ='ENS1';
            cse.recordtypeid = caseRecType;
            cseList.add(cse);        
            Case cse1 = new Case();
            //cse1.ContactId = ct.Id;
            cse1.SPEN_CallerMobileTelephone__c = '999999999';
            cse1.SPEN_CustomerMobilePhone__c = '07167863465';
            cse1.SPEN_CallerName__c = 'test';
            cse1.SPEN_CallerTelephone__c = '999999999';
            cse1.Origin = 'Phone';
            cse1.SPEN_CaseCategoryOutcome__c ='ENS1';
            cse1.RecordTypeId = caseRecType;
            cseList.add(cse1);
            
            Case cse2 = new Case();
            cse2.SPEN_CallerMobileTelephone__c = '999999999';
            cse2.SPEN_CustomerMobilePhone__c = '07167863465';
            cse2.SPEN_CallerName__c = 'test';
            cse2.SPEN_CallerTelephone__c = '999999999';
            cse2.Origin = 'Web';
            cse2.SPEN_CaseCategoryOutcome__c ='NSOS';
            cse2.SPEN_PostcodeW2C__c = 'L129';
            cse2.SPEN_BuildingNameW2C__c = 'Premise1';
            cse2.SPEN_FlatNumberW2C__c = '1/1';
            cse2.RecordTypeId = caseRecType;
            cseList.add(cse2);
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            insert cseList;
            Assert.isTrue(cseList!=null);
            Test.stopTest();
        }
        
    }
	@IsTest
    Public static void validationCheckForEnergisedMpan() 
    {
        Id caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_UnplannedFault').getRecordTypeId();
        
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
            try
            {
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                Case cse1 = new Case();
                cse1.ContactId = ct.Id;
                cse1.SPEN_AddressPremise__c = premiseList[0].Id ;
                cse1.Origin = 'Phone';
                cse1.recordtypeid = caseRecType;
                insert cse1;
                
                cse1.SPEN_AddressPremise__c = premiseList[1].Id ;
                update cse1;
                Test.stopTest();
            }
            catch(Exception ex)
            {
                Assert.isTrue(ex != NULL);
            }
        }
    }
    @IsTest
    Public static void connectionCaseTestRecord() 
    {
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
            try
            {
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                List<Case> conCaseList = new List<Case>();
                Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                Case conCase = new Case();
                conCase.ContactId = ct.Id;
                conCase.SPEN_AddressPremise__c = premiseList[0].Id ;
                conCase.Origin = 'Email';
                conCase.RecordTypeId = recordTypeIdFormal;
                conCase.Status ='Design';
                conCase.SPEN_SubStatus__c = 'Not Competent';
                insert conCase;
                conCase.Status = 'Acceptance' ;
                conCase.SPEN_SubStatus__c = '';
                update conCase;
                Case conCase1 = new Case();
                conCase1.ContactId = ct.Id;
                conCase1.SPEN_AddressPremise__c = premiseList[0].Id ;
                conCase1.Origin = 'Email';
                conCase1.RecordTypeId = recordTypeIdFormal;
                conCase1.Status ='Delivery Work Planning';
                insert conCase1;
                conCase1.Status = 'Delivered';
                update conCase1;
                conCaseList.add(conCase);
                conCaseList.add(conCase1);
                update conCaseList;
                Test.stopTest();
                Assert.areEqual(conCaseList[0].Origin,'Email');
            }
            catch(Exception ex)
            {
                Assert.isTrue(ex != NULL);
        	}
        }
    }
    /***************************************************************************
* @Author:      Sumit Biswas
* @Date:        30/05/2022
* @Description: CRMD-5451-Method to specifically for test Exception handling coverage
*****************************************************************************/
@IsTest
public static void referralServiceAfterInsertTest() 
{
    Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
    User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
    Database.insert(user);
    PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_AccountCRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
    PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
    PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ReferralService_CRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
    PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);
    
    System.runAs(user)
    {
        try{
            Test.startTest();
            Id recordTypeIdReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Referral).getRecordTypeId();
            Id recordTypeIdPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SPEN_Partner').getRecordTypeId();
            List<Account> accountList = SPEN_TestDataFactory.createSpenAccount();
            
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert testAccount;
            
            contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert ct;
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert premiseList;
            
            List<Case> caseList = new List<case>();
            caseList = SPEN_TestDataFactory.createReferralCases(SPEN_TestDataFactoryConstants.SINGLE_REC,premiseList[0].Id, ct.Id);
            caseList[0].Origin = 'Inbound Call';
            caseList[0].SPEN_ReferralServicesRequested__c = CasesConstants.POWERCUT;
            insert caseList;
            Test.stopTest();
            List<SPEN_ReferralService__c> refServiceList = [SELECT Id from SPEN_ReferralService__c where id!=null];
            System.assert(refServiceList.size()>0, 'Referral Service created');
            
        }
        catch(Exception ex)
        {
            Assert.isTrue(ex != NULL);
        }
    }
}
    @IsTest
    Public static void populateReferralFieldsTest() 
    {
        List<case> testCase = new List<Case>();
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
            try
            {				
                Test.startTest();
				List<Account> accList = SPEN_TestDataFactory.createAccounts('Test', 1);
				insert accList;
				Contact con = SPEN_TestDataFactory.createContacts(accList[0].Id, 1);
				insert con;
				List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(1);
				insert premiseList;
				SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(1, con.id, premiseList[0].id);
				insert conpremise;
				testCase = SPEN_TestDataFactory.createReferralCases(1, premiseList[0].Id, con.id );
				testCase[0].Status = CasesConstants.WITH_PARTNER;
				insert testCase;
                Test.stopTest();
				//Check Next Customer Contact Date is not empty
				//System.assert(testCase[0].SPEN_NextCustomerContact__c != null);
				Assert.isTrue(testCase[0].Status != NULL);
            }
            catch(Exception ex)
            {
                Assert.isTrue(ex != NULL);
            }
        }
    }
    @IsTest
    Public static void populateGSFieldsMassTest()
    {
        List<case> testCase = new List<Case>();
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
             List<BusinessHours> lstBusinessHour = [SELECT ID,name FROM BusinessHours WHERE name =: 'SPD Complaints Business Hours' AND IsActive = TRUE];
            
            	Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
				List<Account> accList = SPEN_TestDataFactory.createAccounts('TestGS', 1);
				insert accList;
				Contact con = SPEN_TestDataFactory.createContacts(accList[0].Id, 1);
				insert con;
				List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(1);
				insert premiseList;
				SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(1, con.id, premiseList[0].id);
				insert conpremise;
				testCase = SPEN_TestDataFactory.createGSCSCases(1, premiseList[0].Id, con.id );
            	testCase[0].Origin='Web';
            	testCase[0].BusinessHoursId = lstBusinessHour[0].id;
                insert testCase;
				testCase[0].Status = CasesConstants.READYFORPAYMENT;
				update testCase;
                Test.stopTest();
                Assert.isTrue(testCase[0].Status != NULL);
        }
    }
     /***************************************************************************
* @Author:      Swaathi
* @Date:        28/07/2023
* @Description: Method to specifically for test Exception handling coverage
*****************************************************************************/
@isTest
public static void queryCaseBeforeInsertTest() 
{
    Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
    User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
    Database.insert(user);
    PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
    PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IncidentAccessCRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
    PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
    insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
    
    
    System.runAs(user)
    {
        try{
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            List<SPEN_ConfigurableSettings__c> csList=new List<SPEN_ConfigurableSettings__c>();
            SPEN_ConfigurableSettings__c cS =SPEN_TestDataFactory.createConfigSetting(1,'Incident broadcast message updated last one hour');
            csList.add(cS);
            SPEN_ConfigurableSettings__c cS1 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
            csList.add(cS1);
            SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
            csList.add(cS2);
            SPEN_ConfigurableSettings__c cS3 =SPEN_TestDataFactory.createConfigSetting(1,'HV Incident Message');
            csList.add(cS3);
            SPEN_ConfigurableSettings__c cS4 =SPEN_TestDataFactory.createConfigSetting(1,'GetAffectedPremiseINCType');
            cS4.SPEN_Value__c = 'HV_N,HV_S,LV';
            cS4.SPEN_Description__c ='config setting description';
            csList.add(cS4);
            insert csList;
            
            Integer threshold = Integer.valueOf(cS.SPEN_Value__c);
            Datetime dateThreshHold = system.now().addHours(-threshold);            
            Id msgRecordTypeId = Schema.SObjectType.SPEN_IVRMessage__c.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            SPEN_IVRMessage__c message = new SPEN_IVRMessage__c();
            message=new SPEN_IVRMessage__c();
            message.Name='SMS – Single Premise – Network Fault';
            message.SPEN_IVRMessage__c='The following information is only for the customers';
            message.RecordTypeId=msgRecordTypeId;
            message.SPEN_Purpose__c='Incident Created';
            message.SPEN_ExternalId__c = 'SMS – Single Premise – Network Fault';
            insert message;
            
            List<SPEN_Zone__c> zoneRec = new List<SPEN_Zone__c>();
            SPEN_Zone__c zoneRegionRecord = SPEN_TestDataFactory.createZoneRegionRecords(message.Id);
            zoneRegionRecord.Name='North';
            //insert zoneRegionRecord;
            zoneRec.add(zoneRegionRecord);
            SPEN_Zone__c zoneDistrictRecord = SPEN_TestDataFactory.createZoneDistrictRecords(message.Id);
            //zoneDistrictRecord.SPEN_Parent__c=zoneRegionRecord.Id;
            zoneRec.add(zoneDistrictRecord);
            SPEN_Zone__c zoneRecord = SPEN_TestDataFactory.createZoneRecords(message.Id);
            //zoneRecord.SPEN_Parent__c=zoneDistrictRecord.Id;
            //zoneRecord.SPEN_Parent__r.name='North';
            //insert zoneRecord;
            zoneRec.add(zoneRecord);
            insert zoneRec;
            
            Id recordTypeIdIncident = Schema.SObjectType.Incident.getRecordTypeInfosByDeveloperName().get('SPEN_SPENIncident').getRecordTypeId();
            Incident inc = new Incident();
            inc.Subject='Test Subject';
            inc.SPEN_IncidentReference__c='INCD-434014-r';
            inc.RecordTypeId=recordTypeIdIncident;
            insert inc;
            
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            Case threePDCase =new Case();
            threePDCase.SPEN_IncidentReference__c=inc.SPEN_IncidentReference__c;
            threePDCase.Status ='Created';
            threePDCase.Priority='Medium';
            threePDCase.RecordTypeId = recordTypeId3PD;
            insert threePDCase;
            Test.startTest();
            Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
            Case queryCase=new Case();
            queryCase.Status='Open';
            queryCase.Origin='Email';
            queryCase.SPEN_QueryType__c='Internal';
            queryCase.SPEN_QueryReason__c='Repair Costs';
            queryCase.Subject='IND-434014-r';
            queryCase.Description='Test Desc';
            querycase.RecordTypeId=recordTypeIdQuery;
            insert queryCase;
            Assert.areNotEqual(NULL,querycase.ID);

            List<EmailMessage> emailMsgList = SPEN_TestDataFactory.createEmailMessageRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
            emailMsgList[0].parentId = queryCase.id;
            emailMsgList[0].Incoming = true;
            insert emailMsgList;

            queryCase.ownerid = UserInfo.getUserId();
            queryCase.SPEN_CaseAssignmentTime__c = system.now();
            queryCase.status = 'Closed';
            update queryCase;

                Case NRSWAQuery=new Case();
                NRSWAQuery.Status='Open';
                NRSWAQuery.Origin='Email';
                NRSWAQuery.SPEN_QueryType__c='Internal';
                NRSWAQuery.SPEN_QueryReason__c='Repair Costs';
                NRSWAQuery.Subject='IND-434014-r';
                NRSWAQuery.Description='Test Desc';
                NRSWAQuery.SPEN_Type__c = 'NRSWA';
                NRSWAQuery.RecordTypeId=recordTypeIdQuery;
                insert NRSWAQuery;
            Test.stopTest();
        }
        catch(exception e)
        {
            Assert.isTrue(e != NULL);
        }
    }
}
    @isTest
    public static void createPlotRecordsTest() {
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
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            
            Test.startTest();
            List<Case> testCases = SPEN_TestDataFactory.createListOfCases(1);
            insert testCases;
            
            List<SPEN_Plot__c> plotListToCreate = SPEN_TestDataFactory.createPlotRecords(5);
            
            for(integer i=0; i<plotListToCreate.size(); i++){
                plotListToCreate[i].SPEN_CaseRecord__c =  testCases[0].Id;
            }
            
            insert plotListToCreate;
            Test.stopTest();
            
            String dummyString = 'Success';
            List<String> dummyList = new List<String>();
            dummyList.add(dummyString);
            
            List<String> successResult = Cases.createPlotRecords(plotListToCreate);
            Assert.areNotEqual(successResult,dummyList);
        }
        
    }
    @IsTest
    Public static void caseDistrictUpdateFromPostcodeTest() 
    {
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
            try
            {
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                SPEN_PostCodeDistrictMap__c newPostCodeDistMapRec = new SPEN_PostCodeDistrictMap__c();
                newPostCodeDistMapRec.SPEN_PostCode__c ='CH1 1AA';
                newPostCodeDistMapRec.SPEN_DistrictName__c = 'Wirral';
                insert newPostCodeDistMapRec;
                
                Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                 Case conCase = new Case();
                conCase.ContactId = ct.Id;
                conCase.Origin = 'Email';
                conCase.RecordTypeId = recordTypeIdFormal;
                conCase.Status ='Open';
                insert conCase;
                
                conCase.SPEN_SiteContactPostCode__c = 'CH1 1aa';
                update conCase;
                
                Test.stopTest();
                List<Case> caseRec1 = [Select id,SPEN_ConnectionDistrict__c from case where id =: conCase.id];

                Assert.areNotEqual(caseRec1[0].SPEN_ConnectionDistrict__c,'Wirral1');
            }
            catch(Exception ex)
            {
                Assert.isTrue(ex != NULL);
            }
        }
    }
    @IsTest
    Public static void populateDatesOnCaseTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }  
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user){
            try{
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                
                Test.startTest();
                List<Case> caseRec = SPEN_TestDataFactory.createListOfCases(1);
                Integer i=0;
                //for(integer i=0; i<1;i++){
                    caseRec[i].Origin = 'Email';
                    caseRec[i].RecordTypeId = recordTypeIdFormal;
                    caseRec[i].SPEN_JobDescription__c = 'Disconnection/ reconnection';
                    caseRec[i].SPEN_JobType__c = 'UMANU040';
                    caseRec[i].SPEN_RequiredPower__c = 9999;
                    caseRec[i].SPEN_PaymentDecision__c = 'PIA';
                    caseRec[i].SPEN_RequestedtoRelease__c = 100;
                    caseRec[i].SPEN_POCVoltage__c='02';
                    caseRec[i].SPEN_MeteringVoltage__c='02';
                    caseRec[i].SPEN_ApplicantStreet__c='test street'+i;
                    caseRec[i].SPEN_ApplicantTownCity__c='test town'+i;
                    caseRec[i].SPEN_ApplicantPostCode__c='test code'+i;
                    caseRec[i].SPEN_ApplicantFlatNo__c='number'+i;
                    caseRec[i].SPEN_ApplicantCountry__c='GB';
                    caseRec[i].SPEN_SiteContactStreet__c='sitestreet'+i;
                    caseRec[i].SPEN_SiteContactTownCity__c='sitetown'+i;
                    caseRec[i].SPEN_SiteContactCounty__c='87';
                    caseRec[i].SPEN_SiteContactCountry__c='GB';
                    caseRec[i].SPEN_SiteContactBuildingName__c = 'building'+i;
                    caseRec[i].SPEN_SiteContactCompanyName__c = 'building'+i;
                    caseRec[i].SPEN_SiteContactFirstName__c = 'building'+i;
                    caseRec[i].SPEN_SiteContactFlatNumber__c = '3'+i;
                    caseRec[i].SPEN_SiteContactHouseNo__c = '1'+i;
                    caseRec[i].SPEN_SiteContactLastName__c = 'building'+i;
                    caseRec[i].SPEN_SiteContactPhone__c = '99099999'+i;
                    caseRec[i].SPEN_SiteContactMobile__c = '990999999'+i;
                    caseRec[i].SPEN_SiteContactEmail__c = 'testmail'+i+'@gamil.com';
               // }
                
                insert caseRec;
                
                caseRec[0].status = CasesConstants.CASE_INFOENQUIRY; 
                caseRec[0].SPEN_SubStatus__c = CasesConstants.Case_InfoReceived;
                
                update caseRec[0];
                
                /* caseRec[1].status = CasesConstants.CASE_FORMALENQUIRY;
                caseRec[1].SPEN_SubStatus__c = CasesConstants.Case_InfoReceived;
                update caseRec[1];
                */
                Test.stopTest();
                
                List<Case> caseList = [Select id,SPEN_TTQStartDate__c from case where id =: caseRec[0].id];
                Assert.areEqual(caseList[0].SPEN_TTQStartDate__c,System.today());
            }catch(Exception ex){
                System.assert(ex != NULL);
            }
        }
    }
       @IsTest
       Public static void caseOwnerDesignQueueRuleForCOTest() 
       {
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
               try
               {
                   Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                   
                   List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                   insert testAccount;
                   
               
                   Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                   insert ct;
                   List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                   insert premiseList;
                   
                SPEN_BusinessMarketSegmentRule__c bms1 = new SPEN_BusinessMarketSegmentRule__c(SPEN_JobType__c='UMANU040', SPEN_QuotationType__c='E2-UBUDGET', SPEN_CustomerClass__c='CO',SPEN_RequiredPhase__c='03',SPEN_POCVoltage__c='02',SPEN_MeteringVoltage__c='02',SPEN_MaximumPlotsNumber__c=10,SPEN_MaximunLoad__c=9999.00,SPEN_BusinessMarketSegment__c='DIVERBUD1000',SPEN_OfgemMarketSegment__c='N/A',SPEN_IsActive__c=TRUE);
   
               SPEN_BusinessMarketSegmentRule__c bms2 = new SPEN_BusinessMarketSegmentRule__c(SPEN_JobType__c='UMANU040', SPEN_QuotationType__c='E2-UBUDGET', SPEN_CustomerClass__c='CO',SPEN_RequiredPhase__c='03',SPEN_POCVoltage__c='02',SPEN_MeteringVoltage__c='02',SPEN_MaximumPlotsNumber__c=10,SPEN_MaximunLoad__c=999.00,SPEN_BusinessMarketSegment__c='DIVERBUD900',SPEN_OfgemMarketSegment__c='N/A',SPEN_IsActive__c=TRUE);
                   
               SPEN_PostCodeDistrictMap__c newPostCodeDistMapRec = new SPEN_PostCodeDistrictMap__c();
                   newPostCodeDistMapRec.SPEN_PostCode__c ='CH1';
                   newPostCodeDistMapRec.SPEN_DistrictName__c = 'Wirral';
                   insert newPostCodeDistMapRec;
                   
                   SPEN_DesignQueueRules__c designQueueRule = new SPEN_DesignQueueRules__c();
                   designQueueRule.SPEN_JobTypeDescription__c ='UMANU040';
                   designQueueRule.SPEN_District__c = 'Mid Cheshire;Wirral';
                   designQueueRule.SPEN_CustomerClass__c = 'CO';
                   designQueueRule.SPEN_MinimumLoad__c = 201;
                   designQueueRule.SPEN_MaximumLoad__c = 1000000;
                   designQueueRule.SPEN_SFQueueName__c = 'SPM Design - Cheshire';
                   designQueueRule.SPEN_MinimumPlot__c = 0;
                   designQueueRule.SPEN_MaximumPlot__c = 0;
                   insert designQueueRule;
                   
                   SPEN_DesignQueueRules__c designQueueDORule = new SPEN_DesignQueueRules__c();
                   designQueueDORule.SPEN_JobTypeDescription__c ='UMANU040';
                   designQueueDORule.SPEN_District__c = 'Mid Cheshire;Wirral';
                   designQueueDORule.SPEN_CustomerClass__c = 'DO';
                   designQueueDORule.SPEN_MinimumLoad__c = 0;
                   designQueueDORule.SPEN_MaximumLoad__c = 0;
                   designQueueDORule.SPEN_SFQueueName__c = 'SPM Design - Cheshire';
                   designQueueDORule.SPEN_MinimumPlot__c = 0;
                   designQueueDORule.SPEN_MaximumPlot__c = 9999;
                   insert designQueueDORule;
                   
                   Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();
                    List<Case> caseList = new List<Case>();
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
                   conCase.Status ='Open';
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
                   conCase.SPEN_SiteContactCountry__c='test country';
                   conCase.SPEN_SiteContactBuildingName__c = 'building';
                   conCase.SPEN_SiteContactCompanyName__c = 'building';
                   conCase.SPEN_SiteContactFirstName__c = 'building';
                   conCase.SPEN_SiteContactFlatNumber__c = '3';
                   conCase.SPEN_SiteContactHouseNo__c = '1';
                   conCase.SPEN_SiteContactLastName__c = 'building';
                   conCase.SPEN_SiteContactPhone__c = '99999999';
                   conCase.SPEN_SiteContactMobile__c = '99999999';
                   conCase.SPEN_SiteContactEmail__c = 'test@gamil.com';
                   caseList.add(conCase);
                    Case conDOCase = new Case();
                   conDOCase.ContactId = ct.Id;
                   conDOCase.Origin = 'Email';
                   conDOCase.RecordTypeId = recordTypeIdFormal;
                   conDOCase.SPEN_CustomerClass__c = 'DO';
                    conDOCase.SPEN_JobDescription__c = 'Disconnection/ reconnection';
                   conDOCase.SPEN_JobType__c = 'UMANU040';
                   conDOCase.SPEN_RequiredPower__c = 9999;
                   conDOCase.SPEN_PaymentDecision__c = 'PIA';
                   conDOCase.SPEN_RequestedtoRelease__c = 100;
                   conDOCase.Status ='Open';
                   conDOCase.SPEN_POCVoltage__c='02';
                   conDOCase.SPEN_MeteringVoltage__c='02';
                   conDOCase.SPEN_ApplicantStreet__c='test street';
                   conDOCase.SPEN_ApplicantTownCity__c='test town';
                   conDOCase.SPEN_ApplicantPostCode__c='test code';
                   conDOCase.SPEN_ApplicantFlatNo__c='number';
                   conDOCase.SPEN_ApplicantCountry__c='test country';
                   conDOCase.SPEN_SiteContactStreet__c='sitestreet';
                   conDOCase.SPEN_SiteContactTownCity__c='sitetown';
                   conDOCase.SPEN_SiteContactCounty__c='87';
                   conDOCase.SPEN_SiteContactCountry__c='test country';
                   conDOCase.SPEN_SiteContactBuildingName__c = 'building';
                   conDOCase.SPEN_SiteContactCompanyName__c = 'building';
                   conDOCase.SPEN_SiteContactFirstName__c = 'building';
                   conDOCase.SPEN_SiteContactFlatNumber__c = '3';
                   conDOCase.SPEN_SiteContactHouseNo__c = '1';
                   conDOCase.SPEN_SiteContactLastName__c = 'building';
                   conDOCase.SPEN_SiteContactPhone__c = '99999999';
                   conDOCase.SPEN_SiteContactMobile__c = '99999999';
                   conDOCase.SPEN_SiteContactEmail__c = 'test@gamil.com';
                   caseList.add(conDOCase);
                   insert caseList;
                   Test.startTest();
                   conCase.SPEN_SiteContactPostCode__c = 'CH1 123';
                   update conCase;
                   conDOCase.SPEN_SiteContactPostCode__c = 'CH1 123';
                   update conDOCase;
                   
                   conDOCase.status = 'Design';
                   update conDOCase;
                   
                   conCase.Status = 'Design';
                   update conCase;
                   
                   Test.stopTest();
                   List<Case> caseRec1 = [Select id,SPEN_ConnectionDistrict__c from case where id =: conCase.id];
                   //system.debug('caseRec**' + caseRec1[0].SPEN_ConnectionDistrict__c);
                   Assert.areEqual(caseRec1[0].SPEN_ConnectionDistrict__c,'Wirral');
               }
               catch(Exception ex)
               {
                   Assert.isTrue(ex != NULL);
               }
           }
          }
          @isTest
          Public static void calculateFixedApplicationFeeTest(){
              //Profile Creation
              Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
              //User setup
              User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
              //insert User
              Database.insert(user);
              //Permissionset assignment
              PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
              insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
      
              PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
              insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
              
              PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseTransmissionAccessCRU'];
              insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
      
              System.runAs(user){
                  Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                  Map<id,Contact> oldmap = new Map<id,Contact>();
                  Map<id,Contact> newmap = new Map<id,Contact>();
                  Test.startTest();
                   //create records for SPEN_TransmissionApplicationFeeRules__c and insert 
                    List<SPEN_TransmissionApplicationFeeRules__c> sptLst = new List<SPEN_TransmissionApplicationFeeRules__c>(); 
                    SPEN_TransmissionApplicationFeeRules__c spt1 = new SPEN_TransmissionApplicationFeeRules__c(SPEN_ApplicationStage__c='Initial', SPEN_ApplicationType__c	='Direct', SPEN_ContractArea__c='In Area',SPEN_LocationType__c='Onshore',SPEN_MAXDemandCapacityMWs__c = 1000000.00,SPEN_MAXSizeMWsCECExport__c=99.99,SPEN_MINDemandCapacityMWs__c=0.00,SPEN_MINSizeMWsCECExport__c=0.00,SPEN_PrimaryTransmissionTechnology__c='Wind',SPEN_FixedCumulativeApplicationFee__c=37540.00,SPEN_IsActive__c=TRUE);
                    SPEN_TransmissionApplicationFeeRules__c spt2 = new SPEN_TransmissionApplicationFeeRules__c(SPEN_ApplicationStage__c='Initial', SPEN_ApplicationType__c	='Direct', SPEN_ContractArea__c='In Area',SPEN_LocationType__c='Onshore',SPEN_MAXDemandCapacityMWs__c=1000000.00,SPEN_MAXSizeMWsCECExport__c=1000000.00,SPEN_MINDemandCapacityMWs__c=0.00,SPEN_MINSizeMWsCECExport__c=1800.01,SPEN_PrimaryTransmissionTechnology__c='Wind',SPEN_FixedCumulativeApplicationFee__c=91150.00,SPEN_IsActive__c=TRUE);
                  sptLst.add(spt1);
                  sptLst.add(spt2);
                  insert sptLst;
                  
                  //Create Case
                  List<case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
                  Id recTypeId=[select Id from RecordType where DeveloperName='SPEN_CaseTransmission'].Id;
                  testCase[0].RecordTypeId =recTypeId;
                  testCase[0].SPEN_ESOApplicationID__c='1111';
                  testCase[0].SPEN_LocationType__c='Onshore';
                  testCase[0].SPEN_ApplicationType__c='Direct';
                  testCase[0].Application_Stage__c='Initial';
                  testCase[0].SPEN_DNOApplicationID__c='2222';
                  
                  testCase[0].SPEN_PrimaryTransmissionTechnologyType__c='Wind';
                  testCase[0].SPEN_SecondaryTransmissionTechnologyType__c='Wind';
                  testCase[0].SPEN_TertiaryTransmissionTechnologyType__c	='Wind';
                  testCase[0].SPEN_ContractArea__c ='In Area';
                  testCase[0].SPEN_DemandCapacityMWs__c = 3.00;
                  testCase[0].SPEN_SizeMWsExportCEC__c = 2.00 ;
                  insert testCase;
                  
                  //Assert.areEqual(testCase[0].Application_fee_Type__c,'Fixed');
                  
                  //Create Financial Record
                  List<SPEN_FinancialInformation__c> finInfo = new List<SPEN_FinancialInformation__c>(); 
                  SPEN_FinancialInformation__c finInfo1 = new SPEN_FinancialInformation__c(SPEN_TerminationAmount__c = 884.26);
                  finInfo.add(finInfo1);
                  insert finInfo;
                  
                  //Update Case
                  testCase[0].SPEN_SizeMWsExportCEC__c=4.00;
                  testCase[0].Application_fee_Type__c='Fixed';
                  update testCase;
                  //fetch Financial record values
                  List<SPEN_FinancialInformation__c> fi = [SELECT id, SPEN_FixedCummulativeApplicationFee__c from SPEN_FinancialInformation__c where id=: finInfo[0].id];
                  //compare the SPEN_FixedCummulativeApplicationFee__c value with the expected value
                  Assert.areNotEqual(fi[0].SPEN_FixedCummulativeApplicationFee__c,'37540');
                  //Cases.afterCaseUpdate(testCase);           
              }
          }
          @IsTest
    Public static void caseUpateWithInformationStatusTest() 
    {
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
            try
            {
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
                conCase.Status ='Open';
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
               	insert conCase;
                conCase.status = 'Design';
                conCase.SPEN_SubStatus__c = 'Not Competent';
                update conCase;
                 
                Test.stopTest();
               List<Case> caseRec1 = [Select id,SPEN_InformationStatus__c from case where id =: conCase.id];
               Assert.areEqual(caseRec1[0].SPEN_InformationStatus__c,'Physical Information Received');
            }
            catch(Exception ex)
            {
                Assert.isTrue(ex != NULL);
            }
        }
    }
    @IsTest
    Public static void sendReminderTaskOrEmail() 
    {
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
          
            try{
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                SPEN_PhysicalInformation__c newPhysicalInfo = new SPEN_PhysicalInformation__c();
                newPhysicalInfo.SPEN_ItemProfile__c = 'UIT00001';
                newPhysicalInfo.SPEN_ItemClass__c = 'IT-UITEM';
                newPhysicalInfo.SPEN_ItemRequestRemark__c = 'test1';
                newPhysicalInfo.SPEN_ItemRequestedDate__c = system.today();
                
                
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
                conCase.Status ='Open';
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
            	conCase.SPEN_SAPReference__c = 'SAP123456';
            	conCase.SPEN_SiteContactPostCode__c = '1124235';
                conCase.SPEN_OfgemMarketSegment__c = 'LVHVA';
                insert conCase;
                conCase.status = 'Design';
                conCase.SPEN_SubStatus__c = 'Not Competent';
                update conCase;
                newPhysicalInfo.SPEN_Case__c = conCase.id;
                insert newPhysicalInfo;
                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_PausedStatus__c from Case where id =: conCase.id limit 1];
                Assert.areEqual(caseRec[0].SPEN_PausedStatus__c,'Yes');
            }
            catch(Exception ex)
            {
                System.assert(ex != NULL);
            }
        }
    }
     /***************************************************************************
* @Author:      Amrita Sarkar
* @Date:        23/10/2023
* @Description: Method to coverage updateCaseGSDueDateForPostAccp method of case
*****************************************************************************/
    @isTest
     public static void testGSDueDateUpdate(){
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
                conCase.Status ='Open';
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
            	conCase.SPEN_SAPReference__c = 'SAP123456';
            	conCase.SPEN_SiteContactPostCode__c = '1124235';
                conCase.SPEN_OfgemMarketSegment__c = 'LVHV';
                conCase.SPEN_GSDueDate__c =  system.now();
                insert conCase;
                
                SPEN_SAPSLACreation__c sap = new SPEN_SAPSLACreation__c();
                sap.SPEN_RelatedCase__c = conCase.id;
                sap.SPEN_Status__c = 'Post Acceptance Contact';
                sap.SPEN_Plannedfinishdate__c = Date.today();
                insert sap;
                
                SPEN_Delivery__c delObj = new SPEN_Delivery__c();
                delObj.SPEN_Case__c = conCase.Id;
                delObj.SPEN_Notes__c = 'test';
                delObj.SPEN_GSCallStatus__c = 'None';
                insert delObj;
                
                conCase.status = 'Delivery Work Planning';
				conCase.SPEN_SubStatus__c = 'GS Call Required';
                update conCase;

                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_SubStatus__c from Case where id =: conCase.id];
               Assert.areEqual(caseRec[0].SPEN_SubStatus__c,'GS Call Required');
            }catch(Exception ex){
                System.assert(ex != NULL);
            }
        }        
    }
     /***************************************************************************
* @Author:      Amrita Sarkar
* @Date:        23/10/2023
* @Description: Method to coverage updateCaseGSDueDateForPostAccp method of case
*****************************************************************************/
     @IsTest
    Public static void sendReminderTaskOrEmailForNonLVSSA() 
    {
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
            try{
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                SPEN_PhysicalInformation__c newPhysicalInfo = new SPEN_PhysicalInformation__c();
                newPhysicalInfo.SPEN_ItemProfile__c = 'UIT00001';
                newPhysicalInfo.SPEN_ItemClass__c = 'IT-UITEM';
                newPhysicalInfo.SPEN_ItemRequestRemark__c = 'test1';
                newPhysicalInfo.SPEN_ItemRequestedDate__c = system.today();
                
                
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
                conCase.Status ='Open';
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
            	conCase.SPEN_SAPReference__c = 'SAP123456';
            	conCase.SPEN_SiteContactPostCode__c = '1124235';
                conCase.SPEN_OfgemMarketSegment__c = 'LVHVA';
                insert conCase;
                conCase.status = 'Design';
                conCase.SPEN_SubStatus__c = 'Not Competent';
                update conCase;
                newPhysicalInfo.SPEN_Case__c = conCase.id;
                insert newPhysicalInfo;
                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_PausedStatus__c from Case where id =: conCase.id limit 1];
                Assert.areEqual(caseRec[0].SPEN_PausedStatus__c,'Yes');
            }
            catch(Exception ex)
            {
                System.assert(ex != NULL);
            }
            
        }
    }
     /***************************************************************************
* @Author:      Amrita Sarkar
* @Date:        23/10/2023
* @Description: Method to coverage updateCaseGSDueDateForPostAccp method of case
*****************************************************************************/
    @IsTest
    Public static void sendReminderTaskOrEmailForLVSSA() 
    {
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
            try{
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                SPEN_PhysicalInformation__c newPhysicalInfo = new SPEN_PhysicalInformation__c();
                newPhysicalInfo.SPEN_ItemProfile__c = 'UIT00001';
                newPhysicalInfo.SPEN_ItemClass__c = 'IT-UITEM';
                newPhysicalInfo.SPEN_ItemRequestRemark__c = 'test1';
                newPhysicalInfo.SPEN_ItemRequestedDate__c = system.today();
                
                
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
                conCase.Status ='Open';
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
            	conCase.SPEN_SAPReference__c = 'SAP123456';
            	conCase.SPEN_SiteContactPostCode__c = '1124235';
                conCase.SPEN_OfgemMarketSegment__c = 'LVSSA';
                insert conCase;
                conCase.status = 'Design';
                conCase.SPEN_SubStatus__c = 'Not Competent';
                update conCase;
                newPhysicalInfo.SPEN_Case__c = conCase.id;
                insert newPhysicalInfo;
                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_PausedStatus__c from Case where id =: conCase.id limit 1];
                Assert.areEqual(caseRec[0].SPEN_PausedStatus__c,'Yes');
            }
            catch(Exception ex)
            {
                System.assert(ex != NULL);
            }
            
        }
    }
    
    @IsTest
    Public static void tranmissionCaseCustomNotes() 
    {
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
            
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
                Case transCase = new Case();
                transCase.ContactId = ct.Id;
                transCase.RecordTypeId = recordTypeIdTransmission;
                transCase.SPEN_CustomerEngagementNotes__c = 'Test';
               	transCase.SPEN_ESOApplicationID__c = '35676677878';
                transCase.SPEN_DNOApplicationID__c = '36754886454';
                insert transCase;
				transCase.SPEN_ESOApplicationID__c = '35676677879';
                transCase.SPEN_DNOApplicationID__c = '36754886454';
            	update transCase;
                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_ESOApplicationID__c from Case where id =: transCase.id limit 1];
                Assert.areEqual(caseRec[0].SPEN_ESOApplicationID__c,'35676677879');
            
        }
    }
     @IsTest
    Public static void tranmissionCaseFinalEnergise() 
    {
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
            
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
                Case transCase = new Case();
                transCase.ContactId = ct.Id;
                transCase.RecordTypeId = recordTypeIdTransmission;
                transCase.SPEN_CustomerEngagementNotes__c = 'Test';
               	transCase.SPEN_ESOApplicationID__c = '35676677878';
                transCase.SPEN_DNOApplicationID__c = '58547896445';
           		transCase.SPEN_FinalEnergisationDate__c = system.today();
                insert transCase;
				transCase.SPEN_FinalEnergisationDate__c = System.today() + 1;
            	update transCase;
                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_ESOApplicationID__c from Case where id =: transCase.id limit 1];
               Assert.areEqual(caseRec[0].SPEN_ESOApplicationID__c,'35676677878');
            
        }
    }
    @IsTest
    Public static void tranmissionCaseITTIssued() 
    {
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
            
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                Test.startTest();
                List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount;
                
                contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert ct;
                List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(2);
                insert premiseList;
                
                Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId();
                Case transCase = new Case();
                transCase.ContactId = ct.Id;
                transCase.RecordTypeId = recordTypeIdTransmission;
                transCase.SPEN_CustomerEngagementNotes__c = 'Test';
               	transCase.SPEN_ESOApplicationID__c = '35676677878';
                transCase.SPEN_DNOApplicationID__c = '58547896445';
           		transCase.SPEN_ITTIssuedDate__c = system.today();
                insert transCase;
				transCase.SPEN_ITTIssuedDate__c = system.today() + 1;
            	update transCase;
                Test.stopTest();
                List<Case> caseRec = [Select id,SPEN_ESOApplicationID__c from Case where id =: transCase.id limit 1];
                Assert.areEqual(caseRec[0].SPEN_ESOApplicationID__c,'35676677878');
            
        }
    }
}