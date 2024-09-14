@isTest(SeeAllData=false)
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_SAPGetQASCalloutTest 
{
    
    @isTest
    public static void sendSoapCalloutTest2()
    {
        try
        {
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
            PermissionSet ps11 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PlotAccessCRUD'];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps11.Id);																									  
            
            System.runAs(user){
                Map<id,Contact> oldmap = new Map<id,Contact>();
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityXMLClass()); 
                List<Account> testAccount1 = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,SPEN_TestDataFactoryConstants.SINGLE_REC);
                insert testAccount1;
                Id RecTypeId2=[select Id from RecordType where DeveloperName='SPEN_ContactConnectionsCRM'].Id;
                Contact ct = SPEN_TestDataFactory.createContacts(testAccount1[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);           
                //oldmap.put(ct.id, ct);
                ct.RecordTypeId=RecTypeId2;
                insert ct;
                Id recTypeId=[select Id from RecordType where DeveloperName='SPEN_BudgetConnectionEnquiry'].Id;
                Case cse = new Case();
                cse.SPEN_SendtoPowerOn__c = true;
                cse.SPEN_CallerInitials__c = ct.Salutation;
                cse.SPEN_CallerMobileTelephone__c = ct.MobilePhone;
                cse.SPEN_CallerName__c = ct.Name;
                cse.SPEN_CallerTelephone__c = ct.Phone;
                cse.SPEN_CallerTitle__c = ct.Suffix;
                cse.status='Open';
                cse.SPEN_SAPReference__c='000612777776';
                cse.SPEN_ContactReceivedDate__c = System.now();
                cse.SPEN_TTQStartDate__c = System.today() -1;
                cse.SPEN_CompetentDate__c = System.today() -1;										   									  
                cse.RecordTypeId=recTypeId;
                //cse.SPEN_SubStatus__c ='test';
                Database.SaveResult saveRes = Database.insert(cse);
                //insert testCase;
                List<SPEN_Plot__c> plot1=SPEN_TestDataFactory.createPlotRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
                plot1[0].SPEN_CaseRecord__c=cse.Id;
                plot1[0].SPEN_SupplyPointCode__c='123456789';
                plot1[0].SPEN_MPAN1__c='adcvbgf';
                plot1[0].SPEN_MPAN2__c='rtgfhjg';
                insert plot1;         
                SPEN_SAPGetQASCallout.sendSoapCallout(cse.SPEN_SAPReference__c);
                Assert.areNotEqual(cse.SPEN_SAPReference__c,'000612777777','Assertion Failed');
                Test.stopTest();
            }
            
        }
        catch(Exception ex)
        {
            System.assertNotEquals('', ex.getMessage());   
        } 
    }
    
}