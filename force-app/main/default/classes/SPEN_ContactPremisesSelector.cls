/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the SPEN_ContactPremise__c Queries.
LIBRARY     :   Salesforce Enterprise Library - SPEN_ContactPremise__c Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
OCT-31-2022     Smita Raikar        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_ContactPremisesSelector {
	/**************************************************
	   @Author: Smita Raikar
	   @Date: 31/10/22
	   @purpose: Method to get contact premise details.
	   ***************************************************/
        public static List<SPEN_ContactPremise__c> getPremiseContactInfo(Case caseRecord){
            List<SPEN_ContactPremise__c> conPremiseInfo = new List<SPEN_ContactPremise__c>();
            if(caseRecord != null){
                conPremiseInfo = [SELECT  Id,Name,SPEN_Premise__c,SPEN_RelatedContact__c,SPEN_RelationshipWithPremise__c,SPEN_Role__c,SPEN_Premise__r.SPEN_BuildingNameNumber__c
                                  FROM SPEN_ContactPremise__c
                                  WHERE SPEN_Premise__r.SPEN_PostCode__c=:caseRecord.SPEN_PostcodeW2C__c  AND
                                  (SPEN_Premise__r.SPEN_BuildingNameNumber__c =: caseRecord.SPEN_BuildingNumberW2C__c OR
                                   SPEN_Premise__r.SPEN_BuildingNameNumber__c =: caseRecord.SPEN_BuildingNameW2C__c OR 
                                   SPEN_Premise__r.SPEN_BuildingNameNumber__c =: caseRecord.SPEN_BuildingNameNumberW2C__c OR
                                  SPEN_Premise__r.SPEN_FlatNumber__c=:caseRecord.SPEN_FlatNumberW2C__c)
                                ];
               
            }
            return conPremiseInfo;     
        }
	   public static Map<String,String> getPremiseForContact(Set<Id> conIds)
	   {
		   Map<String,String> contactPremiseMap = new Map<String,String>();
		   for(SPEN_ContactPremise__c contactPremiseObj : [SELECT Id,Name,SPEN_Premise__r.SPEN_PremiseID__c,SPEN_RelatedContact__r.SPEN_CustomerID__c,SPEN_Premise__c,SPEN_RelatedContact__c,SPEN_RelationshipWithPremise__c FROM SPEN_ContactPremise__c WHERE SPEN_RelatedContact__c =:conIds]){
			   If(contactPremiseObj.SPEN_Premise__r.SPEN_PremiseID__c == contactPremiseObj.SPEN_RelatedContact__r.SPEN_CustomerID__c){
				   contactPremiseMap.put(contactPremiseObj.SPEN_RelatedContact__c,contactPremiseObj.SPEN_Premise__c);
			   }
															   
		   }
		   return contactPremiseMap;
	   }
	   public static List<SPEN_ContactPremise__c> getCPIsConPresentInfo(Id conId, Id premId){
		List<SPEN_ContactPremise__c> returnList = new List<SPEN_ContactPremise__c>();
			List<SPEN_ContactPremise__c> conP = [SELECT Id, SPEN_RelatedContact__c, SPEN_Premise__c, SPEN_PremisePrimaryContact__c FROM SPEN_ContactPremise__c WHERE SPEN_Premise__c=:premId AND SPEN_RelatedContact__c=:conId];
			if(conP.size()>0){
				returnList = conP;
			}
			return returnList;
		}
	   public static List<SPEN_ContactPremise__c> getCPPrimaryConInfo(Id premId, Boolean isPrimary){
		List<SPEN_ContactPremise__c> returnList = new List<SPEN_ContactPremise__c>();
			List<SPEN_ContactPremise__c> conPrem = [SELECT Id, SPEN_RelatedContact__c, SPEN_Premise__c, SPEN_PremisePrimaryContact__c FROM SPEN_ContactPremise__c WHERE SPEN_Premise__c=:premId AND SPEN_PremisePrimaryContact__c=:isPrimary];       
			if(conPrem.size()>0){
				returnList = conPrem;
			}
			return returnList;
	   }
    public static List<SPEN_ContactPremise__c> getConPremise(Id contactId){
        List<SPEN_ContactPremise__c> getConPremiseRecords;
            getConPremiseRecords =[SELECT Id,SPEN_Premise__c,SPEN_Premise__r.SPEN_PremiseId__c,SPEN_RelatedContact__c
                               		  FROM SPEN_ContactPremise__c
                                      WHERE SPEN_RelatedContact__c =: contactId
                              		  WITH SECURITY_ENFORCED];
           return getConPremiseRecords;
    }
    
    public static List<SPEN_ContactPremise__c> getContactPremises(Set<Id> premiseIds)
    {
        return [Select Id,SPEN_RelatedContact__c
               FROM SPEN_ContactPremise__c
               WHERE SPEN_Premise__c IN: premiseIds
               WITH SECURITY_ENFORCED];
    }
    public List<SPEN_ContactPremise__c> selectByCustomerContactExternalId(Set<String> conUniqueIds)
	{
		return [Select Id
               FROM SPEN_ContactPremise__c
               WHERE SPEN_RelatedContact__c IN: conUniqueIds
               WITH SECURITY_ENFORCED];
	}
	public List<SPEN_ContactPremise__c> getCPRecordsAfterInsert(Set<Id> setCPIds)
	{// 5199 Related changes: Added required field 
		return [SELECT id,SPEN_RelatedContact__c, SPEN_RelatedContact__r.recordtype.developername,
				SPEN_Premise__r.SPEN_PremiseID__c, SPEN_Role__c,SPEN_RelatedContact__r.SPEN_CustomerID__c,SPEN_RelatedContact__r.SPEN_RequireSynctoADQM__c,
                SPEN_RelatedContact__r.SPEN_ContactRole__c
				FROM SPEN_ContactPremise__c
				WHERE id IN: setCPIds];
	}
	public static Map<Id,Id> checkPremiseForContact(Set<Id> conIds)
    {
        Map<Id,Id> conIdPremieIdMap = new Map<Id,Id>();
        for(SPEN_ContactPremise__c cpRec : [Select SPEN_RelatedContact__c,SPEN_Premise__c
                                           FROM SPEN_ContactPremise__c
                                           WHERE SPEN_RelatedContact__c IN: conIds])
        {
            conIdPremieIdMap.put(cpRec.SPEN_RelatedContact__c,cpRec.SPEN_Premise__c);
        }
        return conIdPremieIdMap;
    }
  // 5199 Related change start
    public static Map<Id, String> checkForExistingConPremRecord(Id contactId,Set<String> setOfContactRoles){
        Set<String> setOfRoles = new Set<String>();
        if(!setOfContactRoles.isEmpty()){
            setOfRoles = setOfContactRoles;
        }else{
            setOfRoles = new Set<String>{'Customer', 'Alternative Contact', 'PSR Contact', 'PSR Contact (Alternative)', 'Premise Owner'};
        }
        
        Map<Id, String> mapOfContactTaggedWithOthers = new Map<Id, String>();

		List<SPEN_ContactPremise__c> returnList = new List<SPEN_ContactPremise__c>();
        try{
            returnList = [SELECT Id, SPEN_RelatedContact__c, SPEN_Premise__c, SPEN_Premise__r.Name, SPEN_Role__c FROM SPEN_ContactPremise__c  WHERE  SPEN_RelatedContact__c = :contactId and SPEN_Premise__c != null and SPEN_Role__c IN :setOfRoles LIMIT 1];
            if(!returnList.isEmpty() && returnList[0].SPEN_Premise__c !=null){
                String finalMessage = returnList[0].SPEN_Role__c +'ConnectedWith'+returnList[0].SPEN_Premise__r.Name;
                mapOfContactTaggedWithOthers.put(contactId, finalMessage);
            }
        }Catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
        return mapOfContactTaggedWithOthers;
	}
    // 5199 Related change end
    /***********************************************************
    @Author: Shubhi Vijayvergia
    @Date: 11/22/2023
    @purpose: Method for SPEN_ImpactedPremise
    ***************************************************************/ 
    public static List<SPEN_ContactPremise__c> getConPremiseRecordsFromPremiseIds(Set<String> premiseIds){
        List<SPEN_ContactPremise__c> getConPremiseRecords = new List<SPEN_ContactPremise__c>();
        if(!premiseIds.isEmpty())
        {
            getConPremiseRecords = [Select Id,SPEN_Premise__c,
                                    SPEN_Premise__r.SPEN_PremiseId__c,SPEN_RelatedContact__c,
                                    SPEN_RelatedContact__r.SPEN_SpecificVulnerability__c,
                                    SPEN_RelatedContact__r.SPEN_PSR__c
                                    FROM SPEN_ContactPremise__c
                                    WHERE SPEN_Premise__r.SPEN_PremiseId__c IN:premiseIds 
                                    AND SPEN_Role__c = 'Customer'];
        }
        return getConPremiseRecords;
    }
}