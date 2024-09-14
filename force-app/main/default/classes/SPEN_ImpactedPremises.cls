public class SPEN_ImpactedPremises { 
    //commented the below code since the mentioned class in line 5 is itself not in org so giving errors.
    SPEN_OutboundDiallersServiceImpl incc = new SPEN_OutboundDiallersServiceImpl();
    public static Map<String,Incident> incidentMap=new Map<String,Incident>();
    public static Set<String> incidentIds = new Set<String>();
    public  void onAfterInsert(List<SPEN_ImpactedPremise__c> implist){
        incc.updateOutboundDiallerPriority(implist, null);
    }

    public  void onAfterUpdate(List<SPEN_ImpactedPremise__c> implist,Map<Id, SPEN_ImpactedPremise__c> impmap){ 
        incc.updateOutboundDiallerPriority(implist, impmap);
    }
    public  void onBeforeInsert(List<SPEN_ImpactedPremise__c> implist){
        try{
            Set<String> premiseIds = new Set<String>();
            for(SPEN_ImpactedPremise__c ipObj: implist){
                incidentIds.add(ipObj.SPEN_IncidentId__c);
                premiseIds.add(ipObj.SPEN_PremiseId__c);
                if(ipObj.SPEN_isMerged__c){
                    ipObj.SPEN_MergeDateTime__c=System.now();
                }
            }
            List<String> caseOutcomeTypeList = getcaseOutcomeTypeList();
            List<String> ipLst = getChildImpactedPremiseList(incidentIds);
            incidentMap = getIncidentMap(incidentIds);
            Map<String,SPEN_ContactPremise__c> contactPremiseMap =getContactPremiseMap(premiseIds);
            Set<String> spIPLst = new Set<String>();
            Set<String> spCaseLst = new Set<String>();
            Set<String> spOrphanCaseLst = new Set<String>();
            Set<String> calledInLst = new Set<String>();
            for(Case caseObj:SPEN_CaseSelector.getCaseFromIncidentids(incidentIds)){
                if(caseObj.SPEN_Incident__r.SPEN_UpgradeDateTime__c != null){
                    spIPLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
                }
                if(caseObj.SPEN_IsMerge__c){
                    spCaseLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
                }
                if(!caseOutcomeTypeList.isEmpty() && caseOutcomeTypeList.contains(String.ValueOf(caseObj.SPEN_CaseCategoryOutcome__c))){
                    spOrphanCaseLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
                }
                calledInLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
            }
            
            for(SPEN_ImpactedPremise__c ipObj: implist){
                //Incident field mapping
                if(!incidentMap.IsEmpty() && incidentMap.containsKey(ipObj.SPEN_IncidentId__c)){
                    ipObj.SPEN_RelatedIncident__c = incidentMap.get(ipObj.SPEN_IncidentId__c).Id;
                    ipObj.SPEN_ResourceID__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceID__c;
                    ipObj.SPEN_ResourceArrivalDate__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceArrivalDate__c;
                    ipObj.SPEN_IncidentType__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_IncidentType__c != null ? incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_IncidentType__c : 'HV_S' ;
                    ipObj.SPEN_Dispatched_Date__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_DispatchedDate__c;
					if (incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceID__c != null){
                        ipObj.SPEN_PreviousStatus__c = 'Resource Dispatched';
                    }
                    else if(incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceArrivalDate__c !=null){
                        ipObj.SPEN_PreviousStatus__c = 'Resource Arrived On Site';
                    }
                    else if(incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_EstimatedRestorationTime__c != null){
                        ipObj.SPEN_PreviousStatus__c = 'INCD Extended';
                    }else{
                        ipObj.SPEN_PreviousStatus__c = ipObj.SPEN_Status__c == 'Not Restored'?'INCD Created':ipObj.SPEN_Status__c == 'Restored'?'INCD Restored':null;
                    }
                    if(incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_isUpgrade__c){
                        ipObj.SPEN_isMerged__c = (spIPLst !=null && spIPLst.contains(ipObj.SPEN_PremiseId__c)) ? true:false;
                    }
                    else if((!spCaseLst.isEmpty() && spCaseLst.contains(ipObj.SPEN_PremiseId__c)) || (!spOrphanCaseLst.isEmpty() && spOrphanCaseLst.contains(ipObj.SPEN_PremiseId__c))){
                        ipObj.SPEN_isMerged__c = true;
                    }
                    else{
                        ipObj.SPEN_isMerged__c = (ipLst !=null && ipLst.contains(ipObj.SPEN_PremiseId__c)) ? true:false;
                    }
                    ipObj.SPEN_isCalledIn__c = (calledInLst !=null && calledInLst.contains(ipObj.SPEN_PremiseId__c)) ? true:false;
                }
                //
                //Contact Premise related field mappings
                if(!contactPremiseMap.IsEmpty() && contactPremiseMap.containsKey(ipObj.SPEN_PremiseId__c)){
                    ipObj.SPEN_ContactPremise__c = contactPremiseMap.get(ipObj.SPEN_PremiseId__c).Id;
                    ipObj.SPEN_PSRType__c = contactPremiseMap.get(ipObj.SPEN_PremiseId__c).SPEN_RelatedContact__r.SPEN_PSR__c ? (contactPremiseMap.get(ipObj.SPEN_PremiseId__c).SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c ? 'PSR' : 'Other PSR') : 'No PSR';
                }
            }
        }catch(Exception ex){
           SEL_LoggingService.log(ex);
        }
    }

    public  void onBeforeUpdate(List<SPEN_ImpactedPremise__c> implist,Map<Id, SPEN_ImpactedPremise__c> impmap){ 
        
        for(SPEN_ImpactedPremise__c ipObj: implist){
            if(ipObj.SPEN_Estimated_Restoration_Time__c != ((SPEN_ImpactedPremise__c)impmap.get(ipObj.Id)).SPEN_Estimated_Restoration_Time__c){
                ipObj.SPEN_IsETRChange__c=true;
                ipObj.SPEN_ETRChangeTime__c=System.now();
            }
            if(ipObj.SPEN_isMerged__c != ((SPEN_ImpactedPremise__c)impmap.get(ipObj.Id)).SPEN_isMerged__c && ipObj.SPEN_isMerged__c){
                ipObj.SPEN_MergeDateTime__c=System.now();
            }
            else if(ipObj.SPEN_MergeDateTime__c!=null && !ipObj.SPEN_isMerged__c){
                ipObj.SPEN_MergeDateTime__c=null;
            }
        }
        try{
            Set<String> premiseIds = new Set<String>();
            for(SPEN_ImpactedPremise__c ipObj: implist){
                incidentIds.add(ipObj.SPEN_IncidentId__c);
                premiseIds.add(ipObj.SPEN_PremiseId__c);
                if(ipObj.SPEN_isMerged__c){
                    ipObj.SPEN_MergeDateTime__c=System.now();
                }
            }
            List<String> caseOutcomeTypeList = getcaseOutcomeTypeList();
            List<String> ipLst = getChildImpactedPremiseList(incidentIds);
            incidentMap = getIncidentMap(incidentIds);
            Map<String,SPEN_ContactPremise__c> contactPremiseMap =getContactPremiseMap(premiseIds);
            Set<String> spIPLst = new Set<String>();
            Set<String> spCaseLst = new Set<String>();
            Set<String> spOrphanCaseLst = new Set<String>();
            Set<String> calledInLst = new Set<String>();
            for(Case caseObj:SPEN_CaseSelector.getCaseFromIncidentids(incidentIds)){
                if(caseObj.SPEN_Incident__r.SPEN_UpgradeDateTime__c != null){
                    spIPLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
                }
                if(caseObj.SPEN_IsMerge__c){
                    spCaseLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
                }
                if(!caseOutcomeTypeList.isEmpty() && caseOutcomeTypeList.contains(String.ValueOf(caseObj.SPEN_CaseCategoryOutcome__c))){
                   spOrphanCaseLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
                }
                calledInLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
            }
            for(SPEN_ImpactedPremise__c ipObj: implist){
                //Incident field mapping
                if(!incidentMap.IsEmpty() && incidentMap.containsKey(ipObj.SPEN_IncidentId__c)){
                    ipObj.SPEN_ResourceID__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceID__c;
                    ipObj.SPEN_ResourceArrivalDate__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceArrivalDate__c;
                    ipObj.SPEN_IncidentType__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_IncidentType__c != null ? incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_IncidentType__c : 'HV_S' ;
                    ipObj.SPEN_Dispatched_Date__c = incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_DispatchedDate__c;
                    if (incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceID__c != null){
                        ipObj.SPEN_PreviousStatus__c = 'Resource Dispatched';
                    }
                    else if(incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_ResourceArrivalDate__c !=null){
                        ipObj.SPEN_PreviousStatus__c = 'Resource Arrived On Site';
                    }
                    else if(incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_EstimatedRestorationTime__c != null){
                        ipObj.SPEN_PreviousStatus__c = 'INCD Extended';
                    }else{
                        ipObj.SPEN_PreviousStatus__c = ipObj.SPEN_Status__c == 'Not Restored'?'INCD Created':ipObj.SPEN_Status__c == 'Restored'?'INCD Restored':null;
                    }
                    if(incidentMap.get(ipObj.SPEN_IncidentId__c).SPEN_isUpgrade__c){
                        ipObj.SPEN_isMerged__c = (spIPLst !=null && spIPLst.contains(ipObj.SPEN_PremiseId__c)) ? true:false;
                    }
                    else if((!spCaseLst.isEmpty() && spCaseLst.contains(ipObj.SPEN_PremiseId__c)) || (!spOrphanCaseLst.isEmpty() && spOrphanCaseLst.contains(ipObj.SPEN_PremiseId__c))){
                        ipObj.SPEN_isMerged__c = true;
                    }
                    else{
                        ipObj.SPEN_isMerged__c = (ipLst !=null && ipLst.contains(ipObj.SPEN_PremiseId__c)) ? true:false;
                    }
                    ipObj.SPEN_isCalledIn__c = (calledInLst !=null && calledInLst.contains(ipObj.SPEN_PremiseId__c)) ? true:false;
                }
                //
                //Contact Premise related field mappings
                if(!contactPremiseMap.IsEmpty() && contactPremiseMap.containsKey(ipObj.SPEN_PremiseId__c)){
                    ipObj.SPEN_ContactPremise__c = contactPremiseMap.get(ipObj.SPEN_PremiseId__c).Id;
                    ipObj.SPEN_PSRType__c = contactPremiseMap.get(ipObj.SPEN_PremiseId__c).SPEN_RelatedContact__r.SPEN_PSR__c ? (contactPremiseMap.get(ipObj.SPEN_PremiseId__c).SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c ? 'PSR' : 'Other PSR') : 'No PSR';
                }
            }
        }catch(Exception ex){
           SEL_LoggingService.log(ex);
        }
    }
   
    public static Boolean checkBlackoutWindowPeriod(String typeCheck){
        Boolean result = false;
        Id recTypeIdOfBlackoutWindowRT = Schema.SObjectType.SPEN_IVROperatingHours__c.getRecordTypeInfosByName().get(typeCheck).getRecordTypeId();
       
        List<SPEN_IVROperatingHours__c> lstIvrHour = [select Id, Name,SPEN_StartTime__c,SPEN_EndTime__c, RecordTypeId from  SPEN_IVROperatingHours__c where RecordTypeId = :recTypeIdOfBlackoutWindowRT and SPEN_isActive__c = true WITH SECURITY_ENFORCED limit 1]; 
        
        if(!lstIvrHour.isEmpty() && lstIvrHour[0] != null){
            if(lstIvrHour[0].SPEN_StartTime__c == null && lstIvrHour[0].SPEN_EndTime__c == null){
                result = true;
            }
            else if((lstIvrHour[0].SPEN_StartTime__c < lstIvrHour[0].SPEN_EndTime__c) && ((System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() < lstIvrHour[0].SPEN_EndTime__c) || (System.now().time() > lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c))){
             
                 result = true;
             }
             else if((lstIvrHour[0].SPEN_StartTime__c > lstIvrHour[0].SPEN_EndTime__c) && (System.now().time() < lstIvrHour[0].SPEN_StartTime__c && System.now().time() > lstIvrHour[0].SPEN_EndTime__c)){
                 result = true;
             }
            
        }
        return result;
    }
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 1122/2023
    @purpose: Method for getting case OutcomeType List from ConfigurationSetting metadata
    ***************************************************************/ 
    private static List<String> getcaseOutcomeTypeList(){
        List<String> caseOutcomeTypeList = new List<String>();
        try{
            SPEN_ConfigurableSettings__c caseOutcomeType =SEL_ConfigurationSettingSelector.getETRConfig('SPCaseOutcomeForMerge');
            if(caseOutcomeType != null){
                caseOutcomeTypeList = caseOutcomeType.SPEN_Value__c.split(',');
            }
        }catch(Exception ex){
           SEL_LoggingService.log(ex);
        }
        return caseOutcomeTypeList;
    }
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method for getting child premises for incidnet
    ***************************************************************/ 
    private static List<String> getChildImpactedPremiseList(Set<String> incidentIds){
        List<String> ipLst = new List<String>();
        for(SPEN_ImpactedPremise__c childIpObj : [SELECT Id,SPEN_PremiseId__c FROM SPEN_ImpactedPremise__c WHERE SPEN_RelatedIncident__r.ParentIncidentId IN:incidentIds]){
            ipLst.add(String.valueOf(childIpObj.SPEN_PremiseId__c));
        }
		return ipLst;
    }
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method for getting related incident
    ***************************************************************/ 
    private static Map<String,Incident> getIncidentMap(Set<String> incidentIds){
        Map<String,Incident> incidentMap1 = new Map<String,Incident>();
        for(Incident incRec: SPEN_IncidentSelector.getIncidentInformationfromIncidentids(incidentIds)){
            incidentMap1.put(incRec.SPEN_IncidentID__c,incRec);
        }
        return incidentMap1;
    }
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method for getting contact premise for associated premises
    ***************************************************************/ 
    private static Map<String,SPEN_ContactPremise__c> getContactPremiseMap(Set<String> premiseIds){
        Map<String,SPEN_ContactPremise__c> contactPremiseMap = new Map<String,SPEN_ContactPremise__c>();
        for(SPEN_ContactPremise__c conPremise:SPEN_ContactPremisesSelector.getConPremiseRecordsFromPremiseIds(premiseIds) ){
            contactPremiseMap.put(conPremise.SPEN_Premise__r.SPEN_PremiseId__c,conPremise);
        }
        return contactPremiseMap;
    }    
}