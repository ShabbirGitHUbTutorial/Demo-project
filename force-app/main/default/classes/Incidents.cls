/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        07/10/2022
* @Description: Handler class is on IncidentTrigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
 
***********************************************************************************************/
public with sharing class Incidents {
    IncidentService inc = new IncidentService();
    public static Boolean isRecordViewdValue = false;
    public void onBeforeInsert(List<Incident> incidentList)
    {
        if(Trigger.isInsert && Trigger.isBefore){
            IncidentService.assignHVIncidentMsg(incidentList,new Map<Id, Incident>());
            IncidentService.beforeEventZone(incidentList);
        }
    }
	public void onBeforeUpdateIVRMsg(List<Incident> incidentList, Map<Id, Incident> incidentOldMap)
	{
		if(Trigger.isUpdate && Trigger.isBefore){
			
			IncidentService.assignHVIncidentMsg(incidentList,incidentOldMap);
            
            
		}
	}
    public void onBeforeUpdate(List<Incident> incdntListToCheckStatus, Map<Id, Incident> incidentOldMap)
    {
        Set<Id> ivrMessageIds = new Set<Id>();
        if(Trigger.isUpdate && Trigger.isBefore){
            if(!isRecordViewdValue ){
                isRecordViewdValue = true;
                inc.compareStatusOfIncident(incdntListToCheckStatus);
            }
            
            for(Incident incRec : incdntListToCheckStatus){
                if(incRec.SPEN_IVRMessages__c != incidentOldMap.get(incRec.Id).SPEN_IVRMessages__c && incRec.SPEN_IVRMessages__c != NULL){
                    ivrMessageIds.add(incRec.SPEN_IVRMessages__c);
                }
                // Start changes for CRMD-5044 for outage state as restored to store the SPEN_OutageStateDateTime__c value when SPEN_Outage_State__c has the value 'Restored'.
                if((incidentOldMap.get(incRec.Id).SPEN_Outage_State__c != incRec.SPEN_Outage_State__c) && 'Restored'.equalsIgnoreCase(incRec.SPEN_Outage_State__c)){
                    incRec.SPEN_OutageStateDateTime__c = System.now(); 
                }
                //End changes for CRMD-5044.
               // Start CRMD-8670 cr-17 story changes
                //CRMD-9208: Added one more OR Partially Restoredcondition in if statement
                if('Confirmed'.equalsIgnoreCase(incRec.SPEN_Outage_State__c) || 'Partially Confirmed'.equalsIgnoreCase(incRec.SPEN_Outage_State__c) || 'Partially Restored'.equalsIgnoreCase(incRec.SPEN_Outage_State__c)){
                    incRec.SPEN_has_confirmed_Outage_State_Reached__c = true;
                } 
                if(incRec.SPEN_EstimatedRestorationTime__c!=incidentOldMap.get(incRec.Id).SPEN_EstimatedRestorationTime__c){
                    incRec.SPEN_TotalNumberofXRTChanges__c=incRec.SPEN_TotalNumberofXRTChanges__c==null?1:incRec.SPEN_TotalNumberofXRTChanges__c+1;
                }  
                             	
                // End CRMD-8670 cr-17 story changes
            //Start SFAMS-664 implementation
             if((incRec.SPEN_Outage_State__c != incidentOldMap.get(incRec.Id).SPEN_Outage_State__c) && ('Confirmed'.equalsIgnoreCase(incRec.SPEN_Outage_State__c) || 'Partially Confirmed'.equalsIgnoreCase(incRec.SPEN_Outage_State__c))){
                 incRec.SPEN_ConfirmedPartiallyConfirmedTime__c = System.now();
             }

            //End SFAMS-664 implementation
                incETRChange(incRec,incidentOldMap);
            }
            List<Id> ivrMsgIds = new List<Id>(ivrMessageIds);
            Map<ID, SPEN_IVRMessage__c> ivrMessageMap = SPEN_IVRMessageSelector.getIVRMessageMap(ivrMsgIds);
            
            incIVRMap(ivrMessageMap,incdntListToCheckStatus);
        }
    }
    //Added on 26/12/2022 
    //Method added for the ETR value to get updated on case
    public void onAfterUpdateETRValueInCases(List<Incident> incdntList, Map<Id, Incident> incidentOldMap)
    {
        if(Trigger.isUpdate && Trigger.isAfter){
            List<Case> relCaseInfo1 = new List<Case>();
            
            // Code with respect to IncidentService class
            //Getting and populating the metadata values in Map
        List<SPEN_Incident_to_case_status_mapping__mdt> incToCaseLst = [SELECT SPEN_IncidentStatus__c,SPEN_CaseStatus__c FROM SPEN_Incident_to_case_status_mapping__mdt];
        Map<String,String> incCaseMap = new Map<String,String>();
        Id recordTypeIdUnplannedFault = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_UnplannedFault).getRecordTypeId();
        Id recordTypeIdCNT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.cntRecordType).getRecordTypeId();
       
        for(SPEN_Incident_to_case_status_mapping__mdt mdtRec : incToCaseLst){
            incCaseMap.put(mdtRec.SPEN_IncidentStatus__c,mdtRec.SPEN_CaseStatus__c);
        }
        Map<String,List<Case>> incCaseListMap = new Map<String,List<Case>>();
        for(Case relatedCase:[SELECT Id, SPEN_Incident__c, SPEN_ETROutage__c, CaseNumber, OwnerId, Status,SPEN_Incident__r.SPEN_IncidentStatus__c,recordTypeId 
                        FROM Case 
                        WHERE SPEN_Incident__c IN: incidentOldMap.keyset() WITH SECURITY_ENFORCED]){
                List<Case> caselist=new List<Case>();
               if(incCaseListMap.containsKey(relatedCase.SPEN_Incident__c))  {
                    caselist.addAll(incCaseListMap.get(relatedCase.SPEN_Incident__c));
               }
               caseList.add(relatedCase);
               incCaseListMap.put(relatedCase.SPEN_Incident__c,caseList);          
        }

		for(Incident incRec : incdntList){
            
                List<Case> relCaseInfo = new List<Case>();
            
                //add one more condition at below if check to enter in the same block on incident's status change ie. either ERT should be changed on Incident or the status should be changed on Incident : To enter in the block.
                if(!incCaseListMap.isEmpty() && incCaseListMap.containsKey(incRec.id)){
                    relCaseInfo = incCaseListMap.get(incRec.id);
                }
                if ((incRec.SPEN_ETA__c!=incidentOldMap.get(incRec.Id).SPEN_EstimatedRestorationTime__c && incRec.SPEN_EstimatedRestorationTime__c!=NULL) || (incRec.SPEN_IncidentStatus__c != incidentOldMap.get(incRec.Id).SPEN_IncidentStatus__c)){
                
                    for(Case c : relCaseInfo){
                        if(c.Status!='Closed' || c.Status!='Cancelled'){
                            c.SPEN_ETROutage__c = (incRec.SPEN_EstimatedRestorationTime__c !=null ) ? (incRec.SPEN_EstimatedRestorationTime__c).format('yyyy-MM-dd HH:mm:ss'):(String.valueOf(incRec.SPEN_EstimatedRestorationTime__c));
                    	   
                        }
                        //Added condition to check the Status changes took place for incident, the same should be stamped on its related cases.
                        if(incCaseMap.containsKey(c.SPEN_Incident__r.SPEN_IncidentStatus__c) && c.Status != incCaseMap.get(c.SPEN_Incident__r.SPEN_IncidentStatus__c) && c.recordTypeId == recordTypeIdUnplannedFault){
                            c.Status = incCaseMap.get(c.SPEN_Incident__r.SPEN_IncidentStatus__c);
                        }
                        if(c.recordTypeId != recordTypeIdCNT){
                             relCaseInfo1.add(c);  
                        }
                       
                    }
                }
            }
           if(System.IsBatch() == false && Schema.sObjectType.Case.isUpdateable()){
           
              Cases.isIncidetSyncFlag = true;
                if(!relCaseInfo1.isEmpty() && relCaseInfo1.size() <= Integer.valueOf(Label.SPEN_CaseProcessingLimit)){
                    update relCaseInfo1;
                }
               //INC3001686_Fixed : MASS CASE UPDATE FIXED
                else if(!relCaseInfo1.isEmpty() && relCaseInfo1.size() > Integer.valueOf(Label.SPEN_CaseProcessingLimit)){
                    Map<Id, Case> mapOfIdVsCases = new Map<Id, Case>(relCaseInfo1);
               		  Database.executeBatch(new SPEN_CaseStatusUpdateBatch(mapOfIdVsCases),Integer.valueOf(Label.SPEN_CaseBatchSizeLimit));
                }

            }
        }
    }
    public void onAfterUpdate(Map<Id,Incident> incidentOldMap, List<Incident> incdntList)
    {
        if(Trigger.isUpdate && Trigger.isAfter){
           
            IncidentService.afterIncidentUpdate(incidentOldMap, incdntList);
            IncidentService.updateOutageFlagOnMessagingTask(incdntList);
        }
    }      
    public static List<Case> caseClosedStatus(List<Case> caseValues, Incident incValue){
        List<Case> relCaseValues = new List<Case>();
        for(Case c : caseValues){
            if(c.Status!='Closed' || c.Status!='Cancelled'){
                c.SPEN_ETROutage__c = (incValue.SPEN_EstimatedRestorationTime__c !=null ) ? (incValue.SPEN_EstimatedRestorationTime__c).format('yyyy-MM-dd HH:mm:ss'):(String.valueOf(incValue.SPEN_EstimatedRestorationTime__c));
                    relCaseValues.add(c);  
            }
        }
        return relCaseValues;
    }
    private static void incETRChange(Incident inc1, Map<ID,Incident> incOld ){
        if(inc1.SPEN_IncidentType__c != incOld.get(inc1.Id).SPEN_IncidentType__c){
            inc1.SPEN_isUpgrade__c = true;
            inc1.SPEN_UpgradeDateTime__c = System.now();
            inc1.SPEN_ETRChangeTime__c = null;
        }
        else if(inc1.SPEN_EstimatedRestorationTime__c != incOld.get(inc1.Id).SPEN_EstimatedRestorationTime__c && incOld.get(inc1.Id).SPEN_EstimatedRestorationTime__c != null){
            inc1.SPEN_ETRChangeTime__c = System.now();
        }
        if((inc1.SPEN_droppedsupply__c != incOld.get(inc1.Id).SPEN_droppedsupply__c && inc1.SPEN_droppedsupply__c) || (inc1.SPEN_DroppedSupplyWithoutNotice__c != incOld.get(inc1.Id).SPEN_DroppedSupplyWithoutNotice__c && inc1.SPEN_DroppedSupplyWithoutNotice__c))
        {
            inc1.SPEN_ETRChangeTime__c = null;
        }
    }
    private static void incIVRMap(Map<ID, SPEN_IVRMessage__c> incMap, List<Incident> incList){
        for(Incident incRec : incList){
            if(!incMap.IsEmpty() && incMap.containsKey(incRec.SPEN_IVRMessages__c)){
                incRec.SPEN_IVRTemplateBody__c = incMap.get(incRec.SPEN_IVRMessages__c).SPEN_IVRMessage__c;
            }
        }
    }
    public void create3PDCase(Map<Id, Incident> incidentNewMap, Map<Id, Incident> incidentOldMap)
    {
        //Check for existing 3PD case
        Case new3PDCase;
        List<Case> listNew3PDCase = new List<Case>();
        Map<Id,Incident> map3PDIncident = new Map<Id,Incident>();
        Map<Id,Case> mapIncident2Case = new Map<Id,Case>();
        Set<String> setSubCategory = new set<String>(system.label.SPEN_IncidentSubcategoryValues.split(';'));
        Id recordtypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
        for(Incident inc: incidentNewMap.values())
        {
            if(inc.SubCategory != null && inc.SubCategory != incidentOldMap.get(inc.id).SubCategory && 
            setSubCategory.contains(inc.SubCategory))
            {
                map3PDIncident.put(inc.id,inc);
            }
        }
        if(!map3PDIncident.isEmpty())
        {
            List<Case> lst3PDCases = SPEN_CaseSelector.get3PDCaseFromIncident(map3PDIncident.keySet());
            if(!lst3PDCases.isEmpty())
            {
                for(Case caseObj: lst3PDCases)
                {
                    mapIncident2Case.put(caseObj.SPEN_Incident__c,caseObj);
                }
            }
           
            
            for(Incident inc: map3PDIncident.values())
            {
                if(lst3PDCases.isEmpty() || (!mapIncident2Case.isEmpty() && !mapIncident2Case.keySet().contains(inc.id)))
                {
                    new3PDCase = new Case();
                    new3PDCase.recordtypeId = recordtypeId3PD;
                    new3PDCase.SPEN_Incident__c = inc.id;
                    new3PDCase.Origin = 'PowerOn'; //CRMD-9523
                    listNew3PDCase.add(new3PDCase);
                }
            }
          
            if(!listNew3PDCase.isEmpty())
            {
                insert listNew3PDCase;
            }
        }
        
    }
    
    public static void createNRSWACase(Map<String,String> incRefIncCoordMap,Map<String,DateTime> incRefIncActualTimeMap) 
    {
        if(!incRefIncCoordMap.isEmpty())
        {
            Id recordtypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
            Id recordtypeIdNRSWASiteDetails= Schema.SObjectType.SPEN_SiteDetails__c.getRecordTypeInfosByDeveloperName().get('NRSWA').getRecordTypeId();
            String recordtypeNameNRSWA = 'SPEN_NRSWA';

            List<Incident> incList = new List<Incident>();
            List<Case> caseListToUpdate = new List<Case>();
            List<SPEN_SiteDetails__c> siteDetailsListToInsert  = new List<SPEN_SiteDetails__c>();
            
            List<Incident> inc = IncidentSelector.getIncidentFromRefWithNRSWACase(incRefIncCoordMap);
                
            if(!inc.isEmpty())
            {
                for(Incident i: inc)
                {
                    List<Case> cseList = i.Cases__r;
                    
                 /*   Incident incd = new Incident();
                    incd.Id = i.Id;
                    incd.SPEN_NumberOfNRSWACoordinates__c = i.SPEN_NumberOfNRSWACoordinates__c != null? i.SPEN_NumberOfNRSWACoordinates__c + 1 : 1;
                    incList.add(incd); */
                    
                    /*if(cseList.isEmpty())
                    {*/
                        Case caseToUpdate = new Case();
                        caseToUpdate.SPEN_Incident__c = i.Id;
                        caseToUpdate.Status = CasesConstants.nrswaReviewStatus; //NRSWA Review
                        caseToUpdate.RecordTypeId = recordtypeIdNRSWA;
                        caseToUpdate.Origin = CasesConstants.poweronOrigin; //PowerOn
                        caseToUpdate.SPEN_NRSWAExternalID__c = recordtypeNameNRSWA+'-'+i.SPEN_IncidentReference__c;
                        //CRMD-7609 START
                        if(i.SPEN_SPDSPM__c == 'SPM')
                        {
                        	caseToUpdate.SPEN_NoticeType__c = 'Immediate';
                        }
                        else if(i.SPEN_SPDSPM__c == 'SPD')
                        {
                        	caseToUpdate.SPEN_NoticeType__c = 'Emergency';
                        }
                        //CRMD-7609 END
                        caseListToUpdate.add(caseToUpdate);
                    /*}
                    else
                    {*/
                       /* for(Case c : cseList)
                        {
                            SPEN_SiteDetails__c sd = new SPEN_SiteDetails__c();
                            sd.SPEN_Case__c = c.id;
                            sd.SPEN_Status__c = CasesConstants.openStatus; //Open
                            sd.SPEN_Coords__c = incRefIncCoordMap.get(i.SPEN_IncidentReference__c);
                            sd.RecordTypeId = recordtypeIdNRSWASiteDetails;
                            sd.SPEN_ActualTime__c = incRefIncActualTimeMap.get(i.SPEN_IncidentReference__c);//9429
                            if(incd.SPEN_NumberOfNRSWACoordinates__c>1){
                            	sd.SPEN_PowerOn_Additional_Coordinates__c=true;
                            }
                            siteDetailsListToInsert.add(sd);
                        }*/
                }
                
                
               /* if(!incList.isEmpty())
                {
                    upsert incList;
                } */
                if(!caseListToUpdate.isEmpty())
                {
                    upsert caseListToUpdate SPEN_NRSWAExternalID__c;
                }
                
                
                if(!caseListToUpdate.isEmpty())
                {
                    for(Incident i: inc)
                    {
                        for(Case c : caseListToUpdate)
                        {
                            SPEN_SiteDetails__c sd = new SPEN_SiteDetails__c();
                            sd.SPEN_Case__c = c.id;
                            sd.SPEN_Status__c = 'Open';
                            sd.SPEN_Coords__c = incRefIncCoordMap.get(i.SPEN_IncidentReference__c);
                            sd.RecordTypeId = recordtypeIdNRSWASiteDetails;
                            sd.SPEN_ActualTime__c = incRefIncActualTimeMap.get(i.SPEN_IncidentReference__c);//9429
                            siteDetailsListToInsert.add(sd);
                        }
                    }
                }
                if(!siteDetailsListToInsert.isEmpty())
                {
                    insert siteDetailsListToInsert;
                }
            }
    	}
    }
}