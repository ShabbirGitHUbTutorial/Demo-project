public class SPEN_JourneySLAUtils {
	
    public static Map<String,Id> businessHoursMap; //BusinessHours Map
    public static Set<String> emergencyTypes = new Set<String>{'Emergency','Urgent','Immediate'}; //Emergency Notice Types
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    Public static Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
    Public static Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
    
    /*
     * This method called from Queable apex
     * Input parameters Set<Id> caseIds
     * Return type Map<Id,DateTime> caseId & Due Date 
    */    
    public static Map<Id,DateTime> getCaseSLADueDate(Set<Id> caseIds)
    {
        Map<Id,DateTime> caseIdDueDateMap = new Map<Id,DateTime>();
        Map<String,SPEN_Case_SLA__mdt> caseSLAMetadataMap = new Map<String,SPEN_Case_SLA__mdt>();
        Set<String> businessHours = new Set<String>();
        
        //Prepare Map of all metadata entries which will be used in further logic
        for(SPEN_Case_SLA__mdt caseSLARec: [Select Id,
                                            SPEN_BusinessHours__c,SPEN_ClockEndTime__c,SPEN_ClockStartTime__c,
                                            SPEN_Excavation_Required__c,SPEN_Notice_Type__c,Number_of_Days__c,
                                            SPEN_NumberofHours__c,SPEN_QueryType__c,SPEN_RecordType__c,
                                            SPEN_Sensitivity__c,SPEN_SLA__c,SPEN_SPD_SPM__c,SPEN_WorkItemRouting__c
                                            FROM SPEN_Case_SLA__mdt])
        {
            businessHours.add(caseSLARec.SPEN_BusinessHours__c);
            String key = '';
            if(caseSLARec.SPEN_RecordType__c == 'SPEN_Streetworks')
            {
                key = caseSLARec.SPEN_RecordType__c + + '|'+caseSLARec.SPEN_SPD_SPM__c + '|' + caseSLARec.SPEN_Notice_Type__c + '|'+ caseSLARec.SPEN_Excavation_Required__c + '|' + caseSLARec.SPEN_Sensitivity__c; 
            }
            else if(caseSLARec.SPEN_RecordType__c == 'SPEN_NRSWA')
            {
                key = caseSLARec.SPEN_RecordType__c + + '|'+caseSLARec.SPEN_SPD_SPM__c + '|' + caseSLARec.SPEN_Notice_Type__c;
            }
            else if(caseSLARec.SPEN_RecordType__c == 'SPEN_Query')
            {
                key = caseSLARec.SPEN_RecordType__c + + '|'+caseSLARec.SPEN_SPD_SPM__c + '|' + caseSLARec.SPEN_QueryType__c + '|' + caseSLARec.SPEN_WorkItemRouting__c;
            }
            
            //if(!string.IsEmpty(key))
            caseSLAMetadataMap.put(key,caseSLARec);
        }
        businessHoursMap = new Map<String,Id>();
        //preare map of BusinessHours Name vs ID map
        if(!businessHours.isEmpty())
        {
            for(BusinessHours bHour: [Select Name,Id 
                                     FROM BusinessHours
                                     Where Name IN: businessHours])
            {
                businessHoursMap.put(bHour.Name,bHour.Id);
            }
        }
        /*Prepare Case Map where key will be combination of
         * fields and which will be similar to key from Metadata entries
        */
        Map<String,Case> caseKeyMap = new Map<String,Case>();
        for(Case caseRec: [Select Id,Recordtypeid,RecordType.DeveloperName,SPEN_SLADueDate__c,CreatedDate,SPEN_QueryReopenedDate__c,//CRMD-9531 SPEN_QueryReopenedDate__c added
                           SPEN_SPDSPMIndicator__c,SPEN_SPD_SPM__c,//bug
                           SPEN_NoticeType__c,SPEN_ExcavationRequired__c,
                           SPEN_Sensitivity__c,SPEN_Type__c,SPEN_Email_WI_Queue_Routing_Outcome__c,
                           SPEN_ProposedStartDate__c,SPEN_EarlyStartDate__c
                           FROM Case
                          WHERE ID IN: caseIds])
        {
            //IF SW case then key would be like this:
            String key = '';
            if(caseRec.RecordType.DeveloperName == 'SPEN_NRSWA')
            {
                key = caseRec.RecordType.DeveloperName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c;
            }
            else if(caseRec.RecordType.DeveloperName == 'SPEN_Streetworks')
            {
                key = caseRec.RecordType.DeveloperName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+caseRec.SPEN_ExcavationRequired__c+'|'+caseRec.SPEN_Sensitivity__c;

            }else if(caseRec.RecordType.DeveloperName == 'SPEN_Query')
            {
                key = caseRec.RecordType.DeveloperName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_Type__c+'|'+ caseRec.SPEN_Email_WI_Queue_Routing_Outcome__c;
            }
            caseKeyMap.put(key,caseRec);
        }
        caseIdDueDateMap = caseSLACalculations(caseKeyMap,caseSLAMetadataMap,businessHoursMap);
        return caseIdDueDateMap;
    }
    
    public static Map<Id,DateTIme> caseSLACalculations(Map<String,Case> caseMap, Map<String,SPEN_Case_SLA__mdt> caseSLAMap, Map<String,Id> bHourMap)
    {
        Map<Id,DateTIme> caseDueDateMap = new Map<Id,DateTIme>();
        String newKey;//new design
        for(String caseKey : caseMap.keySet())
        {
            Case caseRec = new Case();
            caseRec = caseMap.get(caseKey);
            SPEN_Case_SLA__mdt slaMetadataEntry = new SPEN_Case_SLA__mdt();
            slaMetadataEntry = caseSLAMap.get(caseKey);
            Datetime slaBaseLineDate;
//new design - start
            if(slaMetadataEntry == NULL)//if no exact match with Case and Metadata
            {
                if(caseRec.RecordType.DeveloperName == 'SPEN_Streetworks')
                {
                    //check 1
                    newkey = caseRec.RecordType.DeveloperName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+caseRec.SPEN_ExcavationRequired__c+'|'+null;
                    slaMetadataEntry = caseSLAMap.get(newkey); 
                    if(slaMetadataEntry == NULL)
                    {
                         //check 2
                       newkey = caseRec.RecordType.DeveloperName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+null+'|'+caseRec.SPEN_Sensitivity__c;
                        slaMetadataEntry = caseSLAMap.get(newkey); 
                        if(slaMetadataEntry == NULL)
                        {
                             //check 3
                            newkey = caseRec.RecordType.DeveloperName+'|'+caseRec.SPEN_SPDSPMIndicator__c+'|'+caseRec.SPEN_NoticeType__c+ '|'+null+'|'+null;
                            slaMetadataEntry = caseSLAMap.get(newkey); 
                        }
                    }
                }
                
            }
            //new design - end
            if(caseRec.RecordType.DeveloperName == 'SPEN_NRSWA' || caseRec.RecordType.DeveloperName == 'SPEN_Query')
            {
                //CRMD-9531 - Start
                if(caseRec.RecordType.DeveloperName == 'SPEN_Query' && 
                   caseRec.SPEN_QueryReopenedDate__c!= NULL && 
                   caseRec.SPEN_QueryReopenedDate__c > caseRec.CreatedDate)
                {
                    slaBaseLineDate = caseRec.SPEN_QueryReopenedDate__c;
                } //CRMD-9531 - END
                else 
                {
                    slaBaseLineDate =  caseRec.CreatedDate;
                }
              
               //slaBaseLineDate = DateTime.newInstance(2023,10,30,9,29,0);
            }
            else if(caseRec.RecordType.DeveloperName == 'SPEN_Streetworks')
            {
                if(!emergencyTypes.contains(caseRec.SPEN_NoticeType__c))
                {
                    if(caseRec.SPEN_EarlyStartDate__c != null)
                    {
                        slaBaseLineDate = caseRec.SPEN_EarlyStartDate__c;
                        
                    }
                    else{
                        slaBaseLineDate = caseRec.SPEN_ProposedStartDate__c;
                    }
                }
                else{
                   slaBaseLineDate = caseRec.CreatedDate;
                   //slaBaseLineDate = DateTime.newInstance(2023,10,20, 15,30,0);
                }
                
            }
            // weekend check
     
          
            //bug end 
            if(slaMetadataEntry != null) // null pointer check added - new design
            {
                slaBaseLineDate = checkForWeekend(slaBaseLineDate,slaMetadataEntry);
                caseDueDateMap.put(caseRec.Id,getSLACaseDueDate(slaBaseLineDate,slaMetadataEntry,bHourMap.get(slaMetadataEntry.SPEN_BusinessHours__c),caseRec));
            }
            system.debug('----caseDueDateMap----'+caseDueDateMap);
        }
        return caseDueDateMap;
    }
    public static DateTime checkForWeekend(Datetime slaBaseLineDate, SPEN_Case_SLA__mdt slaMetadataEntry)
    {
        
            if( slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Streetworks'){
			if(slaMetadataEntry.SPEN_SPD_SPM__c == 'SPD' || slaMetadataEntry.SPEN_SPD_SPM__c == 'SPM'){
                while(slaBaseLineDate.format('E') == 'Sat' )
                {
                    slaBaseLineDate = slaBaseLineDate.addDays(-1);
                }
                while(slaBaseLineDate.format('E') == 'Sun')
                {
                    slaBaseLineDate = slaBaseLineDate.addDays(-2);
                }
				}
            }
             else{ //NR
			 if(slaMetadataEntry.SPEN_SPD_SPM__c == 'SPD'){
                while(slaBaseLineDate.format('E') == 'Sat' )
                {
                    Time startTimeForDay = Time.newInstance(8,0,0,0);
           		    slaBaseLineDate = DateTime.newInstance(slaBaseLineDate.date().addDays(2),startTimeForDay);
                }
                while(slaBaseLineDate.format('E') == 'Sun')
                {
                    Time startTimeForDay = Time.newInstance(8,0,0,0);
           		    slaBaseLineDate = DateTime.newInstance(slaBaseLineDate.date().addDays(1),startTimeForDay);
                }
				}
            }
        
        return slaBaseLineDate;
    }
    
    // Common SLA method from which other sub-methods are called
    public static DateTime getSLACaseDueDate(DateTime baseLineDate, SPEN_Case_SLA__mdt slaMetadataEntry, Id bHourId, Case caseRec)
    {
        DateTime dueDate;
        Long expectedThreshold; 
        system.debug('baseLineDate ::' + baseLineDate + ' slaMetadataEntry::' + slaMetadataEntry);
        Boolean isSWNonEmergencyType = false;
        //emergencyTypes.addAll('Emergency','Urgent','Immediate');
        //baseLineDate = system.now().addHours(6); // added only for testing purpose
        if(slaMetadataEntry.SPEN_RecordType__c == 'SPEN_NRSWA')
        {
            baseLineDate = getnrswaspmBaseLineAdjustments(baseLineDate,slaMetadataEntry);
            expectedThreshold = getSLAThreshold(slaMetadataEntry,true);
        }
        else if(slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Streetworks')
        {
            if(!emergencyTypes.contains(slaMetadataEntry.SPEN_Notice_Type__c))
            {
                expectedThreshold = -(getSLAThreshold(slaMetadataEntry,false));
                isSWNonEmergencyType = true;
            }
            //Emergency SLA calculations
            else{
                expectedThreshold = getSLAThreshold(slaMetadataEntry,true);
            }

        }else if(slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Query'){
            if(!slaMetadataEntry.SPEN_WorkItemRouting__c.equals('72 Hr SLA South') && !slaMetadataEntry.SPEN_WorkItemRouting__c.equals('72 Hr SLA North'))
                expectedThreshold = getSLAThreshold(slaMetadataEntry,true);
            //else
                //expectedThreshold = getSLAThreshold(slaMetadataEntry,false);
        }
if(slaMetadataEntry.SPEN_WorkItemRouting__c != null 
           && (slaMetadataEntry.SPEN_WorkItemRouting__c.equals('72 Hr SLA South') 
           || slaMetadataEntry.SPEN_WorkItemRouting__c.equals('72 Hr SLA North')))
        {
             Time startTimeForDay = Time.newInstance(baseLineDate.hour(), baseLineDate.minute(), baseLineDate.second(),0);
             dueDate = DateTime.newInstance(baseLineDate.date().addDays(3),startTimeForDay);
        }else{
        dueDate = BusinessHours.addGMT(bHourId,baseLineDate,expectedThreshold);
}
        	
        system.debug('dueDate >>'+ dueDate);
        
        // SW SPM start - roll over scenario
        Time endTimeForDay = Time.newInstance(Integer.ValueOf(slaMetadataEntry.SPEN_ClockEndTime__c.split(',')[0]),Integer.ValueOf(slaMetadataEntry.SPEN_ClockEndTime__c.split(',')[1]),0,0);
        if(((baseLineDate > DateTime.newInstance(baseLineDate.date(),endTimeForDay))
           && ((slaMetadataEntry.SPEN_SPD_SPM__c == 'SPM' || caseRec.SPEN_SPDSPMIndicator__c == 'SPM'))
           && slaMetadataEntry.SPEN_NumberofHours__c != null ))
        {
                Time startTimeForDay = Time.newInstance(Integer.ValueOf(slaMetadataEntry.SPEN_ClockStartTime__c.split(',')[0]),Integer.ValueOf(slaMetadataEntry.SPEN_ClockStartTime__c.split(',')[1]),0,0);
             	if(//(slaMetadataEntry.SPEN_Type__c == 'SPEN_Streetworks') && 
                    slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Query' && slaMetadataEntry.SPEN_WorkItemRouting__c.equals('30 Min SLA South'))
                    dueDate = DateTime.newInstance(baseLineDate.date().addDays(1),startTimeForDay).addMinutes(30);
            //sla prod  bug - start
              else if(slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Query')
              {
                  
                   dueDate = DateTime.newInstance(baseLineDate.date().addDays(1),startTimeForDay).addHours(Integer.valueOf(slaMetadataEntry.SPEN_NumberofHours__c));
					if(dueDate.format('E') == 'Sat' )
                  {
                      Time startTimeForDay1 = Time.newInstance(8,0,0,0);
                      dueDate = DateTime.newInstance(dueDate.date().addDays(2),startTimeForDay1).addHours(Integer.valueOf(slaMetadataEntry.SPEN_NumberofHours__c));
                  }
                  if(dueDate.format('E') == 'Sun')
                  {
                      Time startTimeForDay3 = Time.newInstance(8,0,0,0);
                      dueDate = DateTime.newInstance(dueDate.date().addDays(1),startTimeForDay3).addHours(Integer.valueOf(slaMetadataEntry.SPEN_NumberofHours__c));
                  }
              } 
            //sla prod  bug - end
        }
        //SW SPM - end
        if(isSWNonEmergencyType)
        {
            dueDate =  getSWRegularDueDate(dueDate,slaMetadataEntry,caseRec.CreatedDate);
            //dueDate =  getSWRegularDueDate(dueDate,slaMetadataEntry,DateTime.newInstance(2023,10,17, 15,59,0));
            
        }
      
        return dueDate;
    }
    
    //SW specific method which handles logic of resetting Due Date based on scenarios
    public static DateTime getSWRegularDueDate(DateTime dueDate,SPEN_Case_SLA__mdt slaMetadataEntry, DateTime casecreatedDate)
    {
        String swRegularBusinessHour = 'SPD SW/NRSWA Business Hours';// 4hour SLA we have to consider standard SW Business hours only
        DateTime swRegularFinalDueDate;
        Time endTimeForDay = Time.newInstance(Integer.ValueOf(slaMetadataEntry.SPEN_ClockEndTime__c.split(',')[0]),Integer.ValueOf(slaMetadataEntry.SPEN_ClockEndTime__c.split(',')[1]),0,0);
        //if dueDate is in Future
        if(Date.ValueOf(dueDate) > system.today())
        {
            swRegularFinalDueDate = DateTime.newInstanceGMT(Date.ValueOf(dueDate).addDays(-1),endTimeForDay); 
        //Check Weekend
            swRegularFinalDueDate = checkForWeekend(swRegularFinalDueDate, slaMetadataEntry);
            /*if(slaMetadataEntry.SPEN_SPD_SPM__c == 'SPD')
            {
                while(swRegularFinalDueDate.format('E') == 'Sat' )
                {
                    swRegularFinalDueDate = swRegularFinalDueDate.addDays(-1);
                }
                while(swRegularFinalDueDate.format('E') == 'Sun')
                {
                    swRegularFinalDueDate = swRegularFinalDueDate.addDays(-2);
                }
            }*/
             
        }
        else
        {
            Long regularSWSLA = (4*86400000)/24; //4 hour SLA
            swRegularFinalDueDate = BusinessHours.addGMT(businessHoursMap.get(swRegularBusinessHour),casecreatedDate,regularSWSLA);
        }
        return swRegularFinalDueDate;
    }
    
    //This will be generic method which will give you threshold value based on specified days/hours value
    public static Long getSLAThreshold(SPEN_Case_SLA__mdt slaMetadataEntry, boolean isHourCal)
    {
        Long thresholdVar;
        Decimal hourVal = slaMetadataEntry.SPEN_NumberofHours__c;
        //hour calculations
        if(isHourCal)
        {
            thresholdVar = ((slaMetadataEntry.SPEN_NumberofHours__c) * 86400000).LongValue()/24;
        }
        //Day calculations
        else{
            //thresholdVar =  (86400000 * slaMetadataEntry.Number_of_Days__c).LongValue();
            if(slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Query' )
      			thresholdVar =  (86400000 * (slaMetadataEntry.Number_of_Days__c)).LongValue();
            else if(slaMetadataEntry.SPEN_BusinessHours__c == 'Default' && slaMetadataEntry.SPEN_RecordType__c == 'SPEN_Streetworks')
                
      			thresholdVar =  (86400000 * (slaMetadataEntry.Number_of_Days__c-1)).LongValue(); 
            else
            thresholdVar =  (28800000 * (slaMetadataEntry.Number_of_Days__c-1)).LongValue();
        }
        return thresholdVar; 
    }
    
    //Method for NRSWA SPM adjustments where roll-over scenario is involved
    public static DateTime getnrswaspmBaseLineAdjustments(DateTime baseLineDate, SPEN_Case_SLA__mdt slaMetadataEntry)
    {
        if(slaMetadataEntry.SPEN_SPD_SPM__c == 'SPM')
        {
            Time endTimeForDay = Time.newInstance(Integer.ValueOf(slaMetadataEntry.SPEN_ClockEndTime__c.split(',')[0]),Integer.ValueOf(slaMetadataEntry.SPEN_ClockEndTime__c.split(',')[1]),0,0);
            Time startTimeForDay = Time.newInstance(Integer.ValueOf(slaMetadataEntry.SPEN_ClockStartTime__c.split(',')[0]),Integer.ValueOf(slaMetadataEntry.SPEN_ClockStartTime__c.split(',')[1]),0,0);
            DateTime expetedEndDateTime = DateTime.newInstance(Date.valueOf(baseLineDate),endTimeForDay);
            if(baseLineDate > expetedEndDateTime)
            {
                baseLineDate = DateTime.newInstance(Date.ValueOf(baseLineDate).addDays(1),startTimeForDay); 
            }
        }
        return baseLineDate;
    }
    
}