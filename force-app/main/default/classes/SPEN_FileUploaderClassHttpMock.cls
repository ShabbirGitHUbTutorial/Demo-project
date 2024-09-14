/*************************************************************************
@Author: Amrita Sarkar
@Date: 07/06/2023
@purpose: Mock HTTP class for SPEN_FileUploaderClassTest
*************************************************************************************/
@isTest
global class SPEN_FileUploaderClassHttpMock implements HttpCalloutMock{
/*************************************************************************
@Author: Amrita Sarkar
@Date: 07/06/2023
@purpose: Using below method send Mock HTTP response for SPEN_FileUploaderClassTest
*************************************************************************************/
 global HttpResponse respond(HTTPRequest req){
    Map<String, Object> response = new Map<String, Object>();
    Map<String, Object> response2 = new Map<String, Object>();
    Map<String, Object> listOfMap = new Map<String, Object>();
    Map<String, Object> listOfMap2 = new Map<String, Object>();

    listOfMap2.put('uri', 'Test2SiteName');
    listOfMap.put('__deferred', listOfMap2);
    response2.put('ListItemAllFields', listOfMap);
    response2.put('ServerRelativeUrl', 'http://localhost:8080/test/data');
    response.put('d', response2);
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
     
    res.setBody(JSON.serialize(response));
    return res;
 }
}