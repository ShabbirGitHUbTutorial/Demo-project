/*
@Author Robin Bhatt
@name SysAdminCreationTriggerHandler
@CreateDate 19-April-2019
@Description Hold method to execute After User is inserted and Updated
@Version <1.0>
*/
public without sharing class AP232_SysAdminCreationTriggerHandler {
    
    private static Boolean isFirstTime = true;
    private static final String HEADER_START_TAG = '<h2 style="color:Purple;background:yellow;"><u>';
    private static final String TBL_START_TAG = '</u></h2><br/><table style="width:100%" border="1"><tr><th>';
    private static final String TBL_ROW_HD_START_TAG = '<tr><th>';
    private static final String TBL_ROW_HD_MID_TAG = '</th><th>';
    private static final String TBL_ROW_HD_END_TAG = '</th></tr>';
    private static final String TBL_ROW_DT_START_TAG = '<tr><td>';
    private static final String TBL_ROW_DT_MID_TAG = '</td><td>';
    private static final String TBL_ROW_DT_END_TAG = '</td></tr>';
    private static final String TBL_END_TAG = '</table><BR/><hr>';
    
    /**
*  Method will execute after user detail is modified 
*  @name afterUserUpdate
*  @param (2)- Map<Id,User>:Filtered Trigger.OldMap, List<User> :Filtered Trigger.New
*  @return Void
*  @throws exception
*/
    public static void afterUserUpdate(Map<Id,User> oldMap, List<User> usrs){
        List<User> adminUsers=new List<User>();
        Set<Id> userIds=new Set<Id>();
        string mailBody='';
        Map<Id, User> actingUsers=null;
        if(isFirstTime){
            isFirstTime=false;
            List<Profile> adminpro=[SELECT Id, Name 
                                    FROM Profile 
                                    WHERE Name =: 'System Administrator' limit 1];
            if(adminpro != null && adminpro.size()>0){
                for(User usr:usrs){
                    if(usr.ProfileId == adminpro[0].Id){
                        userIds.add(usr.CreatedById);
                        userIds.add(usr.LastModifiedById);
                        if(OldMap.get(usr.Id).profileId != adminpro[0].Id || (OldMap.get(usr.Id).isActive==false && usr.isActive==true)){
                            adminUsers.add(usr);
                        }
                    }
                }
                if(!adminUsers.isEmpty() && adminUsers.size()>0){
                    actingUsers=new Map<ID, User>([Select Username 
                                                   from User 
                                                   where Id In: userIds]);
                    mailBody = HEADER_START_TAG+System.Label.SysAdminUpdated +UserInfo.getOrganizationId() + TBL_START_TAG + System.Label.Username + TBL_ROW_HD_MID_TAG + System.Label.NewUserMail + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_END_TAG;
                    for(integer i=0; i<adminUsers.size(); i++){
                        mailBody=mailBody +TBL_ROW_DT_START_TAG +adminUsers[i].username+TBL_ROW_DT_MID_TAG+adminUsers[i].email+TBL_ROW_DT_MID_TAG+actingUsers.get(adminUsers[i].LastModifiedById).username+TBL_ROW_DT_END_TAG;
                    }
                    mailBody =mailBody+TBL_END_TAG;
                    List<String> emailsTo=new List<String>();
                    for(EmailIdForEvents__mdt email_md:[Select EmailId__c 
                                                        from EmailIdForEvents__mdt]){
                                                            emailsTo.add(email_md.EmailId__c);
                                                        } 
                    if(emailsTo.size()>0){
                        sendMail(emailsTo, mailBody, System.Label.CountryService +System.Label.SysAdminUpdated+System.now());
                    }
                } 
            }
        }
    }
    
    /**
*  Method will execute after user detail is Inserted 
*  @name afterUserInserted
*  @param (1) List<User> :Filtered Trigger.New
*  @return Void
*  @throws exception
*/
    public static void afterUserInserted(List<User> usrs){
        List<User> adminUsers=new List<User>();
        Set<Id> userIds=new Set<Id>();
        string mailBody='';
        Map<Id, User> actingUsers=null;
        List<Profile> adminpro=[SELECT Id, Name 
                                FROM Profile
                                WHERE Name =: 'System Administrator' limit 1];
        if(adminpro != null && adminpro.size()>0){
            for(User usr:usrs){
                if( usr.ProfileId == adminpro[0].Id){
                    userIds.add(usr.CreatedById);
                    userIds.add(usr.LastModifiedById);
                    adminUsers.add(usr);
                }
            }
            if(!adminUsers.isEmpty() && adminUsers.size()>0){
                actingUsers=new Map<ID, User>([Select Username 
                                               from User 
                                               where Id In: userIds]);
                mailBody = HEADER_START_TAG+System.Label.SysAdminUpdated+UserInfo.getOrganizationId() + TBL_START_TAG + System.Label.Username + TBL_ROW_HD_MID_TAG + System.Label.NewUserMail + TBL_ROW_HD_MID_TAG + System.Label.ActionUser + TBL_ROW_HD_END_TAG;
                for(integer i=0; i<adminUsers.size(); i++){
                    mailBody=mailBody +TBL_ROW_DT_START_TAG +adminUsers[i].username+TBL_ROW_DT_MID_TAG+adminUsers[i].email+TBL_ROW_DT_MID_TAG+actingUsers.get(adminUsers[i].createdById).username+TBL_ROW_DT_END_TAG;
                }
                mailBody =mailBody+TBL_END_TAG;
                List<String> emailsTo=new List<String>();
                for(EmailIdForEvents__mdt email_md:[Select EmailId__c 
                                                    from EmailIdForEvents__mdt]){
                                                        emailsTo.add(email_md.EmailId__c);
                                                    } 
                if(emailsTo.size()>0){
                    sendMail(emailsTo,  mailBody, System.Label.CountryService +System.Label.SysAdminUpdated+System.now());
                }
            }
        }
    }
    
    /**
*  Method will execute to send emailMail
*  @name sendMail
*  @param (3)- TO-recipients, email body, subject line
*  @return Void
*  @catches exception NA
*/
    @future
    private static void sendMail(List<string> toMail, string partBody,string subject){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toMail);
        email.setSubject(subject);
        email.setHtmlBody(partBody);
        List<OrgWideEmailAddress> alertSender=[SELECT Id 
                                               FROM OrgWideEmailAddress 
                                               WHERE Address =: Label.OrgWideEmail limit 1];
        if(alertSender != null && alertSender.size()>0){
            email.setOrgWideEmailAddressId(alertSender[0].Id);
        }
        if(!Test.isRunningTest())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}