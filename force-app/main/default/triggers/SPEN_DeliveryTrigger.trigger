/*-----------------------------------------------------------------------------
DESCRIPTION :   Trigger For Delivery Object
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
18-Oct-2023     Rajat Verma/Amrita Sarkar        Initial version
-----------------------------------------------------------------------------*/
trigger SPEN_DeliveryTrigger on SPEN_Delivery__c (after update) {
    
    /*************************************************************************
@Author: Rajat Verma/Amrita Sarkar
@Date: 18/10/23
@purpose: After Update Event
*************************************************************************************/
    if(Trigger.isUpdate && Trigger.isAfter && !FeatureManagement.checkPermission('SPEN_BypassTriggerDelivery')){
        SPEN_DeliveryUtility.afterDeliveryUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
    }
}