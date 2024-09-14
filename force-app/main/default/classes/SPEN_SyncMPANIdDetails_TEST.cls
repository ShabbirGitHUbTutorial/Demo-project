/*-----------------------------------------------------------------------------
DESCRIPTION	:	Apex class for the SPEN_SyncMPANIdDetails
LIBRARY		:	Salesforce Enterprise Library - Integration Framework
VERSION		:	1.0

HISTORY		:
Date			Author		    		Comment
NOV-07-2022		Sheker Kulkavherla      Initial version
------------------------------------------------------------------------------*/
@isTest
global class SPEN_SyncMPANIdDetails_TEST {
	@isTest
    static List<SPEN_MPAN__c> getmpanRecords(){
        List<SPEN_MPAN__c> mpan = new List<SPEN_MPAN__c>();
        //List<SPEN_MPAN__c> mpan = SPEN_SyncMPANIdDetailsConstant.getMpanIdData()[0];
        //SPEN_MPAN__c mpanUpdate = SPEN_TestDataFactory.updateLastGaspTest()[0];
        SPEN_MPAN__c mpanUpdate = new SPEN_MPAN__c();
        String lastGaspDateTime = '2021-11-02T02:32:23.0000000+01:00';
        //insert mpan;
        insert mpanUpdate;
        mpanUpdate.SPEN_LastGasp__c=Datetime.valueOfGmt(lastGaspDateTime.replace('T', ' '));
        update mpanUpdate;
        mpan.add(mpanUpdate);
        Test.startTest();
        //String reqStr='<soap:Body><RequestBody xmlns="ENMAC/TCS"><SDIFEndDevicePowerDownEvent><CrtdDateTime>'+lastGaspDateTime+'</CrtdDateTime></SDIFEndDevicePowerDownEvent></RequestBody></soap:Body>';
        String reqStr = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ns2:SDIFEndDevicePowerDownEvent xmlns:ns2="SDIF" xmlns:ns3="http://ge.com/dsp/bf/service/commonfault"><EndDevicePowerDownEvent><mRID>8042170386077</mRID><crtdDateTime>2023-01-17T14:31:13.972Z</crtdDateTime><category>newCategory</category><severity>newSeverity</severity><reason>newReason</reason><status><value>newStatus</value><dateTime>2023-01-17T14:31:13.972Z</dateTime><reason>newReason</reason></status></EndDevicePowerDownEvent></ns2:SDIFEndDevicePowerDownEvent></soap:Body></soap:Envelope>';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/SDIFEndDevicePowerDownEvent/';  //Request URL
        req.httpMethod = 'PATCH';//HTTP Request Type
        req.requestBody = Blob.valueOf(reqStr);
        RestContext.request = req;
        RestContext.response= res;

        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass ());
        SPEN_MPAN__c returnMpan = SPEN_SyncMPANIdDetails.UpdateMpanLastGasp();
        Assert.isNotNull(mpan);
        Test.stopTest();
        return mpan;
      }
    /*Static testMethod void UpdateMpanLastGaspTest(){
        SPEN_MPAN__c mpanRecords = getmpanRecords();
        Test.startTest();
       // mpanRecords.SPEN_LastGasp__c=DateTime.valueOfGmt((sdifEvent.crtdDateTime.replace('T', ' ')));;
       // System.assertEquals(expected, actual);
        Test.stopTest();
    }*/

}