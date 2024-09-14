/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the Dynamic Call Wizard.
LIBRARY		:	Salesforce Enterprise Library - Dynamic Call Wizard Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
SEP-16-2022		Dhara Desai         Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SFBG_DynamicCallWizardSelector {
  @AuraEnabled
  public static List<SFBG_Questionnaire__c> getQuestionnaireList(String launchVal) {
      List<SFBG_Questionnaire__c> ques = new List<SFBG_Questionnaire__c>();
      if(launchVal != null){
          ques = [SELECT Id,Name,SFBG_ExternalId__c,SFBG_StartingQuestionId__c,SPEN_CategoryCriticalInfo__c,SPEN_CategoryRemarks__c,
              		SFBG_Version__c
              		FROM SFBG_Questionnaire__c
              		WHERE Name = :launchVal   AND SFBG_IsActive__c = true];
      }
    return ques;
  }
  @AuraEnabled
  public static SFBG_Question__c checkIfQuestionTypeText(Id quesId) {
    SFBG_Question__c ques = new SFBG_Question__c();
      if(quesId != null){
          ques = [SELECT Id,RecordType.Name,SFBG_QuestionnaireId__c,SFBG_QuestionToDisplayId__c
              		FROM SFBG_Question__c
              		WHERE Id = :quesId  AND SFBG_IsActive__c = true];
      }
    return ques;
  }

    @AuraEnabled
    public static SFBG_Question__c getQuesToDisplayList(Id questionnaireId,Id quesId) {
        SFBG_Question__c quesList = new SFBG_Question__c();
        if(questionnaireId != null && quesId != null){
            quesList = [SELECT Id,SFBG_ExternalId__c,SFBG_HelpText__c,SFBG_Question__c,SPEN_CallOutcome__c,SFBG_QuestionnaireId__c,
                        SFBG_QuestionnaireId__r.Name,SFBG_QuestionToDisplayId__c,SFBG_InformationCategory__c,RecordType.DeveloperName
                        FROM SFBG_Question__c
                        WHERE SFBG_QuestionnaireId__c = :questionnaireId AND Id = :quesId  AND SFBG_IsActive__c = true];
        }
        return quesList;
    }
  @AuraEnabled
    public static List<SFBG_Answer__c> getAnswerToDisplayList(Id quesId) {
        List<SFBG_Answer__c> ansList = new List<SFBG_Answer__c>();
        if(quesId != null){
            ansList = [SELECT Name,Id,SFBG_Answer__c,SFBG_ExternalId__c,SFBG_Order__c,SFBG_QuestionId__c,SFBG_QuestionToDisplayId__c,
                SFBG_Value__c
                FROM SFBG_Answer__c
                WHERE SFBG_QuestionId__c = :quesId  AND SFBG_IsActive__c = true
                ORDER BY SFBG_Order__c];
        }
        return ansList;
    }

  @AuraEnabled
  public static List<SFBG_Answer__c> getNextQuesFromAns(Id answerId,Id quesId) {
    List<SFBG_Answer__c> ansList= new List<SFBG_Answer__c>();
      if(answerId != null){
          ansList = [SELECT Name,Id,SFBG_Answer__c,SFBG_ExternalId__c,SFBG_Order__c,SFBG_QuestionId__c,SFBG_QuestionToDisplayId__c,
                      SFBG_Value__c,SFBG_QuestionId__r.SFBG_QuestionnaireId__c,SFBG_QuestionId__r.SFBG_QuestionToDisplayId__c
                      FROM SFBG_Answer__c
                      WHERE Id = :answerId AND SFBG_IsActive__c = true];
      }
    return ansList;
  }
      

  @AuraEnabled
    public static Map<List<Id>, Boolean> getPrevQuesId(Id questionnaireId,Id quesId) {
        Map<List<Id>, Boolean> prevQMap = new Map<List<Id>, Boolean>();
        List<Id> prevQuestionId = new List<Id>();
        Boolean isFirstQ = false;
        List<SFBG_Answer__c> ansList;
        List<SFBG_Question__c> quesList;
        List<SFBG_Questionnaire__c> ques;
        if(quesId != null){
            ansList = [SELECT Id,SFBG_ExternalId__c,SFBG_Order__c,SFBG_QuestionId__c,SFBG_QuestionToDisplayId__c,SFBG_Value__c
                		FROM SFBG_Answer__c
                		WHERE SFBG_QuestionToDisplayId__c = :quesId AND SFBG_IsActive__c = true];
            
            quesList = [SELECT Id,SFBG_ExternalId__c,SFBG_HelpText__c,SFBG_QuestionToDisplayId__c,SFBG_InformationCategory__c,
                		SPEN_CallOutcome__c,RecordType.DeveloperName
                        FROM SFBG_Question__c
                		WHERE SFBG_QuestionToDisplayId__c = :quesId  AND SFBG_IsActive__c = true];
        }
        if (ansList != null && ansList.size() > 0) {
            prevQuestionId.add(ansList[0].SFBG_QuestionId__c);
        } else if (quesList != null && quesList.size() > 0) {
            prevQuestionId.add(quesList[0].Id);
        } else if(questionnaireId != null){
                 ques = [SELECT Id,Name,SFBG_ExternalId__c,SFBG_StartingQuestionId__c,SPEN_CategoryCriticalInfo__c,SPEN_CategoryRemarks__c,
                         SFBG_Version__c
                		FROM SFBG_Questionnaire__c
                		WHERE Id = :questionnaireId AND SFBG_IsActive__c = true];
            
            if(ques != null && !ques.isEmpty())
            	prevQuestionId.add(ques[0].SFBG_StartingQuestionId__c);
            isFirstQ = true;
        }
        prevQMap.put(prevQuestionId, isFirstQ);
        return prevQMap;
    }

    
  @AuraEnabled
  public static VoiceCall updateVoiceCallRec(Id voiceId){
      
      List<VoiceCall> voiceRec;
      if(voiceId != null){
        voiceRec = [SELECT Id, SPEN_VCCase__c
                    FROM VoiceCall 
                    WHERE Id = : voiceId];
      }
      return voiceRec[0]; 
  }
}