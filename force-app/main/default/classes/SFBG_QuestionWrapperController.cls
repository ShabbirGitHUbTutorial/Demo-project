public with sharing class SFBG_QuestionWrapperController {
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class QuestionListWrapper{
        @AuraEnabled
        public SFBG_Question__c quesRecord{get;set;}
        @AuraEnabled
        public SFBG_Question__c firstQuesRecord{get;set;}
    }
    public class QuestionnaireWrapper{
        @AuraEnabled
        public SFBG_Questionnaire__c questionnaireRecord{get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<QuestionnaireWrapper> getAllQuestionnaire(String launchVal){
        List<QuestionnaireWrapper> quesCollectionWrapperList = new List<QuestionnaireWrapper>();
        List<SFBG_Questionnaire__c> quesList;
        if(launchVal != null){
        	quesList = [SELECT Id, Name,SFBG_ExternalId__c,SFBG_StartingQuestionId__c,SFBG_Version__c 
                        FROM SFBG_Questionnaire__c
                        WHERE Name =: launchVal];
    	}
        if(quesList != null && !quesList.isEmpty()){
            for(SFBG_Questionnaire__c qs : quesList){
                QuestionnaireWrapper qWrapper = new QuestionnaireWrapper();
                qWrapper.questionnaireRecord = qs;
                quesCollectionWrapperList.add(qWrapper);
            }
        }
        return quesCollectionWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static List<QuestionListWrapper> getAllQuestions(Id questionnaireId, Id firstquesId){
        List<QuestionListWrapper> quesWrapperList = new List<QuestionListWrapper>();
        List<QuestionListWrapper> firstQuesRecordList = new List<QuestionListWrapper>();
        List<SFBG_Question__c> qList;
        if(questionnaireId != null){
        	qList = [SELECT Name,Id,SFBG_ExternalId__c,SFBG_HelpText__c,SFBG_Question__c,SFBG_QuestionnaireId__c,
                     SFBG_QuestionToDisplayId__c,SFBG_QuestionnaireId__r.Name,RecordType.DeveloperName
                     FROM SFBG_Question__c
                     WHERE SFBG_QuestionnaireId__c =: questionnaireId];
        }
        if(qList != null && !qList.isEmpty()){
            for(SFBG_Question__c acc : qList){
                QuestionListWrapper qWrapper = new QuestionListWrapper();
                if(acc.Id == firstquesId){
                    qWrapper.firstQuesRecord = acc;
                }
                qWrapper.quesRecord = acc;
                quesWrapperList.add(qWrapper);
            }
        }
        return quesWrapperList;
    }
}