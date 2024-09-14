@isTest
global class SPEN_FileUploaderClassLnPHttpMock implements HttpCalloutMock {
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
    res.setStatusCode(400);
     
    res.setBody(JSON.serialize(response));
    return res;
 }

}