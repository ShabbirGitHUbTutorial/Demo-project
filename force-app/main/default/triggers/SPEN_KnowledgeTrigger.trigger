trigger SPEN_KnowledgeTrigger on Knowledge__kav (before update) {
    SPEN_KnowledgeTriggerInterface ct=new SPEN_KnowledgeTriggerInterface();
    TriggerDispatcher.run(ct);
}