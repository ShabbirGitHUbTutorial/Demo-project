/*
 * Service class for case related
 * methods. Add all backend logic methods in this class
 */ 
public with sharing class SPEN_CaseService {
    /*
     * Method will calculate Outage ETR value
     * based on Case category
     */
    

    @AuraEnabled
    public static String getOutageETR(String caseCategory){
        String outageETRVal;
        Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>();
        configSetMap = SPEN_CaseSelector.configSettingsMap;//map to hold COnfig settings value
        DateTime dt = Datetime.valueOfGMT(String.valueOF(System.now()));
        //INC2967428
        Integer hourValue = dt.hourGmt();
        String outageConfigSetting = '';//this will hold the config setting name based on case category value
        Boolean hourCalculationsNeeded = false;//boolean flag to consider extra 3 hours quarter check
        Boolean isInBusinessHours = false; 
        if(caseCategory == CasesConstants.Case_NoSupplySinglePremise || caseCategory == CasesConstants.Case_NoSupplyIVR){
            if(hourValue >= CasesConstants.startTime &&
              hourValue < CasesConstants.endTime)
            {
                outageConfigSetting = CasesConstants.NoSupplyNetworkWithinBusinessHours;
                hourCalculationsNeeded = true;
                isInBusinessHours = true;
                if(caseCategory == CasesConstants.Case_NoSupplyIVR){ //condition added for IVR category so that closest quarter considered
                    isInBusinessHours = false;
                }
            }
            else{
                outageConfigSetting = CasesConstants.NoSupplyNetworkOutsideBusinessHours;
            }
            
            
        }
        else if(caseCategory == CasesConstants.Case_NoSupplyNetwork){
            outageConfigSetting = CasesConstants.NoSupplyNetwork;
            hourCalculationsNeeded = true;
        }
        else{
            outageConfigSetting = CasesConstants.OtherCategory;
        }
        
        if(!configSetMap.isEmpty()){
            if(hourCalculationsNeeded){//get Nearest Hour quarter threshold value
                outageETRVal = getOutageTimeInModValue(Integer.valueOf(configSetMap.get(outageConfigSetting).SPEN_Value__c),isInBusinessHours);
            }
            else{//get direct value from Conf setting
                if(caseCategory == CasesConstants.Case_NoSupplyIVR || caseCategory == CasesConstants.Case_NoSupplySinglePremise){
                    outageETRVal = getOutsideETRMessage(configSetMap.get(outageConfigSetting).SPEN_Value__c);//configSetMap.get(outageConfigSetting).SPEN_Value__c ;
                }
                else{
                    outageETRVal = configSetMap.get(outageConfigSetting).SPEN_Value__c ;
                }
                
                
            }
        }
        return outageETRVal;
    }
    
    public static String getOutageETRVal(Datetime CreatedDate,String ZoneName){
        String outageETRVal;
        Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>();
        configSetMap = SPEN_CaseSelector.configSettingsMap;//map to hold COnfig settings value
        Integer hourValue = CreatedDate.hour();
        String outageConfigSetting = '';//this will hold the config setting name based on case category value
        Boolean hourCalculationsNeeded = false;//boolean flag to consider extra 3 hours quarter check
        Boolean isInBusinessHours = false; 
        ////system.debug('CreatedDate'+CreatedDate);
       	////system.debug('ZoneName'+ZoneName);
            if(hourValue >= CasesConstants.startTime &&
              hourValue < CasesConstants.endTime)
            {
                outageConfigSetting = ZoneName;
                hourCalculationsNeeded = true;
                isInBusinessHours = true;
                
               
            }
        else{
            	outageConfigSetting = ZoneName;
                //hourCalculationsNeeded = false;
                isInBusinessHours = false;
        }
         
        if(!configSetMap.isEmpty()){
           if(hourCalculationsNeeded){//get Nearest Hour quarter threshold value
               outageETRVal = getOutageTimeValue(Integer.valueOf(configSetMap.get(outageConfigSetting).SPEN_Value__c), CreatedDate,isInBusinessHours);  
            }
               
            
        }
        return outageETRVal;
    }

     public static String getOutageTimeValue(Integer valueThreshold,Datetime CreatedDate,Boolean inBusinessHours){
        String calculatedtimeVal = '';
        Datetime latestTimeVal = CreatedDate.addHours(valueThreshold);//add threshold in system.now
        ////system.debug('latestTimeVal'+latestTimeVal);
        Integer hourVal = latestTimeVal.hour(); //hoursValue //.hourGmt();
        ////system.debug('hourVal'+hourVal);
        Integer minVal = latestTimeVal.minute(); // minuteValue //.minuteGmt();
        ////system.debug('minVal'+minVal);
        Decimal expectedMin = (Decimal.valueOf(minVal)/15).round(System.RoundingMode.CEILING);// divide by 15 and set to ceiling value
        ////system.debug('expectedMin'+expectedMin);
        String finalMinVal = String.valueOf(Integer.valueOf(expectedMin)*15);
        ////system.debug('finalMinVal'+finalMinVal);
        if(finalMinVal == '60'){// if last quarter, then consider next hour
            finalMinVal = '00';
            ////system.debug('finalMinValafter'+finalMinVal);
            hourVal++;
            ////system.debug('hourVal'+hourVal);
        }
        	
         if(hourVal==24 || hourVal >= CasesConstants.outsideBusinesshoursstart &&
              hourVal < CasesConstants.outsideBusinesshoursend){
            Date caseCreation = date.newinstance(CreatedDate.year(), CreatedDate.month(), CreatedDate.day());
            caseCreation=caseCreation.addDays(1);
            ////system.debug('caseCreation'+caseCreation);
            calculatedtimeVal = String.valueOf(caseCreation)+ ' ' +hourVal + ':' + finalMinVal;
        	////system.debug('outageETRModVal'+calculatedtimeVal);
            
        } else{
           	Date caseCreation = date.newinstance(CreatedDate.year(), CreatedDate.month(), CreatedDate.day());
            
            calculatedtimeVal = String.valueOf(caseCreation)+ ' ' +hourVal + ':' + finalMinVal;
        	////system.debug('outageETRModVal'+calculatedtimeVal);

        }
           

       
        return calculatedtimeVal;
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
        string strdatetime = string.valueof(latestOutageVal).substringafter(' ');
        integer twfhours = integer.valueof(strdatetime.left(2));
        String latestOutageValAMPM = latestOutageVal.format('hh.mm');
        //system.debug('latestOutageValAMPM' +latestOutageValAMPM);
      //  String ampmStr = latestOutageVal.format('aa');
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
            twfhours++;
           
        }
        hourVal = (hourVal == 13) ? 1 : hourVal;
        string ampmStr;
        //system.debug('twfhours' +twfhours);
        if(twfhours < 12 || twfhours == 24){
            ampmStr = 'AM';
        }
        else {
            ampmStr = 'PM';
        }
        //system.debug('ampmStr' +ampmStr);
            
       
        if(inBusinessHours){
            outageETRModVal = 'Today by ' + string.valueof(hourVal).leftPad(2,'0') + ':' + minVal + ' '+ampmStr; //String.valueOf(system.today().format())+ ' ' +string.valueof(hourVal).leftPad(2,'0') + ':' + minVal + ' '+ampmStr;
        } else{
            outageETRModVal = 'Today by ' + string.valueof(hourVal).leftPad(2,'0') + ':' + finalMinVal + ' '+ampmStr; //String.valueOf(system.today().format())+ ' ' + string.valueof(hourVal).leftPad(2,'0') + ':' + finalMinVal + ' '+ampmStr; //final ETR value for NS- Network

        }
        return outageETRModVal;
    }
    @AuraEnabled
    public static string getOutsideETRMessage(String configStr)
    {
        String etrVal;
        //INC2967428
		DateTime dt = Datetime.valueOfGMT(String.valueOF(System.now()));
		Integer hourVal = dt.hourGmt();
        String dateVal;
		if(hourVal >= 22 && hourVal<=23)
        {
            dateVal = (system.today()+1).format();
        }
        else{
            dateVal = (system.today()).format();
        }
        //The estimated time of arrival of engineer would be {date} by {10am}
        etrVal = configStr + ' '+dateVal + ' by 10 AM';
        return etrVal;
    }
    // Common ETR method
    @AuraEnabled
    public static string getCommonOutageETR(String caseCategory, String incidentRecId){
        String result = '';
        String amPmValue = 'AM';
        try {
            if('NOS'.equalsIgnoreCase(caseCategory) && incidentRecId != null){
                Incident inc = [select id, SPEN_EstimatedRestorationTime__c  from Incident where Id = :incidentRecId];
               String estTime = (inc.SPEN_EstimatedRestorationTime__c != null)? (inc.SPEN_EstimatedRestorationTime__c.format('HH:mm:ss')): '';
               String hh = estTime.substring(0,2);
               if(Integer.valueOf(hh) > 12){
                amPmValue = 'PM';
                    hh = String.valueOf(Integer.valueOf(hh) - 12);
                    if(hh.length() == 1){
                        hh = '0'+hh;
                    }
               }

               //result =  'Today by '+ hh+':'+estTime.substring(3,5)+' '+amPmValue;
               result =  date.valueOf(inc.SPEN_EstimatedRestorationTime__c).format() + ' By ' + hh+':'+estTime.substring(3,5)+' '+amPmValue;
                 ////system.debug('inside if block,k**********');
            }
            else{
                ////system.debug('inside else block,k**********');

                result = getOutageETR(caseCategory);
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}