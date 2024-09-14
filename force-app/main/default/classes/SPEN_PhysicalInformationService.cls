public with sharing class SPEN_PhysicalInformationService {
    @InvocableMethod(label='SAP Callout for Physical Information' description='SAP Callout for Physical Information when case is Competent')
    public static void callSAPCallout(List<Id> phyInfoIds)
    {
        try
        {
            String phyInfoId;
            List<Id> lstCaseId = new List<Id>();
            SPEN_PhysicalInformation__c phyInfo = SPEN_PhysicalInformationSelector.getPhysicalInfoFromPhyInfoIds(phyInfoIds);
            phyInfoId= phyInfo.id;
            lstCaseId.add(phyInfo.SPEN_Case__c);
            if(!System.isfuture())
            {
            SPEN_SAPQASCallout.sendSoapCallout(phyInfoId, lstCaseId);
            }
            
        }
        catch(Exception ex)
        {
            System.debug('In class SPEN_PhysicalInformationService : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }

    }

}