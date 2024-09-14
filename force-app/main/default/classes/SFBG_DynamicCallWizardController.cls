/*-----------------------------------------------------------------------------
DESCRIPTION	:	Service class of the Dynamic Call Wizard. Currently contains Selector Code also. Refinement In Progress.
LIBRARY		:	Salesforce Enterprise Library - Dynamic Call Wizard Framework
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
SEP-21-2022		Dhara Desai     Initial version
12-Oct-2022     Bhagyashree     Appended version
-----------------------------------------------------------------------------*/
public with sharing class SFBG_DynamicCallWizardController {
  // wrapper class with @AuraEnabled and {get;set;} properties
  /*
Wrapper Instances to get only relevant data for rendering
*/
  public class WizardTriageQuestionnaireWrapper {
    @AuraEnabled
    public Id questionnaireId { get; set; }
    @AuraEnabled
    public String questionnaireName { get; set; }    
    @AuraEnabled
    public String questionnaireCriticalInfo { get; set; }
    @AuraEnabled
    public String questionnaireRemarks{ get; set;}
    @AuraEnabled
    public WizardTriageQuestionWrapper firstquestion { get; set; }
  }
  public class WizardTriageQuestionWrapper {
    @AuraEnabled
    public Id previousQuestionId { get; set; }
    @AuraEnabled
    public Id questionnaireId { get; set; }
    @AuraEnabled
    public Id questionId { get; set; }
    @AuraEnabled
    public Id nextQuestionfromQuesId { get; set; }
    @AuraEnabled
    public String questionLabelToDisplay { get; set; }
    @AuraEnabled
    public String questionRecType { get; set; }
    @AuraEnabled
    public String informationQuestionType { get; set; }
    @AuraEnabled
    public List<WizardTriageAnswerWrapper> answers { get; set; }
    @AuraEnabled
    public String questionHelpText { get; set; }

    // Map of current Question and the corresponding answers if more than one options are present
    @AuraEnabled
    public Map<Id, Set<Id>> questionAnswerIdMap { get; set; }

    @AuraEnabled
    public Boolean isLastQuestion { get; set; }
    @AuraEnabled
    public String questionOutcome { get; set; }
  }
  public class WizardTriageAnswerWrapper {
    //Data for Answer
    @AuraEnabled
    public Id answerId { get; set; }
    @AuraEnabled
    public String answerValueToDisplay { get; set; }
    @AuraEnabled
    public Set<Id> answerIds { get; set; }
    @AuraEnabled
    public Decimal answerOrder { get; set; }
    @AuraEnabled
    public Id currentQuestionId { get; set; }
    @AuraEnabled
    public Id nextQuestionId { get; set; }
    @AuraEnabled
    public String answerValue { get; set; }
  }
  public class WizardTriageNewCaseWrapper {
    //Data for Answer
    @AuraEnabled
    public String caseStatus { get; set; }
    @AuraEnabled
    public String caseSubject { get; set; }
    @AuraEnabled
    public String caseOrigin { get; set; }
    @AuraEnabled
    public String caseCategoryOutcome { get; set; }
    @AuraEnabled
    public String caseProblemCategory { get; set; }
    //API NAme of the field in Case Object
    @AuraEnabled
    public String caseTargetFieldName { get; set; }
    //Value to be stored in the caseTargetFieldName field in Case Object
    @AuraEnabled
    public String caseHistory { get; set; }
    @AuraEnabled
    public String caseRemarks { get; set; }
    @AuraEnabled
    public String caseCriticalInformation { get; set; }
    @AuraEnabled
    public String caseRecordType { get; set; }
    @AuraEnabled
    public Id caseContactId { get; set; }
    @AuraEnabled
    public String caseContactName { get; set; }
    @AuraEnabled
    public String contPrefMethod { get; set; }
    @AuraEnabled
    public String caseContactTitle { get; set; }
    @AuraEnabled
    public String casePremiseId { get; set; }
    @AuraEnabled
    public String keyMeterRemarks { get; set; }
    @AuraEnabled
    public Id caseRelatedIncident { get; set; }
  }
}