/**********************************************************************************************
* @Author:      Smita Raikar
* @Date:        18/11/2022
* @Description: AdditionalService class called from SPEN_IVRMessageRequestService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class SPEN_IVRMessageService {
	public static void getIntgReqRsltForAssignIvrMsg(Id intgReqRecordId, String testPremiseID){
        SPEN_IVRToSDIFMessageIntegrationRequest testInstnc = new SPEN_IVRToSDIFMessageIntegrationRequest();
        testInstnc.send(intgReqRecordId, testPremiseID);
        
    }
    
}