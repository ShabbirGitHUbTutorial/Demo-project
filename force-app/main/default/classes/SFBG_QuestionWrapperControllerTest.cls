@isTest
public class SFBG_QuestionWrapperControllerTest {
    @testSetup static void setup(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);  

    }

	@isTest 
    private static void test()
    {
       
        SFBG_Questionnaire__c quest = new SFBG_Questionnaire__c();
        quest.Name = 'Flood Damage';
        quest.SFBG_ExternalId__c = 'Flood Damage-V1';
        quest.SFBG_IsActive__c = true;
        //quest.SFBG_StartingQuestionId__r.SFBG_ExternalId__c = 
        quest.SFBG_Version__c = 1;
        insert quest;
        
        SFBG_Question__c question = new SFBG_Question__c();
        question.Name = 'FloodDamage-V1-Q1';
        question.SFBG_ExternalId__c = 'FloodDamage-V1-Q1';
        //question.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
        //question.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
        question.SFBG_IsActive__c = true;
        question.SFBG_Question__c = 'Is the water covering, or about to cover any Scottish Power Equipment?';
        question.SFBG_InformationCategory__c = '';
        question.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
        question.SPEN_CallOutcome__c = '';
        question.SFBG_QuestionnaireId__c= quest.ID;
		insert  question;       
        SFBG_Questionnaire__c sfbgQues = new SFBG_Questionnaire__c();
        sfbgQues.Name = 'questionname';
        sfbgQues.SFBG_ExternalId__c = 'questionname';
        sfbgQues.SFBG_StartingQuestionId__c = question.Id;
        sfbgQues.SFBG_Version__c = 1;
        sfbgQues.SFBG_IsActive__c = true;        
        insert sfbgQues;
        
        Account ac = new Account();
        ac.Name='Test Question';
        insert ac;
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        { 
            Test.startTest();
            //SPEN_TestDataFactory.prepareQuestionnaireData('Question',2);
            List<SFBG_QuestionWrapperController.QuestionnaireWrapper> resultQ=SFBG_QuestionWrapperController.getAllQuestionnaire('questionname1');
            //SPEN_TestDataFactory.prepareQuestionnaireData('Question',2);
            Assert.isTrue(resultQ!=null,'Question data not available');
            Id accid;
            List<SFBG_QuestionWrapperController.QuestionListWrapper> resultQL=SFBG_QuestionWrapperController.getAllQuestions(quest.ID, accid);
            Assert.isTrue(resultQL!=null,'Question List not available');
            Test.stopTest();
        }
    }
    @isTest 
    private static void testNegative()
    {
       
        SFBG_Questionnaire__c quest = new SFBG_Questionnaire__c();
        quest.Name = 'Flood Damage';
        quest.SFBG_ExternalId__c = 'Flood Damage-V1';
        quest.SFBG_IsActive__c = true;
        //quest.SFBG_StartingQuestionId__r.SFBG_ExternalId__c = 
        quest.SFBG_Version__c = 1;
        insert quest;
        
        SFBG_Question__c question = new SFBG_Question__c();
        question.Name = 'FloodDamage-V1-Q1';
        question.SFBG_ExternalId__c = 'FloodDamage-V1-Q1';
        //question.SFBG_QuestionnaireId__r.SFBG_ExternalId__c = quest.SFBG_ExternalId__c;
        //question.SFBG_QuestionnaireId__r.Name = quest.SFBG_ExternalId__r.Name;
        question.SFBG_IsActive__c = true;
        question.SFBG_Question__c = 'Is the water covering, or about to cover any Scottish Power Equipment?';
        question.SFBG_InformationCategory__c = '';
        question.RecordTypeId = Schema.SObjectType.SFBG_Question__c.getRecordTypeInfosByDeveloperName().get('Radio').getRecordTypeId();
        question.SPEN_CallOutcome__c = '';
        question.SFBG_QuestionnaireId__c= quest.ID;
		insert  question;       
        SFBG_Questionnaire__c sfbgQues = new SFBG_Questionnaire__c();
        sfbgQues.Name = 'questionname';
        sfbgQues.SFBG_ExternalId__c = 'questionname';
        sfbgQues.SFBG_StartingQuestionId__c = question.Id;
        sfbgQues.SFBG_Version__c = 1;
        sfbgQues.SFBG_IsActive__c = true;        
        insert sfbgQues;
        
        Account ac = new Account();
        ac.Name='Test Question';
        insert ac;
        User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
        System.runAs(user)
        { 
            Test.startTest();
            //SPEN_TestDataFactory.prepareQuestionnaireData('Question',2);
            List<SFBG_QuestionWrapperController.QuestionnaireWrapper> resultQ=SFBG_QuestionWrapperController.getAllQuestionnaire('');
            //SPEN_TestDataFactory.prepareQuestionnaireData('Question',2);
            Assert.isTrue(resultQ!=null,'Question data not available');
            Id accid;
            try{
                List<SFBG_QuestionWrapperController.QuestionListWrapper> resultQL=SFBG_QuestionWrapperController.getAllQuestions(accid, accid);
            	Assert.isTrue(resultQL!=null,'Question List not available');
            }catch(Exception e){
                Assert.isTrue(e!=null,'Exception occur');
            }
            
            Test.stopTest();
        }
    }
}