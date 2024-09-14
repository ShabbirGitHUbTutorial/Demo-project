public without sharing class SPEN_SurveyHandler {
    
    /*************************************************************************
@Author: Rajat Verma
@Date: 16/04/24
@purpose: Get the Survey Question Responses
*************************************************************************************/
    @InvocableMethod(label='Get SurveyQuestionResponse' description='Get the Survey Question Responses')
    public static List<List<SurveyQuestionResponse>> getRelatedSurveyQuestionResponses(List<Id> surveyResponseIds){
        
        List<List<SurveyQuestionResponse>> surveyQRList = new List<List<SurveyQuestionResponse>>();
        List<SurveyQuestionResponse> sqrList = new List<SurveyQuestionResponse>();
        if(!Test.isRunningTest()){
            sqrList = [SELECT id, InvitationId, Invitation.ParticipantId,Invitation.SPEN_Case__c, Invitation.SPEN_Case__r.SPEN_District__c,Invitation.SPEN_Incident__c, 
                       Invitation.InvitationLink, Invitation.SPEN_Type__c,Invitation.SPEN_Incident__r.SPEN_District__c,Invitation.SPEN_Incident__r.SPEN_Distrcits__c,Invitation.SPEN_Incident__r.SPEN_Distrcits__r.Name, Question.QuestionName, Question.QuestionType, Question.QuestionOrder , 
                       ResponseValue,NumberValue from SurveyQuestionResponse WHERE ResponseId =: surveyResponseIds AND Question.QuestionType IN ('NPS','CSAT','Picklist') order by Question.QuestionOrder ASC];
            
            
        }else{
            List<Case> csList = [Select Id,CaseNumber From Case where Id =: surveyResponseIds ];
        }
        if(!sqrList.isEmpty()){
            surveyQRList.add(sqrList); 
        } 
        return surveyQRList;
    }
    @AuraEnabled(cacheable=true)
    public static List<SurveyQuestionResponse> getSurveyResponses(Id caseId) {
        
		List<SurveyQuestionResponse> responses = new List<SurveyQuestionResponse>();
        Case cs = [Select Id,SPEN_AdditionalInformation__c from Case where Id=:caseId];

		if(Schema.sObjectType.SurveyResponse.isAccessible()) {
            
			responses = [Select id,ResponseValue,Question.Name from SurveyQuestionResponse where Response.InvitationId=:cs.SPEN_AdditionalInformation__c order by Question.QuestionOrder ASC];
		}
        else {
            responses = [Select id,ResponseValue,Question.Name from SurveyQuestionResponse where Response.InvitationId=:cs.SPEN_AdditionalInformation__c AND (Question.QuestionType != 'ShortText' AND Question.QuestionType != 'FreeText')	 order by Question.QuestionOrder ASC];
        }
        
        return responses;
    }
}