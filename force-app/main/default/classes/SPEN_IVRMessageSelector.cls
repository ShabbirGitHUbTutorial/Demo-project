/*------------------------------------------------------------------------------------
DESCRIPTION	:	Selector class for SPEN_IVRMessage__c custom object
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
JAN-20-2023		Macjules Sevilla	Added feedback.
Jun-28-2013 	Shubhi V			Added new method getIVRMessageMap
------------------------------------------------------------------------------------*/
public inherited sharing class SPEN_IVRMessageSelector 
{
	// REVIEW POINT FROM MACJULES
	// Do not use name; Use the External ID value instead. Use the second method instead.
	public static SPEN_IVRMessage__c getRelatedIVRmsg(String name)
	{
		SPEN_IVRMessage__c ivrMsg=new SPEN_IVRMessage__c();
		if(name!= Null ){
			ivrMsg=[select id from SPEN_IVRMessage__c where Name= :name WITH SECURITY_ENFORCED];
				
		}
		return ivrMsg;     
	}

	// USAGE
	// Returns the SPEN_IVRMessage__c record matching the External Id field.
	// If the search is unable to find a match, a blank record is returned.
	public SPEN_IVRMessage__c selectByExternalId(String externalId)
	{
		List<SPEN_IVRMessage__c> r = new List<SPEN_IVRMessage__c>();

		if(String.isNotBlank(externalId))
		{
			r = [SELECT Id,SPEN_IVRMessage__c
				 FROM   SPEN_IVRMessage__c
				 WHERE  SPEN_ExternalId__c =: externalId
				 //WITH   SECURITY_ENFORCED //201
				 ];
		}

		return r.size() == 0 ? new SPEN_IVRMessage__c() : r[0];
	}
	//USAGE
    //Returns the list of  SPEN_IVRMessage__c record matching the id in Id List.
    //called from SPEN_ZoneConfigurationService
    public static Map<Id,SPEN_IVRMessage__c> getIVRMessageMap(List<Id> ivrMsgIdList){
        Map<Id,SPEN_IVRMessage__c> zoneIVRMesgMap=new Map<Id,SPEN_IVRMessage__c>();
        if(!ivrMsgIdList.isEmpty()){
            for(SPEN_IVRMessage__c imsg:[SELECT Id,Name,SPEN_IVRMessage__c 
                                        FROM SPEN_IVRMessage__c 
                                        WHERE Id IN:ivrMsgIdList 
                                        WITH SECURITY_ENFORCED]){
                zoneIVRMesgMap.put(imsg.Id,imsg);
            }
        }
        return zoneIVRMesgMap;
    }
}