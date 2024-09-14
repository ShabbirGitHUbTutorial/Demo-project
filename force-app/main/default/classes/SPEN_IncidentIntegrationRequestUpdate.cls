public without sharing class SPEN_IncidentIntegrationRequestUpdate {
    public static void afterIncidentIVRMessageAPIUpdate(Map<Id,Incident> selectedIncidentIds,String Incident_ConfigSetting)
    {
        
        Map<String,SPEN_ConfigurableSettings__c> configSetMap = new Map<String,SPEN_ConfigurableSettings__c>();
        configSetMap = SPEN_CaseSelector.configSettingsMap;
        
        Integer threshold = Integer.valueOf(configSetMap.get(Incident_ConfigSetting).SPEN_Value__c);
        Datetime dateThreshold = system.now().addHours(-threshold);
        List<SPEN_IntegrationRequest__c> intReqList = new List<SPEN_IntegrationRequest__c>();
        if(!selectedIncidentIds.isEmpty())
        {
            for(SPEN_IntegrationRequest__c intRequest : geIntegrationRequestIncident(selectedIncidentIds.keySet(), dateThreshold))
            {
                intRequest.SPEN_Response__c = selectedIncidentIds.get(intRequest.SPEN_RelatedRecord__c).SPEN_IVRMessage__c;
                intReqList.add(intRequest);
            }
        }
        
        if(!intReqList.isEmpty())
        {
            update intReqList;
        }
    }
    public static List<SPEN_IntegrationRequest__c> geIntegrationRequestIncident(set<Id> relatedRecordsId, Datetime threshHold){
        List<SPEN_IntegrationRequest__c> intRequestZone;
        if(relatedRecordsId != null && threshHold != null)
        	intRequestZone =[SELECT Id,SPEN_Response__c,SPEN_RelatedRecord__c
                                                        FROM SPEN_IntegrationRequest__c
                                                        WHERE SPEN_RelatedRecord__c =: relatedRecordsId
                                                        AND CreatedDate >=: threshHold
                                                   ];
        /*System.debug('=====intRequestZone'+intRequestZone);
        System.debug('=====zoneId'+relatedRecordsId);
        System.debug('=====threshHold'+threshHold);*/
        return intRequestZone;
    }
}