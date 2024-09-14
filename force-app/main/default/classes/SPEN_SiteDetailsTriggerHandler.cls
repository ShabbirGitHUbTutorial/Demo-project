public class SPEN_SiteDetailsTriggerHandler {
    
	public static void createQueryCase(List<SPEN_SiteDetails__c> siteDetailsRecords){
        Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
        List<Case> newQueryCases=new List<Case>();
        List<Id> nrswaCaseIds=new List<Id>();
        Map<Id,Case> nrswaCaseMap= new Map<Id,Case>();
        for(SPEN_SiteDetails__c sd:siteDetailsRecords){
            if(sd.SPEN_PowerOn_Additional_Coordinates__c==true){
                nrswaCaseIds.add(sd.SPEN_Case__c);
            }
        }
        if(!nrswaCaseIds.isEmpty()){
        	 nrswaCaseMap = new Map<Id,Case>([select id,SPEN_SPDSPMIndicator__c,SPEN_ConnectionDistrict__c from Case where id in: nrswaCaseIds]);
        }
        for(SPEN_SiteDetails__c sd:siteDetailsRecords){
            if(sd.SPEN_PowerOn_Additional_Coordinates__c==true){
                Case queryCase=new Case();
                queryCase.RecordTypeId = recordTypeIdQuery;
                queryCase.Status=CasesConstants.openStatus; //Open
                queryCase.ParentId=sd.SPEN_Case__c;
                queryCase.SPEN_Type__c=CasesConstants.nrswaType;
                queryCase.Origin=CasesConstants.poweronOrigin;
                queryCase.SPEN_ConnectionDistrict__c=nrswaCaseMap.get(sd.SPEN_Case__c).SPEN_ConnectionDistrict__c;
                queryCase.SPEN_SPDSPMIndicator__c=nrswaCaseMap.get(sd.SPEN_Case__c).SPEN_SPDSPMIndicator__c;
                queryCase.SPEN_QueryReason__c=CasesConstants.queryReason;
                newQueryCases.add(queryCase);
            }
        }
        if(!newQueryCases.isEmpty()){
            insert newQueryCases;
        }
    }
}