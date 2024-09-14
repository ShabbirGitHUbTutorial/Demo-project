@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_DamageFormTriggerInterface implements TriggerHandlerInterface{
	public void beforeInsert(SObject[] newItems){
        SPEN_DamageFormTriggerHandler.create3PDCase(newItems);
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        
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