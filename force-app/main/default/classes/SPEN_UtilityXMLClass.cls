@isTest
global class SPEN_UtilityXMLClass implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        /*HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('<Id>123</Id>');
        return res;*/
        //if (req.getEndpoint().contains('https://test-dev-ed.lightning.force.com/'))
         //{
            system.debug('req<test>');
            HTTPResponse res = new HTTPResponse();
            //res.setBody('<Id>123</Id>');
            res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"> <soap-env:Header/><soap-env:Body><n0:ZJws001SapcreateeditqasResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><Returncode>000</Returncode><Zcodqas>000612762162</Zcodqas><Zjews00message><item><Type>W</Type><Language>E</Language><Id>ZDSPW</Id><Number>011</Number><Message>QAS Customer Req. 0000285363 created and not transferred</Message><Type>E</Type><Language>E</Language><Id>ZDSPW</Id><Number>003</Number><Message>Errors in the Control record</Message><Type>E</Type><Language>E</Language><Id>ZDSPW</Id><Number>007</Number><Message>Errors in the "Plots Data" table</Message></item></Zjews00message><Zjews01enclet/><Zjews01letter/><Zjews01note/><Zjews01pendinf/><Zjews01plots/><Zjtegendet/><Zjtplogendt/><Zusuario/></n0:ZJws001SapcreateeditqasResponse></soap-env:Body></soap-env:Envelope>');
            res.setStatusCode(200);
            return res;
        /*} 
        else
        {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"Id":"123"}');
            return res;
        }*/
    }
}