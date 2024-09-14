/* File Name: SPEN_SAPVendorMockResponse
 * Description: Mock class for SAP Vendors GET callout
 * Author: Ajay Chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-29-2024     Ajay Chandraferi    Initial version
 *
 */
@isTest
global class SPEN_SAPVendorMockResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"d":{"results":[{"__metadata":{"id":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/provSalesforceSet(\'RESF\')","uri":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/provSalesforceSet(\'RESF\')","type":"ZQKRE_ESCOMS_SRV.prov_salesforce"},"state":"","country":"","city":"","zipcode":"","street":"","name":"BANK","bp":"","vendor":"","origin":"RESF","companycode":{"results":[{"__metadata":{"id":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/companycodeSet(\'1234567\')","uri":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/companycodeSet(\'1234567\')","type":"ZQKRE_ESCOMS_SRV.companycode"},"proveedor":"1234567","sociedad":"8301","bloqueo":""},{"__metadata":{"id":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/companycodeSet(\'1234567\')","uri":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/companycodeSet(\'1234567\')","type":"ZQKRE_ESCOMS_SRV.companycode"},"proveedor":"1234567","sociedad":"8302","bloqueo":""}]},"results":{"results":[{"__metadata":{"id":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/errorcodeSet(\'ZMM%3A628\')","uri":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/errorcodeSet(\'ZMM%3A628\')","type":"ZQKRE_ESCOMS_SRV.errorcode"},"codError":"ZMM:628","errorTxt":"Lack of authorization"}]},"vendors":{"results":[{"__metadata":{"id":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/outputSet(\'0001234567\')","uri":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/outputSet(\'0001234567\')","type":"ZQKRE_ESCOMS_SRV.output"},"proveedor":"0001234567","bussinessPartner":"","nombre":"TEST BANK","calle":"TEST CALLE","codigoPostal":"BX6 1YU","ciudad":"BOLTON","pais":"GB","region":"","telefCom":"","mailCom":"","telefPers":"","mailPers":"","bloqueo":""}]}}]}}');
        res.setStatusCode(200);
        return res;
    }
}