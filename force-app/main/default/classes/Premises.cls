public with sharing class Premises 
{
    //CRMD-9191 Start
    public static void beforePremiseUpdate(Map<Id,sObject> premiseNewMap,Map<Id,sObject> premiseOldMap)
    {
         List<SPEN_Premise__c> premiseListNew = (List<SPEN_Premise__c>)premiseNewMap.values();
         Map<Id,SPEN_Premise__c> premiseListOld = (Map<Id,SPEN_Premise__c>)premiseOldMap;
        Set<String> PostCodeSet = new Set<String>();
        try
        {
            for(SPEN_Premise__c premise:premiseListNew)
            {
                if(premise.SPEN_PostCode__c != premiseListOld.get(premise.Id).SPEN_PostCode__c)
                {                    PostCodeSet.add(premise.SPEN_PostCode__c);
                }
            }
            List<SPEn_PostcodeMDM__c> postcodeMDMList = [SELECT Id, SPEN_PostCode__c, SPEN_LocalAuthority__c,SPEN_LSOA__c FROM SPEN_PostCodeMDM__c where SPEN_PostCode__c IN: PostCodeSet];
            Map<String,SPEn_PostcodeMDM__c> postcodeMDMMap = new Map<String,SPEn_PostcodeMDM__c> ();
            for(SPEn_PostcodeMDM__c postCode:postcodeMDMList)
            {
                postcodeMDMMap.put(postCode.SPEN_PostCode__c,postCode);
            }
             for(SPEN_Premise__c premise:premiseListNew)   
                {
                    if(!postcodeMDMMap.isEmpty())
                    {
                        SPEn_PostcodeMDM__c pcode = postcodeMDMMap.get(premise.SPEN_PostCode__c);
                        premise.Local_Authority__c = pcode.SPEN_LocalAuthority__c; 
premise.SPEN_LSOA__c = pcode.SPEN_LSOA__c;//CRMD-9191 feedback
                    }
                }
            
        }
        catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
    
     public static void beforePremiseInsert(List<sObject> premiseNewList)
    {
        try
        {
            List<SPEN_Premise__c> premiseListNew = (List<SPEN_Premise__c>)premiseNewList;
            Set<String> PostCodeSet = new Set<String>();
            if(!premiseListNew.isEmpty())
            {
                
               
                for(SPEN_Premise__c premise:premiseListNew)   
                {
                    if(premise.SPEN_PostCode__c!=NULL)
                    {
                        PostCodeSet.add(premise.SPEN_PostCode__c);
                    }
                }
                List<SPEn_PostcodeMDM__c> postcodeMDMList = [SELECT Id, SPEN_PostCode__c, SPEN_LocalAuthority__c,SPEN_LSOA__c FROM SPEN_PostCodeMDM__c where SPEN_PostCode__c IN: PostCodeSet];
                Map<String,SPEn_PostcodeMDM__c> postcodeMDMMap = new Map<String,SPEn_PostcodeMDM__c> ();
                for(SPEn_PostcodeMDM__c postCode:postcodeMDMList)
                {
                    postcodeMDMMap.put(postCode.SPEN_PostCode__c,postCode);
                }
                for(SPEN_Premise__c premise:premiseListNew)   
                {
                    if(!postcodeMDMMap.isEmpty())
                    {
                        SPEn_PostcodeMDM__c pcode = postcodeMDMMap.get(premise.SPEN_PostCode__c);
                        premise.Local_Authority__c = pcode.SPEN_LocalAuthority__c; 
                        premise.SPEN_LSOA__c = pcode.SPEN_LSOA__c;//CRMD-9191 feedback
                    }
                }
            }
        }
        catch(exception e){
            SEL_LoggingService.log(e);
        }
    }
    //CRMD-9191 End
    public static void afterPremiseUpdate(Map<Id, sObject> premiseNewMap, Map<Id, sObject> premiseOldMap)
    {
        List<SPEN_Premise__c> premiseNewList = (List<SPEN_Premise__c>)premiseNewMap.values();
        Map<Id,SPEN_Premise__c> premiseOldMapData = (Map<Id,SPEN_Premise__c>)premiseOldMap;
        Map<Id,SPEN_Premise__c> premiseNewMapData = (Map<Id,SPEN_Premise__c>)premiseNewMap;
        Set<Id> premiseIds = new Set<Id> ();
        //formula limit - START
        Set<Id> premiseIdsForNonBypassCasesSet = new Set<Id>();
        //formula limit - END
        for(SPEN_Premise__c premRec : premiseNewList)
        {
            if(premRec.SPEN_ConsentToSharePSRGiven__c != premiseOldMapData.get(premRec.Id).SPEN_ConsentToSharePSRGiven__c)
            {
                premiseIds.add(premRec.Id);
            }
             //formula limit - START
            if(premRec.SPEN_FullAddress__c != premiseOldMapData.get(premRec.Id).SPEN_fullAddress__c)
            {
                premiseIdsForNonBypassCasesSet.add(premRec.Id);
            }
            
        }
        if(!premiseIdsForNonBypassCasesSet.isEMpty())
        {
            List<Case> caseToBeUpdatedList = new List<Case>();
            List<Case> csList = [Select Id,SPEN_addressPremise__c,SPEN_Bypass__c from Case where SPEN_addressPremise__c IN:premiseIdsForNonBypassCasesSet AND SPEN_Bypass__c = false]; // Check if 3pd record type is needed?
            for(Case cs:csList)
            {
                 SPEN_Premise__c premise = premiseNewMapData.get(cs.SPEn_addressPremise__c);
                 cs.SPEN_Bypass_FullAddress__c  = premise.SPEN_Fulladdress__c;
                
                caseToBeUpdatedList.add(cs);
            }
            update caseToBeUpdatedList;
        }
        //formula limit - END
        List<Contact> contactsTobeUpdated = new List<Contact>();
        if(!premiseIds.isEmpty())
        {
            for(SPEN_ContactPremise__c cpRec : SPEN_ContactPremisesSelector.getContactPremises(premiseIds))
            {
                Contact conRec = new Contact(Id = cpRec.SPEN_RelatedContact__c);
                conRec.SPEN_PSRSynctoADQM__c = true;
                contactsTobeUpdated.add(conRec);
            }
        }
        try{
            if(!contactsTobeUpdated.isEmpty())
            {
                update contactsTobeUpdated;
            }
        }
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
            throw ex;
        }
        
    }
    public static void beforeInsert(List<SPEN_Premise__c> newrecords){
        for(SPEN_Premise__c currentRecord : newrecords){
            if(currentRecord.SPEN_MPAN__c != Null && (currentRecord.SPEN_NewFlatNumber__c != null || currentRecord.SPEN_NewArea__c != null || currentRecord.SPEN_NewTown__c != null || currentRecord.SPEN_NewPremiseNumber__c  != null || currentRecord.SPEN_NewStreet__c != null || currentRecord.SPEN_NewPostcode__c != null)){
                currentRecord.SPEN_Button_Validation__c = true;
            }
        }
    }
    public static void beforeUpdate(List<SPEN_Premise__c> newrecords){
        for(SPEN_Premise__c currentRecord : newrecords){
            SPEN_Premise__c oldData = (SPEN_Premise__c) Trigger.oldMap.get(currentRecord.Id);
            if(!currentRecord.SPEN_Button_Validation__c){
                if(currentRecord.SPEN_MPAN__c != Null && (currentRecord.SPEN_NewFlatNumber__c != oldData.SPEN_NewFlatNumber__c || currentRecord.SPEN_NewArea__c != oldData.SPEN_NewArea__c || currentRecord.SPEN_NewTown__c != oldData.SPEN_NewTown__c || currentRecord.SPEN_NewPremiseNumber__c  != oldData.SPEN_NewPremiseNumber__c || currentRecord.SPEN_NewStreet__c != oldData.SPEN_NewStreet__c || currentRecord.SPEN_NewPostcode__c != oldData.SPEN_NewPostcode__c )){
                    currentRecord.SPEN_Button_Validation__c = true;
                }
            }
            
        }
    }
}