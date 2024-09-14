public class SPEN_CasesUtil {
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    @InvocableMethod(label = 'Return Parent Case Util') 
    public static List<Case> populateParentCaseOnQueryCase(List<sObject> caseNewList)
    {
        
        List<Case> caseList= (List<Case>)caseNewList;
        Case cs = caseList[0];
        List<Case> caseListUpdate=new List<Case>();
        List<String> incidentFinalList= new List<String>();
        List<String> fuzzyIncidentFinalList= new List<String>();
        List<String> caseFinalList= new List<String>();
        List<String> caseRegexList=new List<String>();
        List<String> incidentRefRegexList=new List<String>();
        List<String> fuzzyIncidentRefRegexList=new List<String>();
        //SW
        List<String> workRefRegexList=new List<String>();
        List<String> laRefRegexList=new List<String>();
        List<String> workRefFinalList=new List<String>();
        List<String> laRefFinalList=new List<String>();
       
        String CaseRegex=System.Label.SPEN_CaseNumberRegex;
        String IncidentExactRegex = System.Label.SPEN_IncidentReferenceNumberExactRegex;
        String IncidentFuzzyRegex = System.Label.SPEN_IncidentReferenceNumberFuzzyRegex;
        //SW
        String WorkRefRegex = System.Label.SPEN_WorkRefRegex;
        String LARefRegexSPM = System.Label.SPEN_LARefRegexSPM;
        String LARefRegexSPD = System.Label.SPEN_LARefRegexSPD;
        String LARefRegex;
        
        Map<String,Id> QueryToCaseMap = new Map<String,Id>();
        Map<String,Id> IncRefToNRSWACaseMap = new Map<String,Id>();
        Map<String,Id> IncFuzzyRefToNRSWACaseMap = new Map<String,Id>();
        //SW
        Map<String,Id> WorkRefRegexToSWCaseMap = new Map<String,Id>();
        Map<String,Id> LARefToSWCaseMap = new Map<String,Id>();
        try{
            if(!caseList.isEmpty())
            {
                
                if(cs.RecordTypeId == recordTypeIdQuery && cs.Origin == 'Email')
                {
                    cs.ParentId = NULL;
                    System.debug('Test Inside');
                    //*****************************NRSWA WorkItem*******************************************************//
                    if(caseRegexList.isEmpty() && fuzzyIncidentRefRegexList.isEmpty() && incidentRefRegexList.isEmpty() && cs.SPEN_Type__c=='NRSWA')
                    {
                        System.debug('Inside NRSWA code');
                        
                        //NORMAL Incident Check
                        if(cs.Subject != null)
                        {
                            incidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentExactRegex,cs.Subject);
                            System.debug('incidentRefRegexList+++'+incidentRefRegexList);
                            if(!incidentRefRegexList.isEmpty())
                            {   
                                incidentFinalList.addAll(incidentRefRegexList);
                            }
                        }
                        if(cs.Description != null)
                        {
                            incidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentExactRegex,cs.Description);
                            if(!incidentRefRegexList.isEmpty())
                            {   
                                incidentFinalList.addAll(incidentRefRegexList);
                            }
                        }
                        
                        //Fetching the cases based on Incident Ref
                        if(!incidentFinalList.isEmpty())
                        {
                            IncRefToNRSWACaseMap = SPEN_CaseSelector.get3PDCaseFromIncidentReferenceNew(incidentFinalList,'SPEN_NRSWA');//swaathi
                            System.debug('### IncRefToNRSWACaseMap: '+IncRefToNRSWACaseMap);
                        }
                        /********************************************************************************************************/
                        //Fuzzy Logic
                        if(IncRefToNRSWACaseMap.isEmpty()) //between hyphen
                        {
                            System.debug('Inside+++');
                            if(cs.subject != null)
                            {
                                fuzzyIncidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentFuzzyRegex,cs.Subject);
                                if(!fuzzyIncidentRefRegexList.isEmpty())
                                {
                                    fuzzyIncidentFinalList.addAll(fuzzyIncidentRefRegexList);
                                }
                            }
                            if(cs.Description != null)
                            {
                                fuzzyIncidentRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(IncidentFuzzyRegex,cs.Description);
                                if(!fuzzyIncidentRefRegexList.isEmpty())
                                {
                                    fuzzyIncidentFinalList.addAll(fuzzyIncidentRefRegexList);
                                }
                            }
                        }
                        
                        //Getting valid cases based on fuzzy check list
                        if(!fuzzyIncidentFinalList.isEmpty())
                        {
                            //IncFuzzyRefToNRSWACaseMap = SPEN_CaseSelector.get3PDCaseFromFuzzyIncidentReference(fuzzyIncidentFinalList);
                            IncFuzzyRefToNRSWACaseMap = SPEN_CaseSelector.get3PDCaseFromFuzzyIncidentReferenceNew(fuzzyIncidentFinalList,'SPEN_NRSWA');//swaathi
                            System.debug('### IncRefToNRSWACaseMap: '+IncFuzzyRefToNRSWACaseMap);
                            
                        }
                        /********************************************************************************************************/
                        //cases check
                        if(IncRefToNRSWACaseMap.isEmpty() && IncFuzzyRefToNRSWACaseMap.isEmpty()){
                            if(cs.Subject != null)
                            {
                                caseRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(CaseRegex,cs.Subject);
                                system.debug('Cases+++'+caseRegexList);
                                if(!caseRegexList.isEmpty())
                                {   
                                    CaseFinalList.addAll(caseRegexList);
                                }
                                if(cs.Description != null ) 
                                {
                                    caseRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(CaseRegex,cs.Description);
                                    if(!caseRegexList.isEmpty())
                                    {   
                                        CaseFinalList.addAll(caseRegexList);
                                    }
                                }
                            }
                        }
                        if(!CaseFinalList.isEmpty())
                        {
                            //QueryToCaseMap = SPEN_CaseSelector.get3PDCaseFromCaseId(CaseFinalList);
                            QueryToCaseMap = SPEN_CaseSelector.get3PDCaseFromCaseIdNew(CaseFinalList,'SPEN_NRSWA');//swaathi
                            System.debug('### IncRefToNRSWACaseMap: '+IncRefToNRSWACaseMap);
                            
                        }
                    }
                    /********************************************************************************************************/
                    
                    
                    //*****************************Streetwork WorkItem*******************************************************//
                    if(caseRegexList.isEmpty() && laRefRegexList.isEmpty() && workRefRegexList.isEmpty() && cs.SPEN_Type__c=='Streetworks')
                    {
                        System.debug('Inside SW code');
                        //Case number check => Lets move it to a reusable method
                        if(cs.Subject != null)
                        {
                            caseRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(CaseRegex,cs.Subject);
                            system.debug('Cases+++'+caseRegexList);
                            if(!caseRegexList.isEmpty())
                            {   
                                CaseFinalList.addAll(caseRegexList);
                            }
                            if(cs.Description != null ) 
                            {
                                caseRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(CaseRegex,cs.Description);
                                if(!caseRegexList.isEmpty())
                                {   
                                    CaseFinalList.addAll(caseRegexList);
                                }
                            }
                        }
                        if(!CaseFinalList.isEmpty())
                        {
                            //QueryToCaseMap = SPEN_CaseSelector.get3PDCaseFromCaseId(CaseFinalList);
                            QueryToCaseMap = SPEN_CaseSelector.get3PDCaseFromCaseIdNew(CaseFinalList,'SPEN_Streetworks');//swaathi
                            System.debug('### QueryToCaseMap: '+QueryToCaseMap);
                            
                        }
                        /********************************************************************************************************/
                        // LARef Regex Check
                        if(QueryToCaseMap.isEmpty())
                        {
                            if(cs.SPEN_SPDSPMIndicator__c=='SPM'||cs.SPEN_SPD_SPM__c=='SPM'){
                                LARefRegex=LARefRegexSPM;
                            }
                            else if(cs.SPEN_SPDSPMIndicator__c=='SPD'||cs.SPEN_SPD_SPM__c=='SPD'){
                                LARefRegex=LARefRegexSPD;
                            }
                            if(cs.Subject != null)
                            {
                                laRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(LARefRegex,cs.Subject);
                                System.debug('incidentRefRegexList+++'+incidentRefRegexList);
                                if(!laRefRegexList.isEmpty())
                                {   
                                    laRefFinalList.addAll(laRefRegexList);
                                }
                            }
                            if(cs.Description != null)
                            {
                                laRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(LARefRegex,cs.Description);
                                if(!laRefRegexList.isEmpty())
                                {   
                                    laRefFinalList.addAll(laRefRegexList);
                                }
                            }
                        }
                        
                        //Fetching the cases based on Incident Ref
                        if(!laRefFinalList.isEmpty())
                        {
                            LARefToSWCaseMap = SPEN_CaseSelector.getCaseFromLARefId(laRefFinalList);//swaathi
                            System.debug('### LARefToSWCaseMap: '+LARefToSWCaseMap);
                        }
                        /********************************************************************************************************/
                        //WorkRef Regex Logic
                        if(QueryToCaseMap.isEmpty() && LARefToSWCaseMap.isEmpty())  
                        {
                            System.debug('Inside+++');
                            if(cs.subject != null)
                            {
                                workRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(WorkRefRegex,cs.Subject);
                                if(!workRefRegexList.isEmpty())
                                {
                                    workRefFinalList.addAll(workRefRegexList);
                                }
                            }
                            System.debug('Subject++++'+workRefFinalList);
                            //if(workRefRegexList.isEmpty() && cs.Description != null)
                            if(cs.Description != null)
                            {
                                workRefRegexList = Cases.find3PDCaseFromSubjectOrDescriptionList(WorkRefRegex,cs.Description);
                                if(!workRefRegexList.isEmpty())
                                {
                                    workRefFinalList.addAll(workRefRegexList);
                                }
                            }
                            System.debug('desc++++'+workRefFinalList);
                        }
                        
                        //Getting valid cases based on fuzzy check list
                        if(!workRefFinalList.isEmpty())
                        {
                            WorkRefRegexToSWCaseMap = SPEN_CaseSelector.getCaseFromWorkRefId(workRefFinalList);//swaathi
                            System.debug('### WorkRefRegexToSWCaseMap: '+WorkRefRegexToSWCaseMap);
                            
                        }
                        /********************************************************************************************************/
                        
                    }
                }
                System.debug('### Final List Map: ' + incidentFinalList);
                system.debug('fuzzyIncidentFinalList>>>>>>>>>>>>'+fuzzyIncidentFinalList);
                  
                
            }
            /***************************************************************************************************************/
            
            //All the below Parent ID condition 
            //Exact Incident Ref - Parent ID
            if(cs.SPEN_Type__c == 'NRSWA' )
            {
                if(!IncRefToNRSWACaseMap.isEmpty())
                {
                    cs.ParentId = populateParentID(incidentFinalList,IncRefToNRSWACaseMap);
                    
                }
                //Fuzzy Incident Ref - Parent ID
                if(!IncFuzzyRefToNRSWACaseMap.isEmpty())
                {
                    system.debug('Inside1+++'+fuzzyIncidentFinalList);
                    system.debug('Inside1+++'+IncFuzzyRefToNRSWACaseMap);
                    cs.ParentId = populateParentID(fuzzyIncidentFinalList,IncFuzzyRefToNRSWACaseMap);
                    
                }
            }
            //Case - Parent ID
            if(!QueryToCaseMap.isEmpty())
            {
                cs.ParentId = populateParentID(CaseFinalList,QueryToCaseMap);
               
            }
            
            if(cs.SPEN_Type__c == 'Streetworks')
            {
                //LA Ref - Parent ID
                if(!LARefToSWCaseMap.isEmpty())
                {
                    cs.ParentId = populateParentID(laRefFinalList,LARefToSWCaseMap);
                    
                    
                }
                //Work Ref - Parent ID
                if(!WorkRefRegexToSWCaseMap.isEmpty())
                {
                    cs.ParentId = populateParentID(workRefFinalList,WorkRefRegexToSWCaseMap);
                }
                
            }
            if(caseList!=null){
                	System.debug('Inside DML');
                    update caseList;
                }
            //caseListUpdate.add(cs);
            return caseList;
        }
        catch(Exception e)
        {
            SEL_LoggingService.log(e);
            return NULL;
        }
    }
    
    public static Id populateParentID(List<String> RefFinalList,Map<String,Id> RefRegexToCaseMap)
    {
        
        Id ParentID;
        for(String incref:RefFinalList)
        {
            if(RefRegexToCaseMap.containsKey(incref)){
                ParentID = RefRegexToCaseMap.get(incref);
                
                break;
            }
        }
        system.debug('System++++'+ParentID);
        return ParentID;
    }
}