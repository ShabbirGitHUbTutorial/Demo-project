/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  Unit test class for Log a Fault to Customer apex class SPEN_ContactPremisesSelector.
AUTHOR    :  Smita Raikar
LIBRARY    :  Salesforce Enterprise Library 
VERSION    :  1.0

HISTORY    :
Date      Author      Comment
NOV-03-2022    Smita Raikar     Initial version
-----------------------------------------------------------------------------------------*/
@isTest 
private class SPEN_ContactPremisesSelector_TEST {
@isTest static void getPremiseContactInfoTest() {
        
        List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,
                                                                            SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testAccount;
        Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
     	insert ct; 
    	List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
     	insert premiseList; 
    	SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,ct.Id,premiseList[0].Id);
     	conpremise.SPEN_Role__c='Customer';
    	insert conpremise;
    	List<Case> caseList = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
    	
        Test.startTest();
     	SPEN_ContactPremisesSelector.getPremiseContactInfo(caseList[0]);
		SPEN_ContactPremisesSelector.getContactPremises(new Set<id>{premiseList[0].id});
		//SPEN_ContactPremisesSelector.getCPRecordsAfterInsert(new Set<Id>{conpremise.id});
		SPEN_ContactPremisesSelector.getConPremiseRecordsFromPremiseIds(new Set<String>{premiseList[0].SPEN_PremiseId__c});
        
		Test.stopTest(); 
         
    }
   
	 
}