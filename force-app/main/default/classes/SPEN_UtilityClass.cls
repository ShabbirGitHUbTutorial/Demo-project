@isTest
global class SPEN_UtilityClass implements HttpCalloutMock{
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    res.setBody('{"Id":"123"}');
    return res;
  }
}