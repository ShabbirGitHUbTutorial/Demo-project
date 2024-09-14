@isTest
public class SPEN_EndDeviceStatusCallback_Test {
@isTest
    static void getmpanRecords(){
        SPEN_MPAN__c mpanUpdate = new SPEN_MPAN__c();
        String lastGaspDateTime = '2021-11-02T02:32:23.0000000+01:00';
        mpanUpdate.SPEN_AccountNumberMPAN__c = '123';
        insert mpanUpdate;
        mpanUpdate.SPEN_LastGasp__c=Datetime.valueOfGmt(lastGaspDateTime.replace('T', ' '));
        update mpanUpdate;
        Test.startTest();
        //String reqStr='<soapenv:Body><ReceiveEndDevicePingStatus xmlns="ENMAC/TCS"><StatusReading>	<status>Processing</status><EndDeviceAsset><mRID>123</mRID></EndDeviceAsset></StatusReading><EndDeviceStatusCallbackContext><correlationID>123</correlationID></EndDeviceStatusCallbackContext></ReceiveEndDevicePingStatus></soapenv:Body>';
        String reqStr='<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:end="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><SDIFReceiveEndDevicePingStatus xmlns="SDIF"><StatusReading xmlns="SDIF"><status>Processing</status><EndDeviceAsset xmlns="SDIF"><mRID>123</mRID></EndDeviceAsset></StatusReading><EndDeviceStatusCallbackContext xmlns="SDIF"><correlationID>123</correlationID></EndDeviceStatusCallbackContext></SDIFReceiveEndDevicePingStatus></soap:Body></soap:Envelope>';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/EndDeviceOperation/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueOf(reqStr);
        RestContext.request = req;
        RestContext.response= res;

        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass ());
        SPEN_EndDeviceStatusCallbackService.dopost();
        Test.stopTest();
       
      }
}