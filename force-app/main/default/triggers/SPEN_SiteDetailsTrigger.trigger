trigger SPEN_SiteDetailsTrigger on SPEN_SiteDetails__c (before insert, before update, after insert, after update) {
	SPEN_SiteDetailsTriggerInterface ct=new SPEN_SiteDetailsTriggerInterface();
    TriggerDispatcher.run(ct);
}