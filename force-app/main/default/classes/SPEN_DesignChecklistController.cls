/* File Name: SPEN_DesignChecklistController 
 * Description: The given code is a public class named SPEN_DesignChecklistController which is used in LWC sPEN_DesignChecklist
 * Author: Rajat Kumar Mishra
 * Version: 1.0
 * History:
 * Date            Author                 Comment
 * Aug-31-2023     Rajat Kumar Mishra     Initial version
 *
 */

public with sharing class SPEN_DesignChecklistController{
    
    @AuraEnabled (cacheable=true)
    public static List<SPEN_DesignChecklistRequest__c> getDCRList(String jobId){
        return [SELECT Id,SPEN_Job__c, Name, SPEN_TotalDesignInformation__c, SPEN_CompletedDesignInformation__c, SPEN_DesignCompletion__c
                FROM SPEN_DesignChecklistRequest__c WHERE SPEN_Job__c =:jobId];        
    }
    
    @AuraEnabled (cacheable=true)
    public static SPEN_DesignChecklistRequest__c getDCR(String dcrId){
   
        if(dcrId != null){
            return [SELECT Id, SPEN_TotalDesignInformation__c, SPEN_CompletedDesignInformation__c, SPEN_DesignCompletion__c
                FROM SPEN_DesignChecklistRequest__c WHERE Id =:dcrId]; 
        }
        return null;
       
    }
    
   /*  @AuraEnabled (cacheable=true)
    public static  List<SPEN_DesignInformation__c> getDesignInformationsRelatedToDCR(String designChecklistRecId){
        list<SPEN_DesignInformation__c> dIlist = [SELECT Id, SPEN_BusinessAreaOwner__c, SPEN_DesignInformationDetail__c,SPEN_CompletedStatus__c
                ,SPEN_DesignCategory__c, SPEN_CompletionDate__c, SPEN_Comments__c, SPEN_Sequence__c FROM SPEN_DesignInformation__c WHERE SPEN_DesignChecklist__c =:designChecklistRecId ORDER BY SPEN_Sequence__c, SPEN_DesignCategory__c,SPEN_DesignInformationDetail__c ];         
        return dIlist;
       
    } */

    @AuraEnabled (cacheable=true)
    public static  List<SPEN_DesignInformation__c> getDesignInformationsRelatedToDCR(String designChecklistRecId, String designCategory){
        list<SPEN_DesignInformation__c> dIlist ;
        if(designCategory != null && designCategory != ''){
            dIlist = [SELECT Id, SPEN_BusinessAreaOwner__c, SPEN_DesignInformationDetail__c,SPEN_CompletedStatus__c
                ,SPEN_DesignCategory__c, SPEN_CompletionDate__c, SPEN_Comments__c, SPEN_Sequence__c FROM SPEN_DesignInformation__c WHERE SPEN_DesignChecklist__c =:designChecklistRecId AND SPEN_DesignCategory__c = :designCategory ORDER BY SPEN_Sequence__c, SPEN_DesignCategory__c,SPEN_DesignInformationDetail__c ];         
        }else{
            dIlist = [SELECT Id, SPEN_BusinessAreaOwner__c, SPEN_DesignInformationDetail__c,SPEN_CompletedStatus__c
                ,SPEN_DesignCategory__c, SPEN_CompletionDate__c, SPEN_Comments__c, SPEN_Sequence__c FROM SPEN_DesignInformation__c WHERE SPEN_DesignChecklist__c =:designChecklistRecId ORDER BY SPEN_Sequence__c, SPEN_DesignCategory__c,SPEN_DesignInformationDetail__c ];         
        }
        return dIlist;
       
    }
    
    @AuraEnabled (cacheable=true)
    public static Boolean isExternalUser()
    {
        Boolean isExternalUser = false;            
        Id userId = Userinfo.getUserId();
        Boolean hasPermission = FeatureManagement.checkPermission('SPEN_LnPExternalUsers');
        if(hasPermission==true)
        {
            isExternalUser=true;                
        } 
        return isExternalUser;
    }
}