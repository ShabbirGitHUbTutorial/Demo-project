public class FetchOrgCertificate implements Schedulable{
    public static final String HEADER_START_TAG = '<h2 style="color:white;background:red;"><u>';
    public static final String HEADER_END_TAG = '</u></h2><br/>';

    //This method is responsible for sending email for Certificate Expiry notification
    public static void sendNotificationonExpiry(Map<String,Date> certNameExpDtMap){
        Certificate_Notification_Setting__c certInfo = Certificate_Notification_Setting__c.getOrgDefaults();
        Integer noOfDays = Integer.valueOf(certInfo.First_Notification__c);
        Integer secondNoti = Integer.valueOf(certInfo.Second_Notification__c);
        Integer thirdNoti = Integer.valueOf(certInfo.Third_Notification__c);        
        Integer lastNoti = Integer.valueOf(certInfo.Last_Notification__c);
        
        Boolean sendNotification = false;

		String headerAppend = HEADER_START_TAG+System.Label.CountryTitle +'|'+UserInfo.getOrganizationId() +HEADER_END_TAG;
        
        for(Date dt : certNameExpDtMap.values()){
            if(dt == Date.today().addDays(noOfDays)){
                sendNotification = true;
            }else if(dt == Date.today().addDays(secondNoti)){
                sendNotification = true;
            }else if(dt == Date.today().addDays(thirdNoti)){
                sendNotification = true;
            }else if(Date.today() >= dt.addDays(-1 * lastNoti)){
                sendNotification = true;
            }
        }
        if(sendNotification){
            //Getting the email template
            EmailTemplate emailTemplate = [Select Id,Subject,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Certificate Expiry Notification Template'];
            if(emailTemplate != null){
                String subject = 'Alert|'+System.Label.DailyMonitoring.replace('Daily ','')+'Certificate Expiry Notification|'+system.now();
                String body = emailTemplate.HtmlValue.replaceAll('\\{NoOfDays}',String.valueOf(noOfDays));
                String expiredCertsTemplate = body.substring(body.indexOf('[{1}'), body.indexOf('{1}]'));
                String certsExpiringin15DaysTemplate = body.substring(body.indexOf('[{2}'), body.indexOf('{2}]'));
                String expiredCerts = '',certsExpiringin15Days = '';
                for(String s: certNameExpDtMap.keySet()){
                    if(certNameExpDtMap.get(s) < Date.today()){
                        expiredCerts = expiredCerts + expiredCertsTemplate;
                        expiredCerts = expiredCerts.replace('{certificationName}', s);
                        expiredCerts = expiredCerts.replace('{certificationExpDt}', String.valueOf(certNameExpDtMap.get(s)));
                    }else{
                        certsExpiringin15Days = certsExpiringin15Days + certsExpiringin15DaysTemplate;
                        certsExpiringin15Days = certsExpiringin15Days.replace('{certificationName}', s);
                        certsExpiringin15Days = certsExpiringin15Days.replace('{certificationExpDt}', String.valueOf(certNameExpDtMap.get(s)));
                    } 
                }  
                body = body.replace(expiredCertsTemplate, expiredCerts);
                body = body.replace(certsExpiringin15DaysTemplate, certsExpiringin15Days);
                body = body.remove('[{1}');
                body = body.remove('{1}]');
                body = body.remove('[{2}');
                body = body.remove('{2}]');
                if(String.isBlank(expiredCerts)){
                    body = body.replace('{displayExpiredCerts}','none');
                    body = body.replace('{displayNoExpiredCerts}','show');
                }else{
                    body = body.replace('{displayExpiredCerts}','show');
                    body = body.replace('{displayNoExpiredCerts}','none');
                }
                if(String.isBlank(certsExpiringin15Days)){
                    body = body.replace('{displayExpiringCerts}','none');
                    body = body.replace('{displayNoExpiringCerts}','show');
                }else{
                    body = body.replace('{displayExpiringCerts}','show');
                    body = body.replace('{displayNoExpiringCerts}','none');
                }
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> toAddressList = new List<String>();
                for(AOEventMonitoringRecipients__c eventMonitoring : [Select EmailId__c FROM AOEventMonitoringRecipients__c]){
                    toAddressList.add(eventMonitoring.EmailId__c);
                }
                mail.setToAddresses(toAddressList);
                mail.setSubject(subject);
                mail.setHtmlBody(headerAppend+body); 
                mailList.add(mail);   
                Messaging.sendEmail(mailList);   
            } 
        }
    }
    
    // This the main Method For getting Certificate Information from Tooling API
    @future(callout = true) 
    public static void getORGCertificateFuture(Boolean sendEmail){
        getORGCertificate(sendEmail);
    }
    public static Boolean getORGCertificate(Boolean sendEmail){
        Map<String, Date> certMap = new Map<String,Date>();
        //Getting Config Data here
        Certificate_Notification_Setting__c certInfo = Certificate_Notification_Setting__c.getOrgDefaults();
        if(certInfo != null){
            try{
                HttpRequest request = new HttpRequest();
                request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + certInfo.End_Point__c);
                request.setMethod('GET');
                request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                request.setHeader('Content-Type', 'application/json');
                Integer noOfDays = Integer.valueOf(certInfo.First_Notification__c);
                ToolinApiResponse response = (ToolinApiResponse)JSON.deserialize(new Http().send(request).getBody(), ToolinApiResponse.class);
                System.debug('Response = '+ response);
                for(Cls_records c: response.records){
                    if(!c.OptionsIsUnusable && !c.DeveloperName.endsWithIgnoreCase('_old') && Date.ValueOf(c.ExpirationDate)<= Date.today().addDays(noOfDays)){
                        certMap.put(c.DeveloperName, Date.ValueOf(c.ExpirationDate)); 
                    }
                }

                if(certMap.size()>0){
                    if(sendEmail && certInfo.Enable_Certificate_Notification__c){
                        certInfo.Certificate_Expiring_Nearby__c = true;
                        update certInfo;
                        sendNotificationonExpiry(certMap);         
                    }  
                }
            }catch(Exception e){
                System.debug('Sorry!! Error Occured : '+ e.getMessage());
                return false;
            }
        }
        return certMap.size()>0;
    }
    public Class ToolinApiResponse{
        public Cls_records[] records;
    }
    public class Cls_records {
        public String DeveloperName;
        Public DateTime ExpirationDate;
        public Boolean OptionsIsUnusable;
    }
    public void execute(SchedulableContext sc){
        getORGCertificateFuture(true);
    }
}