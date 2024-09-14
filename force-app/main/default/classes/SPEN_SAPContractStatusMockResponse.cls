/* File Name: SPEN_SAPContractStatusMockResponse
 * Description: Mock class for SAP contracr Status GET callout
 * Author: Ajay Chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-29-2024     Ajay Chandraferi    Initial version
 *
 */
@isTest
global class SPEN_SAPContractStatusMockResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"d":{"results":[{"__metadata":{"id":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/GetStatusSet(ContractNumber=\'a21Pu001200rySfIAI\',Licensearea=\'8302\')","uri":"http://saperpd.iberdrola.com/ukcrmsd1/zqkre_escoms_srv/GetStatusSet(ContractNumber=\'a21Pu001200rySfIAI\',Licensearea=\'8302\')","type":"ZQKRE_ESCOMS_SRV.GetStatus"},"ContractNumber":"a21Pu001200rySfIAI","Licensearea":"8302","Sapnumber":"8302/0000160887","Status":"Requested","Cpudt":"","Msgid":"","Msgno":"","Msgtxt":""}]}}');
        res.setStatusCode(200);
        return res;
    }
}