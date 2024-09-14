/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the Case Queries.
LIBRARY     :   Salesforce Enterprise Library - Case Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
SEP-30-2022     Dhara Desai         Initial version
-----------------------------------------------------------------------------*/
@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class SPEN_CaseSelector {
    /**************************************************
    @Author: Dhara Desai
    @Date: 04/10/22
    @purpose: Method to get contact customer details.
    ***************************************************/
    public static Contact getCustomerInfo(Id contactId){
        Contact conCustomerInfo = new Contact();
        if(contactId != null)
        	conCustomerInfo = [SELECT  Id,Contact.Salutation,MobilePhone,Name,Phone,Contact.Suffix 
                            FROM Contact
                            WHERE Id =: contactId];
        return conCustomerInfo;     
    }
    
    /**************************************************
    @Author: Dhara Desai
    @Date: 04/10/22
    @purpose: Method to get queue details.
    ***************************************************/
    public static List<Group> getQueueDetails(){
        List<Group> queueId = new List<Group>();
        queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'No Supply(Online)Cases'];
        return queueId;     
    }
    
    /**************************************************
    @Author: Nitish Dharm
    @Date: 16th Oct 22
    @purpose: Method to get Config setings map
    ***************************************************/
    public static Map<String,SPEN_ConfigurableSettings__c> configSettingsMap {
        get {
               if (configSettingsMap == null) {
                   configSettingsMap = new Map<String,SPEN_ConfigurableSettings__c>();
                   for(SPEN_ConfigurableSettings__c settingRec: [SELECT Id,Name,SPEN_Value__c FROM SPEN_ConfigurableSettings__c limit 50000]){
                       configSettingsMap.put(settingRec.Name,settingRec);
                   }
               }
               return configSettingsMap;
          }
          set;
    }
    
    /**************************************************
    @Author: Debapriya Saha
    @Date: 03/11/22
    ***************************************************/
    public static Case getUpdateCse(Set<Id> caseIdSet){
          Case updateCse;
        if(caseIdSet != null && !caseIdSet.isEmpty()){
             updateCse = [SELECT Id,recordTypeId, 
                      CaseNumber, SPEN_CallerName__c,Status,
                      SPEN_CallerTitle__c, SPEN_CallerInitials__c, 
                      SPEN_CallerTelephone__c, SPEN_CallerMobileTelephone__c,
                      SPEN_CaseCategoryOutcome__c, Type, Origin,SPEN_CallSource__c,
                      SPEN_CriticalInformation__c, SPEN_Remarks__c, 
                      SPEN_IncidentReference__c, SPEN_PowerOnCallReference__c,
                      SPEN_ThirdPartyName__c, 
                      SPEN_ThirdPartyAddress__c, 
                      SPEN_ThirdPartyTelephone__c, 
                      SPEN_ThirdPartyMobile__c, 
                      SPEN_ThirdPartyCause__c, 
                      SPEN_ThirdPartyDescription__c,SPEN_BuildingNameNumberW2C__c,
                      SPEN_AddressPremise__c , SPEN_AddressPremise__r.SPEN_Area__c,SPEN_AddressPremise__r.SPEN_FlatNumber__c,
                      SPEN_AddressPremise__r.SPEN_PremiseName__c,SPEN_AddressPremise__r.SPEN_PremiseNumber__c,
                      SPEN_AddressPremise__r.SPEN_BuildingNameNumber__c,SPEN_AddressPremise__r.SPEN_Street__c,SPEN_AddressPremise__r.SPEN_PremiseID__c,
                      SPEN_AddressPremise__r.SPEN_PostCode__c, SPEN_AddressPremise__r.SPEN_Town__c, Contact.SPEN_CustomerID__c,SPEN_AddressPremise__r.SPEN_CustomerNumber__c, SPEN_AddressPremise__r.SPEN_OperatingZone__c,SPEN_OperatingZonePowerOnFormula__c,
                      SPEN_Town_PowerOnFormula__c,SPEN_PremiseNameNumber_PowerOnFormula__c,SPEN_FlatNumber_PowerOnFormula__c,SPEN_Postcode_PowerOnFormula__c,SPEN_Street_PowerOnFormula__c,SPEN_CreatedByName__c
                      FROM Case 
                      WHERE Id IN : caseIdSet LIMIT 1];
        }
   
        return updateCse;   
    }
    
    /**************************************************
    @Author: Debapriya Saha
    @Date: 03/11/22
    ***************************************************/
    public static Case getCancelCse(Set<Id> cancelCaseIdSet){
         Case createdCse;
        if(cancelCaseIdSet != null && !cancelCaseIdSet.isEmpty()){
            createdCse = [SELECT Id, CaseNumber, 
                               SPEN_PowerOnCallReference__c, SPEN_CaseCategoryOutcome__c, 
                               SPEN_AddressPremise__c 
                               FROM Case 
                               WHERE Id IN : cancelCaseIdSet LIMIT 1];
        }
        return createdCse;  
    }
    
    /**************************************************
    @Author: Debapriya Saha
    @Date: 03/11/22
    ***************************************************/
    public static List<Case> getUncheckedSendToPowerOnCaseList(Set<Id> caseIdSet){
        List<Case> unchkdCseList;
        if(caseIdSet != null && !caseIdSet.isEmpty()){
           unchkdCseList  = [SELECT Id, CaseNumber, SPEN_SendtoPowerOn__c, RecordTypeId 
                                        FROM Case 
                                        WHERE Id IN : caseIdSet];
        }
        return unchkdCseList;  
    }  
    
    
    /**************************************************
    @Author: Bhagayshree Mandlik
    @Date: 20/01/2023
    ***************************************************/
    public static List<Case> getCaseNumber(Id caseId){
        List<Case> caseRec;
        if(caseId != null){
            caseRec = [SELECT Id, recordtypeid, SPEN_Type__c,CaseNumber,SPEN_Email_WI_Queue_Routing_Outcome__c,ownerId,SPEN_CaseAssignmentTime__c,SPEN_SLADueDate__c
                       FROM Case 
                       WHERE Id = : caseId];
        }
        return caseRec;  
    } 
    
    /**************************************************
    @Author: Smita Raikar
    @Date: 30/01/2023
    ***************************************************/
    public static Case getCaseRecord(){
       Case caseRec = [SELECT Id, CaseNumber,SPEN_PowerOnCallReference__c, SPEN_CaseCategoryOutcome__c,SPEN_AddressPremise__c FROM Case WHERE SPEN_Incident__c=NULL  Limit 1];
            return caseRec;  
        } 
    

        
     /**************************************************
    @Author: Bhagayshree Mandlik
    @Date: 20/01/2023
    ***************************************************/
    public static List<Case> getCaseFromIncRecId(Id incRecId){
        List<Case> caseRec;
        if(incRecId != null){
            caseRec = [ SELECT Id, SPEN_Incident__c, SPEN_ETROutage__c, CaseNumber, OwnerId, Status,SPEN_Incident__r.SPEN_IncidentStatus__c,recordTypeId 
                        FROM Case 
                        WHERE SPEN_Incident__c=: incRecId 
                        WITH SECURITY_ENFORCED];
        }
        return caseRec;  
    } 
    /**************************************************
    @Author: Sumit Biswas
    @Date: 13/05/2023
    @Revision: Sai Shyam, 09/05/2024 , SFAMS-628
    ***************************************************/
    public static Map<Id,Case> getCaseOwner(Set<id> caseIdsSet)
    {
        Map<Id,Case> caseRecMap = new Map<Id,Case>([SELECT Id, OwnerId,BusinessHoursId,SPEN_ReceivedDate__c,recordtype.Name, SPEN_SPDSPMIndicator__c,SPEN_SPD_SPM__c,RecordTypeId,SPEN_CompanyID__c,SPEN_District__c,SPEN_ConnectionDistrict__c,Owner.Name FROM Case WHERE Id =: caseIdsSet]);
        return caseRecMap;
    } 
    /**************************************************
    @Author: Amrita Sarkar
    @Date: 13/07/2023
    ***************************************************/
    public static List<SPEN_PostCodeDistrictMap__c> getPostCodeDisDetails(Set<String> postCodeSet){
        List<SPEN_PostCodeDistrictMap__c> postCodeDisList = new  List<SPEN_PostCodeDistrictMap__c>();
        if(!postCodeSet.isEmpty()){
            postCodeDisList = [Select Id,SPEN_PostCode__c,SPEN_DistrictName__c 
            from SPEN_PostCodeDistrictMap__c where SPEN_PostCode__c IN :postCodeSet limit 10000];
        }
        return postCodeDisList;  
    } 
