/* File Name: SPEN_SAPVendorInvocableTest
 * Description: Test class for SPEN_SAPVendorInvocable class
 * Author: Ajay Chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-29-2024     Ajay Chandraferi    Initial version
 *
 */
@isTest
private class SPEN_SAPVendorInvocableTest {
    
    public static testMethod void sapVendorsTest(){               
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPEN_SAPVendorMockResponse());
        List<SPEN_SAPVendorInvocable.SPEN_SAPVendorRequest> vendorReq = new List<SPEN_SAPVendorInvocable.SPEN_SAPVendorRequest>();
        SPEN_SAPVendorInvocable.SPEN_SAPVendorRequest req = new SPEN_SAPVendorInvocable.SPEN_SAPVendorRequest();                                
        req.vendorName= 'Test Bank';
        req.vendorZipCode= 'ABC1 2XY';
        req.vendorStreet= 'Test Street';
        req.vendorStreet2= 'Test Street2';
        req.vendorStreet3= 'Test Street3';
        req.vendorCity= 'London';
        req.vendorState= 'London';
        req.vendorCountry= 'GB';
        req.vendorNumber= '1234567';
        req.vendorBP= '00000000';
        vendorReq.add(req);
        List<SPEN_SAPVendorInvocable.SPEN_SAPVendorResult> vResult = SPEN_SAPVendorInvocable.getSAPVendors(vendorReq);                      
        Test.stopTest();           
        system.assertNotEquals(null, vResult[0].vendorList);
        system.assertEquals(1, vResult[0].vendorList.size());                   
    }
    
}