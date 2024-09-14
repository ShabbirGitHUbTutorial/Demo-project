/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        15/11/2022
* @Description: AdditionalService class from SPEN_IntegrationRequestService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_MeterPingIntegrationRequest extends SEL_IntegrationsOutboundMessageBase{
    
    public static Id intgReqRecordId;
    public static Id ivrToEcosintgMpanId;
    //String meterVal;
    
    public SPEN_MeterPingIntegrationRequest() 
    {
        super('GetTechDetailsMPANMockAPI');
    }
    
    //public void send(Id intgReqRecordId, String accountNumberMPAN, String suppliermpidValue)
    public void send(Id intgReqRecordId, String accountNumberMPAN)
    {
        try
        {
            SPEN_IntegrationRequest__c inteReqRecord = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(intgReqRecordId);            
            SPEN_MPAN__c ivrToEcosMpanRcrd = SPEN_MPANSelector.getRecordForMpan(accountNumberMPAN); 
            
            //SPEN_MPAN__c ivrToEcosMpanRcrd = SPEN_MPANSelector.getMpanRecordForMeterPing(accountNumberMPAN);
            //HttpRequest request = super.getHttpRequest(ivrToEcosMpanRcrdAfterPingStatus);
            
            HttpRequest request = super.getHttpRequest(ivrToEcosMpanRcrd);
            //System.debug('request : '+request);
            
            if(super.getIsMockingEnabled())
            {
                /*
                SPEN_LastGaspMockIntegrationService.getMockResponse(ivrToEcosMpanRcrd.Id);
                //SPEN_MPAN__c ivrToEcosMpanRcrdAfterPingStatus = SPEN_MPANSelector.getMpanRecord(ivrToEcosMpanRcrd.Id);
                //ivrToEcosMpanRcrdAfterPingStatus.SPEN_PremiseRetailer__c = suppliermpidValue;
                //ivrToEcosMpanRcrdAfterPingStatus.SPEN_Status__c = ivrToEcosMpanRcrdAfterPingStatus.SPEN_PingResult__c;
                //update(ivrToEcosMpanRcrdAfterPingStatus);
                
                HttpResponse response = super.send(request);
                if(response.getStatusCode() == 200)
				{  
                    System.debug('response.getStatusCode() == 200');
                   	List<String> mpanPostCode = new List<String>();

                    SPEN_MPANWrapper wrapper = (SPEN_MPANWrapper) System.JSON.deserialize(response.getBody(), SPEN_MPANWrapper.class);
                    for(SPEN_MPANWrapper.UtilityMatches val : wrapper.UtilityMatches)
					{
                        for(SPEN_MPANWrapper.Meters nextVal : val.Meters)
						{
                            for(SPEN_MPANWrapper.Parameters metVal: nextVal.MeterDetails)
							{
                                mpanPostCode.add(metVal.Value);
                            }
                        }
                    }
                    if(!mpanPostCode.isEmpty())
					{
                      SPEN_MPAN__c mpan = new SPEN_MPAN__c();
                      //mpan.Id = ivrToEcosMpanRcrdAfterPingStatus.Id;
                      mpan.Id = ivrToEcosMpanRcrd.Id;
                      mpan.SPEN_AccountNumberMPAN__c = mpanPostCode[0];
                      update(mpan);
                    }
                    
                    //SPEN_MPAN__c mpanRcrd = SPEN_MPANSelector.getMpanRecordForMeterPing(accountNumberMPAN);
                    SPEN_MPAN__c mpanRcrd = SPEN_MPANSelector.getRecordForMpan(accountNumberMPAN);
                    inteReqRecord.SPEN_Result__c= mpanRcrd.SPEN_PingResult__c;
                    inteReqRecord.SPEN_Status__c= 'completed';
                    update(inteReqRecord);
                } 
                */
            }
			
           	else 
            {
                SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName('SDIFPingMeterAPI');
                //system.debug('cmt'+cmt);
                SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);
                
                System.debug(JSON.serialize(ivrToEcosMpanRcrd));
                String message = ser.generateMessage(ivrToEcosMpanRcrd);
                System.debug('Expected Message'+message);
                ivrToEcosMpanRcrd.SPEN_SmartMeterPingDateTime__c = system.now();
                ivrToEcosMpanRcrd.SPEN_PingResult__c = '';
                update ivrToEcosMpanRcrd;
            	System.enqueueJob(new SPEN_SDIFPingMeterQueueable(intgReqRecordId,message));
            }
        }
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
			throw ex;
        }
    }
   
}