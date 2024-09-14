@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_KnowledgeTriggerInterface implements TriggerHandlerInterface{
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        SPEN_KnowledgeTriggerHandler.updateDataCategories(newItems);
    }
	public void beforeInsert(SObject[] newItems){
      
    }
    
    public void afterInsert(Map<Id, SObject> newItems){
        
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