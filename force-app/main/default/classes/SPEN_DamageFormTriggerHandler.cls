/***************************************************************************
* @Author:      Asmita Rajput
* @Date:        28/08/2023
* @UserStory:   CRMD-6787, 776
* @Description: 
*****************************************************************************/
 
public class SPEN_DamageFormTriggerHandler {
    Public static Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    Public static Id caseInfoRecordTypeId = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_3PDDamageForm').getRecordTypeId();
    
    //Create Case Information record
    public static List<SPEN_CaseInformation__c> createCaseInfo(Map<Id,SPEN_DamageFormStaging__c> mapCaseId2Form)
    {   List<SPEN_CaseInformation__c> listOfCaseInfo = new List<SPEN_CaseInformation__c>();
        for(Id caseId: mapCaseId2Form.keySet())
        {
            sObject damageFromSobj = (sObject)mapCaseId2Form.get(caseId);
            
            sObject caseInfo = ((SObject)Type.forName('SPEN_CaseInformation__c').newInstance()).getSObjectType().newSObject();            
            caseInfo.put('recordtypeid', caseInfoRecordTypeId);
            caseInfo.put('SPEN_Case__c',caseId);
            String equipDamaged;
            equipDamaged = damageFromSobj.get('SPEN_Category__c') != null ? String.valueOf(damageFromSobj.get('SPEN_Category__c')): '';
            equipDamaged = damageFromSobj.get('SPEN_VoltageType__c') !=null ? equipDamaged + ' '+ damageFromSobj.get('SPEN_VoltageType__c'): equipDamaged;
            equipDamaged = damageFromSobj.get('SPEN_LVList__c') != null ? equipDamaged + ' ' + damageFromSobj.get('SPEN_LVList__c'): equipDamaged;
			equipDamaged = damageFromSobj.get('SPEN_HVList__c') != null ? equipDamaged + ' ' + damageFromSobj.get('SPEN_HVList__c'): equipDamaged;
            equipDamaged = damageFromSobj.get('SPEN_WhathasbeenDamaged__c') != null ? equipDamaged + ' ' + damageFromSobj.get('SPEN_WhathasbeenDamaged__c'): equipDamaged;
			caseInfo.put('SPEN_EquipmentDamaged__c',equipDamaged);
            //caseInfo.put('SPEN_EquipmentDamaged__c',damageFromSobj.get('SPEN_Category__c')+''+damageFromSobj.get('SPEN_VoltageType__c')+''+damageFromSobj.get('SPEN_LVList__c')+''+damageFromSobj.get('SPEN_HVList__c')+''+damageFromSobj.get('SPEN_WhathasbeenDamaged__c'));
            
            String folderSharepointUrl;
            if(damageFromSobj.get('SPEN_Incident_Number__c')!=null){
                String baseURL=System.Label.SPEN_FolderSharePointURL;
                folderSharepointUrl=baseURL+damageFromSobj.get('SPEN_Incident_Number__c');
                caseInfo.put('SPEN_FolderSharepointURL__c',folderSharepointUrl);
            } 
            
            List<Case_Information_Field_Mapping__mdt> caseInfoMdtList = Case_Information_Field_Mapping__mdt.getAll().values();
            for(Case_Information_Field_Mapping__mdt mdt: caseInfoMdtList)
            {
                caseInfo.put(mdt.Case_Information_Field__c,damageFromSobj.get(mdt.Damage_Form_Field__c));
            }
            listOfCaseInfo.add((SPEN_CaseInformation__c)caseInfo);
        }
        return listOfCaseInfo;
    }
    public static Boolean checkLastUpdateCondition(Datetime formDate, Datetime incidentLMD, DateTime incidentCD)
    {
        Boolean flag = false;
        Integer diff =(Date.valueOf(incidentLMD)).daysBetween(Date.valueOf(formDate));
        if(formDate >= incidentCD && diff <=2) // SFAMS-642: Removing the diff >=0 && added the formDate >= incidentCD
        {
            flag = true;
        }
        return flag;
    }
    public static void create3PDCase(List<SPEN_DamageFormStaging__c> listDamageForm){
        String incidentFuzzyRegex = System.Label.SPEN_IncidentReferenceNumberFuzzyRegex;
        String incidentFuzzyRegex2 = System.Label.SPEN_IncidentReferenceNumberFuzzyRegex2;
        String incidentFuzzyRegex3 = System.Label.SPEN_IncidentReferenceNumberFuzzyRegex3;
        Set<String> setMatchingInc = new Set<String>();
        Set<Id> setCaseIncidentId = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        List<Case> listNew3PDCase = new List<Case>();
        List<Case> listMatch3PDCase = new List<Case>();
        Set<String> zoneSet = new Set<String>();
        Map<String,SPEN_Zone__c> zoneMap = new Map<String,SPEN_Zone__c>();
        List<SPEN_CaseInformation__c> listCaseInfoInsert = new List<SPEN_CaseInformation__c>();
        Map<String,Incident> mapIncdRef2Inc = new Map<String,Incident>();
        String incidentRef;
        List<SPEN_DamageFormStaging__c> listFormIncidentwith3PDCase = new List<SPEN_DamageFormStaging__c>();
        List<SPEN_DamageFormStaging__c> listFormIncidentWithout3PDCase = new List<SPEN_DamageFormStaging__c>();
        List<SPEN_DamageFormStaging__c> listFormwithoutIncident = new List<SPEN_DamageFormStaging__c>();
        List<Case> CaseList = new List<Case>();
        String TaskDescription = System.label.SPEN_MissingPhotos3PDTaskDescription;
        Boolean isTaskToBeCreated = false;
        List<Case> caseListForTaskCreation = new List<Case>();
		Boolean matchFound;
        Map<String,Case> mapIncdRef2Case = new Map<String,Case>();
        Map<Id,SPEN_DamageFormStaging__c> mapCaseId2Form = new Map<Id,SPEN_DamageFormStaging__c>();
        Case new3PDCase;
        for(SPEN_DamageFormStaging__c form: listDamageForm)
        {
            if(form.SPEN_Incident_Number__c != null)
            {
                incidentRef = findMatchingIncident(incidentFuzzyRegex3,form.SPEN_Incident_Number__c);
                if(incidentRef != null)
                {
                    setMatchingInc.add(form.SPEN_Incident_Number__c);   
                }
                else {
                    incidentRef = findMatchingIncident(incidentFuzzyRegex2,form.SPEN_Incident_Number__c);
                    if(incidentRef != NULL)
                    {
                        setMatchingInc.add(form.SPEN_Incident_Number__c);
                       
                    }else{
                                         
                        incidentRef = findMatchingIncident(incidentFuzzyRegex,form.SPEN_Incident_Number__c);
                        if(incidentRef != NULL)
                        {
                            setMatchingInc.add(form.SPEN_Incident_Number__c);
                        }
                    }
                }    
            }
        }
       
        if(!setMatchingInc.isEmpty())
        {
            listMatch3PDCase = SPEN_CaseSelector.get3PDCaseFromIncidentRef(setMatchingInc);
            for(Case cse: listMatch3PDCase)
            {
                //formula limit - START
               // mapIncdRef2Case.put(cse.SPEN_IncidentReferenceFormula__c,cse);
                mapIncdRef2Case.put(cse.SPEN_IncidentRefFormula__c ,cse);
                //formula limit - END
            }
            mapIncdRef2Inc = IncidentSelector.getIncidentFromRef(setMatchingInc);
        }
        for(SPEN_DamageFormStaging__c form: listDamageForm)
        {
            matchFound = false;
            if(!mapIncdRef2Inc.isEmpty())
            {
                for(String incdRef: mapIncdRef2Inc.KeySet())
                {
                    if(incdRef.containsIgnoreCase(form.SPEN_Incident_Number__c))
                    {
                        matchFound = true;
                        Incident inc = mapIncdRef2Inc.get(incdRef);
                        
                        if(form.SPEN_DateofIncident__c != null && form.SPEN_IsMigrated__c==false && checkLastUpdateCondition(form.SPEN_DateofIncident__c, inc.lastmodifiedDate, inc.createdDate) == false){
                            listFormwithoutIncident.add(form);
                        }else{
                            //3PD Case Present
                            if(mapIncdRef2Case.containsKey(inc.SPEN_IncidentReference__c)){
                                listFormIncidentwith3PDCase.add(form);
                            }
                            else {
                                //3PD Case not Present
                                listFormIncidentWithout3PDCase.add(form);
                            }
                        }
                    }
                }
                if(matchFound == false)
                {
                    listFormwithoutIncident.add(form);
                }
            }
            else{
                listFormwithoutIncident.add(form);
            }
        }
        
       
/********************* INCIDENT FOUND WITH 3PD CASE ************************/
        if(!listFormIncidentwith3PDCase.isEmpty())
        {
            listCaseInfoInsert =new List<SPEN_CaseInformation__c>();
            mapCaseId2Form = new Map<Id, SPEN_DamageFormStaging__c>();
            for(SPEN_DamageFormStaging__c form: listFormIncidentwith3PDCase)
            {
                for(Case cse: listMatch3PDCase)
                {
                    //formula limit -START
                   // if(cse.SPEN_IncidentReferenceFormula__c.containsIgnoreCase(form.SPEN_Incident_Number__c))
                    if(cse.SPEN_IncidentRefFormula__c.containsIgnoreCase(form.SPEN_Incident_Number__c))
                    
                    {
                        //Incident inc = mapIncdRef2Inc.get(cse.SPEN_IncidentReferenceFormula__c);
                        Incident inc = mapIncdRef2Inc.get(cse.SPEN_IncidentRefFormula__c);
                        //formula limit - END
                        form.SPEN_CaseNumber__c = cse.CaseNumber;
                        //Create case information Rec
                        mapCaseId2Form.put(cse.id,form);
                    }
                  
                  if(form.SPEN_Photos_Missing__c == True)
                    {
                       cse.Status = 'Missing  Photos';
                       caseList.add(cse);
                    }else{
                        cse.Status = '3PD Review';
                       caseList.add(cse);
                    }
                }
            }
            if(!mapCaseId2Form.isEmpty())
            {
                listCaseInfoInsert = createCaseInfo(mapCaseId2Form);
                SPEN_DamageFormTriggerHandler.createMaterialDetailsRecord(mapCaseId2Form);  ///AYUSH
            }
            if(!caseList.isEmpty())
            {
                update caseList;
                SPEN_TaskUtility.InsertTask(caseList,TaskDescription);
            }
            if(!listCaseInfoInsert.isEmpty())
            {
                insert listCaseInfoInsert;
            }
        }
/********** **********INCIDENT FOUND NO 3PD CASE *********************/
        if(!listFormIncidentWithout3PDCase.isEmpty())
        {
            listNew3PDCase = new List<Case>();
            listCaseInfoInsert = new List<SPEN_CaseInformation__c>();
            mapCaseId2Form = new Map<Id, SPEN_DamageFormStaging__c>();
            for(SPEN_DamageFormStaging__c form: listFormIncidentWithout3PDCase)
            {
                for(String incdRef: mapIncdRef2Inc.KeySet())
                {
                    if(incdRef.containsIgnoreCase(form.SPEN_Incident_Number__c))
                    {
                        Incident inc = mapIncdRef2Inc.get(incdRef);
                        new3PDCase = new Case();
                        new3PDCase.recordtypeId = recordtypeId3PD;
                        new3PDCase.SPEN_Incident__c = inc.id;
                        new3PDCase.Origin = 'Geofield'; //CRMD-9523
                        // CRMD-8201 - START
                        if(form.SPEN_isMigrated__c == true)
                        {
                            new3PDCase.SPEN_IsMigrated__c = true;
                        }
                        // CRMD-8201 - END
                        if(form.SPEN_Photos_Missing__c == TRUE)
                        {
                            new3PDCase.Status = 'Missing  Photos';
}else{
                       	 	 new3PDCase.Status = '3PD Review';
                        }
                        setCaseIncidentId.add(new3PDCase.SPEN_Incident__c);
                        listNew3PDCase.add(new3PDCase);
                    }
                }
            }
           if(!listNew3PDCase.isEmpty())
            {
                insert listNew3PDCase;
                List<Case> insertedCaseList = SPEN_CaseSelector.get3PDCaseFromIncident(setCaseIncidentId);
                for(SPEN_DamageFormStaging__c form: listFormIncidentWithout3PDCase)
                {
                    for(Case cse: insertedCaseList)
                    {
                        //formula limit - START
                        //if(cse.SPEN_IncidentReferenceFormula__c.containsIgnoreCase(form.SPEN_Incident_Number__c))
                        if(cse.SPEN_IncidentRefFormula__c.containsIgnoreCase(form.SPEN_Incident_Number__c))
                        {
                            //formula limit - END
                            form.SPEN_CaseNumber__c = cse.CaseNumber;
                            //Create case information Rec
                            mapCaseId2Form.put(cse.id,form);
                        }
                        if(cse.status == 'Missing  Photos')
                        {
                            caseListForTaskCreation.add(cse);                  
                        }
                    }
                }
                if(!mapCaseId2Form.isEmpty())
                {
                    listCaseInfoInsert = createCaseInfo(mapCaseId2Form);
                    SPEN_DamageFormTriggerHandler.createMaterialDetailsRecord(mapCaseId2Form);  ///AYUSH
                }
                if(!caseListForTaskCreation.isEmpty())
                {
                    SPEN_Taskutility.InsertTask(caseListForTaskCreation, TaskDescription);
                }
                if(!listCaseInfoInsert.isEmpty())
                {
                    insert listCaseInfoInsert;
                }
            }
        }

        /********** IF NO INCIDENT FOUND ***********/
        if(!listFormwithoutIncident.isEmpty()) {
            listNew3PDCase = new List<Case>();
            listCaseInfoInsert = new List<SPEN_CaseInformation__c>();
            mapCaseId2Form = new Map<Id, SPEN_DamageFormStaging__c>();
           for(SPEN_DamageFormStaging__c form: listFormwithoutIncident)
            {
                new3PDCase = new Case();
                new3PDCase.recordtypeId = recordtypeId3PD;
                new3PDCase.SPEN_DamageFormNumber__c = form.SPEN_Incident_Number__c;
                new3PDCase.SPEN_ConnectionDistrict__c = form.SPEN_District__c;
                new3PDCase.Origin = 'Geofield'; //CRMD-9523
                // CRMD-8201 - START
                if(form.SPEN_isMigrated__c == true)
                {
                    new3PDCase.SPEN_IsMigrated__c = true;
                }
                // CRMD-8201 - END
                if(form.SPEN_Photos_Missing__c == TRUE)
                {
                    new3PDCase.Status = 'Missing  Photos';
                }else{
                     new3PDCase.Status = '3PD Review';
                }
                listNew3PDCase.add(new3PDCase);
            }
            
            if(!listNew3PDCase.isEmpty())
            {
                insert listNew3PDCase;
               
                for(case cs: listNew3PDCase)
                {
                    setCaseId.add(cs.id);
                }
                List<Case> insertedCaseList = SPEN_CaseSelector.getCaseListFromId(setCaseId);
                for(SPEN_DamageFormStaging__c form: listFormwithoutIncident)
                {
                    for(Case cse: insertedCaseList)
                    {
                        if(cse.SPEN_DamageFormNumber__c ==form.SPEN_Incident_Number__c)
                        {
                            form.SPEN_CaseNumber__c = cse.CaseNumber;
                            //Create case information Rec
                            mapCaseId2Form.put(cse.id,form);
                        }
                        if(cse.status == 'Missing  Photos')
                        {
                            caseListForTaskCreation.add(cse);                  
                        }
                    }
                }
                if(!mapCaseId2Form.isEmpty())
                {
                    listCaseInfoInsert = createCaseInfo(mapCaseId2Form);
                    SPEN_DamageFormTriggerHandler.createMaterialDetailsRecord(mapCaseId2Form);  ///AYUSH
                }
                   
                if(!caseListForTaskCreation.isEmpty())
                {
                    SPEN_Taskutility.InsertTask(caseListForTaskCreation, TaskDescription);
                }
                if(!listCaseInfoInsert.isEmpty())
                {
                    insert listCaseInfoInsert;
                }
            }
        }
    }

