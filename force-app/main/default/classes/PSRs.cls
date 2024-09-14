public with sharing class PSRs 
{
    public static Set<Id> contactIds = new Set<Id>();
	public static void afterPSRInsert(List<SPEN_PSR__c> newPSRList)
    {
        for(SPEN_PSR__c psrRec : newPSRList){
            //system.debug('---InsideInsertLoop---');
            contactIds.add(psrRec.SPEN_Contact__c);
        }
        if(!contactIds.isEmpty() && !System.isBatch()){
            setSpecificVulOnContact(contactIds);
        }
    }
    public static void afterPSRUpdate(Map<Id, sObject> psrNewMap, Map<Id, sObject> psrOldMap)
    {
        List<SPEN_PSR__c> pasrnewList = (List<SPEN_PSR__c>)psrNewMap.values();
        Map<Id,SPEN_PSR__c> psrMapOldVal = (Map<Id,SPEN_PSR__c>)psrOldMap;
        for(SPEN_PSR__c psrRec: pasrnewList){
            if(psrRec.SPEN_PSRVulnerabilityType__c != psrMapOldVal.get(psrRec.Id).SPEN_PSRVulnerabilityType__c)
            {
                contactIds.add(psrRec.SPEN_Contact__c);
            }
        }
        
        if(!contactIds.isEmpty() && !System.isBatch()){
            setSpecificVulOnContact(contactIds);
        }
    }    
    
    public static void PSRUpdateSyncADQMValue(List<SPEN_PSR__c> newPSRList){
        List<Contact> conUpd=new List<Contact>();
        Set<Id> contactIds = new Set<Id> ();
        for(SPEN_PSR__c psrRec : newPSRList){
            contactIds.add(psrRec.SPEN_Contact__c);
        }
        
        if(!contactIds.isEmpty() && !contactIds.contains(null))
        {
            for(Id conId : contactIds)
            {
                Contact psrContact = new Contact(Id = conId);
                psrContact.SPEN_RequireSynctoADQM__c = true;
                psrContact.SPEN_PSRSynctoADQM__c = true;
                conUpd.add(psrContact);
            }
            update conUpd;
        }
    }
	public static void beforePSRInsert(List<SPEN_PSR__c> newPSRList){
        Set<String> setVulnerabilityId = new Set<String>();
        Set<String> setPremiseId = new Set<String>();
        Map<Id, SPEN_Premise__c> mapId2Premise = new Map<Id,SPEN_Premise__c>();
        Map<Id, SPEN_PSRVulnerabilityType__c> mapId2Vulnerability = new Map<Id,SPEN_PSRVulnerabilityType__c>();
        for(SPEN_PSR__c psrRec : newPSRList)
        {
            setPremiseId.add(psrRec.SPEN_Premise__c);
            setVulnerabilityId.add(psrRec.SPEN_PSRVulnerabilityType__c);
        }
        for(SPEN_Premise__c prem: new SPEN_PremisesSelector().getPremiseForBeforeTrigger(setPremiseId))
        {
            mapId2Premise.put(prem.id,prem);
        }
        for(SPEN_PSRVulnerabilityType__c vul: new SPEN_PSRVulnerabilitySelector().getCodeForBeforeTrigger(setVulnerabilityId))
        {
            mapId2Vulnerability.put(vul.id,vul);
        }
        if(!mapId2Premise.isEmpty() && !mapId2Vulnerability.isEmpty())
        {
            for(SPEN_PSR__c psrRec : newPSRList)
            {
                if(mapId2Premise.containsKey(psrRec.SPEN_Premise__c) && mapId2Vulnerability.containsKey(psrRec.SPEN_PSRVulnerabilityType__c))
                {
                    String extId = mapId2Premise.get(psrRec.SPEN_Premise__c).SPEN_PremiseId__c + '-' + 
                                mapId2Vulnerability.get(psrRec.SPEN_PSRVulnerabilityType__c).SPEN_Code__c;
                    psrRec.SPEN_PSRId__c = extId;
                }
            }
        }
    }
    
    @future
    public static void setSpecificVulOnContact(Set<Id> conIds){
        List<Contact> contactsToBeUpdated = new List<Contact>();
        List<Contact> contactSet = SPEN_ContactSelector.setVulCon(conIds);
        for(Contact conRec : contactSet)
        {
            if(conRec.PSRs__r.size() > 0){
                conRec.SPEN_SpecificVulnerability__c = true;
                
            }
            else{
                conRec.SPEN_SpecificVulnerability__c = false;
            }
            contactsToBeUpdated.add(conRec);
        }
        
        if(!contactsToBeUpdated.isEmpty()){
            update contactsToBeUpdated;
        }
    }
}