public class SPEN_ImpactedPremiseTriggerHandler implements TriggerHandlerInterface{
    public void beforeInsert(SObject[] newItems){
        new SPEN_ImpactedPremises().onBeforeInsert((List<SPEN_ImpactedPremise__c>)newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        new SPEN_ImpactedPremises().onBeforeUpdate((List<SPEN_ImpactedPremise__c>)newItems.values(),(Map<Id, SPEN_ImpactedPremise__c>) oldItems);
	}

    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }

    public void afterInsert(Map<Id, SObject> newItems){
        new SPEN_ImpactedPremises().onAfterInsert((List<SPEN_ImpactedPremise__c>)newItems.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
    	new SPEN_ImpactedPremises().onAfterUpdate((List<SPEN_ImpactedPremise__c>)newItems.values(),(Map<Id, SPEN_ImpactedPremise__c>) oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems){
        
    }

    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }

}