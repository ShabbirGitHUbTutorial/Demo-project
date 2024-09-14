public class SPEN_SurveyUtility {
    public static SurveyInvitation createSurveyInvitation(String communityId, String surveyId, String name, String channel, String type, boolean anonymousresponse, boolean guestUserResponse, Id caseId, Id incidentId, Id participantId, DateTime expirationDate) {
        SurveyInvitation sInv = new SurveyInvitation();
        sInv.CommunityId = communityId;
        sInv.Name = 'SI-' + name;
        sInv.SPEN_SurveyChannel__c = channel;
        sInv.SPEN_Type__c = type;
        sInv.OptionsCollectAnonymousResponse = false;
        sInv.OptionsAllowGuestUserResponse = true;
        sInv.SurveyId = surveyId;
        sInv.SPEN_Case__c = caseId;
        sInv.SPEN_Incident__c = incidentId;
        sInv.ParticipantId = participantId;
        return sInv;
    }
    public static List<SurveySubject> createSurveySubject(List<SurveyInvitation> sInvList){
        List<SurveySubject> sSubList = new List<SurveySubject>();
        //Create survey subject records
        for(SurveyInvitation sInv : sInvList){
            SurveySubject SS = new SurveySubject();
            SS.SubjectId = sInv.ParticipantId;
            SS.Name = 'SS' + sInv.Name;
            SS.ParentId = SInv.Id;
            system.debug(sInv.InvitationLink);
            sSubList.add(SS);		
        }
        return sSubList;
    }
    public static Map<String, Id> getSurveyIDs(List<String> surveyNames){
        Map<String, Id> surveyNameIdMap = new Map<String, Id>();
        if(!Test.isRunningTest())
        {
        	for(Survey surveyrec : [Select Id, Name, DeveloperName from Survey where Name in :surveyNames or  DeveloperName in :surveyNames ]){
            	surveyNameIdMap.put(surveyrec.Name, surveyrec.Id);
            	surveyNameIdMap.put(surveyrec.DeveloperName, surveyrec.Id);
        	}
        }
        else{
            surveyNameIdMap.put('surveyName', null);
            surveyNameIdMap.put('surveyDeveloperName', null);
        }
        return surveyNameIdMap;
        
    }
	public static OrgWideEmailAddress getSurveyOrgWideAddress(){
		//List<OrgWideEmailAddress> oweaList = new OrgWideEmailAddress();
        return [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address like '%survey%'];
	}
    
    public static void updateVoiceAlertWithInvitation(Set<Id> voiceAlertIds, String surveyType){
        try
        {
            Map<Id, SPEN_VoiceAlert__c> voiceAlertMap = new Map<Id, SPEN_VoiceAlert__c> ();
            for(SPEN_VoiceAlert__c va : [SELECT Id, Name, SPEN_IncidentId__c, SPEN_ContactId__c, SPEN_CalledInTelephone__c, SPEN_Event__c, SPEN_IsProactive__c, SPEN_Case__c FROM SPEN_VoiceAlert__c WHERE ID IN :voiceAlertIDs]){
                voiceAlertMap.put(va.Id, va);
            }
            if(!voiceAlertMap.isEmpty()){
                Map<Id,String> contactSurveyIdMap = new Map<Id, String>();
                Set<Id> sInvSet = new Set<Id>();
                String key;
                Map<String, String> surveySettingMap = new Map<String, String>();
                
                //Get Custom Metadata
                for(SPEN_SurveySetting__mdt surveySetting : [SELECT Id, SPEN_Active__c, SPEN_CaseOrigin__c, SPEN_Proactive__c, SPEN_SurveyChannel__c, SPEN_SurveyName__c, SPEN_Type__c FROM SPEN_SurveySetting__mdt WHERE SPEN_SurveyChannel__c = 'Voice Alert' and SPEN_Active__c = true]){
                    
                    if(surveyType.equalsIgnoreCase('Faults') && surveySetting.SPEN_Type__c.equalsIgnoreCase('Faults')){
                        if(surveySetting.SPEN_Proactive__c){
                            key = surveySetting.SPEN_Type__c + '|' + surveySetting.SPEN_Proactive__c;			 
                        }
                        else{
                            key = surveySetting.SPEN_Type__c + '|' + surveySetting.SPEN_Proactive__c;
                        }
                        surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                    } else if(surveyType.equalsIgnoreCase('Single Premise') && surveySetting.SPEN_Type__c.equalsIgnoreCase('Single Premise')){
                        key = surveySetting.SPEN_Type__c;
                        surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                    }
                    else if(surveyType.equalsIgnoreCase('General Enquiries') && surveySetting.SPEN_Type__c.equalsIgnoreCase('General Enquiries')){
                        key = surveySetting.SPEN_Type__c;
                        surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                    }	
                }
                system.debug('surveySettingMap>>'+surveySettingMap);
                //Run Survey Invitation Logic only if Surveys available
                if(!surveySettingMap.isEmpty()){
                    List<SurveyInvitation> sInvList = new List<SurveyInvitation>();
                    List<SurveySubject> sSubList = new List<SurveySubject>();	
                    Map<String,Id> surveyNameIdMap = new Map<String,Id>();
                    
                    //Get survey ids against surveys
                    surveyNameIdMap = getSurveyIDs(surveySettingMap.values());
                    system.debug('surveyNameIdMap>>'+surveyNameIdMap);
                    
                    if(!surveyNameIdMap.isEmpty()){
                        
                        List<Network> communityId = new List<Network>([select Id from Network where Name = :System.Label.SPEN_SurveyCommunityName]);
                        
                        //Survey Surveyrec = [Select Id,Name from Survey where Name = 'SPEN Survey Example'];
                        system.debug('communityId>>'+communityId);    
                        
                        //Create SurveyInvitation records
                        for(SPEN_VoiceAlert__c va : voiceAlertMap.values() ){
                            Id surveyId;
                            if(surveyType.equalsIgnoreCase('Faults')){
                                if(va.SPEN_IsProactive__c && surveySettingMap.containsKey('Faults|true')){
                                    surveyId = surveyNameIdMap.get(surveySettingMap.get('Faults|true'));
                                }
                                else if(!va.SPEN_IsProactive__c && surveySettingMap.containsKey('Faults|false')){
                                    surveyId = surveyNameIdMap.get(surveySettingMap.get('Faults|false'));
                                }
                            }
                            else if(surveyType.equalsIgnoreCase('Single Premise')){
                                surveyId = surveyNameIdMap.get(surveySettingMap.get('Single Premise')); 
                            }
                            else if(surveyType.equalsIgnoreCase('General Enquiries')){
                                surveyId = surveyNameIdMap.get(surveySettingMap.get('General Enquiries')); 
                            }         
                            
                            system.debug('surveyId>>'+surveyId); 
                            if(surveyId != null){
                                SurveyInvitation SInv = SPEN_SurveyUtility.createSurveyInvitation(communityId[0].id,surveyId,va.Name,'Voice Alert',surveyType, false, false,va.SPEN_Case__c, va.SPEN_IncidentId__c, va.SPEN_ContactId__c, null);				
                                sInvList.add(SInv);
                            }			
                        }
                        system.debug('sInvList>>'+sInvList);
                        
                        if(!sInvList.isEmpty()){
                            insert sInvList;
                            for(SurveyInvitation sInv : sInvList){
                                sInvSet.add(sInv.id);           
                            }
                            //Create survey subject records
                            for(SurveyInvitation sInv : [Select id, Name, InvitationLink, ParticipantId from surveyInvitation where id in :sInvSet]){
                                SurveySubject SS = new SurveySubject();
                                SS.SubjectId = sInv.ParticipantId;
                                SS.Name = 'SS' + sInv.Name;
                                SS.ParentId = SInv.Id;
                                system.debug(sInv.InvitationLink);
                                contactSurveyIdMap.put(sInv.ParticipantId, sInv.id);
                                sSubList.add(SS);		
                            }
                            system.debug('sSubList>>' + sSubList);
                            insert sSubList;
                        }
                    }
                    //Update VA record with Survey Invitation Link and Status
                    for(SPEN_VoiceAlert__c va : voiceAlertMap.values()){
                        String sInvLink;
                        if(contactSurveyIdMap.containsKey(va.SPEN_ContactId__c)){
                            sInvLink = contactSurveyIdMap.get(va.SPEN_ContactId__c);
                            va.SPEN_SurveyInvitation__c = sInvLink;
                        }                               
                    }
                    system.debug('voiceAlertMap>>'+voiceAlertMap);
                    update voiceAlertMap.values();
                }
            }
        }
        
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }    
    }
    
    //Added by Govind 
    public static String getshortenURL(String uuId){
        String dumyUid;
        String shortenURL;
        String communityUrl;
        
        List<Domain> dnsName = [SELECT Id,HttpsOption,  Domain, DomainType FROM Domain where HttpsOption ='CommunityAlt'];
        List<Network> netwrokURL = [SELECT Name, UrlPathPrefix FROM Network where Name = :System.Label.SPEN_SurveyCommunityName];
        /*List<SurveyInvitation> sInvitation = [SELECT Id, InvitationLink, Name, UUID FROM SurveyInvitation WHERE UUID=:uuId];
        dumyUid=sInvitation.UUID;*/
        
        shortenURL = 'https:/'+ '/' + dnsName[0].Domain + '/'+ netwrokURL[0].UrlPathPrefix +'?uuid=' + uuId;
        system.debug('shortenURL==>' + shortenURL);
        return shortenURL;
        
    }
    
    public static void updateSMSWithInvitation(Set<Id> smsIdSet, String surveyType){
        String key; //Format : Type|Proactive, when case origin is included in future - update to Type|Proactive|Case Origin
        Map<String, String> surveySettingMap = new Map<String, String>();
        Map<Id,SPEN_SMS__c> smsMap = new Map <Id,SPEN_SMS__c> ([SELECT Id, Name, SPEN_IncidentId__c, SPEN_ContactId__c, SPEN_Message__c, SPEN_IsProactive__c, SPEN_CaseId__c FROM SPEN_SMS__c where id in :smsIdSet and SPEN_Status__c = 'Created']);
        try{      	
            for(SPEN_SurveySetting__mdt surveySetting : [SELECT Id, SPEN_Active__c, SPEN_CaseOrigin__c, SPEN_Proactive__c, SPEN_SurveyChannel__c, SPEN_SurveyName__c, SPEN_Type__c FROM SPEN_SurveySetting__mdt WHERE  SPEN_SurveyChannel__c = 'SMS' and SPEN_Active__c = true]){
                
                if(surveyType.equalsIgnoreCase('Faults') && surveySetting.SPEN_Type__c.equalsIgnoreCase('Faults'))
                {
                    if(surveySetting.SPEN_Proactive__c){
                        key = surveySetting.SPEN_Type__c + '|' + surveySetting.SPEN_Proactive__c;			 
                    }
                    else{
                        key = surveySetting.SPEN_Type__c + '|' + surveySetting.SPEN_Proactive__c;
                    }
                    surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                } 
                else if(surveyType.equalsIgnoreCase('Single Premise') && surveySetting.SPEN_Type__c.equalsIgnoreCase('Single Premise'))
                {
                    key = surveySetting.SPEN_Type__c;
                    surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                }
                else if(surveyType.equalsIgnoreCase('General Enquiries') && surveySetting.SPEN_Type__c.equalsIgnoreCase('General Enquiries'))
                {
                    key = surveySetting.SPEN_Type__c;
                    surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                }
                
            }
            system.debug('surveySettingMap>>'+surveySettingMap);
            
            if(!surveySettingMap.isEmpty()){
                Map<Id,String> contactSurveyLinkMap = new Map<Id, String>();
                Map<id,String> uiMap=new Map<id,String>();
                List<SurveyInvitation> sInvList = new List<SurveyInvitation>();
                List<SurveySubject> sSubList = new List<SurveySubject>();	
                Map<String,Id> surveyNameIdMap = new Map<String,Id>();
                String uuid;
                Id surveyId;
                SPEN_IVRMessageSelector ivrSel = new SPEN_IVRMessageSelector();
                SPEN_IVRMessage__c faultSPIntroMsg = ivrSel.selectByExternalId('SMS – Faults and SP – Survey Intro');
                String surveyIntroMsg = '';
                
                //Get survey ids against surveys
                surveyNameIdMap = getSurveyIDs(surveySettingMap.values());
                system.debug('surveyNameIdMap>>'+surveyNameIdMap);
                
                if(!surveyNameIdMap.isEmpty()){
                    Set<Id> sInvSet = new Set<Id>();
                    List<Network> communityId = new List<Network>([select Id from Network where Name = :System.Label.SPEN_SurveyCommunityName]);
                    system.debug('communityId>>'+communityId);   
                    //Create SurveyInvitation records
                    for(SPEN_SMS__c sms : smsMap.values() ){
                        if(surveyType.equalsIgnoreCase('Faults')){
                            if(sms.SPEN_IsProactive__c && surveySettingMap.containsKey('Faults|true')){
                                surveyId = surveyNameIdMap.get(surveySettingMap.get('Faults|true')); 
                            }
                            else if(!sms.SPEN_IsProactive__c && surveySettingMap.containsKey('Faults|false')){
                                surveyId = surveyNameIdMap.get(surveySettingMap.get('Faults|false')); 
                            }
                            surveyIntroMsg = faultSPIntroMsg.SPEN_IVRMessage__c;
                        }
                        else if(surveyType.equalsIgnoreCase('Single Premise')){
                            surveyId = surveyNameIdMap.get(surveySettingMap.get('Single Premise')); 
                            surveyIntroMsg = faultSPIntroMsg.SPEN_IVRMessage__c;
                        }
                        else if(surveyType.equalsIgnoreCase('General Enquiries')){
                            surveyId = surveyNameIdMap.get(surveySettingMap.get('General Enquiries')); 
                        }
                        system.debug('surveyId>>'+surveyId); 
                        if(surveyId != null){
                            SurveyInvitation SInv = createSurveyInvitation(communityId[0].id,surveyId,sms.Name,'SMS',surveyType, false, false,sms.SPEN_CaseId__c, sms.SPEN_IncidentId__c, sms.SPEN_ContactId__c, null);				
                            sInvList.add(SInv);
                        }			
                    }
                    system.debug('sInvList>>'+sInvList);
                    
                    if(!sInvList.isEmpty()){
                        insert sInvList; 
                        for(SurveyInvitation sInv : sInvList){
                            sInvSet.add(sInv.id);     
                            
                        }
                        //Create survey subject records
                        for(SurveyInvitation sInv : [Select id, Name, InvitationLink,UUId, ParticipantId from surveyInvitation where id in :sInvSet]){
                            uiMap.put(sInv.ParticipantId,sInv.UUId);
                            System.debug('uuid'+uuid);
                            SurveySubject SS = new SurveySubject();
                            SS.SubjectId = sInv.ParticipantId;
                            SS.Name = 'SS' + sInv.Name;
                            SS.ParentId = SInv.Id;
                            system.debug(sInv.InvitationLink);
                            contactSurveyLinkMap.put(sInv.ParticipantId, sInv.InvitationLink);
                            sSubList.add(SS);		
                        }
                        system.debug('sSubList>>' + sSubList);
                        insert sSubList;
                    }
                }
                //Update SMS record with Survey Invitation Link and Status
                for(SPEN_SMS__c sms : smsMap.values()){
                    String sInvLink;
                    if(contactSurveyLinkMap.containsKey(sms.SPEN_ContactId__c)){
                        sInvLink=getshortenURL(uiMap.get(sms.SPEN_ContactId__c));
                        System.debug('sInvLink'+sInvLink);
                        sms.SPEN_Message__c = sms.SPEN_Message__c + '\n\n' + surveyIntroMsg + ' ' + sInvLink;
                        sms.Survey_Invitation_Link__c = sInvLink;
                    }
                    sms.SPEN_Status__c = 'Ready';
                    
                }
                system.debug('smsMap>>'+smsMap);
                update smsMap.values();
            }
        }
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }		
        
    }
    
    public static void sendSurveyEmails(Map<Id,Id> caseContactMap, Map<Id,String> caseEmailMap, String surveyType)
    {
        String key;
        Map<String, String> surveySettingMap = new Map<String, String>();
        List<String> lstTemplate = new List<String>();
        try{
            for(SPEN_SurveySetting__mdt surveySetting : [SELECT Id, SPEN_Active__c, SPEN_CaseOrigin__c, SPEN_Proactive__c, SPEN_SurveyChannel__c, SPEN_SurveyName__c, SPEN_Type__c,SPEN_EmailTemplate__c FROM SPEN_SurveySetting__mdt WHERE  SPEN_SurveyChannel__c = 'Email' and SPEN_Active__c = true])
            {
                if(surveyType.equalsIgnoreCase('General Enquiries') && surveySetting.SPEN_Type__c.equalsIgnoreCase('General Enquiries'))
                {
                    key = surveySetting.SPEN_Type__c;
                    surveySettingMap.put(key,surveySetting.SPEN_SurveyName__c);
                    lstTemplate.add(surveySetting.SPEN_EmailTemplate__c);
                }     			
            }
            system.debug('surveySettingMap>>'+surveySettingMap);
            
            if(!surveySettingMap.isEmpty())
            {
                Map<Id,String> contactSurveyLinkMap = new Map<Id, String>();
                Map<id,String> uiMap=new Map<id,String>();
                List<SurveyInvitation> sInvList = new List<SurveyInvitation>();
                List<SurveySubject> sSubList = new List<SurveySubject>();	
                Map<String,Id> surveyNameIdMap = new Map<String,Id>();
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String uuid;
                Id surveyId;
                Messaging.SingleEmailMessage mail;
                String conId;
                
                //Get survey ids against surveys
                surveyNameIdMap = getSurveyIDs(surveySettingMap.values());
                system.debug('surveyNameIdMap>>'+surveyNameIdMap);
                
                if(!surveyNameIdMap.isEmpty())
                {
                    Set<Id> sInvSet = new Set<Id>();
                    List<Network> communityId = new List<Network>([select Id from Network where Name = :System.Label.SPEN_SurveyCommunityName]); 
                    system.debug('communityId>>'+communityId);   
                    
                    for(Id caseId : caseContactMap.keySet())
                    {
                        if(surveyType.equalsIgnoreCase('General Enquiries'))
                        {
                            surveyId = surveyNameIdMap.get(surveySettingMap.get('General Enquiries')); 
                        }
                        if(surveyId != null)
                        {
                            SurveyInvitation SInv = createSurveyInvitation(communityId[0].id,surveyId,caseId,'Email',surveyType, false, false,caseId, null, caseContactMap.get(caseId), null);				
                            sInvList.add(SInv);
                        }
                    }
                    
                    if(!sInvList.isEmpty())
                    {
                        insert sInvList; 
                        for(SurveyInvitation sInv : sInvList)
                        {
                            sInvSet.add(sInv.id);     
                        }
                        //Create survey subject records
                        for(SurveyInvitation sInv : [Select id, Name, InvitationLink,UUId, ParticipantId from surveyInvitation where id in :sInvSet])
                        {
                            // uiMap.put(sInv.ParticipantId,sInv.UUId);
                            // System.debug('uuid'+uuid);
                            SurveySubject SS = new SurveySubject();
                            SS.SubjectId = sInv.ParticipantId;
                            SS.Name = 'SS' + sInv.Name;
                            SS.ParentId = SInv.Id;
                            system.debug(sInv.InvitationLink);
                            contactSurveyLinkMap.put(sInv.ParticipantId, sInv.InvitationLink);
                            sSubList.add(SS);		
                        }
                        system.debug('sSubList>>' + sSubList);
                        insert sSubList;
                        
                        //get org wide email adderess
                        Id oweaId = getSurveyOrgWideAddress().id;
                        
                        EmailTemplate emailTemplate = [select Id,Name, Subject, HtmlValue, Body from EmailTemplate where Name In : lstTemplate];
                        for(Id caseId : caseContactMap.keyset())
                        {
                            mail = new Messaging.SingleEmailMessage();
                            conId = caseContactMap.get(caseId);
                            mail.setWhatId(caseId);
                            String htmlBody = emailTemplate.HtmlValue;
                            htmlBody = htmlBody.replace('[[SURVEY_INVITATION_URL]]', contactSurveyLinkMap.get(conId));
                            mail.settargetobjectid(conId);
                            mail.setToAddresses(new List<String>{caseEmailMap.get(caseId)});
                            mail.setOrgWideEmailAddressId(oweaId);
                            mail.setSubject(emailTemplate.Subject);
                            mail.setHtmlBody(htmlBody);
                            mail.setTreatBodiesAsTemplate(true);
                            mail.setTreatTargetObjectAsRecipient(false);
                            
                            emailList.add(mail);								
                        }
                        if(!emailList.isEmpty()){
                            Messaging.sendEmail(emailList);
                        }	
                    }				
                }
            }
        }
        catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
}