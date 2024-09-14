//Rest Resource for GetAffectedPremise
@RestResource(urlMapping='/GetAffectedPremise/*')
global with sharing class SPEN_GetAffectedPremiseResponseDetails {
    
    @HttpPost
    global static void affectedPremiseDetails()
    {	
       try{
        Integer size = integer.valueof(System.Label.SPEN_BatchSizeLabel);
       // SPEN_Premise__c affectedPremiseObjDetails = new SPEN_Premise__c();
        Map<String,String> premiseMap = new Map<String,String>();
        List<String> premNumberList = new List<String>();
        
        RestRequest req = RestContext.request;  
        RestResponse res = Restcontext.response;
        String prmsIdValue = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String rqstBody = req.requestBody.toString();
        //system.debug('-----rqstBodyStr-------'+rqstBody);
        SPEN_AffectedPremisesResponseWrapper.RequestBody affectedPremiseWrapper = (SPEN_AffectedPremisesResponseWrapper.RequestBody) System.JSON.deserialize(rqstBody, SPEN_AffectedPremisesResponseWrapper.RequestBody.class);
        system.debug('affectedPremiseWrapper: '+affectedPremiseWrapper);
        //String xrtNew = affectedPremiseWrapper.estimatedRestotationDate;
        String xrtNew = affectedPremiseWrapper.estimateRestorationDate;
        String incdntID = affectedPremiseWrapper.incidentId;
		
		//Added for code correction of Restored/Not Restored Count
		Integer chunkCount = Integer.valueOf(affectedPremiseWrapper.chunkCount); 				
		Integer currentChunk = Integer.valueOf(affectedPremiseWrapper.currentChunk);				
		//Added for code correction of Restored/Not Restored Count
		
        //system.debug('affectedPremiseWrapper incdntID: '+incdntID);
           //For CMDR-2170 Query - Field Resource ID, Resource arrival date, ETA, Incident lookup
           Incident incidentRec = [select id,SPEN_ResourceID__c,SPEN_isUpgrade__c,SPEN_IncidentID__c,SPEN_ResourceArrivalDate__c,SPEN_ETA__c,SPEN_EstimatedRestorationTime__c,SPEN_IncidentType__c,SPEN_DispatchedDate__c from Incident where SPEN_IncidentID__c = :incdntID limit 1];
        if(affectedPremiseWrapper!=null && !affectedPremiseWrapper.premiseEnergisationState.isEmpty())
        {
            for(SPEN_AffectedPremisesResponseWrapper.premiseEnergisationState premiseList : affectedPremiseWrapper.premiseEnergisationState)
            {
                premiseMap.put(premiseList.pn, premiseList.es);
                premNumberList.add(premiseList.pn);
            }
        }
        //system.debug('premNumberList ---->'+ premNumberList);
        //system.debug('premiseMap ---->'+ premiseMap);
       /* if(premNumberList!=null){
         affectedPremiseObjDetails  = [Select id from SPEN_Premise__c where SPEN_PremiseNumber__c =: premNumberList];   
        }
        //system.debug('affectedPremiseObjDetails ---->'+ affectedPremiseObjDetails);*/
		
		//Commented for code correction of Restored/Not Restored Count
        //SPEN_AffectedPremiseBatch impactedPremiseBatch = new SPEN_AffectedPremiseBatch(premiseMap,premNumberList,incidentRec,xrtNew);
		
		//Added for code correction of Restored/Not Restored Count
        SPEN_AffectedPremiseBatch impactedPremiseBatch = new SPEN_AffectedPremiseBatch(premiseMap,premNumberList,incidentRec,xrtNew,chunkCount,currentChunk);
    	Database.executeBatch(impactedPremiseBatch); 
        }catch(Exception ex){
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }  
}