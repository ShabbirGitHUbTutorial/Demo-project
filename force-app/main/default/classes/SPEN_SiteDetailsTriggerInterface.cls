@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_SiteDetailsTriggerInterface implements TriggerHandlerInterface{
	public void beforeInsert(SObject[] newItems){
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
    }
    public void afterInsert(Map<Id, SObject> newItems){
        SPEN_SiteDetailsTriggerHandler.createQueryCase((List<SPEN_SiteDetails__c>)newItems.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
      
    }
     public void afterDelete(Map<Id, SObject> oldItems){
        
    }
	 public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }


}