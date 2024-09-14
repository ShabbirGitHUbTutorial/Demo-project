trigger SPEN_Impactedpremise on SPEN_ImpactedPremise__c (before insert, after insert , After Update, before update) {
    SPEN_ImpactedPremiseTriggerHandler impt=new SPEN_ImpactedPremiseTriggerHandler();
    TriggerDispatcher.run(impt);
    /*if(trigger.isinsert && trigger.isafter){s
    new SPEN_ImpactedPremises().onAfterInsert(Trigger.new);
    }
    if(trigger.isinsert && trigger.isBefore){
    new SPEN_ImpactedPremises().onBeforeInsert(Trigger.new);
    }
    if(trigger.isupdate && trigger.isafter){
    new SPEN_ImpactedPremises().onAfterUpdate(Trigger.new, Trigger.oldmap);
    //new SPEN_ImpactedPremises().onAfterUpdateCreateSMSMC(Trigger.oldmap , Trigger.new);
    }
    if(trigger.isupdate && trigger.isBefore){
    new SPEN_ImpactedPremises().onBeforeUpdate(Trigger.new, Trigger.oldmap);
    }*/
}