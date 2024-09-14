/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex class of the Common Dynamic Wizard. 
LIBRARY		:	Salesforce Enterprise Library - Common Dynamic Wizard Script
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
OCT-7-2022		Smita Raikar     Initial version

-----------------------------------------------------------------------------*/
public with sharing class SFBG_CommonDynamicWizardService {
    @AuraEnabled(cacheable=true)
    public static Contact getPreferredContactMethod(String recordId) {
        
        //system.debug('recID >> ' + recordId);
        try {
                Contact c = new Contact();
                c = SPEN_DynamicWizardServiceHelper.getContactData(c,recordId); 
                return c;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
	@AuraEnabled
    public static Contact updatePreferredContactMethod(String recordId,String selectedMethod) {
        //system.debug('recID >> ' + recordId);
        try {
            Id insertedRecord;
            Contact caseContact = [SELECT Id,Name,MailingAddress,SPEN_PreferredMethodofContact__c  FROM Contact WHERE Id = :recordId];
             //INC3215577- to update the PreferedMethod when previous and current value is different
            if(caseContact.SPEN_PreferredMethodofContact__c != selectedMethod){
                caseContact.SPEN_PreferredMethodofContact__c = selectedMethod;
            // Database.SaveResult dataSaveRes = Database.update(caseContact);
            // if(dataSaveRes.isSuccess()){
            //     insertedRecord = dataSaveRes.getId();
            // }
            //update(caseContact);
            caseContact = SPEN_DynamicWizardServiceHelper.updateContact(caseContact); 
            }
            return caseContact;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
       
    }
}