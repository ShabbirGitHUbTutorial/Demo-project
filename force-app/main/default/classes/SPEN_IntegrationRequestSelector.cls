public without sharing class SPEN_IntegrationRequestSelector 
{
	public static SPEN_IntegrationRequest__c getIntegrationRequestRecord(Id intReqId)
    {
        SPEN_IntegrationRequest__c intReqRecord;
        if(intReqId != null)
        	intReqRecord = [SELECT Id, SPEN_Records__c,SPEN_Status__c, SPEN_Response__c, SPEN_Result__c FROM SPEN_IntegrationRequest__c WHERE Id =: intReqId WITH SECURITY_ENFORCED];
        return intReqRecord;
    }
    public static SPEN_IntegrationRequest__c getIntegrationRequestRecordByContact(Id conId)
    {
        SPEN_IntegrationRequest__c intReqRecord;
        if(conId != null)
        	intReqRecord = [SELECT Id, SPEN_Records__c,SPEN_Status__c, SPEN_Response__c, SPEN_Result__c,SPEN_RelatedRecord__c,SPEN_RequestedBy__c FROM SPEN_IntegrationRequest__c WHERE SPEN_RelatedRecord__c =: conId Order By CreatedDate DESC LIMIT 1 ];
        return intReqRecord;
    }
	public static void geIntegrationRequestZoneRecord(Map<Id,SPEN_Zone__c> zoneMap, Datetime threshHold){
        List<SPEN_IntegrationRequest__c> intReqList = new List<SPEN_IntegrationRequest__c>();
      if(!zoneMap.isEmpty() && threshHold != null){
          for(SPEN_IntegrationRequest__c intRequest : [SELECT Id,SPEN_Response__c,SPEN_RelatedRecord__c
                                                      FROM SPEN_IntegrationRequest__c
                                                      WHERE SPEN_RelatedRecord__c =: zoneMap.keySet()
                                                   AND CreatedDate >=: threshHold]){

              intRequest.SPEN_Response__c = zoneMap.get(intRequest.SPEN_RelatedRecord__c).SPEN_BroadcastMessage__c;
              intReqList.add(intRequest);
          }
          if(!intReqList.isEmpty() && Schema.sObjectType.SPEN_IntegrationRequest__c.isUpdateable()){
              update intReqList;
          }
      }
  }

    
    public static List<SPEN_IntegrationRequest__c> geIntegrationRequestMapRecord(Datetime threshHold){
        List<SPEN_IntegrationRequest__c> intRequestMap;
        if(threshHold != null)
        	intRequestMap =[SELECT Id,SPEN_Response__c,SPEN_RelatedRecord__c
                                                        FROM SPEN_IntegrationRequest__c
                                                        WHERE CreatedDate >=: threshHold
                                                   ];
        return intRequestMap;
    }
}