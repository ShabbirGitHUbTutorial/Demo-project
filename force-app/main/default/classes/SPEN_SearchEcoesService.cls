/**********************************************************************************************
* @Author:      Ayush Mittal
* @Date:        07/12/2022
* @Description: AdditionalService class called from SPEN_IntegrationRequestService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public class SPEN_SearchEcoesService 
{
	public static void getResultFromMpan(Id intgReqRecordId, String details)
    {
        SPEN_SearchEcoesIntegrationRequest searchEchoes = new SPEN_SearchEcoesIntegrationRequest();
        searchEchoes.send(intgReqRecordId, details);
    }
}