/***********************************************************
@Author: sheker Kulkacherla
@Date: 07/10/23
@purpose: Method to get Case details for IncidentService class.
***************************************************************/
public static List<Case> getCaseIncRecords(Set<Id> incIds){
    List<Case> caseIncRecords = new List<Case>();
    if(incIds != null && !incIds.isEmpty()){
        caseIncRecords = [ SELECT id, SPEN_Incident__c, SPEN_PreferredMethodofContact__c,SPEN_Incident__r.SPEN_IncidentType__c,
                          SPEN_CaseCategoryOutcome__c,ContactId,SPEN_CallerMobileTelephone__c,SPEN_CallerTelephone__c
                          FROM Case 
                          WHERE SPEN_Incident__c IN: incIds];
    }
    return caseIncRecords;  
} 
/**************************************************
    @Author: Amrita Sarkar
    @Date: 13/07/2023
    ***************************************************/
    public static List<SPEN_DesignQueueRules__c> getDesignQueueRuleSet(String districtSet,String jobTypeString){
        List<SPEN_DesignQueueRules__c> designQueueRuleSetList = new  List<SPEN_DesignQueueRules__c>();
        if(districtSet != '' && jobTypeString!= ''){
        String query = 'Select SPEN_JobTypeDescription__c,SPEN_District__c,SPEN_CustomerClass__c,SPEN_MinimumLoad__c,SPEN_MaximumLoad__c,SPEN_SFQueueName__c,SPEN_MinimumPlot__c,SPEN_MaximumPlot__c,SPEN_QueueNameAPIFormula__c from SPEN_DesignQueueRules__c where SPEN_District__c '+ 'Includes (' + districtSet+')'+ ' and SPEN_JobTypeDescription__c IN (' + jobTypeString+')';
        //system.debug('query**' + query);
         designQueueRuleSetList = database.query(query);
        }
        return designQueueRuleSetList;  
    } 
