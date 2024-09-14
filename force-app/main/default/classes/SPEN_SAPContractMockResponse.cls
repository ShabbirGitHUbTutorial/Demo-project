/* File Name: SPEN_SAPContractMockResponse
 * Description: Mock class for SAP callout
 * Author: Rajat mishra
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-14-2024     Rajat Mishra    Initial version
 *
 */
@isTest
global class SPEN_SAPContractMockResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<?xml version="1.0" encoding="utf-8"?><error xmlns="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata"><code>CX_SXML_PARSE_ERROR/001560AA0E081DEB8CA398CC1690D406</code><message xml:lang="en">Failed to read property TaxtypePy at offset 373 ,Failed to read property PymtmethPy at offset 700, Failed to read property FrequencyRh at offset 701, Failed to read property PaymentformrhRh at offset 800,Failed to read property MonthfromRh at offset 805</message><innererror><application><component_id/><service_namespace>/SAP/</service_namespace><service_id>zqkre_escoms_srv</service_id><service_version>0001</service_version></application><transactionid>AC1E4D4D110224031215593507296700</transactionid><timestamp>20240312145935.1113430</timestamp><Error_Resolution><SAP_Transaction>For backend administrators: run transaction /IWFND/ERROR_LOG on SAP Gateway hub system and search for entries with the timestamp above for more details</SAP_Transaction><SAP_Note>See SAP Note 1797736 for error analysis (https://service.sap.com/sap/support/notes/1797736)</SAP_Note></Error_Resolution><errordetails/></innererror></error>');
        res.setStatusCode(200);
        return res;
    }
}