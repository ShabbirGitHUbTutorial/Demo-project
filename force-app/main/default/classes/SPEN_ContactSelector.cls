/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector Class for the PSR Custom UI
LIBRARY		:	Salesforce Enterprise Library - 
VERSION		:	1.0
HISTORY		:
Date			Author		    Comment
OCT-27-2022		Ayush Mittal     Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_ContactSelector 
{    
    public static Contact getContact(Id contactId)
    {
        Contact con;
        if(contactId != null)
        	con =[SELECT id, SPEN_Premise__c,SPEN_CustomerID__c,SPEN_PSR__c from Contact where id=:contactId and RecordType.Name = 'Customer' WITH SECURITY_ENFORCED];
        return con;
    }
    
    public static Map<id,Contact> contactRecord(Set<Id> conIds)
    {
        Map<Id,Contact> con;
        if(conIds != null && !conIds.isEmpty())
        	 con= new Map<Id,Contact>([SELECT id, SPEN_Premise__c,Salutation,MobilePhone,Name,Phone,Suffix,MiddleName from Contact WHERE Id IN :conIds WITH SECURITY_ENFORCED]);
        return con;
    }
    
    public static Map<id,Contact> getContactnonPsrlist(set<Id> contactIdlist)
    {
        Map<Id,Contact> con;
        if(contactIdlist != null && !contactIdlist.isEmpty())
        	con = new Map<Id,Contact>([SELECT id, SPEN_Premise__c,SPEN_IsPrimaryContact__c, SPEN_PSR__c from contact where SPEN_PSR__c = false and SPEN_IsPrimaryContact__c = true and SPEN_PreferredMethodofContact__c = 'H' and id IN:contactIdlist WITH SECURITY_ENFORCED]);
        return con;
    }
     public static Map<id,Contact> getContactPsrlist(set<Id> contactIdlist)
    {
        Map<Id,Contact> con;
        if(contactIdlist != null && !contactIdlist.isEmpty())
        	con = new Map<Id,Contact>([SELECT id, SPEN_Premise__c,SPEN_IsPrimaryContact__c, SPEN_PSR__c,Phone from contact where SPEN_PSR__c = true and SPEN_IsPrimaryContact__c = true and id IN:contactIdlist WITH SECURITY_ENFORCED]);
        return con;
    }
    public static List<Contact> setVulCon(Set<Id> conIds)
    {
        List<Contact> con;
        if(conIds != null && !conIds.isEmpty())
        	con=[Select Id,SPEN_SpecificVulnerability__c,
                              (Select Id from PSRs__r
                              Where SPEN_SpecificVulnerability__c = TRUE) 
                              from Contact
                              where Id IN: conIds WITH SECURITY_ENFORCED];
        return con;
    }
    public static String phoneNo(Id vAId)
    {
        String phn;
        if(vAId != null)
        	phn=[SELECT MobilePhone,Contact.Phone FROM CONTACT WHERE Id in(select SPEN_ContactId__c from SPEN_VoiceAlert__c 
                                                                where id =:vAId) WITH SECURITY_ENFORCED].Phone; //Riccha Mohanty-18-01-2023
        return phn;
    }
    
    public static List<Contact> getContactsByCustomerId(Set<String> conExternalIdSet)
    {
        return [Select Id,SPEN_CustomerID__c,SPENAdqmLastSyncDateTime__c,
                Email,MobilePhone,OtherPhone,Phone,FirstName,LastName,Salutation,
                SPEN_Initials__c
                From Contact
                WHERE SPEN_CustomerID__c IN: conExternalIdSet
                WITH SECURITY_ENFORCED];
    }
    public static List<Contact> getIdForSyncContactsBatchService(Set<String> conUniqueIds){
        List<Contact> contactIdlist = new List<Contact>();
        if(!conUniqueIds.isEmpty())
            contactIdlist = [Select Id,SPEN_CustomerID__c
                        FROM Contact
                        Where SPEN_CustomerID__c IN: conUniqueIds
                        WITH SECURITY_ENFORCED];
        return contactIdlist;
    }
    public static List<Contact> getIdForSyncContactsUpdateCase(Set<String> conUniqueIds){
        List<Contact> contactIdlist = new List<Contact>();
        if(!conUniqueIds.isEmpty())
            contactIdlist = [Select Id,SPEN_CustomerID__c,SPENAdqmLastSyncDateTime__c
                        FROM Contact
                        Where SPEN_CustomerID__c IN: conUniqueIds
                        WITH SECURITY_ENFORCED];
        return contactIdlist;
    }
    public static List<Contact> getContactForSyncContactsBatchService(Set<String> premiseExtIdSet){
        List<Contact> contactDetailslist = new List<Contact>();
        if(!premiseExtIdSet.isEmpty())
            contactDetailslist = [Select Id,AccountId,SPEN_CustomerID__c 
                                 FROM Contact
                                 Where SPEN_CustomerID__c IN : premiseExtIdSet
                                 AND AccountId != NULL
                             	 WITH SECURITY_ENFORCED];
        return contactDetailslist;
    }

    public static List<Contact> getCntctFrADQM(Set<Id> contactId){
        List<Contact> cntctADQM;
        if(!contactId.isEmpty())
            cntctADQM = [select id,FirstName, SPEN_Company__c, SPEN_VersionNumber__c, SPEN_AgentID__c, Phone, Email, SPEN_PSRLetterDates__c, Name,SPEN_CustomerPasswordDoorstep__c,SPEN_Initials__c,SPEN_Position__c,
            SPEN_Premise__c,SPEN_Premise__r.SPEN_PremiseID__c,SPEN_Premise__r.SPEN_BuildingNameNumber__c,
            SPEN_Premise__r.SPEN_District__c,SPEN_Premise__r.SPEN_LicenseArea__c,SPEN_Premise__r.SPEN_Area__c,
            SPEN_Premise__r.SPEN_Street__c,SPEN_Premise__r.SPEN_PremiseNumber__c,SPEN_Premise__r.SPEN_PostCode__c,
            SPEN_Premise__r.SPEN_Town__c
            from Contact where Id IN : contactId];
        return cntctADQM;
    }
    public List<Contact> getContactForSyncPSRFlag(Set<String> customerIdSet)
    {
        List<Contact> lstContact = new List<Contact>();
        if(!customerIdSet.isEmpty())
        {
            lstContact = [
                        SELECT	Id, (SELECT Id from PSRs__r), SPEN_PSR__c
                        FROM	Contact
                        WHERE	SPEN_CustomerID__c IN: customerIdSet
                        ];
        }
        return lstContact;
    }
    public List<Contact> getSuccessContactsForbatch(Set<String> setSuccessContId)
    {
        List<Contact> lstContact = new List<Contact>();
        if(!setSuccessContId.isEmpty())
        {
            lstContact = [
                        SELECT id,SPEN_CustomerID__c,SPEN_IsPrimaryContact__c
                        FROM Contact
                        WHERE id IN: setSuccessContId
                        ];
        }
        return lstContact;
    }
    public static Contact getSyncFromADQMVal(Id contactId)
    {
        Contact con;
        if(contactId != null)
        	con =[SELECT id, SPEN_RequireSynctoADQM__c,SPENAdqmLastSyncDateTime__c,SPEN_PSRSynctoADQM__c from Contact where id=:contactId  WITH SECURITY_ENFORCED];
        return con;
    }
}