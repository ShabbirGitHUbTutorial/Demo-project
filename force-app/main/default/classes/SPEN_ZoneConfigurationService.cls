/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler for Zone Trigger
AUTHOR      :   Smita Raikar
LIBRARY     :   Salesforce Enterprise Library (SEL) - Core
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
NOV-11-2022     Smita Raikar         Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_ZoneConfigurationService {
    //public static final String Zone_ConfigSetting = 'Zone broadcast message updated last one hour';
    /*************************************************************************
@Author: Smita Raikar
@Date: 11/11/2022
@purpose: Update the IVR message template and broadcast message fields on all child records and its descedents of Zone
*************************************************************************************/
    public static void beforeZoneInsert(List<sObject> zoneNewList){
        List<SPEN_Zone__c> zoneMapNewVal = (List<SPEN_Zone__c>)zoneNewList;
        //List<SPEN_Zone__c> zoneDisListVal = new List<SPEN_Zone__c>();
        //List<SPEN_Zone__c> zoneListVal = new List<SPEN_Zone__c>();
        try{
            if(!zoneMapNewVal.isEmpty()){
                /*for(SPEN_Zone__c z: zoneMapNewVal){
                    SPEN_Zone__c ezone=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='Region'  ];
                    SPEN_IVRMessage__c msg=[Select Id,Name,SPEN_IVRMessage__c from SPEN_IVRMessage__c where Id=:z.SPEN_IVRMessageTemplate__c ];
                    if(z.SPEN_OverwriteToChild__c ==true && z.SPEN_Type__c=='Region'){
                        List<SPEN_Zone__c> zoneDisList=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='District'  AND SPEN_Parent__c=:ezone.Id];
                        
                        system.debug('zoneList ---->' + zoneDisList);   
                        for(SPEN_Zone__c zone: zoneDisList){
                            zone.SPEN_IVRMessageTemplate__c=z.SPEN_IVRMessageTemplate__c;
                            //Change based on CRMD-5177
                            //zone.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                            zone.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;
                            zone.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c;
                            List<SPEN_Zone__c> zoneList=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='Zone' AND SPEN_Parent__c=:zone.Id];
                            system.debug('zoneList-->'+zoneList);
                            //system.debug('Size of ZoneList' +zoneList.size());
                            for(SPEN_Zone__c zone1: zoneList){
                                zone1.SPEN_IVRMessageTemplate__c=z.SPEN_IVRMessageTemplate__c;
                                //Change based on CRMD-5177
                                //zone1.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                                zone1.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;
                                zone1.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c;
                                zoneListVal.add(zone1);
                            }
                            zoneDisListVal.add(zone);
                        }
                        update zoneDisListVal;
                        //System.debug('Line 47 zoneDisListVal' +zoneDisListVal);
                        update zoneListVal;
                        //System.debug('Line 49 zoneListVal' +zoneListVal);
                        
                    }
                    if(z.SPEN_OverwriteToChild__c ==true && z.SPEN_Type__c=='District'){
                        List<SPEN_Zone__c> zoneList=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where  SPEN_Type__c=:'Zone' and  SPEN_Parent__c=:ezone.Id];
                        
                        system.debug('zoneList ---->' + zoneList);  
                        for(SPEN_Zone__c zone: zoneList){
                            System.debug('Zone Line 54' +zone);
                            zone.SPEN_IVRMessageTemplate__c=z.SPEN_IVRMessageTemplate__c;
                            //Change based on CRMD-5177
                            //zone.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                            zone.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;  
                            zone.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c;
                            zoneListVal.add(zone);
                        }
                        update zoneListVal;
                        
                    }//Change based on CRMD-5177
                    //z.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                    //z.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;*/
                //}
                SPEN_ZoneConfigurationServiceHelper.updateMessageOnInsert(zoneMapNewVal); //added by shubhi for remediation
            }
        }  
        
        catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
    /*************************************************************************
@Author: Smita Raikar
@Date: 11/11/2022
@purpose: Update the IVR message template and broadcast message fields on all child records and its descedents of Zone
*************************************************************************************/
    public static void beforeZoneUpdate( Map<Id, sObject> zoneOldMap,List<sObject> zoneNewList){
        List<SPEN_Zone__c> zoneMapNewVal = (List<SPEN_Zone__c>)zoneNewList;
        Map<Id,SPEN_Zone__c> zMapOldVal = (Map<Id,SPEN_Zone__c>)zoneOldMap;
        //List<SPEN_Zone__c> zoneDisListVal = new List<SPEN_Zone__c>();
        //List<SPEN_Zone__c> zoneListVal = new List<SPEN_Zone__c>();
        try{
            if(zMapOldVal!=null && zoneMapNewVal!=null){
                SPEN_ZoneConfigurationServiceHelper.updateMessageOnUpdate(zMapOldVal,zoneMapNewVal);  
            }
                /*for(SPEN_Zone__c z: zoneMapNewVal){
                    SPEN_IVRMessage__c msg=[Select Id,Name,SPEN_IVRMessage__c from SPEN_IVRMessage__c where Id=:z.SPEN_IVRMessageTemplate__c ];
                    if((z.SPEN_OverwriteToChild__c && z.SPEN_OverwriteToChild__c != zMapOldVal.get(z.id).SPEN_OverwriteToChild__c) ||
                       z.SPEN_IVRMessageTemplate__c != zMapOldVal.get(z.id).SPEN_IVRMessageTemplate__c
                      )
                    {    
                    if(z.SPEN_OverwriteToChild__c ==true && z.SPEN_Type__c=='Region'){
                        List<SPEN_Zone__c> zoneDisList=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='District'  AND SPEN_Parent__c=:z.Id];
                        
                        system.debug('zoneList ---->' + zoneDisList);   
                        for(SPEN_Zone__c zone: zoneDisList){
                            zone.SPEN_IVRMessageTemplate__c=z.SPEN_IVRMessageTemplate__c;
                            //Change based on CRMD-5177
                            //zone.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                            zone.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c; 
                            zone.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c; 
                            List<SPEN_Zone__c> zoneList=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where SPEN_Type__c='Zone'  AND SPEN_Parent__c=:zone.Id];
                            for(SPEN_Zone__c zone1: zoneList){
                                zone1.SPEN_IVRMessageTemplate__c=z.SPEN_IVRMessageTemplate__c; 
                                //Change based on CRMD-5177
                            	//zone1.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                            	zone1.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;
                                zone1.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c;   
                                zoneListVal.add(zone1);
                            }
                            zoneDisListVal.add(zone);
                        }
                        update zoneDisListVal;
                        update zoneListVal;
                        
                    }
                    if(z.SPEN_OverwriteToChild__c ==true && z.SPEN_Type__c=='District'){
                        List<SPEN_Zone__c> zoneList=[Select Id,Name,SPEN_BroadcastMessage__c,SPEN_IVRMessage__c,SPEN_IVRMessageTemplate__c,SPEN_OverwriteToChild__c,SPEN_Parent__c,SPEN_Type__c from SPEN_Zone__c where  SPEN_Type__c=:'Zone'and  SPEN_Parent__c=:z.Id];
                        
                        system.debug('zoneList ---->' + zoneList);  
                        for(SPEN_Zone__c zone: zoneList){
                            zone.SPEN_IVRMessageTemplate__c=z.SPEN_IVRMessageTemplate__c; 
                            //Change based on CRMD-5177
                            //zone.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                            zone.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;
                            zone.SPEN_IVRMessage__c=msg.SPEN_IVRMessage__c;
                            zoneListVal.add(zone);
                        }
                        update zoneListVal;
                        
                    } 
                    //Change based on CRMD-5177
                        //z.SPEN_BroadcastMessage__c=msg.SPEN_IVRMessage__c;
                        z.SPEN_IVRTemplateBody__c=msg.SPEN_IVRMessage__c;
                    }
                }*/
                //SPEN_ZoneConfigurationServiceHelper.updateChildrenFromParent(zMapOldVal,zoneNewList); //added by shubhi for remediation
            //}
        }  
        
        catch(exception e){
            SEL_LoggingService.log(e);
        }
    }

 
     /*************************************************************************
@Author: Sheker Kulkacherla
@Date: 12/12/2022
@purpose: Update the SPEN_IntegrationRequest__c.SPEN_Response__c from SPEN_Zone__c.	SPEN_BroadcastMessage__c - CRMD-2168
*************************************************************************************/   
    public static void afterZoneUpdate( Map<Id, sObject> zoneOldMap,List<sObject> zoneNewList){
        List<SPEN_Zone__c> zoneMapNewVal = (List<SPEN_Zone__c>)zoneNewList;
        Map<Id,SPEN_Zone__c> zMapOldVal = (Map<Id,SPEN_Zone__c>)zoneOldMap;
        /*Map<Id,SPEN_Zone__c> zoneMap = new Map<Id,SPEN_Zone__c>();
        for(SPEN_Zone__c zoneValue: zoneMapNewVal){
            if(zMapOldVal.get(zoneValue.Id) != Null && zoneValue.SPEN_BroadcastMessage__c !=null && zMapOldVal.get(zoneValue.Id).SPEN_BroadcastMessage__c !=zoneValue.SPEN_BroadcastMessage__c)
            {
                zoneMap.put(zoneValue.Id,zoneValue);
            }
        }
        
        Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>();
        configSetMap = SPEN_CaseSelector.configSettingsMap;//map to hold COnfig settings value
        
        Integer threshold = Integer.valueOf(configSetMap.get(Zone_ConfigSetting).SPEN_Value__c);
        System.debug('====zoneconfig'+configSetMap.get(Zone_ConfigSetting).SPEN_Value__c);
         System.debug('====threshold'+threshold);
        Datetime dateThreshold = system.now().addHours(-threshold);
        System.debug('====dateThreshold'+dateThreshold);
        List<SPEN_IntegrationRequest__c> intReqList = new List<SPEN_IntegrationRequest__c>();
        System.debug('====zoneMap'+zoneMap);
        //SPEN_IntegrationRequestSelector.getZoneRecord(zoneMap.keySet());
        if(!zoneMap.isEmpty()){
            for(SPEN_IntegrationRequest__c intRequest : SPEN_IntegrationRequestSelector.geIntegrationRequestZoneRecord(zoneMap.keySet(),dateThreshold))
            {
                intRequest.SPEN_Response__c = zoneMap.get(intRequest.SPEN_RelatedRecord__c).SPEN_BroadcastMessage__c;
                intReqList.add(intRequest);
            }
             System.debug('====intReqList'+intReqList);
        }
        
        if(!intReqList.isEmpty()){
            update intReqList;
        }*/
        //try{
            if(zMapOldVal!=null && zoneMapNewVal!=null){
                SPEN_UpdateMessageOnChildUtility.updateChildMessageFromParent(zMapOldVal,zoneMapNewVal);
                SPEN_ZoneConfigurationServiceHelper.updateIROnUpdate(zMapOldVal,zoneMapNewVal);
            }
        /*}catch(exception e){
            SEL_LoggingService.log(e);
        }*/
    }
    /*************************************************************************
@Author: PatanShabbir Ali Khan
@Date: 14/08/2023
@purpose: Audit trail of when IVR messages are assigned and removed to/from zones and districts --CRMD-5528
*************************************************************************************/   
public static void createZoneCreate( Map<Id, sObject> zoneOldMap,List<sObject> zoneNewList){
    List<SPEN_Zone__c> zoneMapNewVal = (List<SPEN_Zone__c>)zoneNewList;
    Map<Id,SPEN_Zone__c> zMapOldVal = (Map<Id,SPEN_Zone__c>)zoneOldMap;
    List<SPEN_Zone_History__c> zoneHistoryList = new List<SPEN_Zone_History__c>();
    for(SPEN_Zone__c zone : zoneMapNewVal){
        SPEN_Zone_History__c zHistory = new SPEN_Zone_History__c();
        zHistory.SPEN_User__c = UserInfo.getName();
        zHistory.SPEN_Date__c = System.now();
        System.debug( zone.Id);
        zHistory.SPEN_Zone__c	= zone.Id;
        if(zMapOldVal.get(zone.Id).Name != zone.Name){
            zHistory.Name = (String)((SObject)Type.forName('SPEN_Zone__c').newInstance()).getSObjectType().getDescribe().fields.getMap().get('Name').getDescribe().getLabel();
            zHistory.SPEN_Field__c = (String)((SObject)Type.forName('SPEN_Zone__c').newInstance()).getSObjectType().getDescribe().fields.getMap().get('Name').getDescribe().getLabel();            zHistory.SPEN_Original_Value__c = zMapOldVal.get(zone.Id).Name;
            zHistory.SPEN_New_Value__c = zone.Name;
            zoneHistoryList.add(zHistory);
        }else if(zMapOldVal.get(zone.Id).SPEN_BroadcastMessage__c != zone.SPEN_BroadcastMessage__c){
            zHistory.Name = (String)((SObject)Type.forName('SPEN_Zone__c').newInstance()).getSObjectType().getDescribe().fields.getMap().get('SPEN_BroadcastMessage__c').getDescribe().getLabel();            
            zHistory.SPEN_Field__c = (String)((SObject)Type.forName('SPEN_Zone__c').newInstance()).getSObjectType().getDescribe().fields.getMap().get('SPEN_BroadcastMessage__c').getDescribe().getLabel();zHistory.SPEN_Original_Value__c = zMapOldVal.get(zone.Id).SPEN_BroadcastMessage__c;
            zHistory.SPEN_New_Value__c = zone.SPEN_BroadcastMessage__c;
            zoneHistoryList.add(zHistory);
        }
        
        if(!zoneHistoryList.isEmpty()){
            try{
            insert zoneHistoryList;
            } catch(Exception ex){
                SEL_LoggingService.log(ex);
            }
        }

    }
}
    public static String getOutageETR(){
        String outageETRVal;
       /* Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>();
        configSetMap = SPEN_ZoneSelector.configSettingsMap;//map to hold COnfig settings value
        Integer hourValue = system.now().hour();
        String outageConfigSetting = '';//this will hold the config setting name based on case category value
        Boolean hourCalculationsNeeded = false;//boolean flag to consider extra 3 hours quarter check
        Boolean isInBusinessHours = false; 
        //if(CasesConstants.Case_NoSupplySinglePremise){
            if(hourValue >= CasesConstants.startTime &&
              hourValue < CasesConstants.endTime)
            {
                outageConfigSetting = CasesConstants.NoSupplyNetworkWithinBusinessHours;
                hourCalculationsNeeded = true;
                isInBusinessHours = true;
                
            }
            else{
                outageConfigSetting = CasesConstants.NoSupplyNetworkOutsideBusinessHours;
            }
            
        /*}   
        
        else if(CasesConstants.Case_NoSupplyNetwork){
            outageConfigSetting = CasesConstants.NoSupplyNetwork;
            hourCalculationsNeeded = true;
        }
        else{
            outageConfigSetting = CasesConstants.OtherCategory;
        }
		*/        
       /* if(!configSetMap.isEmpty()){
            if(hourCalculationsNeeded){//get Nearest Hour quarter threshold value
                outageETRVal = getOutageTimeInModValue(Integer.valueOf(configSetMap.get(outageConfigSetting).SPEN_Value__c),isInBusinessHours);
            }
            else{//get direct value from Conf setting
                outageETRVal = getOutsideETRMessage(configSetMap.get(outageConfigSetting).SPEN_Value__c);//configSetMap.get(outageConfigSetting).SPEN_Value__c ;
            }
        }*/
        return outageETRVal;
    }
    
    /*
     * This method will calculate ERT thershold value 
     * based on respective config settings
     * Retutn type: String
     * Parameters : Integer (threshold)
     */ 
    @AuraEnabled
    public static String getOutageTimeInModValue(Integer valueThreshold, Boolean inBusinessHours){
        String outageETRModVal = '';
        Datetime latestOutageVal = system.now().addHours(valueThreshold);//add threshold in system.now
        String latestOutageValAMPM = latestOutageVal.format('hh.mm');
        String ampmStr = latestOutageVal.format('aa');
        Integer hourVal = Integer.valueOf(latestOutageValAMPM.left(2));//latestOutageVal.hour(); //hoursValue //.hourGmt();
        String minVal = latestOutageValAMPM.right(2);//String.valueOf(latestOutageVal.minute()); // minuteValue //.minuteGmt();
        if(latestOutageVal.minute() < 10){
            minVal = minVal.leftPad(2,'0');
        }
        //String minVal = String.valueOf(latestOutageVal.minute()); // minuteValue //.minuteGmt();
        //system.debug(minVal);
        Decimal expectedMin = (Decimal.valueOf(minVal)/15).round(System.RoundingMode.CEILING);// divide by 15 and set to ceiling value
        //system.debug(expectedMin);
        String finalMinVal = String.valueOf(Integer.valueOf(expectedMin)*15);
        //system.debug(finalMinVal);
        if(finalMinVal == '60'){// if last quarter, then consider next hour
            finalMinVal = '00';
            hourVal++;
        }
        if(inBusinessHours){
            outageETRModVal = String.valueOf(system.today().format())+ ' ' +string.valueof(hourVal).leftPad(2,'0') + ':' + minVal + ' '+ampmStr;
        } else{
            outageETRModVal = String.valueOf(system.today().format())+ ' ' + string.valueof(hourVal).leftPad(2,'0') + ':' + finalMinVal + ' '+ampmStr; //final ETR value for NS- Network

        }
        return outageETRModVal;
    }
    @AuraEnabled
    public static string getOutsideETRMessage(String configStr)
    {
        String etrVal;
		Integer hourVal = system.now().hourGmt();
        String dateVal;
		if(hourVal >= 22 && hourVal<=23)
        {
            dateVal = (system.today()+1).format();
        }
        else{
            dateVal = (system.today()).format();
        }
        etrVal = configStr + ' '+dateVal;
        return etrVal;
    }
}