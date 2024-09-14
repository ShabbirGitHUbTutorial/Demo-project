/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        15/11/2022
* @Description: AdditionalService class from SPEN_IntegrationRequestService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_MeterPingService
{ 
    public static void getIntgReqResultDetails(Id intgReqRecordId, String mpanNumber)
    {
        try
        {
            SPEN_IVRToECOSIntegrationReqRes testIVRToECOSInstnc = new SPEN_IVRToECOSIntegrationReqRes();
            testIVRToECOSInstnc.send(intgReqRecordId, mpanNumber);
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    } 
}