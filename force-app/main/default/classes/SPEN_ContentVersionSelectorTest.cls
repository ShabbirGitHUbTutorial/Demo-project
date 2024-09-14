/*------------------------------------------------------------------------------------
DESCRIPTION	:	Test class of SPEN_ContentVersionSelector
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment

------------------------------------------------------------------------------------*/
@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_ContentVersionSelectorTest {
    @testSetup static void setup(){
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
            List<SPEN_MessagingTask__c> sMsgtask = new List<SPEN_MessagingTask__c>();
            SPEN_MessagingTask__c sMsgtask1 = new SPEN_MessagingTask__c();
            sMsgtask1.SPEN_Status__c='New';   
            insert sMsgtask1;                
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Test1234',
                PathOnClient = 'Test.csv',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE  Title='Test1234'];
            ContentDocumentLink cdli = New ContentDocumentLink();
            cdli.LinkedEntityId = sMsgtask1.id;
            cdli.ContentDocumentId = documents[0].Id;
            cdli.shareType = 'V';
            insert cdli;
            Test.stopTest();
        }
    }
    @IsTest
    public static void getContentVersionListFromDocidsTestPositive(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {
            Map<Id,ContentDocument> contentdocMap=new Map<Id,ContentDocument>([SELECT id,title FROM ContentDocument WHERE Title='Test1234']);
            List<ContentVersion> csvDoc = new List<ContentVersion>();
            SPEN_ContentVersionSelector cvs=new SPEN_ContentVersionSelector();
            csvDoc = cvs.getContentVersionListFromDocids(contentdocMap.KeySet());
            Assert.areEqual(csvDoc.size(),1); 
        }
    } 
    @IsTest
    public static void getContentVersionListTestPositiveBulk(){
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        {
            Map<Id,ContentDocument> contentdocMap=new Map<Id,ContentDocument>([SELECT id,title FROM ContentDocument WHERE Title='Test1234']);
            List<ContentVersion> csvDoc = new List<ContentVersion>();
            SPEN_ContentVersionSelector cvs=new SPEN_ContentVersionSelector();
            csvDoc = cvs.getContentVersionListFromDocids(contentdocMap.KeySet());
            Assert.areEqual(csvDoc.size(),1);
        }
    }
    @IsTest
    public static void getContentVersionListFromDocidsTestNegative(){
        Map<Id,ContentDocument> contentdocMap=new Map<Id,ContentDocument>();
        //[SELECT id,title FROM ContentDocument WHERE Title!=null ];
        List<ContentVersion> csvDoc = new List<ContentVersion>();
        SPEN_ContentVersionSelector cvs=new SPEN_ContentVersionSelector();
        csvDoc = cvs.getContentVersionListFromDocids(contentdocMap.KeySet());
        Assert.areEqual(csvDoc.size(),0);
    }         
    
}