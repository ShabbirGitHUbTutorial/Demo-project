/**
 * @description  This class runs the appropriate methods on the trigger handler based on the current trigger context.
 */
public without sharing class TriggerDispatcher {
	private static String objectType;
	private static Trigger_Setting__mdt activeSetting;
  /*
    Call this method from your trigger, passing in an instance of a trigger handler which implements TriggerHandlerInterface.
    This method will fire the appropriate methods on the handler depending on the trigger context.
  */
  public static void run(TriggerHandlerInterface handler)
  {

        if(Trigger.isExecuting) {
            if(Trigger.isDelete) {
                objectType = Trigger.old.getSObjectType().getDescribe().getName();
            } else {
                objectType = Trigger.new.getSObjectType().getDescribe().getName();
            }
        }
        
        if(executeTriggerHandler()) {  
            if(Trigger.isBefore){
                beforeTrigger(handler);
            }
            if(Trigger.isAfter){
                afterTrigger(handler);
            }
        }
	}
    private static void beforeTrigger(TriggerHandlerInterface handler){
        if(Trigger.isInsert && activeSetting.Before_Insert__c){
            handler.BeforeInsert(Trigger.New);
        }
        if(Trigger.isUpdate && activeSetting.Before_Update__c){
            handler.BeforeUpdate(Trigger.NewMap, Trigger.oldMap);
        }
        if(Trigger.isDelete && activeSetting.Before_Delete__c){
            handler.BeforeDelete(Trigger.oldMap);
        }
    }
    private static void afterTrigger(TriggerHandlerInterface handler){
        if(Trigger.isInsert && activeSetting.After_Insert__c){
            handler.AfterInsert(Trigger.newMap);
        }
        if(Trigger.isUpdate && activeSetting.After_Update__c){
            handler.AfterUpdate(Trigger.newMap, Trigger.oldMap);
        }

        If(Trigger.isDelete && activeSetting.After_Delete__c){
            handler.AfterDelete(Trigger.oldMap);
        }
        If(Trigger.isUndelete && activeSetting.After_Undelete__c){
            handler.AfterUndelete(Trigger.oldMap);
        }
    }	
    public static Boolean executeTriggerHandler() {
        Boolean hasBypass = false;
        Boolean triggerIsActive = false;
        if(null == activeSetting) {
            for(Trigger_Setting__mdt triggerSetting : getAllTriggerSettings()) {
                if(String.isNotBlank(triggerSetting.Triggering_Object__c) && triggerSetting.Triggering_Object__r.QualifiedApiName == objectType) {
                        activeSetting = triggerSetting;
                        break;
                } else if(String.isNotBlank(triggerSetting.Alt_Object_Api_Name__c) && triggerSetting.Alt_Object_Api_Name__c == objectType) {
                        activeSetting = triggerSetting;
                        break;
                }
            }
        }
        if(null != activeSetting) {
            triggerIsActive = activeSetting.IsActive__c;
            if(String.isNotBlank(activeSetting.Bypass_Permission_Name__c)) {
				hasBypass = FeatureManagement.checkPermission(activeSetting.Bypass_Permission_Name__c);
            }
        }
        return (!hasBypass && triggerIsActive);
    }
	@SuppressWarnings('PMD.SOQLSelectorPattern')
    public static List<Trigger_Setting__mdt> getAllTriggerSettings() {
        List<Trigger_Setting__mdt> metadataList=new  List<Trigger_Setting__mdt> ();
            if(String.isNotBlank(objectType)){
                metadataList.addAll([SELECT Id, MasterLabel, DeveloperName, IsActive__c, 
                        Alt_Object_Api_Name__c, Bypass_Permission_Name__c,
                        After_Delete__c, After_Insert__c, After_Undelete__c,
                        After_Update__c, Before_Delete__c, Before_Insert__c,
                        Before_Update__c, Triggering_Object__c, Triggering_Object__r.QualifiedApiName
                FROM Trigger_Setting__mdt WHERE Triggering_Object__r.QualifiedApiName =:objectType]);
                
                metadataList.AddAll([SELECT Id, MasterLabel, DeveloperName, IsActive__c, 
                        Alt_Object_Api_Name__c, Bypass_Permission_Name__c,
                        After_Delete__c, After_Insert__c, After_Undelete__c,
                        After_Update__c, Before_Delete__c, Before_Insert__c,
                        Before_Update__c, Triggering_Object__c, Triggering_Object__r.QualifiedApiName
                FROM Trigger_Setting__mdt WHERE Alt_Object_Api_Name__c =:objectType]);
            }
               return metadataList;
    }
}