/**************************************************
    @Author: Amrita Sarkar
    @Date: 13/07/2023
    ***************************************************/
    public static List<Group> getQueueDetailList(List<String> queueValues){
        List<Group> queueIdList = new List<Group>();
        if(!queueValues.isEmpty() && queueValues.size() > 0){
            queueIdList = [SELECT Id,Name,DeveloperName,Type FROM Group WHERE Type = 'Queue' AND DeveloperName IN : queueValues];
        }
        return queueIdList;     
    }
    /**************************************************
    @Author: Amrita Sarkar
    @Date: 13/07/2023
    ***************************************************/
    public static List<Task> getExistingPreQuoteTaskFromCase(Set<Id> caseId,Set<Id> taskRecrTypeId){
        List<Task> taskList = new List<Task>();
         if(!caseId.isEmpty() && !taskRecrTypeId.isEmpty()){
            taskList = [SELECT id, WhatId,RecordTypeId,status,SPEN_TaskType__c,IsClosed FROM Task WHERE WhatId In : caseId and RecordType.id IN : taskRecrTypeId and IsClosed = false];
         }
        return taskList;     
    }
    /**************************************************
    @Author: Rohit Sharma
    @Date: 21/07/2023
    ***************************************************/
    public static List<Case> getCaseDetailsForSAPCallout(Id caseId){
        List<Case>	caseList = new List<Case>();
        if(caseId!=null)
        {
            caseList = [Select Id,CaseNumber,
                            SPEN_CancellationReason__c,SPEN_SAPReference__c,SPEN_UKC1ID__c,SPEN_UKC2ID__c,SPEN_CCCompanyName__c,
                            SPEN_AddInCustomerSatisfactionSurvey__c,SPEN_CaseDescription__c,SPEN_CompanyID__c,SPEN_SiteName__c,
                            SPEN_ApplicantSiteIdentifier__c,SPEN_SiteContactFlatNumber__c,SPEN_SiteContactHouseNo__c,
                            SPEN_SiteContactBuildingName__c,SPEN_SiteContactStreet__c,SPEN_SiteContactLocality__c,
                            SPEN_SiteContactTownCity__c,SPEN_SiteContactCountry__c,SPEN_SiteContactCounty__c,
                            SPEN_SiteContactPostCode__c,SPEN_XCoOrdinate__c,SPEN_YCoOrdinate__c,SPEN_CustomerRef__c,
                            SPEN_PONumber__c,SPEN_RaDaR__c,SPEN_PaymentDecision__c,SPEN_RequestedtoRelease__c,SPEN_IsCaseCompetentInSAP__c,
                            SPEN_MutuallyExclusiveQuoteRef__c,SPEN_InteractiveQuoteRef__c,SPEN_ConnectionType__c,SPEN_CustomerClass__c,
                            SPEN_JobType__c,SPEN_DesignType__c,SPEN_QuotationType__c,SPEN_ActualPower__c,SPEN_ActualPhase__c,
                            SPEN_ActualEarth__c,SPEN_ConnectedLoadkVA__c,SPEN_RequiredPower__c,SPEN_RequiredPhase__c,SPEN_RequiredEarth__c,
                            SPEN_Diversity__c,SPEN_POCVoltage__c,SPEN_MeteringVoltage__c,SPEN_TTQStartDate__c,SPEN_EVChargingCapabilities__c,
                            SPEN_EVChargeQuantity__c,SPEN_EVtoGrid__c,SPEN_HeatingMethod__c,SPEN_HeatingType__c,SPEN_DisturbingLoadkw__c,
                            SPEN_DisturbingLoadSummary__c,SPEN_SiteContactFirstName__c,SPEN_SiteContactLastName__c,SPEN_LegacyGenerationType__c,
                            SPEN_CustomerRequestClass__c,SPEN_SiteContactPhone__c,SPEN_SiteContactMobile__c,SPEN_SiteContactEmail__c,SPEN_Plots__c,
                            SPEN_CompetentDate__c,SPEN_BusinessMarketSegment__c,SPEN_OfgemMarketSegment__c,SPEN_TTQ_Start_Time__c,SPEN_Competent_Time__c, 
							SPEN_ContactReceivedDate__c,SPEN_CaseTransferredDateTimeInSAP__c,SPEN_CancellationNote__c,AccountId,SPEN_SyncToSAPDate__c FROM Case where id=:caseId LIMIT 1];
        }
        			
        return caseList;     
    }
