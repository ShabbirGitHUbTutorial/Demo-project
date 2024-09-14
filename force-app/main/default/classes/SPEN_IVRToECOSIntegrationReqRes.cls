/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        17/11/2022
* @Description: IVRToECOSIntegrationReq&Res class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_IVRToECOSIntegrationReqRes extends SEL_IntegrationsOutboundMessageBase
{
    
    public List<String> dccServiceFlagValue = new List<String>();
    public List<String> suppliermpidValue = new List<String>();
    public String ivrToEcosintgAccountNumberMPAN;
	
    public SPEN_IVRToECOSIntegrationReqRes() 
    {
        super('IVRtoECOSCallAPI');
    }
    
    public void send(Id ivrToEcosintgReqRecordId, String mpanNumberForPingMeter)
    {
        try
        {
            //system.debug('mpanNumberForPingMeter '+ mpanNumberForPingMeter);

            SPEN_MPAN__c mpanRcd = SPEN_MPANSelector.getRecordForMpan(mpanNumberForPingMeter);
            ivrToEcosintgAccountNumberMPAN = mpanRcd.SPEN_AccountNumberMPAN__c;
            
            //system.debug('ivrToEcosintgAccountNumberMPAN--------->'+ivrToEcosintgAccountNumberMPAN);
            SPEN_IntegrationRequest__c inteReqRcrd = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(ivrToEcosintgReqRecordId);
            HttpRequest request = super.getHttpRequest(mpanRcd);
            System.debug('request : '+request);
            if(super.getIsMockingEnabled())
            {
                /*
                HttpResponse response = super.send(request);
				system.debug('response.getStatusCode() ---->'+ response.getStatusCode());
                if(response.getStatusCode() == 200){  
                    System.debug('response.getStatusCode() == 200');
                    SPEN_ECOSResponseWrapper.RequestBody ecosWrapper = (SPEN_ECOSResponseWrapper.RequestBody) System.JSON.deserialize(response.getBody(), SPEN_ECOSResponseWrapper.RequestBody.class);
                    if(!ecosWrapper.UtilityAddressMatches.isEmpty())
					{
						for(SPEN_ECOSResponseWrapper.UtilityAddressMatches val : ecosWrapper.UtilityAddressMatches)
						{
							for(SPEN_ECOSResponseWrapper.Parameters nextVal : val.AddressDetails)
							{
								if(nextVal.Key == 'dcc_service_flag')
								{
									dccServiceFlagValue.add(nextVal.Value);
								}
								else If(nextVal.Key == 'supplier_mpid')
								{
									suppliermpidValue.add(nextVal.Value);   
								} 
							}
							System.debug('dccServiceFlagValue' +dccServiceFlagValue);
						}
                    }
                    if(dccServiceFlagValue[0] == 'N' || dccServiceFlagValue[0] == 'I')
					{
                        inteReqRcrd.SPEN_Status__c= 'completed';
                        inteReqRcrd.SPEN_Result__c = 'Not a smart meter';
                        update(inteReqRcrd);
                    }
					else
					{
                        SPEN_MeterPingIntegrationRequest testInstncMeterPing = new SPEN_MeterPingIntegrationRequest();
                        testInstncMeterPing.send(ivrToEcosintgReqRecordId, ivrToEcosintgAccountNumberMPAN);
                    }
                }
                */
            }
            
            else 
            {
				dccServiceFlagValue.add(mpanRcd.SPEN_DCCServiceFlag__c);
				if(dccServiceFlagValue[0] == 'N' || dccServiceFlagValue[0] == 'I' || dccServiceFlagValue[0] == null)
				{
                    inteReqRcrd.SPEN_Status__c= 'completed';
                    inteReqRcrd.SPEN_Result__c = 'Not a smart meter';
                    update(inteReqRcrd);
				}
				else if(dccServiceFlagValue[0] == 'A')
                {
                    SPEN_MeterPingIntegrationRequest testInstncMeterPing = new SPEN_MeterPingIntegrationRequest();
                    testInstncMeterPing.send(ivrToEcosintgReqRecordId, ivrToEcosintgAccountNumberMPAN);
                }
            }
        }
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
			throw ex;
        }
    }

}