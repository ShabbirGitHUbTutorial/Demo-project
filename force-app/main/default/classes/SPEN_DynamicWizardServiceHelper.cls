/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex  Class to hold without sharing methods. 
LIBRARY		:	Salesforce Enterprise Library - Common Dynamic Wizard Script
VERSION		:	1.0

HISTORY		:
Date			Author		    Comment
OCT-15-2022		Nitish Dharm     Initial version

-----------------------------------------------------------------------------*/

 
public without sharing class SPEN_DynamicWizardServiceHelper {
    public static Contact getContactData(Contact c,String recordId){
        if(recordId != null)
        	c = [SELECT Id, Title, Name, MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet, SPEN_PreferredMethodofContact__c  from Contact where Id = :recordId];
        return c;
    }
    public static Contact updateContact(Contact contactRec){
        update contactRec;
        return contactRec;
    }
    public static SPEN_Premise__c getPremiseData(SPEN_Premise__c premise,String  premiseId){
        if(premiseId != null)
        	premise = [SELECT Id, Name, SPEN_FullAddress__c FROM SPEN_Premise__c where Id = :premiseId];
        return premise;
    }
    
    public static void updateVoiceCall(VoiceCall voiceRec){
        update voiceRec;
    }

}