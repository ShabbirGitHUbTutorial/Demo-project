/*-----------------------------------------------------------------------------
DESCRIPTION :   Trigger handler for SPEN_ContactPremise__c custom object.
AUTHOR      :   Sheker Kulkacherla
TEST        :   SPEN_PSRTriggerHandler_Test
LIBRARY     :   SPEN

HISTORY     :
Date            Author                  Comment
Aug-8-2023     Sheker Kulkacherla    Refactored trigger 
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_PSRTriggerHandler implements TriggerHandlerInterface{
    // RULE
    // Bypass the business logic if the running user
    // is the Data Migration user.
    public void beforeInsert(SObject[] newItems){
        PSRs.beforePSRInsert(newItems);
    }
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    
    public void afterInsert(Map<Id, SObject> newItems){
        PSRs.afterPSRInsert((List<SPEN_PSR__c>)newItems.values());
        PSRs.PSRUpdateSyncADQMValue((List<SPEN_PSR__c>)newItems.values());
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        PSRs.afterPSRUpdate((Map<Id, SPEN_PSR__c>)newItems, (Map<Id, SPEN_PSR__c>)oldItems);
        PSRs.PSRUpdateSyncADQMValue((List<SPEN_PSR__c>)newItems.values());
    }
    
    public void afterDelete(Map<Id, SObject> oldItems){
        PSRs.PSRUpdateSyncADQMValue((List<SPEN_PSR__c>)oldItems.values());
    }
    
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
}