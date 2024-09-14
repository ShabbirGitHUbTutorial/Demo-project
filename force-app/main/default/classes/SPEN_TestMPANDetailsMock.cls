global with sharing class SPEN_TestMPANDetailsMock extends SEL_IntegrationsOutboundMessageBase
{
    global static Id recordId;
    public SPEN_TestMPANDetailsMock() 
    {
        super('GetTechDetailsMPANMockAPI');
    }
    public void send(Id recordId)
    {
        //System.debug('Enter into Send()');
        // Get Data
        //System.debug('record ID' + recordId);
        SPEN_MPAN__c mpanMock;
        //SPEN_MPAN__c mpanMock = getMPANDetails(SPEN_TestMPANDetailsMock.recordId);
        if(recordId != null)
        	 mpanMock = [SELECT Id, SPEN_AccountNumberMPAN__c,SPEN_PingResult__c,
                                    ExternalId__c FROM SPEN_MPAN__c WHERE Id =: recordId];
        //System.debug('mpanMock : '+mpanMock);
        // Create a request record
        HttpRequest request = super.getHttpRequest(mpanMock);
        //System.debug('request : '+request);
        String meterVal;
        if(super.getIsMockingEnabled() || Test.isRunningTest())
        {
            HttpResponse response = super.send(request);
            if(response.getStatusCode() == 200){	
                List<String> mpanPostCode = new List<String>();
                SPEN_MPANWrapper wrapper = (SPEN_MPANWrapper) System.JSON.deserialize(response.getBody(), SPEN_MPANWrapper.class);
                for(SPEN_MPANWrapper.UtilityMatches val : wrapper.UtilityMatches){
                    for(SPEN_MPANWrapper.Meters nextVal : val.Meters){
                        for(SPEN_MPANWrapper.Parameters metVal: nextVal.MeterDetails){
                            mpanPostCode.add(metVal.Value);
                        }
                    }
                }
                if(!mpanPostCode.isEmpty()){
                	SPEN_MPAN__c mpan = new SPEN_MPAN__c();
                	mpan.Id = mpanMock.Id;
                	mpan.SPEN_AccountNumberMPAN__c = mpanPostCode[0];
                	Database.SaveResult dataSaveRes = Database.update(mpan);
					//System.debug('database res' +dataSaveRes);
				}
            }
            //system.debug('Mocked Response - Body');
            //system.debug(response.getBody());
            
            //system.debug('Mocked Response - StatusCode');
            //system.debug(response.getStatusCode());
            
            //system.debug('Mocked Response - Status');
            //system.debug(response.getStatus());
            
            //system.debug('Mocked Response - Header Keys');
            //system.debug(response.getHeaderKeys());
        }
        else 
        {
            system.debug(request.getBody());
        }
    }
    public void mockException()
    {
        try 
        {
            SPEN_MPAN__c mpanMock = [SELECT Id, SPEN_AccountNumberMPAN__c,ExternalId__c,SPEN_PingResult__c FROM SPEN_MPAN__c WHERE ExternalId__c =: '123445' LIMIT 1];
            // Create a request record
            HttpRequest request = super.getHttpRequest(mpanMock);
            HttpResponse resp = super.send(request);
            
        } catch (Exception ex) 
        {
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
}