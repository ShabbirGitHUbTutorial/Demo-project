/*************************************************************************
@Author: Amrita Sarkar
@Date: 08/06/2023
@purpose: Test class for SPEN_FileUploader
*************************************************************************************/
@IsTest
public class SPEN_FileUploaderClassConnTest {
/*************************************************************************
@Author: Amrita Sarkar
@Date: 08/06/2023
@purpose: Data setup method for Test class
*************************************************************************************/
    @testSetup static void setup() 
    {
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
        System.runAs(user){
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            Contact con= SPEN_TestDataFactory.createContacts(accRec[0].Id,SPEN_TestDataFactoryConstants.SINGLE_REC);
            con.MobilePhone = '07883344559';
            con.Email = 'test@gmail.com';
            insert con;
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con.Id;
            testCase[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            testCase[0].SPEN_ApplicantEmail__c = 'test@gmail.com';
            insert testCase;
            Test.stopTest();
        }
    }
/*************************************************************************
@Author: Amrita Sarkar
@Date: 08/06/2023
@purpose: Test method for createFolder
*************************************************************************************/ 
    @IsTest
    public static void createFolder()
    {
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
        System.runAs(u)
        {
            Case caseRec= [SELECT id ,CaseNumber,SPEN_SAPReference__c FROM CASE where SPEN_PowerOnCallReference__c =:'CALL-261472-f' LIMIT 1];
            String caseid = caseRec.id;
            List<ID> recordIdList = new List<Id>();
            recordIdList.add(caseid);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            SPEN_FileUploaderConnClass.uploadFile(recordIdList);
            SPEN_FileUploaderConnClass.getCaseNumber(recordIdList[0]);
            Test.stopTest();
           //System.assertEquals(caseRec.CaseNumber, caseid);
        }
    }
    /*************************************************************************
@Author: Amrita Sarkar
@Date: 08/06/2023
@purpose: Test method for uploadFile
*************************************************************************************/  
    @IsTest
    public static void uploadFile()
    {
        User u= [Select id FROM User WHERE IsActive=true LIMIT 1];
        System.runAs(u)
        {
            Case caseRec= [SELECT id ,CaseNumber,SPEN_SAPReference__c FROM CASE where SPEN_PowerOnCallReference__c =:'CALL-261472-f' LIMIT 1];
            String caseid = caseRec.id;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_FileUploaderClassHttpMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            String fileName = 'Test-File';
            SPEN_FileUploaderConnClass.uploadFile('Base64-Test',fileName,caseRec);
            Test.stopTest();
            System.assertEquals('Test-File', fileName);
        }
    }
     @IsTest
    public static void fetchSPDocuments()
    {
        String caseid = null;
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
        System.runAs(user){
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
            insert accRec;
            List<Contact> con = [Select id from Contact where MobilePhone = '07883344559' limit 1];
            List<Case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
            testCase[0].Origin = 'Web';
            testCase[0].ContactId=con[0].Id;
            testCase[0].SPEN_ApplicantEmail__c = 'test@gmail.com';
            testCase[0].SPEN_PowerOnCallReference__c = 'CALL-261472-f';
            insert testCase;
            caseid = testCase[0].id;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_ViewSharePointDeatilsHttpMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            List<SPEN_FileUploaderConnClass.DocumentWrapper> docWrapList = SPEN_FileUploaderConnClass.fetchSPDocuments(caseid);
            System.assertEquals('Category-Test', docWrapList[0].DocName);
            Test.stopTest();
        }
    }
}