/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-24-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SPEN_VoiceAlertServiceQueueable Implements Queueable, Database.AllowsCallouts {
    
    Set<Id> vAlrtIdLst = new Set<Id> (); 
    String ivrBroadcstMsg;
    
    public SPEN_VoiceAlertServiceQueueable(Set<Id> idLst, String ivrMsg) { 
        this.vAlrtIdLst.addAll(idLst);
        this.ivrBroadcstMsg = ivrMsg;        
    } 
    
    public void execute(QueueableContext context) { 
        
        //System.debug('Inside queueable Callout');
        //System.debug('ivrMsg' +ivrBroadcstMsg);
        if(!vAlrtIdLst.isEmpty()) {
            Integer vaCount=0;
            Integer iteration=1;
            Integer awsVoiceAlertLimit=Integer.valueof(SPEN_BatchSettings__mdt.getInstance('SPEN_AWSVoiceAlertLimit').SPEN_BatchSize__c);
            Map<Integer,List<SPEN_VoiceAlert__c>> awsSubVaListMap=new Map<Integer,List<SPEN_VoiceAlert__c>>();
            Set<String> surveyInvitationIds = new Set<String>();
            Map<String,String> invitationSurveyIdMap = new Map<String,String> ();
            Map<String,String> invitationVersionIdMap = new Map<String,String> ();
            for(SPEN_VoiceAlert__c vAlert : [select id, SPEN_TelephoneNumberFormula__c,SPEN_CalledInTelephone__c,
                                             SPEN_ContactId__c,SPEN_ContactId__r.OtherPhone,SPEN_SurveyInvitation__c,
                                             SPEN_Event__c
                                             from SPEN_VoiceAlert__c WHERE  Id IN :this.vAlrtIdLst]){
                if(vaCount<awsVoiceAlertLimit){
                    List<SPEN_VoiceAlert__c> subVaList=new List<SPEN_VoiceAlert__c>();
                    if(awsSubVaListMap.containsKey(iteration)){
                        subVaList.addAll(awsSubVaListMap.get(iteration));
                    }
                    subVaList.add(vAlert);
                    surveyInvitationIds.add(vAlert.SPEN_SurveyInvitation__c);
                    awsSubVaListMap.put(iteration,subVaList);
                    vaCount++;
                }else{
                    vaCount=0;
                    iteration++;
                }
            }
            if(!surveyInvitationIds.IsEmpty())
            {
                for(SurveyInvitation surveyInv: [Select Id,SurveyId,Survey.ActiveVersionID
                                      			FROM SurveyInvitation
                                                WHERE ID IN: surveyInvitationIds])
                {
                    //String surveyInvId = String.ValueOf(surveyInv.Id).left(15);// check this if 15 digit will work or 18 digit needed for AWS
                    invitationSurveyIdMap.put(surveyInv.Id,surveyInv.SurveyId);
                    invitationVersionIdMap.put(surveyInv.SurveyId,surveyInv.Survey.ActiveVersionID);
                }
            }
            Map<String,String> versionQuestionsMap = new Map<String,String> ();
			String questionStr;
            for(SurveyQuestion surveyQuestionRec : [SELECT Id,  DeveloperName, questionorder, QuestionType, Name, SurveyVersionId, surveyversion.SurveyStatus, CreatedById 
                                                    from SurveyQuestion 
                                                    where surveyversionid IN: invitationVersionIdMap.Values() 
                                                    AND surveyversion.SurveyStatus = 'Active' order by questionorder ASC])
            {
                if(!versionQuestionsMap.containsKey(surveyQuestionRec.surveyversionid))
                {
                    questionStr = '\''+surveyQuestionRec.DeveloperName +'\''; 
                }
                else
                {
                    questionStr = questionStr + ',' + '\''+surveyQuestionRec.DeveloperName +'\'';
                }
                versionQuestionsMap.put(surveyQuestionRec.surveyversionid,questionStr);
            }
            
            for(Integer i:awsSubVaListMap.keyset()){
                String jsonString = '{ \"attributes\": [';
                Boolean isJSONEmpty=true;
                String resultStr ='';
                for(SPEN_VoiceAlert__c vAlert :awsSubVaListMap.get(i)){
                    String phoneNumberWithOutOther = (vAlert.SPEN_CalledInTelephone__c != null) ? vAlert.SPEN_CalledInTelephone__c : vAlert.SPEN_TelephoneNumberFormula__c;
                    // CRMD-5225 condition added at below places.
                    String phoneNumber = String.isNotBlank(phoneNumberWithOutOther) ? phoneNumberWithOutOther : vAlert.SPEN_ContactId__r.OtherPhone;

                    // phoneNumber=SPEN_ContactSelector.phoneno(sId);
                    if(String.isNotBlank(phoneNumber)) 
                    {
                        isJSONEmpty=false;
                        String surveyId = (!invitationSurveyIdMap.IsEmpty()) ? invitationSurveyIdMap.get(vAlert.SPEN_SurveyInvitation__c) : '';
                        String questionIds =  (!versionQuestionsMap.IsEmpty() && String.IsNotBlank(surveyId))? versionQuestionsMap.get(invitationVersionIdMap.get(surveyId)): '';
                        phoneNumber = phoneNumber.startsWith('0') ? ('+44'+phoneNumber.removeStart('0')) : phoneNumber;
                        jsonString+='{'+
                        '       \"phoneNumber\": \"'+phoneNumber+'\",'+
                            '       \"voiceId\": \"'+vAlert.id+'\",'+
                            '       \"ivrMessage\": \"'+ivrBroadcstMsg+'\",'+
                            '       \"contactId\": \"'+vAlert.SPEN_ContactId__c+'\",'+
                            '       \"surveyQuestionsIds\": \"'+questionIds+'\",'+
                            '       \"surveyInvitationId\": \"'+vAlert.SPEN_SurveyInvitation__c+'\",'+
                            '       \"surveyId\": \"'+surveyId+'\",'+
                            '       \"Event\": \"'+vAlert.SPEN_Event__c+'\"'+
                            '   },';
                    }
                }
                jsonString=jsonString.removeEnd(',');
                jsonString+=']}' ;          
                try{
                    if(!isJSONEmpty){
                        SPEN_IVRVoiceAlertWrapper testBody = SPEN_IVRVoiceAlertWrapper.parse(jsonString);
                        system.debug('JSON.serialize(testBody) --------->>>>>'+ JSON.serialize(testBody));     
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint('callout:AWSLambda');
                        req.setMethod('POST');
                        req.setHeader('content-type', 'application/json');
                        //req.setBody(phoneNumber);
                        req.setTimeout(SPEN_ImpactedPremisesConstants.VA_TIMEOUT); 
                        req.setBody(JSON.serialize(testBody));
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        resultStr = res.getBody();
                        system.debug('resultStr --------->>>>>'+ resultStr); 
                    } 
                }catch(Exception ex){
                    SEL_LoggingService.log(ex);
                    throw ex;
                }
            }
        }   
               
    }
  }