trigger SPEN_CaseInformationTrigger on SPEN_CaseInformation__c(before insert, before update, after insert, after update) {

     SPEN_CaseInformationInterface ct=new SPEN_CaseInformationInterface();
    TriggerDispatcher.run(ct);
}