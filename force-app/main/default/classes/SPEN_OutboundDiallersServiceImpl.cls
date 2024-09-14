public with sharing class SPEN_OutboundDiallersServiceImpl {
	public void updateOutboundDiallerPriority(List<SPEN_ImpactedPremise__c> impactedPremiseList, Map<Id,SPEN_ImpactedPremise__c> impactedPremiseMap){
		
		Map<String, SPEN_OutboundDiallerConfig__mdt> priorityDetailMap = SPEN_OutboundDiallerConfig__mdt.getAll();
        group grp = [Select id from group where DeveloperName = 'Outbound_Dialer'];
		Boolean isInsert = impactedPremiseMap==null?true:false;
		List<SPEN_CustomerUpdate__c> outboundDiallerList = new List<SPEN_CustomerUpdate__c>();
		
		for(SPEN_ImpactedPremise__c impactedPremiseObj : impactedPremiseList){
			if(impactedPremiseObj.SPEN_PSRType__c!= null && impactedPremiseObj.SPEN_RelatedContact__c!= null && impactedPremiseObj.SPEN_Status__c!=null && impactedPremiseObj.SPEN_IncidentType__c!='' && (impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR') || impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('Other PSR'))){
				SPEN_CustomerUpdate__c odRec = new SPEN_CustomerUpdate__c();
				if(isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_INCETRChangeTimeFormula__c ==null && !impactedPremiseObj.SPEN_OutComfortHoursFormula__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						if(impactedPremiseObj.SPEN_isMerged__c && priorityDetailMap.get('A3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('A3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('A3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='A3';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('A4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A4';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('A2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A2';
						}
						else if(priorityDetailMap.get('A1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('A1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('A1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='A1'; 
						}
					}
					else {
						if(impactedPremiseObj.SPEN_isMerged__c && priorityDetailMap.get('D3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('D3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('D3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='D3';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('D4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D4';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('D2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D2';
						}
						else if(priorityDetailMap.get('D1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('D1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('D1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='D1'; 
						} 
					}
				}
				else if(isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_INCETRChangeTimeFormula__c !=null && !impactedPremiseObj.SPEN_OutComfortHoursFormula__c){
					if(!(impactedPremiseObj.SPEN_isMerged__c && impactedPremiseObj.SPEN_MergeDateTime__c > impactedPremiseObj.SPEN_INCETRChangeTimeFormula__c) && !(impactedPremiseObj.SPEN_isMerged__c && impactedPremiseObj.SPEN_MergeDateTime__c ==null)){
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('B4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='B4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('B2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='B2';
							}
							else if(priorityDetailMap.get('B1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('B1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('B1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='B1'; 
							}
						}
						else {
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('C4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='C4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('C2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='C2';
							}
							else if(priorityDetailMap.get('C1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('C1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('C1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='C1'; 
							}
						}
					}
					else {
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR') && priorityDetailMap.get('B3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('B3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('B3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='B3';
						}
						else if(priorityDetailMap.get('C3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('C3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('C3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='C3'; 
						}
					}
				}
				else if(isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_OutComfortHoursFormula__c){
					if(!(impactedPremiseObj.SPEN_isMerged__c)){
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('E4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='E4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('E2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='E2';
							}
							else if(priorityDetailMap.get('E1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('E1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('E1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='E1'; 
							}
						}
						else {
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('G4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='G4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('G2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='G2';
							}
							else if(priorityDetailMap.get('G1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('G1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('G1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='G1'; 
							}
						}
					}
					else {
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR') && priorityDetailMap.get('E3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('E3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('E3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='E3';
						}
						else if(priorityDetailMap.get('G3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('G3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('G3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='G3'; 
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Restored')){
					if(impactedPremiseObj.SPEN_IncidentType__c == ((SPEN_ImpactedPremise__c)impactedPremiseMap.get(impactedPremiseObj.Id)).SPEN_IncidentType__c){
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('F4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('F4').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c))){
								odRec.SPEN_Priority__c='F4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('F2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('F2').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c))){
								odRec.SPEN_Priority__c='F2';
							}
							else if(priorityDetailMap.get('F1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('F1').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c)) && ((priorityDetailMap.get('F1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('F1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='F1'; 
							}
						}
						else {
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('H4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('H4').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c))){
								odRec.SPEN_Priority__c='H4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('H2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('H2').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c))){
								odRec.SPEN_Priority__c='H2';
							}
							else if(priorityDetailMap.get('H1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('H1').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c)) && ((priorityDetailMap.get('H1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('H1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='H1'; 
							}
						}
					}
					else {
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR') && priorityDetailMap.get('F3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('F3').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c)) && ((priorityDetailMap.get('F3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('F3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='F3';
						}
						else if(priorityDetailMap.get('H3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && priorityDetailMap.get('H3').ApplicableINCStatus__c.contains(String.ValueOf(impactedPremiseObj.SPEN_INCStatusFormula__c)) && ((priorityDetailMap.get('H3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('H3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='H3'; 
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_INCETRChangeTimeFormula__c !=null && !impactedPremiseObj.SPEN_OutComfortHoursFormula__c){
					if(!(impactedPremiseObj.SPEN_isMerged__c && impactedPremiseObj.SPEN_MergeDateTime__c > impactedPremiseObj.SPEN_INCETRChangeTimeFormula__c) && !(impactedPremiseObj.SPEN_isMerged__c && impactedPremiseObj.SPEN_MergeDateTime__c ==null)){
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('B4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='B4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('B2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='B2';
							}
							else if(priorityDetailMap.get('B1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('B1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('B1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='B1'; 
							}
						}
						else {
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('C4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='C4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('C2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='C2';
							}
							else if(priorityDetailMap.get('C1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('C1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('C1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='C1'; 
							}
						}
					}
					else {
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR') && priorityDetailMap.get('B3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('B3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('B3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='B3';
						}
						else if(priorityDetailMap.get('C3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('C3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('C3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='C3'; 
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_OutComfortHoursFormula__c){
					if(impactedPremiseObj.SPEN_IncidentType__c== ((SPEN_ImpactedPremise__c)impactedPremiseMap.get(impactedPremiseObj.Id)).SPEN_IncidentType__c && !(impactedPremiseObj.SPEN_isMerged__c && impactedPremiseObj.SPEN_MergeDateTime__c >= impactedPremiseObj.SPEN_ETRChangeTime__c)){
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('E4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='E4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('E2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='E2';
							}
							else if(priorityDetailMap.get('E1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('E1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('E1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='E1'; 
							}
						}
						else {
							if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('G4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='G4';
							}
							else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('G2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
								odRec.SPEN_Priority__c='G2';
							}
							else if(priorityDetailMap.get('G1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('G1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('G1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
								odRec.SPEN_Priority__c='G1'; 
							}
						}
					}
					else {
						if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR') && priorityDetailMap.get('E3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('E3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('E3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='E3';
						}
						else if(priorityDetailMap.get('G3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('G3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('G3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='G3'; 
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_INCETRChangeTimeFormula__c ==null && !impactedPremiseObj.SPEN_OutComfortHoursFormula__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						
						if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('A4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A4';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('A2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A2';
						}
						else if(priorityDetailMap.get('A1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('A1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('A1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='A1'; 
						}
						else if(impactedPremiseObj.SPEN_isMerged__c && priorityDetailMap.get('A3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('A3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('A3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='A3';
						}
					}
					else {
						
						if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('D4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D4';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('D2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D2';
						}
						else if(priorityDetailMap.get('D1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('D1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('D1').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='D1'; 
						} 
						else if(impactedPremiseObj.SPEN_isMerged__c && priorityDetailMap.get('D3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && ((priorityDetailMap.get('D3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)) && impactedPremiseObj.SPEN_isCalledIn__c) || !priorityDetailMap.get('D3').ApplicableCalledInINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c)))){
							odRec.SPEN_Priority__c='D3';
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_IncidentType__c != ((SPEN_ImpactedPremise__c)impactedPremiseMap.get(impactedPremiseObj.Id)).SPEN_IncidentType__c && !impactedPremiseObj.SPEN_IsETRChange__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						if(priorityDetailMap.get('A3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A3';
						}
					}
					else {
						if(priorityDetailMap.get('D3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D3';
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_isMerged__c != ((SPEN_ImpactedPremise__c)impactedPremiseMap.get(impactedPremiseObj.Id)).SPEN_isMerged__c && !impactedPremiseObj.SPEN_IsETRChange__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						if(priorityDetailMap.get('A3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A3';
						}
					}
					else {
						if(priorityDetailMap.get('D3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D3';
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && !impactedPremiseObj.SPEN_IsETRChange__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('A4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A4';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('A2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A2';
						}
						else if(priorityDetailMap.get('A1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='A1'; 
						}
					}
					else {
						if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('D4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D4';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('D2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D2';
						}
						else if(priorityDetailMap.get('D1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='D1'; 
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_ResourceArrivalDate__c!= ((SPEN_ImpactedPremise__c)impactedPremiseMap.get(impactedPremiseObj.Id)).SPEN_ResourceArrivalDate__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						if(priorityDetailMap.get('I1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='I1'; 
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('I2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='I2';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('I3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='I3';
						}
					}
					else {
						if(priorityDetailMap.get('J1').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='J1'; 
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('J2').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='J2';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('J3').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='J3';
						}
					}
				}
				else if(!isInsert && (impactedPremiseObj.SPEN_Status__c).equalsIgnoreCase('Not Restored') && impactedPremiseObj.SPEN_Dispatched_Date__c!= ((SPEN_ImpactedPremise__c)impactedPremiseMap.get(impactedPremiseObj.Id)).SPEN_Dispatched_Date__c){
					if(impactedPremiseObj.SPEN_PSRType__c.equalsIgnoreCase('PSR')){
						if(priorityDetailMap.get('I4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='I4'; 
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('I5').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='I5';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('I6').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='I6';
						}
					}
					else {
						if(priorityDetailMap.get('J4').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='J4'; 
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithNoticeFormula__c && priorityDetailMap.get('J5').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='J5';
						}
						else if(impactedPremiseObj.SPEN_DroppedSupplyWithoutNoticeFormula__c && priorityDetailMap.get('J6').ApplicableINCType__c.contains(String.ValueOf(impactedPremiseObj.SPEN_IncidentType__c))){
							odRec.SPEN_Priority__c='J6';
						}
					}
				}
				else{
					continue;
				}

				if(priorityDetailMap.containsKey(odRec.SPEN_Priority__c) && priorityDetailMap.get(odRec.SPEN_Priority__c).IsActive__c){
					odRec.SPEN_Info__c = priorityDetailMap.get(odRec.SPEN_Priority__c).RuleName__c;
					odRec.SPEN_Type__c = priorityDetailMap.get(odRec.SPEN_Priority__c).Type__c;
					odRec.SPEN_Campaign__c = priorityDetailMap.get(odRec.SPEN_Priority__c).Campaign__c;
					odRec.SPEN_ContactId__c = impactedPremiseObj.SPEN_RelatedContact__c;
					odRec.SPEN_IncidentId__c = impactedPremiseObj.SPEN_RelatedIncident__c;
					odRec.SPEN_Impacted_Premise__c = impactedPremiseObj.Id;
					odRec.OwnerId=grp.Id;
					odRec.SPEN_ExternalId__c = String.valueOf(impactedPremiseObj.SPEN_RelatedIncident__c)+String.valueOf(odRec.SPEN_ContactId__c)+String.valueOf(odRec.SPEN_Campaign__c);
					outboundDiallerList.add(odRec);
				}
			}
		}
		if(!outboundDiallerList.isEmpty()){
			Upsert outboundDiallerList SPEN_ExternalId__c;
		}
	}
}