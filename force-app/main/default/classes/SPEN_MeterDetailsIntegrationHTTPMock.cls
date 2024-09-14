@isTest
global class SPEN_MeterDetailsIntegrationHTTPMock implements HttpCalloutMock {
global HttpResponse respond(HTTPRequest req){
    String resbody = '{"Header":{"RequestDate":"20230203 08:06:26.AM","RequestId":17267658,"ResponseTime":"343.8054","VersionNumber":"1.0.0.0;Instance=UIT"},"Results":[{"Errors":[],"ParameterSet":{"Parameters":[{"Key":"MPAN","Value":"1800051691439"}]},"UtilityMatches":[{"UtilityDetails":[{"Key":"mpan_core","Value":"1800051691439"},{"Key":"dcc_service_flag","Value":"N"},{"Key":"supplier_mpid","Value":"BGAS"}],"UtilityKey":"1800051691439","UtilityType":"electricity","Meters":[{"MeterDetails":[{"Key":"mpancore","Value":"1800051691439"},{"Key":"meter_type","Value":"S"}]}]}]}]}';
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
     
    res.setBody(resbody);
    return res;
  }
}