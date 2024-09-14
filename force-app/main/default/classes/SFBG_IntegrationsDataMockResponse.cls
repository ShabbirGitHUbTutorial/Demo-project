@isTest
global class SFBG_IntegrationsDataMockResponse implements HttpCalloutMock {
     
    global static HTTPResponse respond(HTTPRequest req) {
         
        System.assertEquals('https://test.salesforce.com/services/Soap/c/55.0/0DF3G0000008V53', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
         
        HttpResponse res = new HttpResponse();
       
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<soapenv:Envelope><soapenv:Header/><soapenv:Body><Industry>Electronics</Industry><Name>TestMockAccount1</Name><Phone>+44 7711 089069</Phone><Website>https://trailhead.salesforce.com</Website></soapenv:Body></soapenv:Envelope>');
        
        return res;
    }
}