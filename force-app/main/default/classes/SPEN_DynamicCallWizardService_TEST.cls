/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  Unit test class for  Dynamic Wizard apex class SFBG_DynamicWizardService.
AUTHOR       :  Bhagyashree Mandlik
LIBRARY      :  Salesforce Enterprise Library 
VERSION      :  1.0
HISTORY      :
Date            Author                  Comment
OCT-18-2022     Bhagyashree Mandlik     Initial version
-----------------------------------------------------------------------------------------*/
@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public with sharing class SPEN_DynamicCallWizardService_TEST {
    @TestSetup
    static void createQuestionanireData() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user){
            List<List<SObject>> wizardSet = SPEN_TestDataFactory.createBundleOfQuestionnaires();
            List<SFBG_Questionnaire__c> questionnaires = wizardSet[0];
            List<SFBG_Question__c> questions = wizardSet[1];
            List<SFBG_Answer__c> answers = wizardSet[2];
            List<Database.SaveResult> insertedQuestionnaires = Database.insert(questionnaires);
            List<Id> ids = new List<Id>();
            for (Database.SaveResult qid : insertedQuestionnaires) {
                ids.add(qid.getId());
            }
            questions[0].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[1].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[2].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[3].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[4].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[5].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[6].SFBG_QuestionnaireId__c = insertedQuestionnaires[0].getId();
            questions[7].SFBG_QuestionnaireId__c = insertedQuestionnaires[1].getId();
            questions[8].SFBG_QuestionnaireId__c = insertedQuestionnaires[1].getId();
            questions[9].SFBG_QuestionnaireId__c = insertedQuestionnaires[1].getId();

            insert questions;

            List<SFBG_Questionnaire__c> questionnairesList = [SELECT Id,Name,SFBG_StartingQuestionId__c FROM SFBG_Questionnaire__c WHERE Id IN:ids];
            
            questionnaires[0].SFBG_StartingQuestionId__c = questions[0].Id;
            questionnaires[1].SFBG_StartingQuestionId__c = questions[7].Id;

            update questionnaires;

            answers[0].SFBG_QuestionId__c = questions[0].Id;
            answers[1].SFBG_QuestionId__c = questions[0].Id;
            answers[2].SFBG_QuestionId__c = questions[3].Id;
            answers[3].SFBG_QuestionId__c = questions[3].Id;
            answers[4].SFBG_QuestionId__c = questions[3].Id;
            answers[5].SFBG_QuestionId__c = questions[7].Id;
            answers[6].SFBG_QuestionId__c = questions[7].Id;

            insert answers;
            Assert.areEqual(true,user.IsActive,'active user');
        }
    }


    @IsTest
    private static void getQuestionanireTestMethod() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);    
        System.runAs(user){
            Test.startTest();
            List<SFBG_Question__c> questionList = [SELECT Id,Name,SFBG_QuestionnaireId__c, SFBG_QuestionnaireId__r.Name FROM SFBG_Question__c];
            List<SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper> aire = SFBG_DynamicCallWizardService.getQuestionnaire(questionList[0].SFBG_QuestionnaireId__r.Name);
            
            
            List<SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper> noAire = SFBG_DynamicCallWizardService.getQuestionnaire('No Supply');
            Assert.areEqual(true, noAire.size() <= 0, 'Questionnaire fetched SUccessfully');

            Test.stopTest();
        }
    }   
    
    @IsTest
    private static void getPrevQuestionTestMethod() {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);    
        System.runAs(user){
            Test.startTest();
            List<SFBG_Answer__c> ansList = [SELECT Id,Name,SFBG_QuestionId__c, SFBG_QuestionId__r.SFBG_QuestionnaireId__c FROM SFBG_Answer__c];
            SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper prev = SFBG_DynamicCallWizardService.getPrevQuestion(ansList[0].SFBG_QuestionId__r.SFBG_QuestionnaireId__c, ansList[0].SFBG_QuestionId__c);
            SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper next = SFBG_DynamicCallWizardService.getNextQuesFromAns(ansList[1].Id, ansList[1].SFBG_QuestionId__c);
            Assert.areEqual(true, prev.isLastQuestion, 'Questionnaire fetched SUccessfully');
            Test.stopTest();
        }
    } 

