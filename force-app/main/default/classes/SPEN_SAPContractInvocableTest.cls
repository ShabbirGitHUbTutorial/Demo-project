/* File Name: SPEN_SAPContractInvocableTest
 * Description: Test class for SPEN_SAPContractInvocable class
 * Author: Rajat mishra
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-14-2024     Rajat Mishra    Initial version
 *
 */
@isTest
private class SPEN_SAPContractInvocableTest {
    
    public static testMethod void sapContractCreationTest(){
        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
        System.runAs(u){
            SPEN_WorkCategory__c wc = SPEN_TestDataUtility.createWorkCategoryRecord('Test WC','SPD');
            
            List<SPEN_Job__c> job = SPEN_TestDataUtility.createJobRecord('Draft','Yes',wc.Id,'create job through Email',1);
            job[0].SPEN_LicenseArea__c = 'SPD';
            job[0].SPEN_Work_Category__c='CCT Customer Contact Enquiry';
            job[0].SPEN_District__c='Lanarkshire';
            job[0].SPEN_BusinessArea__c='Finance';
            Database.insert(job);
            
            SPEN_Land__c land = SPEN_TestDataUtility.createLandRec();
            
            SPEN_Land_Interest__c lndRight = SPEN_TestDataUtility.createLandIntRec(land.id,job[0].id);
            
            SPEN_Condition__c condRec = new SPEN_Condition__c();
            condRec.SPEN_LandInterest__c = lndRight.id;
            condRec.SPEN_Type__c = 'VEL0';
            condRec.SPEN_Unit__c = '2';
            insert condRec;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_SAPContractMockResponse());
            List<SPEN_SAPContractInvocable.SPEN_CreateContractRequest> contractReq = new List<SPEN_SAPContractInvocable.SPEN_CreateContractRequest>();
            SPEN_SAPContractInvocable.SPEN_CreateContractRequest req = new SPEN_SAPContractInvocable.SPEN_CreateContractRequest();                    
            SPEN_Land_Interest__c lrObj = [SELECT Id, SPEN_Licence_Area_Code__c,SPEN_Contract_Type__c, SPEN_Contract_Start_Date__c, SPEN_Contract_First_End_Date__c, SPEN_Contract_Valid_From__c, SPEN_ConsentType__c, SPEN_Annual_Wayleave_Payment_Payable__c, SPEN_SAPContract__c
                                           from SPEN_Land_Interest__c where id =: lndRight.id];
            req.landRightObj= lrObj;
            contractReq.add(req);
            List<SPEN_SAPContractInvocable.SPEN_CreateContractResult> contractResult = SPEN_SAPContractInvocable.createSAPContract(contractReq);                      
            Test.stopTest();                
            //Assert
            system.assertEquals(false, contractResult[0].hasContractInitiated);            
        }
        
    }
}