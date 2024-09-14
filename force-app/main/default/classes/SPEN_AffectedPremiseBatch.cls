/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  
AUTHOR    : 
LIBRARY    :  Salesforce Enterprise Library (SEL) 
VERSION    :  1.0

HISTORY    :
Date      Author        Comment
NOV-23-2022      Initial version
-----------------------------------------------------------------------------------------*/
global with sharing class SPEN_AffectedPremiseBatch implements Database.Batchable<sObject>,Database.Stateful
{
    Map<String,String> premiseNumberMap = new Map<String,String>();
    List<String> pNumberList = new List<String>();
    Incident prmIncId;
    String xrtNewVal;
	Integer totalChunkCount;			   //Added for code correction of Restored/Not Restored Count									
	Integer currentChunkCount;			   //Added for code correction of Restored/Not Restored Count
	
    List<SPEN_ImpactedPremise__c> listOfImpactedPremiseCreation = new List<SPEN_ImpactedPremise__c>();
    Map<Id,Integer> ActiveCountMap = New Map<Id,Integer>();
    Map<Id,Integer> RestoredCountMap = New Map<Id,Integer>();
    public SPEN_AffectedPremiseBatch(Map<String,String> pMap, List<String> premiseNumberList, incident incdntID, String xrtNew,Integer chunkCount,Integer currentChunk)     //Added 2 more parameters for Count Correction
    {
        premiseNumberMap = pMap;
        pNumberList = premiseNumberList;
        prmIncId=incdntID;
        xrtNewVal=xrtNew; 
		totalChunkCount = chunkCount;               //Added for code correction of Restored/Not Restored Count
        currentChunkCount = currentChunk;           //Added for code correction of Restored/Not Restored Count					  
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        ////system.debug('premiseNumberMap ----- >'+ premiseNumberMap);
        ////system.debug('pNumberList ----- >'+ pNumberList);
        
        return Database.getQueryLocator([Select id,SPEN_PremiseId__c from SPEN_Premise__c where SPEN_PremiseId__c =: pNumberList]);
    }
    
    global void execute(Database.BatchableContext bc, List<SPEN_Premise__c> spenPremiseList)
    {
        set<id> Premidset = new set<id>();
        Map<String,String> premisePSRMap = new Map<String,String>();
        map<string,SPEN_ContactPremise__c> ContactPremiseMap = New map<string,SPEN_ContactPremise__c>();
        
        for(SPEN_Premise__c spn : spenPremiseList){
            Premidset.add(spn.id);
        }
        for(SPEN_ContactPremise__c spn : [Select Id,SPEN_Premise__c,SPEN_Premise__r.SPEN_PremiseId__c,SPEN_RelatedContact__c from SPEN_ContactPremise__c where SPEN_Premise__c IN:Premidset and SPEN_Role__c = 'Customer']){
            ContactPremiseMap.put(spn.SPEN_Premise__r.SPEN_PremiseId__c,spn);
        }
        // Currently not sure as to use the SPEN_Current__c or not. Could be validated after full data load of ADQM
        // Have given order by so that first Specific Set fills and then other
        for(SPEN_PSR__c psrObj : [SELECT Id,SPEN_Current__c,SPEN_Premise__c,SPEN_SpecificVulnerability__c FROM SPEN_PSR__c WHERE SPEN_Premise__c IN:Premidset ORDER BY SPEN_SpecificVulnerability__c DESC]){
            if(psrObj.SPEN_SpecificVulnerability__c){
                premisePSRMap.put(psrObj.SPEN_Premise__c,'PSR');
            }
            else if(!premisePSRMap.containsKey(psrObj.SPEN_Premise__c)){
                premisePSRMap.put(psrObj.SPEN_Premise__c,'Other PSR');
            }
        }
        //Check if the current Incident is parent INC of any Merged INC
        List<String> ipLst = new List<String>();
        List<SPEN_ImpactedPremise__c> childIncIPLst = [SELECT Id,SPEN_PremiseId__c FROM SPEN_ImpactedPremise__c WHERE SPEN_RelatedIncident__r.ParentIncidentId =:prmIncId.ID];
        for(SPEN_ImpactedPremise__c ipObj : childIncIPLst){
            ipLst.add(String.valueOf(ipObj.SPEN_PremiseId__c));
        }
        Set<String> spIPLst = new Set<String>();
        Set<String> spCaseLst = new Set<String>();
        Set<String> spOrphanCaseLst = new Set<String>();
        Set<String> calledInLst = new Set<String>();
        SPEN_ConfigurableSettings__c caseOutcomeType =[SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='SPCaseOutcomeForMerge' Limit 1];
        List<String> caseOutcomeTypeList = new List<String>();
        if(caseOutcomeType != null){
            caseOutcomeTypeList = caseOutcomeType.SPEN_Value__c.split(',');
        }
        List<Case> spCaseList = [SELECT Id,SPEN_AddressPremise__c,ContactId,SPEN_AddressPremise__r.SPEN_PremiseID__c,SPEN_INCChangeTime__c,SPEN_Incident__r.SPEN_UpgradeDateTime__c,SPEN_IsMerge__c,SPEN_CaseCategoryOutcome__c FROM Case WHERE SPEN_Incident__c =:prmIncId.ID];
        for(Case caseObj:spCaseList){
            /*if(caseObj.SPEN_INCChangeTime__c < caseObj.SPEN_Incident__r.SPEN_UpgradeDateTime__c){
                spIPLst.add(caseObj.SPEN_AddressPremise__r.SPEN_PremiseID__c);
            }*/
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
        
        try{
            ////system.debug('spenPremiseList '+ spenPremiseList);
            for(Integer i = 0; i < spenPremiseList.size(); i++)
            {
                SPEN_ImpactedPremise__c impactedPremiseCreation = new SPEN_ImpactedPremise__c();
                impactedPremiseCreation.SPEN_IncidentId__c = prmIncId.SPEN_IncidentID__c != null ? prmIncId.SPEN_IncidentID__c : null ;
                impactedPremiseCreation.SPEN_RelatedIncident__c = prmIncId.ID != null ? prmIncId.ID : null ;
                impactedPremiseCreation.SPEN_ResourceID__c = prmIncId.SPEN_ResourceID__c != null ? prmIncId.SPEN_ResourceID__c : null ;
                impactedPremiseCreation.SPEN_ResourceArrivalDate__c = prmIncId.SPEN_ResourceArrivalDate__c != null ? prmIncId.SPEN_ResourceArrivalDate__c : null ;
                impactedPremiseCreation.SPEN_Estimated_Restoration_Time__c = prmIncId.SPEN_EstimatedRestorationTime__c != null ? prmIncId.SPEN_EstimatedRestorationTime__c : null;
                impactedPremiseCreation.SPEN_ContactPremise__c = ContactPremiseMap.containskey(spenPremiseList[i].SPEN_PremiseId__c) ? ContactPremiseMap.get(spenPremiseList[i].SPEN_PremiseId__c).id: null;
                //impactedPremiseCreation.SPEN_PremiseId__c = premiseNumberMap.get(pNumberList[i]);
                impactedPremiseCreation.SPEN_PremiseId__c = spenPremiseList[i].SPEN_PremiseId__c;
                impactedPremiseCreation.SPEN_ExternalId__c = spenPremiseList[i].SPEN_PremiseId__c+prmIncId.ID;
                impactedPremiseCreation.SPEN_PSRType__c = premisePSRMap.containsKey(spenPremiseList[i].Id)?premisePSRMap.get(spenPremiseList[i].Id):'No PSR';
                impactedPremiseCreation.SPEN_IncidentType__c = prmIncId.SPEN_IncidentType__c != null ? prmIncId.SPEN_IncidentType__c : 'HV_S' ;
                impactedPremiseCreation.SPEN_Dispatched_Date__c = prmIncId.SPEN_DispatchedDate__c != null ? prmIncId.SPEN_DispatchedDate__c : null ;
                if(prmIncId.SPEN_isUpgrade__c){
                    impactedPremiseCreation.SPEN_isMerged__c = (spIPLst !=null && spIPLst.contains(spenPremiseList[i].SPEN_PremiseId__c)) ? true:false;
                }
                else if((!spCaseLst.isEmpty() && spCaseLst.contains(spenPremiseList[i].SPEN_PremiseId__c)) || (!spOrphanCaseLst.isEmpty() && spOrphanCaseLst.contains(spenPremiseList[i].SPEN_PremiseId__c))){
                    impactedPremiseCreation.SPEN_isMerged__c = true;
                }
                else{
                    impactedPremiseCreation.SPEN_isMerged__c = (ipLst !=null && ipLst.contains(spenPremiseList[i].SPEN_PremiseId__c)) ? true:false;
                }
                impactedPremiseCreation.SPEN_isCalledIn__c = (calledInLst !=null && calledInLst.contains(spenPremiseList[i].SPEN_PremiseId__c)) ? true:false;
                
                
                If (prmIncId.SPEN_ResourceID__c != null)
                    impactedPremiseCreation.SPEN_PreviousStatus__c = 'Resource Dispatched';
                else if(prmIncId.SPEN_ResourceArrivalDate__c !=null)
                    impactedPremiseCreation.SPEN_PreviousStatus__c = 'Resource Arrived On Site';
                else if(prmIncId.SPEN_EstimatedRestorationTime__c != null)
                    impactedPremiseCreation.SPEN_PreviousStatus__c = 'INCD Extended';
                if(premiseNumberMap.get(spenPremiseList[i].SPEN_PremiseId__c) == 'DE')
                {
                    impactedPremiseCreation.SPEN_Status__c = 'Not Restored';
                    if(impactedPremiseCreation.SPEN_PreviousStatus__c == null){
                        impactedPremiseCreation.SPEN_PreviousStatus__c = 'INCD Created';
                    }
                }
                else if(premiseNumberMap.get(spenPremiseList[i].SPEN_PremiseId__c) == 'EN')
                {
                    impactedPremiseCreation.SPEN_Status__c = 'Restored';
                    if(impactedPremiseCreation.SPEN_PreviousStatus__c == null){
                        impactedPremiseCreation.SPEN_PreviousStatus__c = 'INCD Restored';
                    }
                }
                listOfImpactedPremiseCreation.add(impactedPremiseCreation);
            }
            
            ////system.debug('listOfImpactedPremiseCreation '+ listOfImpactedPremiseCreation);
            if(listOfImpactedPremiseCreation.size()>0)
            {
                Upsert listOfImpactedPremiseCreation SPEN_ExternalId__c;  
            }
             
        }
		catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
            throw ex;
        }    
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        //Added for code correction of Restored/Not Restored Count
        integer restoredCount;
        integer notRestoredCount;

        if((currentChunkCount + 1) == totalChunkCount)      
        {
            List<SPEN_ImpactedPremise__c> impacPremiseRecRestored = [Select Id, SPEN_Status__c,SPEN_RelatedIncident__c from SPEN_ImpactedPremise__c where SPEN_PremiseId__c!=null AND SPEN_RelatedIncident__c=:prmIncId.ID AND SPEN_Status__c='Restored'];
            List<SPEN_ImpactedPremise__c> impacPremiseRecNotRestored = [Select Id, SPEN_Status__c,SPEN_RelatedIncident__c from SPEN_ImpactedPremise__c where SPEN_PremiseId__c!=null AND SPEN_RelatedIncident__c=:prmIncId.ID AND SPEN_Status__c='Not Restored'];

            IF(impacPremiseRecRestored!=null)
            {
                restoredCount = impacPremiseRecRestored.size();
            }
            IF(impacPremiseRecNotRestored!=null)
            {
                notRestoredCount = impacPremiseRecNotRestored.size();
            }
        }
        //Added for code correction of Restored/Not Restored Count till above line
		
		
		/*Commented for code correction of Restored/Not Restored Count
        List<SPEN_ImpactedPremise__c> impacPremise = [Select Id, SPEN_Status__c,SPEN_RelatedIncident__c from SPEN_ImpactedPremise__c where SPEN_PremiseId__c!=null AND SPEN_RelatedIncident__c=:prmIncId.ID];    
        for(SPEN_ImpactedPremise__c s: impacPremise)
        {
            if(s.SPEN_Status__c == 'Restored')
            {
                if(RestoredCountMap.containsKey(s.SPEN_RelatedIncident__c)){
                    integer count = RestoredCountMap.get(s.SPEN_RelatedIncident__c);
                    RestoredCountMap.put(s.SPEN_RelatedIncident__c,count + 1);
                }else{
                    RestoredCountMap.put(s.SPEN_RelatedIncident__c,1);
                }
                
            }
            else if(s.SPEN_Status__c == 'Not Restored')
            {
                if(ActiveCountMap.containsKey(s.SPEN_RelatedIncident__c))
                    integer count = ActiveCountMap.get(s.SPEN_RelatedIncident__c);
                    ActiveCountMap.put(s.SPEN_RelatedIncident__c,count + 1); 
                }
				else
                    ActiveCountMap.put(s.SPEN_RelatedIncident__c,1);
                }
            }
        }
        */
		
        //has to update integration request record as complete
        List<SPEN_IntegrationRequest__c> intgReqToUpdateList = [Select id,SPEN_Status__c,SPEN_Records__c from SPEN_IntegrationRequest__c where  SPEN_IntegrationRequestServiceClass__c ='SPEN_GetAffectedPremiseService' AND SPEN_RelatedRecord__c=:prmIncId.SPEN_IncidentID__c AND SPEN_Status__c='Processing' LIMIT 1];
        ////system.debug('intgReqToUpdateList--->>'+intgReqToUpdateList);
        ////system.debug('prmIncId--->>'+prmIncId);
            if(!intgReqToUpdateList.isEmpty() && prmIncId.SPEN_IncidentID__c !=null){
                intgReqToUpdateList[0].SPEN_Status__c = 'Completed';
                update intgReqToUpdateList[0]; 
            }
        
        
        
        //has to update respective incident record status as merged
        /* Commented to merge with below query because of 2 updates on same object [was hitting Queueable limit of 1 because of 2 after updates]
        Incident incToUpdate = [Select id,SPEN_IncidentStatus__c,SPEN_EstimatedRestorationTime__c from Incident where SPEN_IncidentId__c =: prmIncId.SPEN_IncidentID__c and ParentIncidentId != null limit 1];
																		
        incToUpdate.SPEN_IncidentStatus__c = 'Merged';
        update incToUpdate;   
        */
        
        //Incident inc = [Select id,SPEN_ActiveNumberofCustomers__c,SPEN_RestoredNumberofCustomer__c,SPEN_EstimatedRestorationTime__c,SPEN_TotalNumberofXRTChanges__c from Incident where SPEN_IncidentId__c =: prmIncId.SPEN_IncidentID__c limit 1];
		
     	Incident inc = [Select id,SPEN_IncidentStatus__c,ParentIncidentId,SPEN_ActiveNumberofCustomers__c,SPEN_RestoredNumberofCustomer__c,SPEN_EstimatedRestorationTime__c,SPEN_TotalNumberofXRTChanges__c from Incident where SPEN_IncidentId__c =: prmIncId.SPEN_IncidentID__c limit 1];
        if(xrtNewVal !=null){
            SPEN_IncidentHistory__c incHis = new SPEN_IncidentHistory__c();
            //incHis.SPEN_Field__c=String.valueOf(incToUpdate.SPEN_EstimatedRestorationTime__c);
            //incHis.SPEN_OldValue__c=String.valueOf(incToUpdate.SPEN_EstimatedRestorationTime__c);
            incHis.SPEN_Field__c=String.valueOf(inc.SPEN_EstimatedRestorationTime__c);
            incHis.SPEN_OldValue__c=String.valueOf(inc.SPEN_EstimatedRestorationTime__c);
            incHis.SPEN_NewValue__c=xrtNewVal;
			
			//Commented for code correction of Restored/Not Restored Count
			/*			
            incHis.SPEN_RestoredNumberofCustomer__c = RestoredCountMap.containskey(prmIncId.Id) ? string.valueof(RestoredCountMap.get(prmIncId.Id)) : null;
            incHis.SPEN_ActiveNumberofCustomers__c = ActiveCountMap.containskey(prmIncId.id) ? string.valueof(ActiveCountMap.get(prmIncId.id)) : null;
			*/
			
            //Added for code correction of Restored/Not Restored Count
            incHis.SPEN_RestoredNumberofCustomer__c = restoredCount!=null ? string.valueof(restoredCount) :null;
            incHis.SPEN_ActiveNumberofCustomers__c = notRestoredCount!=null ? string.valueof(notRestoredCount) :null;
            //Added for code correction of Restored/Not Restored Count till above line
			
            incHis.SPEN_IncidentId__c = prmIncId.Id;
            upsert incHis;
                
            ////system.debug('incHis--->>'+incHis);
        
			//Commented for code correction of Restored/Not Restored Count
			/*			
            inc.SPEN_ActiveNumberofCustomers__c = ActiveCountMap.containskey(inc.id) ? string.valueof(ActiveCountMap.get(inc.id)) : null;
            inc.SPEN_RestoredNumberofCustomer__c = RestoredCountMap.containskey(inc.id) ? String.valueOf(RestoredCountMap.get(inc.Id)) : null;
			*/

            //Added for code correction of Restored/Not Restored Count
            inc.SPEN_ActiveNumberofCustomers__c = notRestoredCount!=null ? string.valueof(notRestoredCount) :null;
            inc.SPEN_RestoredNumberofCustomer__c = restoredCount!=null ? string.valueof(restoredCount) :null;
            //Added for code correction of Restored/Not Restored Count till above line
			
            ////system.debug('-----inc.SPEN_EstimatedRestorationTime__c--------'+inc.SPEN_EstimatedRestorationTime__c);
            ////system.debug('-----xrtNewVal-------'+xrtNewVal);
            ////system.debug('-----conversion-------'+Datetime.valueOfGmt(xrtNewVal.replace('T', ' ')));
			
            if(inc.SPEN_EstimatedRestorationTime__c != Datetime.valueOfGmt(xrtNewVal.replace('T', ' ')))
            {
                //inc.SPEN_EstimatedRestorationTime__c = Datetime.valueOfGmt(xrtNewVal.replace('T', ' '));
                inc.SPEN_TotalNumberofXRTChanges__c = inc.SPEN_TotalNumberofXRTChanges__c != null ? inc.SPEN_TotalNumberofXRTChanges__c + 1:1;
            }
        
            update inc;
            ////system.debug('inc--->>'+inc);
        }
    }
}