/***********************************************************
@Author: Swaathi KR
@Date: 01/08/23
@purpose: Method to get 3PD Case details for Cases class.
***************************************************************/

public static Map<String,Id> get3PDCaseFromCaseIdNew(List<String> caseId,String recType){
    List<Case> listCase = new List<Case>();
    Map<String,Id> caseMap = new Map<String,Id>();
    Set<String> caseSet = new Set<String>();
    caseSet.addAll(caseId);
    if(caseId != NULL && !caseSet.isEmpty())
    {
        listCase = [SELECT Id,recordtypeId,CaseNumber 
                    FROM Case WHERE CaseNumber IN: caseSet AND
                    //(recordtype.developerName = 'SPEN_ThirdPartyDamage'OR recordtype.developerName = 'SPEN_Streetworks' OR recordtype.developerName = 'SPEN_NRSWA')
                    (recordtype.developerName =: recType)
                    WITH SECURITY_ENFORCED];
    }
    for(Case cs:listCase)
    {
        caseMap.put(cs.CaseNumber,cs.Id);
    }
    system.debug('map>>>>>'+caseMap);
    return caseMap;
} 
public static Map<String,Id> get3PDCaseFromIncidentReferenceNew(List<String> incidentRefId,String recType){
    List<Case> listCase = new List<Case>();
    Map<String,Id> caseMap = new Map<String,Id>();
    Set<String> incSet = new Set<String>();
    
    incSet.addAll(incidentRefId);
    if(incidentRefId != NULL && !incSet.isEmpty())
    {
        listCase = [Select Id,recordtypeId,
                    SPEN_IncidentRefFormula__c
                    From Case where 
                    SPEN_IncidentRefFormula__c
                    IN: incSet AND
                    (recordtype.developerName =: recType)
                    WITH SECURITY_ENFORCED];
    }
    for(Case cs:listCase)
    {
       
        caseMap.put(cs.SPEN_IncidentRefFormula__c,cs.Id);
        
    }
    return caseMap;
} 

