@IsTest
public class SFBG_DynamicCallWizardSelectorTEST {
    @IsTest
    private static void testgetQuestionnaireList()
    {
        Test.startTest();
        List<SFBG_Questionnaire__c> testQue = SPEN_TestDataFactory.prepareQuestionnaireData('Flood Damage-V1',
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testQue; 
        List<SFBG_Questionnaire__c> assertQue=SFBG_DynamicCallWizardSelector.getQuestionnaireList(testQue[0].Name);
        Assert.isNotNull(assertQue, 'Assertion Passed');
        Test.stopTest();      
    }
    
    @IsTest
    private static void testgetQuestionList()
    {
        Test.startTest();
       List<SFBG_Questionnaire__c> testQue = SPEN_TestDataFactory.prepareQuestionnaireData('Flood Damage-V1',
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testQue;
    	List<SFBG_Question__c> testQues = SPEN_TestDataFactory.prepareQuestionData('FloodDamage-V1-Q1',testQue[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
		insert testQues;
        SFBG_Question__c question1=new SFBG_Question__c();
        if(!testQues.isEmpty()){
             question1=[Select Id from SFBG_Question__c where Id=: testQues[0].Id];
        }
       
        SFBG_DynamicCallWizardSelector.checkIfQuestionTypeText(question1.Id);
        Assert.areEqual(testQues[0].Id,question1.Id,'The Question is present in Question List');
        Test.stopTest();
	}
    
    @IsTest
    private static void testgetQuesToDisplayList()
    {
        Test.startTest();
       List<SFBG_Questionnaire__c> testQue = SPEN_TestDataFactory.prepareQuestionnaireData('Flood Damage-V1',
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testQue;
    	List<SFBG_Question__c> testQues = SPEN_TestDataFactory.prepareQuestionData('FloodDamage-V1-Q1',testQue[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
		insert testQues;
        SFBG_Question__c question1=new SFBG_Question__c();
        if(!testQues.isEmpty()){
             question1=[Select Id from SFBG_Question__c where Id=: testQues[0].Id];
        }
       
        SFBG_Questionnaire__c testQue1=new SFBG_Questionnaire__c();
        if(!testQue.isEmpty()){
             testQue1=[Select Id,Name from SFBG_Questionnaire__c where Id=:testQue[0].Id];
        }
       
        SFBG_DynamicCallWizardSelector.getQuesToDisplayList(testQue1.Id,question1.Id);
        Assert.areEqual(testQues[0].Id,question1.Id,'The Question is present in Question List');
        Assert.areEqual(testQue[0].Id,testQue1.Id,'The Questionnaire is present in Questionnaire List');
        Test.stopTest();
    }
    @IsTest
    private static void testgetAnswerToDisplayList()
    {
        Test.startTest();
         List<SFBG_Questionnaire__c> testQue = SPEN_TestDataFactory.prepareQuestionnaireData('Flood Damage-V1',
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testQue;
    	List<SFBG_Question__c> testQues = SPEN_TestDataFactory.prepareQuestionData('FloodDamage-V1-Q1',testQue[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
		insert testQues;
        List<SFBG_Answer__c> testAns = SPEN_TestDataFactory.prepareAnswerData('FloodDamage-V1-Q1-A1',testQues[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
		insert testAns;
        List<SFBG_Answer__c> assertans=SFBG_DynamicCallWizardSelector.getAnswerToDisplayList(testAns[0].SFBG_QuestionId__c);
        Assert.isNotNull(assertans, 'Assertion Passed');
        Test.stopTest();
    }
    @IsTest
    private static void testgetNextQuesFromAns()
    {
        Test.startTest();
         List<SFBG_Questionnaire__c> testQue = SPEN_TestDataFactory.prepareQuestionnaireData('Flood Damage-V1',
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testQue;
    	List<SFBG_Question__c> testQues = SPEN_TestDataFactory.prepareQuestionData('FloodDamage-V1-Q1',testQue[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
		insert testQues;
        List<SFBG_Answer__c> testAns = SPEN_TestDataFactory.prepareAnswerData('FloodDamage-V1-Q1-A1',testQues[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
		insert testAns;
        List<SFBG_Answer__c> answerList = SFBG_DynamicCallWizardSelector.getNextQuesFromAns(testAns[0].Id,testAns[0].SFBG_QuestionId__c);
        Assert.isNotNull(answerList, 'Assertion Passed');
        Test.stopTest();
    }
     @IsTest
    private static void testgetPrevQuesId()
    {
        	Test.startTest();
         	List<SFBG_Questionnaire__c> testQue = SPEN_TestDataFactory.prepareQuestionnaireData('Flood Damage-V1',
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        	insert testQue;
    		List<SFBG_Question__c> testQues = SPEN_TestDataFactory.prepareQuestionData('FloodDamage-V1-Q1',testQue[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
			insert testQues;
       
        	List<SFBG_Question__c> testprev = SPEN_TestDataFactory.preparePrevQuestionData('FloodDamage-V1-Q2',testQues[0].Id,testQue[0].Id,
                                                                                          SPEN_TestDataFactoryConstants.SINGLE_REC);
        	
			insert testprev;
         	List<SFBG_Answer__c> testAns = SPEN_TestDataFactory.prepareAnswerData('FloodDamage-V1-Q1-A1',testprev[0].Id,
                                                                              SPEN_TestDataFactoryConstants.SINGLE_REC);
        	testAns[0].SFBG_QuestionToDisplayId__c=testQues[0].Id;
			insert testAns;
        	testQue[0].SFBG_StartingQuestionId__c=testQues[0].Id;
        	update testQue;
        	SFBG_Questionnaire__c testQue1=new SFBG_Questionnaire__c();
            if(!testQue.isEmpty()){
                testQue1=[Select Id,SFBG_StartingQuestionId__c from SFBG_Questionnaire__c where Id=:testQue[0].Id];
            }
        	
        	Map<List<Id>,Boolean> prevQMap=SFBG_DynamicCallWizardSelector.getPrevQuesId(testQue[0].Id,testprev[0].Id);
        	Assert.isNotNull(prevQMap, 'Assertion Passed');
        	Test.stopTest();
        
    }
}