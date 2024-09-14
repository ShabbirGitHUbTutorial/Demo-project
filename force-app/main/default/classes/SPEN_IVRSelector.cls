/*------------------------------------------------------------------------------------
DESCRIPTION	:	Selector class of IVR Object
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
25.07.2023      shubhi V            created for remediation
------------------------------------------------------------------------------------*/
public with sharing class SPEN_IVRSelector {
        
    public static List<SPEN_IVR__c> getIvrSelector(List<String> externalIdSet){
        List<SPEN_IVR__c > lstIVR = new List<SPEN_IVR__c >();
        if(externalIdSet!=null && !externalIdSet.isEmpty()){
            lstIVR = [SELECT SPEN_CallGroup__c,SPEN_ExternalId__c FROM SPEN_IVR__c	
                WHERE SPEN_ExternalId__c IN:externalIdSet WITH SECURITY_ENFORCED];
        }
        return lstIVR;
    }
}