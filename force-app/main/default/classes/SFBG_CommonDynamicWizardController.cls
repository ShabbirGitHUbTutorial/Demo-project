/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex class of the Common Dynamic Wizard. 
LIBRARY		:	Salesforce Enterprise Library - Common Dynamic Wizard Script
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
OCT-7-2022		Smita Raikar     Initial version

-----------------------------------------------------------------------------*/
public with sharing class SFBG_CommonDynamicWizardController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getPreferredContactMethod(String recordId) {
      //system.debug('recID >> ' + recordId);
      try {
        List<Contact> conList = new List<Contact>();
        conList = [
          SELECT Id, SPEN_PreferredMethodofContact__c
          FROM Contact
          WHERE Id = :recordId
        ];
        return conList;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
    @AuraEnabled(cacheable=true)
    public static Id updatePreferredContactMethod(
      String recordId,
      String selectedMethod
    ) {
      //system.debug('recID >> ' + recordId);
      try {
        Id insertedRecord;
        Contact caseContact = [
          SELECT Id, SPEN_PreferredMethodofContact__c
          FROM Contact
          WHERE Id = :recordId
        ];
        caseContact.SPEN_PreferredMethodofContact__c = selectedMethod;
  
        Database.UpsertResult dataSaveRes = Database.upsert(caseContact);
        if (dataSaveRes.isSuccess()) {
          insertedRecord = dataSaveRes.getId();
        }
        return insertedRecord;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }