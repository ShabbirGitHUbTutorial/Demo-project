/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler Class for Delivery Trigger Operations
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
18-Oct-2023     Rajat Verma/Amrita Sarkar        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_DeliveryUtility {
    
    
    /*************************************************************************
@Author: Rajat Verma/Amrita Sarkar
@Date: 18/10/23
@purpose: Method for after update events on Delivery Object 
*************************************************************************************/
    public static void afterDeliveryUpdate(List<SPEN_Delivery__c> newUpdatedDeliveryList,Map<Id,SPEN_Delivery__c> oldUpdatedDeliveryMap,Map<Id,SPEN_Delivery__c> newUpdatedDeliveryMap ){
        List<id> delRf = new List<id>();
        List<id> delIdsForProjectAssign = new List<id>();
        Map<Id,String> projectManagerMap = new Map<Id,String>();
        for(SPEN_Delivery__c delvR : newUpdatedDeliveryList){
            if(delvR.SPEN_GSCallStatus__c != null && delvR.SPEN_GSCallStatus__c  != oldUpdatedDeliveryMap.get(delvR.id).SPEN_GSCallStatus__c 
               && delvR.SPEN_GSCallStatus__c == 'Successful')  {
                   delRf.add(delvR.id);                
               }
            //CRMD-919
            if(delvR.SPEN_DeliveryProjectManager__c != null && delvR.SPEN_DeliveryProjectManager__c  != oldUpdatedDeliveryMap.get(delvR.id).SPEN_DeliveryProjectManager__c){
                delIdsForProjectAssign.add(delvR.id);    
                projectManagerMap.put(delvR.id,delvR.SPEN_DeliveryProjectManager__c);
            }
            //END
        }
        if(delRf != null && delRf.size() > 0){
            SPEN_SAPPostAccContactCallOut.sendPostAccContactCallout(delRf);
        }
        //CRMD-919
        if(!delIdsForProjectAssign.isEmpty()){
            SPEN_SAPProjectAssignCallOut.sendProjectAssignCallout(delIdsForProjectAssign);
            updateRelatedCaseOwner(projectManagerMap);
        }
        //END
    }
    /*************************************************************************
@Author: Rajat Verma
@Date: 18/10/23
@purpose: CRMD-919 : Method to update case owner based on delivery project manager 
*************************************************************************************/
    public static void updateRelatedCaseOwner(Map<Id,String> deliverMap){
        List<Case> caseListToUpdate = new List<Case>();
        try{
            for(Case cseObj : [Select Id, OwnerId,SPEN_Delivery__c From Case where SPEN_Delivery__c =: deliverMap.KeySet()]){
                Case cse = new Case();
                cse.Id = cseObj.Id;
                cse.OwnerId = deliverMap.get(cseObj.SPEN_Delivery__c);
                caseListToUpdate.add(cse);
            }
            if(!caseListToUpdate.isEmpty()){
                update caseListToUpdate;
            }
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
}