public static Map<String,Id> get3PDCaseFromFuzzyIncidentReferenceNew(List<String> incidentRef,String recType){
    List<String> fuzzyIncRefList = new List<String>();
    List<Case> listCase = new List<Case>();
    String[] incRefArray = new String[]{};
    Map<String,Id> caseMap = new Map<String,Id>();
    Set<String> incSet = new Set<String>();
   
    incSet.addAll(incidentRef);
    for(String inc: incSet)
    {
        incRefArray.add('%'+inc+'%');
    }
     system.debug('Incident++++++'+incRefArray);
    if(incidentRef != NULL && !incRefArray.isEmpty())
    {
        listCase = [SELECT Id,recordtypeId,
                    SPEN_IncidentRefFormula__c
                    FROM Case WHERE 
                    SPEN_IncidentRefFormula__c
                    like:incRefArray
                    AND (recordtype.developerName =: recType)
                    WITH SECURITY_ENFORCED];
        fuzzyIncRefList.addAll(incRefArray);
    }
    for(Case cs:listCase)
    {
        //formula limit - START
        caseMap.put(cs.SPEN_IncidentRefFormula__c,cs.Id);
        //formula limit - END
    } 
    Map<String,Id> finalMap = new Map<String,Id>();
     for(String cas:caseMap.keyset())
    {
        for(String incref:IncidentRef)
        {
            if(cas.contains(incref))
            {
                finalMap.put(incref,caseMap.get(cas));
            }
        }
    }
    return finalMap;
}
public static Map<String,Id> get3PDCaseFromInvoiceNumber(List<String> InvoiceId){
    List<Case> listCase = new List<Case>();
    Map<String,Id> caseMap = new Map<String,Id>();
    Set<String> invSet = new Set<String>();
   
    invSet.addAll(InvoiceId);
    if(InvoiceId != NULL)
    {
        listCase = [Select Id,recordtypeId from Case where Id in(select SPEN_Case__c from SPEN_Invoice__c where SPEN_InvoiceNumber__c IN: invSet) AND
                    recordtype.developerName = 'SPEN_ThirdPartyDamage'];
    }
    System.debug('### listCase: '+listCase);
    
    List<SPEN_Invoice__c> invoiceList = [select SPEN_Case__c,SPEN_InvoiceNumber__c from SPEN_Invoice__c where SPEN_InvoiceNumber__c IN: invSet and SPEN_Case__c IN:listCase ];
    System.debug('### invoiceList: '+invoiceList);
    for(SPEN_invoice__c Invoice : invoiceList)
    {
        caseMap.put(Invoice.SPEN_InvoiceNumber__c,Invoice.SPEN_case__c);
    }
    System.debug('### caseMap: '+caseMap);
    return caseMap;
}  
public static Map<String,Id> getCaseFromWorkRefId(List<String> workRefId){
    List<SPEN_SiteDetails__c> listCase = new List<SPEN_SiteDetails__c>();
    Map<String,Id> caseMap = new Map<String,Id>();
    Set<String> workRefSet = new Set<String>();
    workRefSet.addAll(workRefId);
    if(workRefId != NULL && !workRefSet.isEmpty())
    {
        listCase = [SELECT Id,recordtypeId,SPEN_WorksReference__c	,SPEN_Case__c
                    FROM SPEN_SiteDetails__c WHERE SPEN_WorksReference__c IN: workRefSet AND
                    recordtype.developerName = 'Streetworks'
                    WITH SECURITY_ENFORCED];
    } 
    for(SPEN_SiteDetails__c cs:listCase)
    {
        caseMap.put(cs.SPEN_WorksReference__c,cs.SPEN_Case__c);
    }
    system.debug('map>>>>>'+caseMap);
    return caseMap;
} 
public static Map<String,Id> getCaseFromLARefId(List<String> LARefId){
    List<SPEN_SiteDetails__c> listCase = new List<SPEN_SiteDetails__c>();
    Map<String,Id> caseMap = new Map<String,Id>();
    Set<String> LARefSet = new Set<String>();
    LARefSet.addAll(LARefId);
    if(LARefId != NULL && !LARefSet.isEmpty())
    {
        listCase = [SELECT Id,recordtypeId,SPEN_LAReference__c,SPEN_Case__c
                    FROM SPEN_SiteDetails__c WHERE SPEN_LAReference__c IN: LARefSet AND
                    recordtype.developerName = 'Streetworks'
                    WITH SECURITY_ENFORCED];
    } 
    for(SPEN_SiteDetails__c cs:listCase)
    {
        caseMap.put(cs.SPEN_LAReference__c,cs.SPEN_Case__c);
    }
    system.debug('map>>>>>'+caseMap);
    return caseMap;
} 
    /***********************************************************
    @Author: Asmita Rajput
    @Date: 07/24/2023
    @purpose: Method to get Case details for SPEN_CaseAssignmentNotificationQueable
    ***************************************************************/
    public static List<Case> getCaseInfoForQueuable(Set<Id> caseIdSet){
        List<Case> listCase = new List<Case>();
        if(!caseIdSet.isEmpty())
        {
            listCase = [SELECT id, caseNumber,recordtypeId, Owner.type, Owner.Name,ownerId
                        FROM Case
                        WHERE id IN: caseIdSet
                        WITH SECURITY_ENFORCED];
        }
        return listCase;
    }
    
      /**************************************************
    @Author: Akshay Pandit
    @Date: 31/07/2023
    ***************************************************/
    public static List<Case> getCaseDetailsForIds(List<Id> caseIds){
        List<Case>	caseList = new List<Case>();
        if(!caseIds.isEmpty())
        {
            caseList = [select id,SPEN_IsCaseCompetentInSAP__c,SPEN_CaseTransferredDateTimeInSAP__c,CaseNumber from case where id IN: caseIds];
        }
        return caseList;     
    }
    /**************************************************
    @Author: Rajat Verma
    @Date: 02/08/2023
    ***************************************************/
    public static List<Case> getAccountDetailsFromCase(Id accountId){
        List<Case>	caseList = new List<Case>();
        if(accountId != null){
            caseList = [SELECT Id,SPEN_SAPReference__c FROM Case WHERE SPEN_SAPReference__c !=null AND AccountId=:accountId WITH SECURITY_ENFORCED];
        }
        return caseList;  
    }	
	public static List<Case> getQueryCase(Set<Id> IdSet){
        List<Case> listCase = new List<Case>();
        Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
        if(IdSet != NULL)
        {
            listCase = [Select Id,recordtypeId,Status,ParentId from Case where ParentId IN :IdSet AND recordTypeId=:recordTypeIdQuery];
        }
        return listCase;
    }
    public static List<Case> get3PDCaseFromIncident(Set<Id> incIdSet){
        List<Case> listCase = new List<Case>();
        if(!incIdSet.isEmpty())
        {
            listCase = [SELECT id, status,SPEN_Incident__c,SPEN_IncidentRefFormula__c, //SPEN_IncidentReferenceFormula__c,//formula limit
                        casenumber,recordtype.developerName
                         FROM Case 
                        WHERE SPEN_Incident__c IN: incIdSet AND
                        recordtype.developerName = 'SPEN_ThirdPartyDamage'
                        WITH SECURITY_ENFORCED];
        }
        return listCase;
    }
    public static List<Case> get3PDCaseFromIncidentRef(Set<String> setMatchingInc)
    {
        List<Case> caseList = new List<Case>();
        Set<String> incRefArray = new Set<String>();
         for(String inc: setMatchingInc)
        {
            incRefArray.add('%'+inc+'%');
        }
        if(!setMatchingInc.isEmpty())
        {
            caseList = [SELECT id, CaseNumber,SPEN_IncidentRefFormula__c //SPEN_IncidentReferenceFormula__c // formula limit
                        FROM Case 
                        WHERE  (recordtype.developerName = 'SPEN_ThirdPartyDamage'//OR recordtype.developerName = 'SPEN_Streetworks'
                                )
                        AND SPEN_IncidentRefFormula__c //SPEN_IncidentReferenceFormula__c // formula limit
                        LIKE: incRefArray
                        WITH SECURITY_ENFORCED];
        }
        return caseList;
    }
    public static List<Case> get3PDCaseFromIncidentRefNew(Set<String> setMatchingInc)
    {
        List<Case> caseList = new List<Case>();
        Set<String> incRefArray = new Set<String>();
         for(String inc: setMatchingInc)
        {
            incRefArray.add('%'+inc+'%');
        }
        if(!setMatchingInc.isEmpty())
        {
            caseList = [SELECT id, CaseNumber,SPEN_IncidentRefFormula__c
                        FROM Case 
                        WHERE  (recordtype.developerName = 'SPEN_ThirdPartyDamage'OR recordtype.developerName = 'SPEN_Streetworks'OR recordtype.developerName = 'SPEN_NRSWA')
                        AND SPEN_IncidentRefFormula__c 
                        LIKE: incRefArray
                        WITH SECURITY_ENFORCED];
        }
        return caseList;
    }
    public static List<Case> getCaseListFromId(Set<Id> setCaseId)
    {
        List<Case> caseList = new List<Case>();
        if(!setCaseId.isEmpty())
        {
            caseList = [SELECT ID, status,CaseNumber,SPEN_DamageFormNumber__c 
                        FROM Case
                        WHERE ID IN: setCaseId 
                        WITH SECURITY_ENFORCED];
        }
        return caseList;
    }
    /***********************************************************
@Author: Swaathi KR
@Date: 08/09/23
@purpose: Method to get Incident by Incident Reference
***************************************************************/ 
public static Incident getIncidentFromIncidentReference(String IncRef)
{
    List<Incident> incList = [SELECT ID,SPEN_incidentReference__C from Incident where SPEN_incidentReference__C=:IncRef];
    if(incList.isEmpty())
    {
        return Null;
    }
    return incList[0];
}
public static Map<ID, String> getQueueName(Set<Id> setQueueID){
    List<Group> lstQueue = new List<Group>();
    Map<ID, String> mapQueueId2Name = new Map<Id,String>();
    if(!setQueueID.isEmpty()){
        lstQueue = [SELECT Id, Type, Name FROM Group WHERE Type = 'Queue' AND ID IN: setQueueID
                    WITH SECURITY_ENFORCED];
    }
    if(!lstQueue.isEmpty()){
        for(Group q: lstQueue){
            mapQueueId2Name.put(q.id,q.name);
        }
    }
   
    return mapQueueId2Name;     
}
//CRMD-10627 - Start
    public static Map<ID, String> getOldParentAccountName(Set<Id> oldParentAccountCaseIDSet){
        List<Account> parentAccountList = new List<Account>();
        Map<ID, String> mapAccountId2Name = new Map<Id,String>();
        if(!oldParentAccountCaseIDSet.isEmpty()){
            parentAccountList = [Select Id,Name from Account where id IN:oldParentAccountCaseIDSet
                        WITH SECURITY_ENFORCED];
        }
        if(!parentAccountList.isEmpty()){
            for(Account q: parentAccountList){
                mapAccountId2Name.put(q.id,q.name);
            }
        }
        
        return mapAccountId2Name;     
    }
       public static Map<ID, String> getNewParentAccountName(Set<Id> newParentAccountCaseIDSet){
         List<Account> parentAccountList = new List<Account>();
        Map<ID, String> mapAccountId2Name = new Map<Id,String>();
        if(!newParentAccountCaseIDSet.isEmpty()){
            parentAccountList = [Select Id,Name from Account where id IN:newParentAccountCaseIDSet
                        WITH SECURITY_ENFORCED];
        }
        if(!parentAccountList.isEmpty()){
            for(Account q: parentAccountList){
                mapAccountId2Name.put(q.id,q.name);
            }
        }
        
        return mapAccountId2Name;    
    }
    //CRMD-10627 - End
