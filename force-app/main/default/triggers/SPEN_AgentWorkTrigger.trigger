trigger SPEN_AgentWorkTrigger on AgentWork (before insert, after update) {
    
    SPEN_AgentWorkTriggerInterface ct=new SPEN_AgentWorkTriggerInterface();
    TriggerDispatcher.run(ct);    
}