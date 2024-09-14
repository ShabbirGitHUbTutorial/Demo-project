public without sharing class AP230_MonitoringEventsTypes {
    
    private static String mailmessage='';   
    private static String mailmessage2='';// this will form Table available in email body 
    private static DateTime last1hour = System.Now().addHours(-1);
    private static final String HEADER_START_TAG = '<h2 style="color:Purple;background:yellow;"><u>';
    private static final String HEADER_START_TAG1 = '<h2>';
    private static final String HEADER_END_TAG = '</u></h2>';
    private static final String HEADER_END_TAG1 = '</h2>';
    private static final String PARA_START_TAG ='<p>';
    private static final String PARA_END_TAG = '</p>';
    private static final String LINE_BREAK_TAG = '<br>';
    private static final String TBL_START_TAG = '</u></h2><br/><table style="width:100%" border="1"><tr><th>';
    private static final String TBL_ROW_HD_START_TAG = '<tr><th>';
    private static final String TBL_ROW_HD_MID_TAG = '</th><th>';
    private static final String TBL_ROW_HD_END_TAG = '</th></tr>';
    private static final String TBL_ROW_DT_START_TAG = '<tr align="center"><td>';
    private static final String TBL_ROW_DT_MID_TAG = '</td><td>';
    private static final String TBL_ROW_DT_END_TAG = '</td></tr>';
    private static final String TBL_END_TAG = '</table><BR/><hr>';
    private static final String EMPTY_MAIL ='<No Entry Recorded>';
    public static final string UNIT_TESTING = 'Unit.Testing';
    public static final string PDF_EXTENSION = '.pdf';
    public static final string ACTION_EXPORT = 'export';
    public static final string ACTION_LOGIN_FORENSICS = 'loginForensics%';
    public static final string ACTION_EVENTLOG_WAVE_INTEGRATE = 'eventLogWaveInteg%';
    public static final string ACTION_DELETE_MONITORING_DATA = 'deleteMonitoringData%';
    public static final string SECTION_SESSION_SETTINGS = 'Session Settings';
    public static final string SECTION_PASSWORD_POLICIES = 'Password Policies';
    public static final string ACTION_PASSWORD_LIKE = '%Password%';
    public static final string ACTION_PASSWORD_OBSCURE = '%obscureSecretAnswer%';
    public static final string ACTION_IP_WHITELIST = '%IpWhiteList';
    public static final string ACTION_PROFILE_CUSTOM = '%profile%Custom';
    public static final string ACTION_PROFILE_PERMISSION_CHANGED = 'profilePermChanged%';
    public static final string ACTION_PERM_SET = 'PermSet%';
    public static final string ACTION_DISABLEICFORINTERNALUSERS = 'disableICForInternalUsers%';
    public static final string ACTION_RELAXEMPLOYEEIPRESTRICTIONS = 'relaxEmployeeIpRestrictions%';
    public static final string ACTION_RETAINLOGINHINTS ='retainloginhints%' ;
    public static final string ACTION_HTTPONLY = 'httponly%';
    public static final string ACTION_OVERRIDEIEBLOCKTEMPLATES = 'overrideIeBlockTemplates%';
    public static final string ACTION_SESSION_INBETWEEN = '%session%';
    public static final string ACTION_ICONEMAILCHANGE =  'icOnEmailChange%';
    public static final string ACTION_CERTAUTHENTICATIONENABLE = 'certAuthenticationEnable%';
    public static final string ACTION_LOCKERSERVICE =  'lockerService%';
    public static final string ACTION_LOCKIP =  'lockip%';
    public static final string ACTION_AURACDNPREF = 'auracdnpref%';
    public static final string ACTION_ALLOWOAUTHFORINTERNALUSERS = 'allowOAuthForInternalUsers%';
    public static final string ACTION_CONTINUOUSIPRESTRICTIONS = 'continuousIpRestrictions%';
    public static final string ACTION_FORCESULOGIN = 'forcesulogin%';
    public static final string ACTION_IE11AGREETOTOTERMS = 'IE11AgreeToToTerms%';
    public static final string USER_TYPE_STANDARD = 'Standard';
    public static final String APPLICATION_PDF = 'application/pdf';
    public static final String PROFILE_SYSTEM_ADMIN_EN = 'System Administrator';
    
    /* To run a check on potentially dangerous system permissions assigned through profile or permission set to a user and not to run this query on exception list of profiles & permissionsets mentioned in custom meta data */
    public static List<PermissionSetAssignment> getDangerousSystemPermChanged(){
        mailmessage='';
        List<PermissionSetAssignment> profilePerms=new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permSetPerms=new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> allPerms =new List<PermissionSetAssignment>();
        SecurityPermissionTracker__mdt PSMeta =[select id,Value__c from SecurityPermissionTracker__mdt where developername='PermissionList'];
        SecurityPermissionTracker__mdt PermMeta = [select id,Value__c from SecurityPermissionTracker__mdt where developername='Profile_List'];
        SecurityPermissionTracker__mdt CriticalPermissions = [select id,Value__c from SecurityPermissionTracker__mdt where developername= 'CriticalPermissions'];
        
        String[] PSList = PSMeta.Value__c.split(',');
        String[] ProfileListMeta = PermMeta.Value__c.split(',');
        String CriticalPerms = CriticalPermissions.Value__c;
        Set<String> profileId = new Set<String>();
        for(Profile prId : [Select id from Profile where name IN : ProfileListMeta]) {
            profileId.add(prId.id);
            
        }      
        Map<String,String> proIdTonameMap = new Map<String,String>();
        for(Profile prId : [Select id,name from Profile]) {
            proIdTonameMap.put(prId.id,prId.name);
        }
        String mailbody=HEADER_START_TAG1+System.Label.OrgLabel+UserInfo.getOrganizationId() +HEADER_END_TAG1+HEADER_START_TAG+System.Label.PermLabel+HEADER_END_TAG+ TBL_START_TAG + System.Label.PermSentence + TBL_ROW_HD_MID_TAG + System.Label.AssignedUser + TBL_ROW_HD_MID_TAG + System.Label.ActionDate + TBL_ROW_HD_END_TAG;
        String Q1 = 'SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name,PermissionSet.Label,Assignee.Name,PermissionSet.Profile.Name,PermissionSet.isOwnedByProfile,SystemModstamp,Assignee.CreatedDate FROM PermissionSetAssignment where SystemModstamp >: last1hour and';
        
        String Q2 = CriticalPerms ;
        
        String Q3 = 'and PermissionSet.isOwnedByProfile = false and PermissionSet.Name NOT IN :PSList ORDER BY SystemModstamp DESC';
        
        String Q4 = 'and PermissionSet.isOwnedByProfile = true and PermissionSet.Label NOT IN : profileId ORDER BY SystemModstamp DESC';
        
        String finalPermSetQuery = Q1 + Q2 + Q3 ;
        
        List<PermissionSetAssignment> newList = (List<PermissionSetAssignment>)Database.query(String.escapeSingleQuotes(finalPermSetQuery));
        /* check for permissionSets*/
        for(PermissionSetAssignment permSetDetail : newList){
            permSetPerms.add(permSetDetail);
            
            mailbody=mailbody + TBL_ROW_DT_START_TAG +permSetDetail.PermissionSet.Name + TBL_ROW_DT_MID_TAG + permSetDetail.Assignee.Name+ TBL_ROW_DT_MID_TAG + permSetDetail.SystemModstamp + TBL_ROW_DT_END_TAG;
            
        }       
        
        mailbody = mailbody+ TBL_END_TAG;
        if(permSetPerms!=null && permSetPerms.size()>0){
            mailmessage= mailmessage+ mailbody;
        }
        
        String mailbody2=HEADER_START_TAG+System.Label.ProfilePermSubjectLabel + HEADER_END_TAG+ TBL_START_TAG + System.Label.AssignedProfile + TBL_ROW_HD_MID_TAG + System.Label.AssignedUser + TBL_ROW_HD_MID_TAG + System.Label.ActionDate + TBL_ROW_HD_END_TAG;
        
        /* check for profiles*/
        
        String finalProfileQuery = Q1 + Q2 + Q4 ;
        
        List<PermissionSetAssignment> newListProfile = (List<PermissionSetAssignment>)Database.query(String.escapeSingleQuotes(finalProfileQuery));
        
        for(PermissionSetAssignment permSetDetail : newListProfile){
            profilePerms.add(permSetDetail);
            
            String profileName = proIdTonameMap.get(permSetDetail.PermissionSet.Label);
            mailbody2 = mailbody2 + TBL_ROW_DT_START_TAG + permSetDetail.PermissionSet.Profile.Name + TBL_ROW_DT_MID_TAG +permSetDetail.Assignee.Name +TBL_ROW_DT_MID_TAG + permSetDetail.SystemModstamp + TBL_ROW_DT_END_TAG; 
            System.debug(profileName+mailbody2);
        }
        mailbody2 = mailbody2 + TBL_END_TAG;
        if(profilePerms!=null && profilePerms.size()>0){
            mailmessage= mailmessage+ mailbody2;     
        }
        allPerms.addAll(profilePerms);
        allPerms.addAll(permSetPerms);
        
        if(allPerms!=null && allPerms.size()>0){
            mailmessage = mailmessage + LINE_BREAK_TAG + System.Label.SecurityInformation;    
        }
        
        return allPerms;
        
    }
    
    
    
    /**
*  Return all the events that will be captured by changing Network Settings 
*  @name getNetworkAccessModifications
*  @param (0)
*  @return List<SetupAuditTrail>
*  @throws NA
*/
    public static List<SetupAuditTrail> getNetworkAccessModifications(){
        mailmessage='';
        List<SetupAuditTrail> networkchanges=new List<SetupAuditTrail>();
        String mailbody=HEADER_START_TAG1+System.Label.OrgLabel+UserInfo.getOrganizationId() +HEADER_END_TAG1+HEADER_START_TAG+ System.Label.NetworkSettingChanges + TBL_START_TAG + System.Label.ActionDate + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_MID_TAG + System.Label.Action + TBL_ROW_HD_END_TAG;
        for(SetupAuditTrail auditTrail:[SELECT Action, CreatedBy.Name, CreatedDate, Display, CreatedBy.username 
                                        FROM SetupAuditTrail 
                                        where Action like : ACTION_IP_WHITELIST 
                                        AND CreatedDate >: last1hour ORDER BY CreatedDate DESC]){
                                            networkchanges.add(auditTrail);
                                            mailbody=mailbody +TBL_ROW_DT_START_TAG +auditTrail.CreatedDate + TBL_ROW_DT_MID_TAG +auditTrail.CreatedBy.username+ TBL_ROW_DT_MID_TAG +auditTrail.Display+ TBL_ROW_DT_END_TAG;
                                        }
        mailbody = mailbody + TBL_END_TAG;
        if(networkchanges!=null && networkchanges.size()>0){
            mailmessage= mailmessage+ mailbody;
        }
        return networkchanges;
    }
    
    /**
*  Return all the events that will be captured by changing Password Policies, 
*  @name getPasswordSettings
*  @param (0)
*  @return List<SetupAuditTrail>
*  @throws NA
*/
    public static List<SetupAuditTrail> getPasswordSettings(){
        mailmessage='';
        List<SetupAuditTrail> passwordSetting=new List<SetupAuditTrail>();
        String mailbody=HEADER_START_TAG1+System.Label.OrgLabel+UserInfo.getOrganizationId() +HEADER_END_TAG1+HEADER_START_TAG+System.Label.PasswordPolicyChanges+  TBL_START_TAG + System.Label.ActionDate + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_MID_TAG + System.Label.Action + TBL_ROW_HD_END_TAG;
        for(SetupAuditTrail auditTrail:[SELECT CreatedDate,Section, Display, CreatedBy.Name, CreatedBy.username 
                                        FROM SetupAuditTrail 
                                        WHERE (Action LIKE : ACTION_PASSWORD_LIKE OR Action like : ACTION_PASSWORD_OBSCURE ) 
                                        AND CreatedDate >: last1hour ORDER BY CreatedDate DESC]){
                                            if(auditTrail.Section == SECTION_PASSWORD_POLICIES){
                                                passwordSetting.add(auditTrail);
                                                mailbody=mailbody + TBL_ROW_DT_START_TAG +auditTrail.CreatedDate + TBL_ROW_DT_MID_TAG +auditTrail.CreatedBy.username + TBL_ROW_DT_MID_TAG +auditTrail.Display+ TBL_ROW_DT_END_TAG;
                                                
                                            }
                                        }
        mailbody = mailbody + TBL_END_TAG;
        if(passwordSetting!=null && passwordSetting.size()>0){
            mailmessage= mailmessage+ mailbody;
        }
        return passwordSetting;
    }
    
    /**
*  Return all the events that will be captured by changing Session Settings
*  @name getSessionSettings
*  @param (0)
*  @return List<SetupAuditTrail>
*  @throws NA
*/
    public static List<SetupAuditTrail> getSessionSettings(){
        mailmessage='';
        List<SetupAuditTrail> sessionSetting=new List<SetupAuditTrail>();
        String mailbody=HEADER_START_TAG1+System.Label.OrgLabel+UserInfo.getOrganizationId() +HEADER_END_TAG1+HEADER_START_TAG+System.Label.SessionSettingChanges + TBL_START_TAG + System.Label.ActionDate + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_MID_TAG + System.Label.Action + TBL_ROW_HD_END_TAG;
        for(SetupAuditTrail auditTrail:[SELECT Section, CreatedDate, Display, CreatedBy.Name, CreatedBy.username 
                                        FROM SetupAuditTrail 
                                        WHERE (      Action like : ACTION_SESSION_INBETWEEN OR Action like : ACTION_IE11AGREETOTOTERMS OR Action like : ACTION_LOCKERSERVICE OR Action like : ACTION_OVERRIDEIEBLOCKTEMPLATES OR
                                               Action like : ACTION_CONTINUOUSIPRESTRICTIONS OR Action like : ACTION_FORCESULOGIN OR Action like : ACTION_LOCKIP OR Action like : ACTION_HTTPONLY OR
                                               Action like : ACTION_ICONEMAILCHANGE OR Action like : ACTION_AURACDNPREF OR Action like : ACTION_RETAINLOGINHINTS OR
                                               Action like : ACTION_CERTAUTHENTICATIONENABLE OR Action like : ACTION_ALLOWOAUTHFORINTERNALUSERS OR Action like : ACTION_RELAXEMPLOYEEIPRESTRICTIONS OR
                                               Action like : ACTION_DISABLEICFORINTERNALUSERS)
                                        AND CreatedDate >: last1hour ORDER BY CreatedDate DESC]){
                                            if(auditTrail.Section== SECTION_SESSION_SETTINGS){
                                                sessionSetting.add(auditTrail);
                                                mailbody=mailbody + TBL_ROW_DT_START_TAG +auditTrail.CreatedDate + TBL_ROW_DT_MID_TAG +auditTrail.CreatedBy.username + TBL_ROW_DT_MID_TAG +auditTrail.Display+ TBL_ROW_DT_END_TAG;
                                            }
                                        }
        mailbody = mailbody + TBL_END_TAG;
        if(sessionSetting!=null && sessionSetting.size()>0){
            mailmessage= mailmessage+ mailbody;
        }
        return sessionSetting;
    }
    
    /**
*  Return all the events that will be captured by changing Event monitoring Settings
*  @name getEventConfigurationMonitoring
*  @param (0)
*  @return List<SetupAuditTrail>
*  @throws NA
*/
    public static List<SetupAuditTrail> getEventConfigurationMonitoring(){
        mailmessage='';
        List<SetupAuditTrail> eventMonitorings=new List<SetupAuditTrail>();
        String mailbody=HEADER_START_TAG1+System.Label.OrgLabel+UserInfo.getOrganizationId() +HEADER_END_TAG1+HEADER_START_TAG+ System.Label.EventMonitoring + TBL_START_TAG + System.Label.ActionDate + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_MID_TAG + System.Label.Action + TBL_ROW_HD_END_TAG;
        for(SetupAuditTrail auditTrail:[SELECT Action , CreatedDate, Display, CreatedBy.Name, CreatedBy.username 
                                        FROM SetupAuditTrail 
                                        WHERE (Action LIKE : ACTION_LOGIN_FORENSICS OR Action LIKE : ACTION_EVENTLOG_WAVE_INTEGRATE OR Action LIKE : ACTION_DELETE_MONITORING_DATA ) 
                                        AND CreatedDate >: last1hour ORDER BY CreatedDate DESC]){
                                            eventMonitorings.add(auditTrail);
                                            mailbody=mailbody + TBL_ROW_DT_START_TAG +auditTrail.CreatedDate + TBL_ROW_DT_MID_TAG +auditTrail.CreatedBy.username + TBL_ROW_DT_MID_TAG +auditTrail.Display+ TBL_ROW_DT_END_TAG;
                                        }
        mailbody = mailbody + TBL_END_TAG;
        if(eventMonitorings!=null && eventMonitorings.size()>0){
            mailmessage= mailmessage+ mailbody;
        }
        return eventMonitorings;
    }
    
    /**
*  Return all the events that will be captured by Exporting Data from salesforce by data export
*  @name getDataExport
*  @param (0)
*  @return List<SetupAuditTrail>
*  @throws NA
*/
    public static List<SetupAuditTrail> getDataExport(){
        mailmessage='';
        List<SetupAuditTrail> dataExpList=new List<SetupAuditTrail>();
        String mailbody=HEADER_START_TAG1+System.Label.OrgLabel+UserInfo.getOrganizationId() +HEADER_END_TAG1+HEADER_START_TAG+ System.Label.DataExpLabel +  TBL_START_TAG + System.Label.ActionDate + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_MID_TAG + System.Label.Action + TBL_ROW_HD_END_TAG;
        for(SetupAuditTrail auditTrail:[SELECT CreatedDate, Display, CreatedBy.Name, CreatedBy.username 
                                        FROM SetupAuditTrail 
                                        WHERE Action =: ACTION_EXPORT 
                                        AND CreatedDate >: last1hour  ORDER BY CreatedDate DESC]){
                                            dataExpList.add(auditTrail);
                                            mailbody=mailbody + TBL_ROW_DT_START_TAG +auditTrail.CreatedDate + TBL_ROW_DT_MID_TAG +auditTrail.CreatedBy.username + TBL_ROW_DT_MID_TAG +auditTrail.Display+ TBL_ROW_DT_END_TAG;
                                        }
        mailbody = mailbody + TBL_END_TAG;
        if(dataExpList!=null && dataExpList.size()>0){
            mailmessage= mailmessage+ mailbody;
        }
        return dataExpList;
    }
    
    /**
*  Method that will fetch pdf attachment from VF Page
*  @name getAttachment
*  @param (2)- String, PageReference
*  @return  Messaging.EmailFileAttachment
*  @throws NA
*/
    private static Messaging.EmailFileAttachment getAttachment(string fileName, PageReference pgRef){
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType(APPLICATION_PDF);
        attach.setFileName(fileName + PDF_EXTENSION);
        attach.setInline(false);
        Blob b1 = Test.isRunningTest()?blob.valueOf(UNIT_TESTING):pgRef.getContentAsPDF();
        attach.setBody(b1);
        return attach;
    }
    
    /**
*  Method will be called directly from Schedular classwhich internall call all 6 method
*  @name callingMethod
*  @param (0)
*  @throws Exception
*/
    public static void callingMethod(){
        String subjectline='';
        
        List<String> emailsTo=new List<String>();
        for(EmailIdForEvents__mdt email_md:[Select EmailId__c 
                                            from EmailIdForEvents__mdt]){
                                                emailsTo.add(email_md.EmailId__c);
                                            }
        if(emailsTo.size()>0){
            if( getDataExport().size()>0 || Test.isRunningTest()){
                subjectline=System.Label.CountryService+System.Label.DataExpLabel+ System.now();
                sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.DataExpLabel,Page.VFP228_EM_MonitorDataExport));
            }else{
                subjectline=System.Label.CountryService +System.Label.DataExpLabel+ System.now()+EMPTY_MAIL+null;
                sendMail(emailsTo, null, null, mailmessage, subjectline, null);
            }
            /*
if(getProfilePermChanged().size()>0|| Test.isRunningTest()){
subjectline=System.Label.CountryService +System.Label.ProfilePermSubjectLabel+ System.now();
sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.ProfilePermSubjectLabel,Page.VFP227_EM_MonitorProfPermChanges));
}else{
subjectline=System.Label.CountryService +System.Label.ProfilePermSubjectLabel+ System.now()+EMPTY_MAIL+null;
sendMail(emailsTo, null, null, mailmessage, subjectline, null);
}
*/
            if( getNetworkAccessModifications().size()>0|| Test.isRunningTest()){
                subjectline=System.Label.CountryService +System.Label.NetworkSettingChanges+ System.now();
                sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.NetworkSettingChanges,Page.VFP231_EM_NetworkAccessChanges));
            }else{
                subjectline=System.Label.CountryService +System.Label.NetworkSettingChanges+ System.now()+EMPTY_MAIL+null;
                sendMail(emailsTo, null, null, mailmessage, subjectline, null);
            }
            if( getPasswordSettings().size()>0|| Test.isRunningTest()){
                subjectline=System.Label.CountryService +System.Label.PasswordPolicyChanges+ System.now();
                sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.PasswordPolicyChanges,Page.VFP229_EM_MonitorPasswordSettingVF));
            }else{
                subjectline=System.Label.CountryService +System.Label.PasswordPolicyChanges+ System.now()+EMPTY_MAIL+null;
                sendMail(emailsTo, null, null, mailmessage, subjectline, null);
            }
            if( getSessionSettings().size()>0|| Test.isRunningTest()){
                subjectline=System.Label.CountryService +System.Label.SessionSettingChanges+ System.now();
                sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.SessionSettingChanges,Page.VFP230_EM_MonitorSessionSettingsVF));
            }else{
                subjectline=System.Label.CountryService +System.Label.SessionSettingChanges+ System.now()+EMPTY_MAIL+null;
                sendMail(emailsTo, null, null, mailmessage, subjectline, null);
            }
            if( getEventConfigurationMonitoring().size()>0|| Test.isRunningTest()){
                subjectline=System.Label.CountryService +System.Label.EventMonitoring + System.now();
                sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.EventMonitoring,Page.VFP232_EM_EventConfigurationMonitoringVF));
            }else{
                subjectline=System.Label.CountryService +System.Label.EventMonitoring + System.now()+EMPTY_MAIL+null;
                sendMail(emailsTo, null, null, mailmessage, subjectline, null);
            }
            
            if( getDangerousSystemPermChanged().size()>0 || Test.isRunningTest()){
                subjectline=System.Label.CountryService+System.Label.ProfilePermMsg+ System.now();
                sendMail(emailsTo, null, null, mailmessage, subjectline, getAttachment(System.Label.ProfilePermMsg,Page.VFP227_EM_MonitorProfPermChanges));
            }else{
                subjectline=System.Label.CountryService +System.Label.ProfilePermMsg+ System.now()+EMPTY_MAIL+null;
                sendMail(emailsTo, null, null, mailmessage, subjectline, null);
            }
            
        }
    }
    /**
*  Method will execute to send emailMail
*  @name sendMail
*  @param (6)- TO-recipients, CC-recipients, reply-to email, email body, subject line, list of attachments
*  @return Void
*  @catches exception
*/
    public static void sendMail(List<string> toMail, string ccMail, string repMail, string partBody,string subject, Messaging.EmailFileAttachment attachment){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] cc = new string[] {ccMail};
            email.setToAddresses(toMail);
        if(ccMail!=null && ccMail != ''){
            email.setCcAddresses(cc);
        }
        if(repmail!=null && repmail!= ''){
            email.setInReplyTo(repMail);
        }
        email.setSubject(subject);
        email.setHtmlBody(partBody);
        List<OrgWideEmailAddress> alertSender=[SELECT Id 
                                               FROM OrgWideEmailAddress 
                                               WHERE Address =: Label.OrgWideEmail limit 1];
        if(alertSender != null && alertSender.size()>0){
            email.setOrgWideEmailAddressId(alertSender[0].Id);
        }
        if(attachment!=null){
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment}); 
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}