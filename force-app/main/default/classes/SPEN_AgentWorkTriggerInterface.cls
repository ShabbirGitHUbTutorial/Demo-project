@SuppressWarnings('PMD.EmptyStatementBlock')
public class SPEN_AgentWorkTriggerInterface implements TriggerHandlerInterface{
    public void beforeInsert(SObject[] newItems){
        SPEN_AgentWorkTriggerHandler.beforeInsertDummy();
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
    }
    public void afterInsert(Map<Id, SObject> newItems){
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<AgentWork> newAgentWorkList = (List<AgentWork>)newItems.values();
        SPEN_AgentWorkTriggerHandler.createCaseTracker(newAgentWorkList);
    }
    public void afterDelete(Map<Id, SObject> oldItems){
    }
    public void beforeDelete(Map<Id, SObject> oldItems){
    }
    public void afterUndelete(Map<Id, SObject> oldItems){
    }
}