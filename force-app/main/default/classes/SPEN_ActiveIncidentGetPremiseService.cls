public class SPEN_ActiveIncidentGetPremiseService 
{
    public static void getIntgRequestRecord(Id intgReqRecordId, String testPremiseID)
    {
        try
        {
            SPEN_ActiveIncidentGetPremiseIntRequest testInstnc = new SPEN_ActiveIncidentGetPremiseIntRequest();
            testInstnc.send(intgReqRecordId, testPremiseID);
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }
}