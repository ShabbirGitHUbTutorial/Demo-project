trigger SPEN_DamageFormStagingTrigger on SPEN_DamageFormStaging__c (before insert, before update, after insert, after update) {

    SPEN_DamageFormTriggerInterface ct=new SPEN_DamageFormTriggerInterface();
   TriggerDispatcher.run(ct);
}