/* File Name: SPEN_RefreshSAPVendorInvocableTest
 * Description: Test class for SPEN_RefreshSAPVendorInvocable class
 * Author: Anwesha Dey
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * May-20-2024     Anwesha Dey    Initial version
 *
 */
@isTest
public class SPEN_RefreshSAPVendorInvocableTest {
    
   
    public static testMethod void vendorSyncTest(){
        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
        System.runAs(u){
            SPEN_Land__c land = SPEN_TestDataUtility.createLandRec();
            Account vendorAccount=SPEN_TestDataUtility.createVendorAccount();
            SPEN_LandAssociation__c vendorLandContact=SPEN_TestDataUtility.createVendorLandContact(vendorAccount,land);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SPEN_SAPVendorMockResponse());
            List<Account> vendorAccountToBeSync=SPEN_RefreshSAPVendorInvocable.getVendorAccount(land.Id);
            SPEN_RefreshSAPVendorInvocable.syncVendorRequest(vendorAccountToBeSync);
            Account updatedVendorAccount=[Select id,SPEN_AccountLastSynchronised__c from Account where Id=:vendorAccount.Id];
            Test.stopTest();                
            system.assertEquals(System.now().date(), updatedVendorAccount.SPEN_AccountLastSynchronised__c.date());           
        }
        
    }

}