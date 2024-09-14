/**
 * @description       : This component will be called in Update Zone data button.
 * @author            : ramesh.c.singh@accenture.com
 * @group             : 
 * @last modified on  : 12-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SPEN_UpdateZoneDataController {

    @AuraEnabled
    public static Boolean updateZoneRecords(){
        Boolean isSuccess = false;
        try{
            String jsonContent = SPEN_UpdateZoneDataService.getZoneData();
            //System.debug('jsonContent:'+ jsonContent);
            if(jsonContent.contains('success')){
                jsonContent = jsonContent.subStringAfter('success');
                isSuccess = true;
                Map<String, String> mapZoneIdToParentId = new Map<String,String>();
                SPEN_UpdateZoneDataController.ZoneWrapper objZoneWrapper = (SPEN_UpdateZoneDataController.ZoneWrapper)JSON.deserialize(jsonContent, SPEN_UpdateZoneDataController.ZoneWrapper.class);
                //System.debug('===== lstZoneWrapper size:'+objZoneWrapper.operatingZoneList.size());
                if(objZoneWrapper != null){
                    List<SPEN_UpdateZoneDataController.OperatingZoneList> lstZone = objZoneWrapper.operatingZoneList;
                    //System.debug('===== lstZone size:'+lstZone.size());
                    for(SPEN_UpdateZoneDataController.OperatingZoneList objZone : lstZone){
                        mapZoneIdToParentId.put(objZone.ozId, objZone.ozParentId);	
                    }
                    SPEN_UpdateZoneDataBatch objZoneDataBatch = new SPEN_UpdateZoneDataBatch(mapZoneIdToParentId);
                    Database.executeBatch(objZoneDataBatch,integer.valueof(System.Label.SPEN_BatchSizeLabel));
                }    
            } 
        }catch(Exception ex){
            SEL_LoggingService.log(ex);  
            //isSuccess = false;
        }
        return isSuccess;
    }
   
    public class ZoneWrapper{
        public List<OperatingZoneList> operatingZoneList {get;set;}
        //public String apiName {get;set;}
    }
    
    public class OperatingZoneList{
        public String  ozId {get;set;}
        //public String townName {get;set;}
        public String ozParentId {get;set;}
        
    }
    
}