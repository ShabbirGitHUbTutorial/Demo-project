public class SPEN_ActiveIncidentCheck {
    
    Public static void fetchIncidentRecValue(Set<Id> recId){
        ID IncidentID;
        String voicePrmiseExternalID;
        Map<string,List<VoiceCall>> returnMapRec = new Map<string,List<VoiceCall>>();
        Map<String,VoiceCall> premiseIdVsVoiceCallMap = new Map<String,VoiceCall>();
        Map<id,VoiceCall> vcIdVSVc = new Map<id,VoiceCall>();
        List<VoiceCall> voicecallRec = [Select id,SPEN_RelatedIncident__c,SPEN_VoicecallPremise__c,SPEN_VoicecallPremise__r.SPEN_PremiseID__c from VoiceCall where id IN: recId];
        system.debug('VoicecallRec**' + voicecallRec);
        List<VoiceCall> finalVoicecallRecList =  new List<VoiceCall>();
        List<SPEN_IntegrationRequest__c> intReqList =  new List<SPEN_IntegrationRequest__c>();
        Set<String> premiseExterIdSet = new Set<String>();
        for(VoiceCall vc : voicecallRec){
            if(vc.SPEN_VoicecallPremise__c != NULL){
                voicePrmiseExternalID = vc.SPEN_VoicecallPremise__r.SPEN_PremiseID__c;
                premiseIdVsVoiceCallMap.put(voicePrmiseExternalID,vc);
                premiseExterIdSet.add(voicePrmiseExternalID);
            }
            
        }
        if (premiseExterIdSet != null && premiseExterIdSet.size()>0)
        {
            List<SPEN_ImpactedPremise__c> ImpPremiseRec = [Select Id,SPEN_RelatedIncident__c,SPEN_PremiseId__c,SPEN_RelatedIncident__r.SPEN_IncidentStatus__c from SPEN_ImpactedPremise__c where SPEN_PremiseId__c IN: premiseExterIdSet ORDER BY SPEN_RelatedIncident__r.CreatedDate DESC];
            system.debug('ImpPremiseRec**' + ImpPremiseRec);
            
            for(SPEN_ImpactedPremise__c impPrm : ImpPremiseRec){
                VoiceCall vcRec =  new VoiceCall();
                if(impPrm.SPEN_RelatedIncident__c != NULL)
                {
                   if(!vcIdVSVc.containskey(premiseIdVsVoiceCallMap.get(impPrm.SPEN_PremiseId__c).id) && (impPrm.SPEN_RelatedIncident__r.SPEN_IncidentStatus__c == 'Awaiting' || impPrm.SPEN_RelatedIncident__r.SPEN_IncidentStatus__c == 'In Progress' ||
                     impPrm.SPEN_RelatedIncident__r.SPEN_IncidentStatus__c == 'On Site')){
                        if(premiseIdVsVoiceCallMap != null && premiseIdVsVoiceCallMap.containsKey(impPrm.SPEN_PremiseId__c)){
                            vcRec = premiseIdVsVoiceCallMap.get(impPrm.SPEN_PremiseId__c);
                            vcRec.SPEN_RelatedIncident__c = impPrm.SPEN_RelatedIncident__c;
                        }
                        finalVoicecallRecList.add(vcRec);
                         vcIdVSVc.put(vcRec.id,vcRec);
                    }
                }
                else{
                    if(premiseIdVsVoiceCallMap != null && premiseIdVsVoiceCallMap.containsKey(impPrm.SPEN_PremiseId__c)){
                        vcRec = premiseIdVsVoiceCallMap.get(impPrm.SPEN_PremiseId__c);
                    }
                    
                    SPEN_IntegrationRequest__c IntegrationRequestRecordCreation = new SPEN_IntegrationRequest__c();
                    IntegrationRequestRecordCreation.SPEN_Status__c = 'Processing';
                    IntegrationRequestRecordCreation.SPEN_Records__c = VoicePrmiseExternalID;
                    IntegrationRequestRecordCreation.SPEN_IntegrationRequestServiceClass__c = 'SPEN_ActiveIncidentGetPremiseService';
                    IntegrationRequestRecordCreation.SPEN_RelatedVoiceCall__c = vcRec.id;
                    intReqList.add(IntegrationRequestRecordCreation);
                    system.debug('intReqList**' + intReqList);              
                }
            }
            
        } 
        system.debug('finalVoicecallRecList**' + finalVoicecallRecList);
        if(finalVoicecallRecList != null && finalVoicecallRecList.size()>0){
            update finalVoicecallRecList;// 8331 Enh changes
        }
        if(intReqList != null && intReqList.size()>0){
            insert intReqList;// 8331 Enh changes
        }
    }
    
}