    public static String findMatchingIncident(String exp,String field)
    {
        Pattern regexPattern;
        Matcher matcher;
        String str;
        if(exp != NULL)
        {
            regexPattern = Pattern.compile(exp);
            matcher = regexPattern.matcher(field);
            if(matcher.find())
            {
                str = matcher.group();
            }
        }
        return str;
    }

    public static void createMaterialDetailsRecord(Map<Id,SPEN_DamageFormStaging__c> mapCaseId2Form)
    {
        List<SPEN_MaterialDetails__c> materialDetailsList = new List<SPEN_MaterialDetails__c>();
        for(Id caseId: mapCaseId2Form.keySet())
        {
            SPEN_DamageFormStaging__c form = mapCaseId2Form.get(caseId);
            if(!String.isBlank(form.SPEN_MaterialDetails__c))
            {
            	Map<String, Object> parsedMap = (Map<String, Object>) JSON.deserializeUntyped(form.SPEN_MaterialDetails__c);
                
                // Access the "Materials" key to get the list of materials
                List<Object> materialsList = (List<Object>) parsedMap.get('Materials');
                
                // Iterate through the list of materials
                for (Object materialObj : materialsList)
                {
                    SPEN_MaterialDetails__c mD = new SPEN_MaterialDetails__c();
                    
                    Map<String, Object> materialMap = (Map<String, Object>) materialObj;
                
                    String jobCategory = (String) materialMap.get('3PDJobCategory');
                    String materialCategory = (String) materialMap.get('3PDMaterialCategory');
                    String materialName = (String) materialMap.get('3PDMaterial');
                    String quantity = (String) materialMap.get('3PDQuantity');
                
                    md.SPEN_Case__c = caseId;
                    md.SPEN_JobCategory__c = jobCategory;
                    md.SPEN_MaterialCategory__c = materialCategory;
                    md.SPEN_Material__c = materialName;
                    md.SPEN_Quantity__c = Decimal.valueof(quantity);
					materialDetailsList.add(md);
                }
            }
        }
        if(!materialDetailsList.isEmpty())
        {
            insert materialDetailsList;
        }
    }
}