public static Map<ID, String> getUserName(Set<Id> setOwnerID){
    List<User> lstUser = new List<User>();
    Map<ID, String> mapUserId2Name = new Map<Id,String>();
    if(!setOwnerID.isEmpty()){
        lstUser = [Select id, Name FROM User WHERE id IN: setOwnerID WITH SECURITY_ENFORCED];
    }
    if(!lstUser.isEmpty()){
        for(User u: lstUser){
            mapUserId2Name.put(u.id,u.name);
        }
    }
    return mapUserId2Name;     
}

public static List<Case> getCaseRecords(Set<Id> caseIdSet){
    List<Case> caseList=new List<Case>();
   if(caseIdSet != null && !caseIdSet.isEmpty()){
        caseList = [SELECT Id,recordTypeId, 
                 CaseNumber, SPEN_CallerName__c, 
                 SPEN_CallerTitle__c, SPEN_CallerInitials__c, 
                 SPEN_CallerTelephone__c, SPEN_CallerMobileTelephone__c,
                 SPEN_CaseCategoryOutcome__c, Type, Origin,SPEN_CallSource__c,
                 SPEN_CriticalInformation__c, SPEN_Remarks__c, 
                 SPEN_IncidentReference__c, SPEN_PowerOnCallReference__c,
                 SPEN_ThirdPartyName__c, 
                 SPEN_ThirdPartyAddress__c, 
                 SPEN_ThirdPartyTelephone__c, 
                 SPEN_ThirdPartyMobile__c, 
                 SPEN_ThirdPartyCause__c, 
                 SPEN_ThirdPartyDescription__c,SPEN_BuildingNameNumberW2C__c,
                 SPEN_AddressPremise__c , SPEN_AddressPremise__r.SPEN_Area__c,SPEN_AddressPremise__r.SPEN_FlatNumber__c,SPEN_AddressPremise__r.SPEN_PlotNumber__c,
                 SPEN_AddressPremise__r.SPEN_PremiseName__c,SPEN_AddressPremise__r.SPEN_PremiseNumber__c,
                 SPEN_AddressPremise__r.SPEN_BuildingNameNumber__c,SPEN_AddressPremise__r.SPEN_Street__c,SPEN_AddressPremise__r.SPEN_PremiseID__c,
                 SPEN_AddressPremise__r.SPEN_PostCode__c, SPEN_AddressPremise__r.SPEN_Town__c, Contact.SPEN_CustomerID__c,SPEN_AddressPremise__r.SPEN_CustomerNumber__c, SPEN_AddressPremise__r.SPEN_OperatingZone__c,SPEN_OperatingZonePowerOnFormula__c,
                 SPEN_Town_PowerOnFormula__c,SPEN_PremiseNameNumber_PowerOnFormula__c,SPEN_FlatNumber_PowerOnFormula__c,SPEN_Postcode_PowerOnFormula__c,SPEN_Street_PowerOnFormula__c,SPEN_CreatedByName__c
                 FROM Case 
                 WHERE Id IN : caseIdSet ];
   }

   return caseList;   
}
    public static Map<Id, Case> getDamageEquipWizardCase(Set<Id> setIncidentId)
    {
        Map<Id,Case> mapIncident2DamageCase = new Map<Id,Case>();
        List<Case> lstDamageWizardCase = new List<Case>();
        if(!setIncidentId.isEmpty()){
            lstDamageWizardCase = [SELECT id, SPEN_CallerName__c, SPEN_CallerTelephone__c,
                                                SPEN_CallerMobileTelephone__c,Contact.name,
                                                Contact.MobilePhone, Contact.Phone, recordtypeId,SPEN_Incident__c
                                                FROM CASE 
                                                WHERE Subject =: System.Label.SPEN_DamageEquipmentWizardCase
                                                AND SPEN_Incident__c IN:setIncidentId
                                                WITH SECURITY_ENFORCED];
        }
        if(!lstDamageWizardCase.isEmpty()){
            for(Case caseRec: lstDamageWizardCase)
            {
                mapIncident2DamageCase.put(caseRec.SPEN_Incident__c,caseRec);
            }
        }  
        return mapIncident2DamageCase;
    }


  /**************************************************
    @Author: Rajat Verma
    @Date: 23/09/2023
    ***************************************************/
    @AuraEnabled
    public static List<Case> findRecords(String searchValue){
        try {
            String key = '%'+searchValue+'%';
            String transmissionRecordType = System.Label.SPEN_CaseRecordTypeForRelatedProject;
            String queryString = 'Select Id, CaseNumber,SPEN_ContractReferenceNumberFormula__c, Status,Account.Name,AccountId,SPEN_ProjectName__c From Case Where ( CaseNumber LIKE : key  OR ' ;
            queryString += ' Account.Name LIKE : Key OR SPEN_ProjectName__c LIKE : Key OR SPEN_ContractReferenceNumberFormula__c LIKE : Key ) ';
            queryString += ' AND RecordType.DeveloperName =: transmissionRecordType Limit 200';
            List<Case> caseList = Database.query(queryString);
            return caseList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**************************************************
    @Author: Rajat Verma
    @Date: 16/10/2023
    ***************************************************/
    public static List<SPEN_Delivery__c> getCaseDetailsFromDeliveryRecords(List<Id> deliveryIds){
        List<SPEN_Delivery__c>	deliveryList = new List<SPEN_Delivery__c>();
        if(!deliveryIds.isEmpty())
        {
            deliveryList = [select Id,SPEN_Case__c,SPEN_CaseSAPRefFormula__c,
                        SPEN_DeliveryProjectManager__c,SPEN_DeliveryProjectManager__r.SPEN_SAPId__c from SPEN_Delivery__c where id IN: deliveryIds];
        }
        return deliveryList;     
    }

    //CRMD-8706
    public static Case getNRSWACase(Id incId){
        Case nrswaCase = new Case();
        if(incId != NULL) 
        {
            try{
                nrswaCase = [SELECT id,SPEN_Incident__c,RecordType.DeveloperName 
                             FROM Case 
                             WHERE RecordType.DeveloperName = 'SPEN_NRSWA'
                             AND Status != 'Closed'
                             AND SPEN_Incident__c=:incId LIMIT 1];
            }
            catch(Exception ex){
                SEL_LoggingService.log(ex);
            }
        }
        return nrswaCase;
    }
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method to get Case details for SPEN_ImpactedPremise
    ***************************************************************/   
    public static List<Case> getCaseFromIncidentids(Set<String> incidentIds){
        List<Case> listCase = new List<Case>();
        if(!incidentIds.isEmpty())
        {
            listCase = [SELECT Id,SPEN_AddressPremise__c,ContactId,SPEN_AddressPremise__r.SPEN_PremiseID__c,
                            SPEN_INCChangeTime__c,SPEN_Incident__r.SPEN_UpgradeDateTime__c,SPEN_IsMerge__c,SPEN_CaseCategoryOutcome__c 
                        FROM Case WHERE SPEN_Incident__r.SPEN_IncidentID__c IN:incidentIds];
        }
        return listCase;
    }
    public static Map<String,Id> getQueueDetails(Set<String> setQueuName){
        List<Group> lstQueue = new List<Group>();
        Map<String,Id> mapQueueName2Id = new Map<String, Id>();
        if(!setQueuName.isEmpty()){
            //lstQueue = [SELECT Id, Type, Name FROM Group WHERE Type = 'Queue' AND Name IN: setQueuName WITH SECURITY_ENFORCED];
        	lstQueue = [SELECT Id, Type, Name FROM Group WHERE Type = 'Queue' AND Name IN: setQueuName];
        
        }
        if(!lstQueue.isEmpty()){
            for(Group q: lstQueue){
                mapQueueName2Id.put(q.name,q.id);
            }
        }
        return mapQueueName2Id;     
    }
    public static Map<Id,Case> getCaseForAgentWork(Set<Id> setCaseID, set<Id> setRecType){
        Map<Id,Case> mapCaseid2Case;
        if(!setCaseID.isEmpty() && !setRecType.isEmpty()){
        	mapCaseid2Case= new Map<ID, Case>([Select id,SPEN_CaseAssignmentTime__c FROM 
                     Case WHERE Id IN: setCaseID 
                     AND recordtypeid IN: setRecType WITH SECURITY_ENFORCED]);
        }
        return mapCaseid2Case;
    }
/**************************************************
    @Author: Sai Shyam
    @Date: 09/05/2024
    @Purpose: SFAMS-628
***************************************************/
public static List<Task> getTaskConnectionList(Set<Id> caseIds){
    List<Task> taskList = new List<Task>();
    if(!caseIds.isEmpty())
    {
        taskList = [SELECT id,WhatId,SPEN_SPD_SPM__c,SPEN_CaseOwnerDetails__c,SPEN_CaseConnectionDistrict__c from Task where WhatId IN: caseIds];
    }
    return taskList;     
}
    /**************************************************
    @Author: Sumit Biswas
    @Date: 08/28/24
    ***************************************************/
    public static List<SPEN_CaseInformation__c> getCaseInformationList(Set<Id> caseInfoIdSet){
        List<SPEN_CaseInformation__c> CaseInfoList = new List<SPEN_CaseInformation__c>();
        if(caseInfoIdSet != null && !caseInfoIdSet.isEmpty()){
           CaseInfoList  = [SELECT Id, SPEN_Case__c, SPEN_DateLetter1__c, SPEN_JobStatus__c, SPEN_FlowReceivedDate__c, SPEN_28CDresolutiondate__c, SPEN_10WDApptBooked__c, SPEN_40WDresolutiondate__c 
                             FROM SPEN_CaseInformation__c 
                             WHERE Id IN :caseInfoIdSet WITH SECURITY_ENFORCED];
        }
        return CaseInfoList;  
    }
}