/*-----------------------------------------------------------------------------
DESCRIPTION :   Trigger handler for SPEN_ContactPremise__c custom object.
AUTHOR      :   Shubhi Vijayvergia
TEST        :   SPEN_ContactPremise_TriggerHandlerTest
LIbRARY     :   SPEN

HISTORY     :
Date            Author                  Comment
Aug-8-2023     Shubhi Vijayvergia    Refactored trigger 
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_ContactPremise_TriggerHandler implements TriggerHandlerInterface{
    // RULE
    // bypass the business logic if the running user
    // is the Data Migration user.
    
    public void beforeInsert(SObject[] newItems){
        new SPEN_ContactPremiseTriggerHandler().validatebeforeInsert(newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        new SPEN_ContactPremiseTriggerHandler().validatebeforeUpdate((Map<Id,SPEN_ContactPremise__c>)oldItems,(List<SPEN_ContactPremise__c>)newItems.values());                                                               
    }

    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }

    public void afterInsert(Map<Id, SObject> newItems){
        new SPEN_ContactPremiseTriggerHandler().updateContactafterInsert((Map<Id,SPEN_ContactPremise__c>)newItems);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
       new SPEN_ContactPremiseTriggerHandler().updateContactafterUpdate((Map<Id,SPEN_ContactPremise__c>)newItems, (Map<Id,SPEN_ContactPremise__c>)oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems){
        
    }

    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }

}