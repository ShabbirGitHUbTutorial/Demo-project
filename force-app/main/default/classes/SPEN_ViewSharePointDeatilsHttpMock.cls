/*************************************************************************
@Author: Amrita Sarkar
@Date: 08/06/2023
@purpose: Using below method send Mock HTTP response for SPEN_ViewSharePointFilesTest
*************************************************************************************/
@isTest
global class SPEN_ViewSharePointDeatilsHttpMock implements HttpCalloutMock{
/*************************************************************************
@Author: Amrita Sarkar
@Date: 08/06/2023
@purpose: Using below method send Mock HTTP response for SPEN_ViewSharePointFilesTest
*************************************************************************************/
    global HttpResponse respond(HTTPRequest req){
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Object> response2 = new Map<String, Object>();
        Map<String, Object> listOfMap = new Map<String, Object>();
        listOfMap.put('LinkFilename', 'Category-Test');
        listOfMap.put('SHAREPOINTID', 'SHAREPOINTID-Test');
        listOfMap.put('EncodedAbsUrl', 'http://localhost:8080/test/data');
        
        List<Object> listOfObj = new List<Object>();
        listOfObj.add(listOfMap);
        response2.put('results', listOfObj);
        response.put('d', response2);
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        
        res.setBody(JSON.serialize(response));
        return res;
    }
    
}