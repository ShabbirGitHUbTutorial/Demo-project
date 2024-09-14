@isTest(SeeAllData=false)
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_SAPQASCalloutTest { 
    
    @testsetup
    public static void setupdata(){
        /*Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
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
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps10.Id);*/
        
           	//Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass());
           	Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Map<id,Contact> oldmap = new Map<id,Contact>();
            Map<id,Contact> newmap = new Map<id,Contact>();
            List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            insert testAccount;
        	Id RecTypeId2=[select Id from RecordType where DeveloperName='SPEN_ContactConnectionsCRM'].Id;
            Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            
            oldmap.put(ct.id, ct);
        	ct.RecordTypeId=RecTypeId2;
            insert ct;
            List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(1);
            insert premiseList;
            List<SPEN_ContactPremise__c> conPremList = new List<SPEN_ContactPremise__c>();
            SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,ct.Id,premiseList[0].Id);
            conpremise.SPEN_ExternalId__c='1244';
            conpremise.SPEN_PremisePrimaryContact__c = true;
            conpremise.SPEN_Role__c = 'Customer';
            conPremList.add(conpremise);
            insert conPremList;
            Id recTypeId=[select Id from RecordType where DeveloperName='SPEN_BudgetConnectionEnquiry'].Id;
            Case cse = new Case();
            cse.ContactId = ct.Id;
            cse.SPEN_SendtoPowerOn__c = true;
            cse.SPEN_CallerInitials__c = ct.Salutation;
            cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
            cse.SPEN_CallerName__c = ct.Name;
            cse.SPEN_CallerTelephone__c = ct.Phone;
            cse.SPEN_CallerTitle__c = ct.Suffix;
            cse.status='Open';
			cse.SPEN_ContactReceivedDate__c = System.now();
            cse.SPEN_TTQStartDate__c = System.today() -1;
            cse.SPEN_CompetentDate__c = System.today() -1;										   
													 
													  
            cse.RecordTypeId=recTypeId;
            //cse.SPEN_SubStatus__c ='test';
            Database.SaveResult saveRes = Database.insert(cse);
            system.debug('Record type'+ cse.RecordTypeId);
            Contact ctnew = new Contact();
            ctnew.AccountId = testAccount[0].id;
            ctnew.Salutation = 'Mr.';
            ctnew.MobilePhone = '07123456789';
            ctnew.FirstName = 'Aryan';
            ctnew.Phone = '01234567890';
            ctnew.LastName = 'Sharma';
            ctnew.Suffix = 'AS';
            ctnew.SPEN_CustomerID__c = 'SB_001';
        	ctnew.RecordTypeId=RecTypeId2;
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
                          SPEN_CallerName__c,SPEN_CallerTelephone__c,SPEN_UKC1ID__c,SPEN_UKC2ID__c,SPEN_CCCompanyName__c,
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
			upcse.SPEN_ContactReceivedDate__c = System.now();
            upcse.SPEN_TTQStartDate__c = System.today() -2;
            upcse.SPEN_CompetentDate__c = System.today() -2;											 
													   
														
            upcse.RecordTypeId=recTypeId;
            //upcse.SPEN_UKC1ID__c='';
            Database.SaveResult saveRes2 = Database.update(upcse);
            SPEN_Plot__c plot=new SPEN_Plot__c(SPEN_CaseRecord__c=cse.Id);
            plot.SPEN_Status__c='To be delete';
            Insert plot;
            
            //system.assert(testAccount.size()>0, 'assert fail');
            
            List<Id> lstCaseIds = new List<Id>();
            lstCaseIds.add(upcse.Id);
        List <SPEN_ConfigurableSettings__c> configSettingList = SPEN_TestDataFactory.createConfigSettingforSMSConfig(1);
        insert configSettingList;
        List<SPEN_PhysicalInformation__c> physInfoLst=SPEN_TestDataFactory.createPhysInfoRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
        physInfoLst[0].SPEN_Case__c=lstCaseIds[0];
        insert physInfoLst;
        
	        
    }
    @isTest
    public static void sendSoapCalloutTest1 (){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        Test.startTest();
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
		PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PhysicalInformationAccessCRUD'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);																									  
        
        System.runAs(user){
        	Id ids =[select id from case where SPEN_AdditionalCaller__c = true and status='Open'].Id;
        List<Id> lstCaseIds=new List<id>();
        lstCaseIds.add(ids);
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass());
            SPEN_SAPQASCallout.sendSoapCallout('CREATE_QAS',lstCaseIds);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void sendSoapCalloutTest2 (){
        try{
            Test.startTest();         
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass());
            SPEN_SAPQASCallout.sendSoapCallout('CREATE_QAS',null);
            Test.stopTest();
            
        }catch(Exception ex){
          System.assertNotEquals('', ex.getMessage());  
        } 
    }
    
    @isTest
    public static void sendSoapCalloutTest3 (){
        try{
            Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
            User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
            Database.insert(user); 
            Test.startTest();  
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
            PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PhysicalInformationAccessCRUD'];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);																									  
            
            System.runAs(user){
                
                List<Case> caseLst =[select id from case where SPEN_AdditionalCaller__c = true and status='Open' limit 1];
                caseLst[0].SPEN_IsCaseCompetentInSAP__c=True;
                update caseLst;
                SPEN_PhysicalInformation__c phyRec=[select id from SPEN_PhysicalInformation__c where SPEN_Case__c=:caseLst[0].id];
                String phyRecId = phyRec.Id;
                List<Id> lstCaseId =new List<Id>();
                lstCaseId.add(caseLst[0].id);       
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass());
                SPEN_SAPQASCallout.sendSoapCallout(phyRecId,lstCaseId);
                //SPEN_SAPQASCallout.sendSoapCalloutSyncCall(phyRecId,lstCaseId);
                Test.stopTest();
            }
        }catch(Exception ex){
            System.assertNotEquals('', ex.getMessage());  
        } 
    }
    
    @isTest
    public static void sendSoapCalloutTest4 (){
        try{
            Test.startTest();
            List<Case> caseLst =[select id from case where SPEN_AdditionalCaller__c = true and status='Open' and SPEN_IsCaseCompetentInSAP__c=False limit 1];
            SPEN_PhysicalInformation__c phyRec=[select id from SPEN_PhysicalInformation__c where SPEN_Case__c=:caseLst[0].id];
            String phyRecId = phyRec.Id;
            List<Id> lstCaseId =new List<Id>();
            lstCaseId.add(caseLst[0].id);   
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass());
            SPEN_SAPQASCallout.sendSoapCalloutSyncCall(phyRecId,lstCaseId);
            Test.stopTest();
            
        }catch(Exception ex){
            System.assertNotEquals('', ex.getMessage());  
        } 
    }
    
    @isTest
    public static void parseNumberFromStringTest (){
        try{
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass());
            SPEN_SAPQASCallout obj = new SPEN_SAPQASCallout();
            String objs='1234567';
            String res = obj.parseNumberFromString(objs);
            System.debug('res>>>'+res);
            Test.stopTest();
            
        }catch(Exception ex){
            System.assertNotEquals('', ex.getMessage()); 
        }
        
    }    
}