@isTest
public class SPEN_KnowledgeTriggerHandlerTest {
    
    @testSetup static void setup() {
        Id recordTypeIdKnowledge = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('FAQ').getRecordTypeId();
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
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_KnowledgeAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user){
            Knowledge__kav article = new Knowledge__kav();
            article.Summary = 'Summary';
            article.Title = 'Test Knowledge';
            article.UrlName = 'Test-Knowledge';
            article.recordtypeid = recordTypeIdKnowledge;
            insert article;
            
            Knowledge__kav article2 = new Knowledge__kav();
            article2.Summary = 'Summary';
            article2.Title = 'Test Knowledge 2';
            article2.UrlName = 'Test-Knowledge2';
            article2.recordtypeid = recordTypeIdKnowledge;
            insert article2;
            
            List<Knowledge__DataCategorySelection> lstDC = new List<Knowledge__DataCategorySelection>();
            Knowledge__DataCategorySelection dc = new Knowledge__DataCategorySelection();
            dc.ParentId = article.id;
            dc.DataCategoryName = 'Third_Party_Damage';
            dc.DataCategoryGroupName = 'SPEN_CustomerService';
            
            Knowledge__DataCategorySelection dc2 = new Knowledge__DataCategorySelection();
            dc2.ParentId = article.id;
            dc2.DataCategoryName = 'Complaints';
            dc2.DataCategoryGroupName = 'SPEN_CustomerService';
            
            Knowledge__DataCategorySelection dc3= new Knowledge__DataCategorySelection();
            dc3.ParentId = article.id;
            dc3.DataCategoryName = 'Neutral_Faults';
            dc3.DataCategoryGroupName = 'SPEN_CustomerService';
            
            lstDC.add(dc3);
            lstDC.add(dc2);
            lstDC.add(dc);
            insert lstDC;
        }
    }
    @isTest 
    public static void testUpdateDC2() 
    {
        Knowledge__kav article = [Select id, summary, Title FROM Knowledge__kav WHERE Title=: 'Test Knowledge 2' LIMIT 1];
        test.startTest();
        
        article.Summary = 'Updated';
        update article;
    }
    @isTest 
    public static void testUpdateDC() 
    {
        Knowledge__kav article = [Select id, summary, Title FROM Knowledge__kav WHERE Title=: 'Test Knowledge' LIMIT 1];
        test.startTest();
        
        article.Summary = 'Updated';
        update article;
        
        SPEN_KnowledgeTriggerInterface obj = new SPEN_KnowledgeTriggerInterface(); 
        Map<Id, sObject> deleteMap = new Map<Id,sObject>();
        deleteMap.put(article.id,article);
        obj.beforeInsert(new List<Knowledge__kav>{article});
        obj.afterInsert(deleteMap);
        
        obj.beforeDelete(deleteMap);
        obj.afterDelete(deleteMap);
        obj.afterUndelete(deleteMap);
        test.stopTest();
    }
    
    @isTest 
    public static void testUpdateAndPublishArticleExt() 
    {
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
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_KnowledgeAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user){
            Knowledge__kav kavObj = [SELECT Id, Title, LastPublishedDate, NextReviewDate, ValidationStatus, PublishStatus, KnowledgeArticleId FROM Knowledge__kav WHERE Title=: 'Test Knowledge' LIMIT 1];
            List<SPEN_KnowledgeTriggerHandler.DraftKnowledgeDetails> dftList = new List<SPEN_KnowledgeTriggerHandler.DraftKnowledgeDetails>();
            SPEN_KnowledgeTriggerHandler.DraftKnowledgeDetails dft = new SPEN_KnowledgeTriggerHandler.DraftKnowledgeDetails();
            dft.articleId = kavObj.KnowledgeArticleId;
            dft.reviewAction = 'Yes';
            dftList.add(dft);
            
            test.startTest();
            SPEN_KnowledgeTriggerHandler.updateAndPublishArticle(dftList);
            test.stopTest();
        }
    }
}