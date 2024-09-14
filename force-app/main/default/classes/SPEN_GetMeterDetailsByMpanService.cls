/**********************************************************************************************
* @Author:      Ayush Mittal
* @Date:        11/01/2023
* @Description: AdditionalService class called from SPEN_IntegrationRequestService 
***********************************************************************************************/
public with sharing class SPEN_GetMeterDetailsByMpanService
{
	public static void getMeterDetailsFromMpan(Id intgReqRecordId, String mpanNumber)
    {
        try
        {
            SPEN_MeterDetailsIntegrationRequest getMeterDetails = new SPEN_MeterDetailsIntegrationRequest();
            getMeterDetails.send(intgReqRecordId, mpanNumber);
        }
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
}