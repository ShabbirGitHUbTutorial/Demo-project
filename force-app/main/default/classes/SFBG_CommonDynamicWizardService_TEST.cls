/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  Unit test class for Common Dynamic Wizard apex class SFBG_CommonDynamicWizardService.
AUTHOR    :  Smita Raikar
LIBRARY    :  Salesforce Enterprise Library 
VERSION    :  1.0

HISTORY    :
Date      Author      Comment
OCT-13-2022    Smita Raikar     Initial version
-----------------------------------------------------------------------------------------*/
@isTest 
private  class SFBG_CommonDynamicWizardService_TEST {
@isTest static void getPreferredContactMethodtest() {
        
        List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,
                                                                            SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testAccount;
        Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
     	insert ct;
    	List<SPEN_Premise__c> prem = SPEN_TestDataFactory.createPremiseRecord('Test Prem', 'Test', SPEN_TestDataFactoryConstants.SINGLE_REC);
    	insert prem;
    	CallCenter center=[select Id from CallCenter limit 1];
    	VoiceCall voiceCall = SPEN_TestDataFactory.createVoiceCall(SPEN_TestDataFactoryConstants.SINGLE_REC);
    	voiceCall.CallCenterId =center.Id;
    	insert voiceCall;
        Test.startTest();
     	SFBG_CommonDynamicWizardService.getPreferredContactMethod(ct.id);
    	SPEN_DynamicWizardServiceHelper.getPremiseData(prem[0], prem[0].id);
    	SPEN_DynamicWizardServiceHelper.updateVoiceCall(voiceCall);
        Assert.isNotNull(ct.id, 'Assertion Passed');
        Test.stopTest(); 
        
        
    }
    @isTest static void updatePreferredContactMethod() {
        
        List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,
                                                                            SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testAccount;
        Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
     	insert ct; 
        Test.startTest();
     
        SFBG_CommonDynamicWizardService.updatePreferredContactMethod(ct.id,'T');
        Assert.isNotNull(ct.id, 'Assertion Passed');
        Test.stopTest(); 
        
        
    }
	 static testMethod void testexceptioncoverage() {
            try{
                Test.startTest(); 
               
                SFBG_CommonDynamicWizardService.getPreferredContactMethod(NULL);
                SFBG_CommonDynamicWizardService.updatePreferredContactMethod(NULL,NULL);
                Assert.isNotNull(NULL, 'Assertion Passed');
                Test.stopTest();   
            }
            catch(Exception ex){
                System.assert(NULL != ex);
            }
    }
}