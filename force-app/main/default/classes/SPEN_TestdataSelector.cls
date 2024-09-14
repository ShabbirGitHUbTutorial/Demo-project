/*-----------------------------------------------------------------------------
DESCRIPTION :   Test class for queries in test class
AUTHOR      :   Shubhi Vijayvergia
HISTORY     :
Date            Author              Comment
Jun-27-2023     Shubhi Vijayvergia         Initial version
-----------------------------------------------------------------------------*/
/* note for any existing query please add fields in the same query 
 only if the access is there in devops permissionset group
/*---------------------------------------------------------------------------------*/
@isTest
public with sharing class SPEN_TestdataSelector {
    //method to fetch profile
    public static Profile getProfile(String profileName){
        Profile p;
        if(String.isNotBlank(profileName)){
            p= [SELECT Id FROM Profile WHERE Name =:profileName LIMIT 1];
        }
        return p;
    }
    //method to fetch permission set group
    public static PermissionSetGroup getPSGroup(String psGroupName){
        PermissionSetGroup pg=new PermissionSetGroup();
        if(String.isNotBlank(psGroupName)){
            pg= [SELECT Id,Status FROM PermissionSetGroup WHERE DeveloperName =:psGroupName LIMIT 1]; 
        }
        return pg;
    }
    //method to fetch permission set
    public static PermissionSet getPermissionSet(String psName){
        PermissionSet ps1=new PermissionSet();
        if(String.isNotBlank(psName)){
            ps1 = [SELECT Id FROM PermissionSet WHERE Name =: psName];
        }
        return ps1;
    }
    //meythod to fetch user
    public static User getuser(String firstName){
        User user =new User();
        if(String.isNotBlank(firstName)){
            user= [SELECT id FROM user where firstname=:firstName AND isActive=true limit 1];
        }
        return user;
    }
    public static User getuserProfile(String profileName){
        User user =new User();
        if(String.isNotBlank(profileName)){
            user= [SELECT id FROM user where profile.Name=:profileName AND isActive=true limit 1];
        }
        return user;
    }
    //method to fetch ivrmessagge
    public static SPEN_iVRmessage__c getIVRMessage(String externalId){
        SPEN_iVRmessage__c iVRmessage=new SPEN_iVRmessage__c();
        if(String.isNotBlank(externalId)){
            iVRmessage =  [SELECT id,SPEN_iVRmessage__c FROM SPEN_iVRmessage__c WHERE SPEN_ExternalId__c=:externalId limit 1]; 
        }
        return iVRmessage;
    }
    //method to fetcvh zone filtering type
    public static SPEN_Zone__c getZone(String type){
        SPEN_Zone__c zone=new SPEN_Zone__c();
        if(String.isNotblank(type)){
            zone= [SELECT id,SPEN_Parent__c,SPEN_Type__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_IVRTemplateBody__c
                        FROM SPEN_Zone__c WHERE SPEN_Type__c=:type limit 1];

        }
        return zone;
    }
    //method to fetcvh zone filtering type
    public static SPEN_Zone__c getZone(Id id){
        SPEN_Zone__c zone=new SPEN_Zone__c();
        if(id!=null){
            zone= [SELECT id,SPEN_Parent__c,SPEN_Type__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_IVRTemplateBody__c
                        FROM SPEN_Zone__c WHERE Id=:id limit 1];

        }
        return zone;
    }
    //method to fetch IR
    public static  SPEN_IntegrationRequest__c getIR(Id id){
        SPEN_IntegrationRequest__c ir=new SPEN_IntegrationRequest__c();
        if(id!=null){
            ir= [Select id,SPEN_RelatedRecord__c,SPEN_Response__c from SPEN_IntegrationRequest__c where SPEN_RelatedRecord__c=:id];
        }
        return ir;
    }
    //get listviews
   	public static List<ListView> getListViews(String type){
        List<ListView> listViewList=new List<ListView>();
        if(String.isNotBlank(type)){
    		listViewList=[SELECT Id, Name FROM ListView WHERE SobjectType =:type order by Name];
        }
        return listViewList;
	}

}