/*-----------------------------------------------------------------------------
DESCRIPTION	:	Service class of the Dynamic Call Wizard. Currently contains Selector Code also. Refinement In Progress.
LIBRARY		:	Salesforce Enterprise Library - Dynamic Call Wizard Framework
VERSION		:	1.0

HISTORY		:
Date			Author				    Comment
SEP-21-2022		Bhagyashree Mandlik     Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SFBG_DynamicCallWizardService {
  @AuraEnabled
  public static List<SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper> getQuestionnaire(
    String launchVal
  ) {
    try {
      List<SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper> questionnaireData = new List<SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper>();
      List<SFBG_Questionnaire__c> questionnaireList = SFBG_DynamicCallWizardSelector.getQuestionnaireList(
        launchVal
      );
      SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper questionnaireDataToSend = new SFBG_DynamicCallWizardController.WizardTriageQuestionnaireWrapper();

      if (!questionnaireList.isEmpty()) {
        for (SFBG_Questionnaire__c quest : questionnaireList) {
          questionnaireDataToSend.questionnaireId = quest.Id;
          questionnaireDataToSend.questionnaireName = quest.Name;
          questionnaireDataToSend.questionnaireCriticalInfo = quest.SPEN_CategoryCriticalInfo__c;
          questionnaireDataToSend.questionnaireRemarks = quest.SPEN_CategoryRemarks__c;
          questionnaireDataToSend.firstquestion = getQuesAndAnsToDisplay(
            quest.Id,
            quest.SFBG_StartingQuestionId__c
          );
          questionnaireData.add(questionnaireDataToSend);
        }
      }
      return questionnaireData;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper getQuesAndAnsToDisplay(
    Id questionnaireId,
    Id quesId
  ) {
    try {
      SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper questionData = new SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper();
      SFBG_Question__c question = SFBG_DynamicCallWizardSelector.getQuesToDisplayList(
        questionnaireId,
        quesId
      );
      List<SFBG_DynamicCallWizardController.WizardTriageAnswerWrapper> answerListToSend = new List<SFBG_DynamicCallWizardController.WizardTriageAnswerWrapper>();
      Map<SFBG_Question__c, List<SFBG_Answer__c>> quesAnsMap = new Map<SFBG_Question__c, List<SFBG_Answer__c>>();
      List<SFBG_Answer__c> answerList = SFBG_DynamicCallWizardSelector.getAnswerToDisplayList(
        quesId
      );
      Boolean nextQfromA = false;
      if (question != null) {
        questionData.questionnaireId = question.SFBG_QuestionnaireId__c;
        questionData.questionId = question.Id;
        questionData.questionLabelToDisplay = question.SFBG_Question__c;
        questionData.questionRecType = question.RecordType.DeveloperName;
        if (question.SFBG_QuestionToDisplayId__c != null) {
          questionData.nextQuestionfromQuesId = question.SFBG_QuestionToDisplayId__c;
        }
        questionData.informationQuestionType = question.SFBG_InformationCategory__c;
        questionData.questionHelpText = question.SFBG_HelpText__c;
        questionData.questionOutcome = question.SPEN_CallOutcome__c;
      }
      if (!answerList.isEmpty()) {
        for (SFBG_Answer__c answer : answerList) {
          SFBG_DynamicCallWizardController.WizardTriageAnswerWrapper currAnswer = new SFBG_DynamicCallWizardController.WizardTriageAnswerWrapper();

          currAnswer.answerId = answer.Id;
          currAnswer.answerValueToDisplay = answer.SFBG_Answer__c;
          currAnswer.answerValue = answer.SFBG_Value__c;
          currAnswer.answerOrder = answer.SFBG_Order__c;
          currAnswer.currentQuestionId = answer.SFBG_QuestionId__c;
          if (answer.SFBG_QuestionToDisplayId__c != null) {
            currAnswer.nextQuestionId = answer.SFBG_QuestionToDisplayId__c;
            nextQfromA = true;
          } else{            
            questionData.isLastQuestion = true;
          }
          answerListToSend.add(currAnswer);
        }
      }
      if (questionData.nextQuestionfromQuesId == null && nextQfromA == false) {
        questionData.isLastQuestion = true;
      }

      questionData.answers = answerListToSend;
      return questionData;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper getNextQuesFromAns(
    Id answerId,
    Id quesId
  ) {
    try {
      SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper wrapperToReturn = new SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper();
      List<SFBG_Answer__c> ansList = SFBG_DynamicCallWizardSelector.getNextQuesFromAns(
        answerId,
        quesId
      );
      SFBG_Question__c currentQuestion = SFBG_DynamicCallWizardSelector.checkIfQuestionTypeText(
        quesId
      );

      if (
        ansList.size() > 0 &&
        ansList[0].SFBG_QuestionToDisplayId__c != null
      ) {
        wrapperToReturn = getQuesAndAnsToDisplay(
          ansList[0].SFBG_QuestionId__r.SFBG_QuestionnaireId__c,
          ansList[0].SFBG_QuestionToDisplayId__c
        );
      }

      if (
        currentQuestion.RecordType.Name == 'Textbox' ||
        currentQuestion.RecordType.Name == 'Information'
      ) {
        wrapperToReturn = getQuesAndAnsToDisplay(
          currentQuestion.SFBG_QuestionnaireId__c,
          currentQuestion.SFBG_QuestionToDisplayId__c
        );
      }
      wrapperToReturn.previousQuestionId = quesId;
      return wrapperToReturn;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Case createCasefromCallWizard(
    String caseData,
    Boolean isBypassCase
  ) {
    try {
      String result;
      Id insertedRecord;
      SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper caseDataWrapper = (SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper) System.JSON.deserializeStrict(
        caseData,
        SFBG_DynamicCallWizardController.WizardTriageNewCaseWrapper.class
      );
      Case wizardCase = new Case();
      wizardCase.Status = caseDataWrapper.caseStatus;
      wizardCase.Subject = caseDataWrapper.caseSubject;
      wizardCase.Origin = caseDataWrapper.caseOrigin;
      wizardCase.SPEN_CaseCategoryOutcome__c = caseDataWrapper.caseCategoryOutcome;
      wizardCase.SPEN_CaseProblemCategory__c = caseDataWrapper.caseProblemCategory;
      wizardCase.SPEN_WizardHistory__c = caseDataWrapper.caseHistory;
      wizardCase.SPEN_Incident__c = caseDataWrapper.caseRelatedIncident;

      if (
        caseDataWrapper.caseCategoryOutcome ==
        SFBG_DynamicCallWizardConstant.Case_KeyMeter
      ) {
        if (caseDataWrapper.keyMeterRemarks == 'faulty') {
          caseDataWrapper.caseRemarks = addAutoPopulationFields(
            'Meter Faulty',
            caseDataWrapper.caseRemarks
          );
        } else if (caseDataWrapper.keyMeterRemarks == 'lost') {
          caseDataWrapper.caseRemarks = addAutoPopulationFields(
            'Lost or Faulty Key',
            caseDataWrapper.caseRemarks
          );
        }
      }
      wizardCase.SPEN_Remarks__c = caseDataWrapper.caseRemarks;
      wizardCase.SPEN_CriticalInformation__c = caseDataWrapper.caseCriticalInformation;
      if (isBypassCase == true) {
        wizardCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get(CasesConstants.Case_UnplannedBypass)
          .getRecordTypeId();
      }
      else
      {
          wizardCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get(CasesConstants.Case_UnplannedFault)
          .getRecordTypeId();
      }
      //Written by Ayush
      if (caseDataWrapper.casePremiseId != null) {
        wizardCase.SPEN_AddressPremise__c = caseDataWrapper.casePremiseId;
      }
      //Written by Ayush
      if (caseDataWrapper.caseContactId != null) {
        Contact callerData = SFBG_CommonDynamicWizardService.getPreferredContactMethod(
          caseDataWrapper.caseContactId
        );
        wizardCase.ContactId = caseDataWrapper.caseContactId;
        wizardCase.SPEN_PreferredMethodofContact__c = caseDataWrapper.contPrefMethod;
        wizardCase.SPEN_CallerName__c = callerData.Name;
        wizardCase.SPEN_CallerTitle__c = callerData.Title;
      }
      Database.SaveResult dataSaveRes = Database.insert(wizardCase);
      if (dataSaveRes.isSuccess()) {
        insertedRecord = dataSaveRes.getId();
      }
      List<Case> caseToReturn = SPEN_CaseSelector.getCaseNumber(insertedRecord);
      return caseToReturn[0];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper getPrevQuestion(
    Id questionnaireId,
    Id quesId
  ) {
    try {
      SFBG_DynamicCallWizardController.WizardTriageQuestionWrapper wrapperToReturn = getQuesAndAnsToDisplay(
        questionnaireId,
        quesId
      );
      Map<List<Id>, Boolean> prevQId = SFBG_DynamicCallWizardSelector.getPrevQuesId(
        questionnaireId,
        quesId
      );
      Boolean isfirstQuestion = false;
      for (List<Id> idValue : prevQId.keyset()) {
        isfirstQuestion = prevQId.get(idValue);
        if (!isfirstQuestion) {
          wrapperToReturn.previousQuestionId = idValue[0];
        }
      }
      return wrapperToReturn;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static String addAutoPopulationFields(
    String infoToAdd,
    String destField
  ) {
    try {
      if (
        destField != '' ||
        destField != null ||
        destField != 'undefined' ||
        destField != 'null'
      ) {
        destField = infoToAdd + ': ' + destField;
      } else {
        destField = infoToAdd;
      }
      return destField;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static CasesConstants getAllConstants() {
      return new CasesConstants();
  }

  @AuraEnabled
  public static SPEN_Premise__c getPremiseDetails(Id premiseId){
    try {
     
      SPEN_Premise__c premise = new SPEN_Premise__c();
      premise = SPEN_DynamicWizardServiceHelper.getPremiseData(premise,premiseId); 
      return premise;
      
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void updateVoiceCall(Id voiceCallId, Id caseId) {
    if(voiceCallId != NULL && caseId != NULL){
      SFBG_DynamicCallWizardSelector.updateVoiceCallRec(voiceCallId);
      VoiceCall vcToUpdate = new VoiceCall();
      vcToUpdate.Id = voiceCallId;
      vcToUpdate.SPEN_VCCase__c = caseId;
      SPEN_DynamicWizardServiceHelper.updateVoiceCall(vcToUpdate);
    }
  }
  
}