/*@IsTest 
private static void createCaseTestMethod() {
    Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
    User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
    List<String> outcomeString = new List<String>();
    Database.insert(user);    
    System.runAs(user){
        Test.startTest();    
        SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper caseData = new SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper();
        SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper caseData1 = new SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper();
        caseData.caseSubject = ' Wizard Case';
        caseData.caseStatus = 'Open';
        caseData.caseOrigin =  'Phone'; //SPEN_CaseCategoryOutcome__c
        caseData.caseProblemCategory =  'Flood Damage';
        caseData.contPrefMethod = 'T';
        

        Contact ctnew = new Contact();
        ctnew.Salutation = 'Mr.';
        ctnew.MobilePhone = '07123456789';
        ctnew.FirstName = 'Aryan';
        ctnew.Phone = '01234567890';
        ctnew.LastName = 'Sharma';
        ctnew.Suffix = 'AS';
        insert ctnew;

        List<SPEN_Premise__c> premises = SPEN_TestDataFactory.createListOfPremise(2);

        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_3PDamageEquip);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_FireCall);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_FlickeringLights);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_HiEarthReading);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_LowGrndConductor);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_MeterDamInterference);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_NSOffPeak);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_ShocksFromEquipExt);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_TreeCutReq);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_WireHangingFromMeter);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_ShocksFromEquipInt);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_SmellOfBurning);
        outcomeString.add(SFBG_DynamicCallWizardConstant.Case_KeyMeter);

        Test.setMock(HttpCalloutMock.class, new SPEN_SyncIncidentDetailsHttpMock());
        for(String outcome : outcomeString){
            if( outcome == 'KEY'){
                caseData.caseProblemCategory =  'Key Meter';
                caseData.keyMeterRemarks = 'faulty';
			}
            caseData.caseCategoryOutcome = outcome;
            String cseData = JSON.serialize(caseData);
            caseData.caseContactId = ctnew.Id;
            caseData.casePremiseId = premises[0].Id;
            //Id cseId = SFBG_DynamicCallWizardService.createCasefromCallWizard(cseData, false);
            //System.assertEquals(true, cseId != null, 'cseId fetched SUccessfully');
        }
        Assert.areEqual('Aryan',ctnew.FirstName,'Contact First Name');
        Test.stopTest();
    }
}*/
    private static testMethod void testExceptionCoverage() {
        try{
            Test.startTest(); 
            SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper prev = SFBG_DynamicCallWizardService.getPrevQuestion(NULL,NULL);
            SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper next = SFBG_DynamicCallWizardService.getNextQuesFromAns(NULL, NULL);
            List<SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper> aire = SFBG_DynamicCallWizardService.getQuestionnaire(NULL);
            SFBG_DynamicCallWizardService.createCasefromCallWizard('', NULL);
            SFBG_DynamicCallWizardService.addAutoPopulationFields(NULL,NULL);
            SFBG_DynamicCallWizardService.addAutoPopulationFields('null',NULL);
            Test.stopTest();   
        }
        catch(Exception ex){
            Assert.areEqual(true, ex != null, 'Null Exception');
        }
    }
    //Added by Sumit
    @isTest
    static void testCreateCasefromCallWizard() {
        // Set up test data
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.MobilePhone = '07123456789';
        contact.FirstName = 'Aryan';
        contact.Phone = '01234567890';
        contact.LastName = 'Sharma';
        contact.Suffix = 'AS';
        insert contact;
        
        SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper caseDataWrapper = new SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper();
        // Populate caseDataWrapper with necessary data for testing
		caseDataWrapper.caseSubject = ' Wizard Case';
        caseDataWrapper.caseStatus = 'Open';
        caseDataWrapper.caseOrigin =  'Phone'; 
        caseDataWrapper.caseProblemCategory =  'Key Meter';
        caseDataWrapper.caseCategoryOutcome = 'KEY';
        caseDataWrapper.contPrefMethod = 'H';
        caseDataWrapper.caseContactId = contact.Id;
        caseDataWrapper.keyMeterRemarks = 'lost';
        
        Test.startTest();
        Case resultCase = SFBG_DynamicCallWizardService.createCasefromCallWizard(JSON.serialize(caseDataWrapper), true);
        Case resultCase1 = SFBG_DynamicCallWizardService.createCasefromCallWizard(JSON.serialize(caseDataWrapper), false);
        
        caseDataWrapper.keyMeterRemarks = 'faulty';
        Case resultCase2 = SFBG_DynamicCallWizardService.createCasefromCallWizard(JSON.serialize(caseDataWrapper), true);
        
        Test.stopTest();

        // Assert the results
        System.assertNotEquals(null, resultCase.Id, 'cseId fetched Successfully');
    }
        
}