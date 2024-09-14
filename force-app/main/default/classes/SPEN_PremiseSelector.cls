public class SPEN_PremiseSelector 
{
	public static SPEN_Premise__c getPremiseRecord(String premiseId)
    {
        SPEN_Premise__c premiseRecord = [SELECT Id, SPEN_PremiseID__c,SPEN_FlatNumber__c,SPEN_Zone__c,SPEN_PostCode__c,SPEN_BuildingNameNumber__c,SPEN_AccountNumberMPAN__c FROM SPEN_Premise__c WHERE SPEN_PremiseID__c =: premiseId WITH SECURITY_ENFORCED];
        return premiseRecord;
    }
    
    public static SPEN_Premise__c getPremiseIVRMessages(String premiseId)
    {
        SPEN_Premise__c premiseRecord = [select id, SPEN_Zone__c, SPEN_Zone__r.SPEN_BroadcastMessage__c, SPEN_Zone__r.SPEN_Parent__c, SPEN_Zone__r.SPEN_Parent__r.SPEN_BroadcastMessage__c,  SPEN_Zone__r.SPEN_Parent__r.SPEN_Parent__c ,SPEN_Zone__r.SPEN_Parent__r.SPEN_Parent__r.SPEN_BroadcastMessage__c from SPEN_Premise__c WHERE Id =: premiseId WITH SECURITY_ENFORCED];
        return premiseRecord;
    }
    
    public static List<SPEN_Premise__c> getPresmise(Set<Id> contactId){
        List<SPEN_Premise__c> sPremises = [select id, SPEN_PremiseId__c from SPEN_Premise__c where id in(select SPEN_Premise__c from contact where id=:contactId)];
        return sPremises;
    }
    
    public static SPEN_Premise__c getPremiseFromUniqueCustomerId(String customerId)
    {
        List<SPEN_Premise__c> results = new List<SPEN_Premise__c>();
        
        results = [
            SELECT Id,SPEN_PremiseId__c FROM SPEN_Premise__c 
            WHERE SPEN_PremiseId__c =: customerId 
            WITH SECURITY_ENFORCED
            LIMIT:(Limits.getLimitQueryRows()-Limits.getQueryRows())
        ];
        
        return results.size() == 0 ? new SPEN_Premise__c() : results[0];
    }   
    public static Map<Id,Integer> getPremiseEnergisedMPANCount(Set<Id> premIds)
    {
        List<SPEN_MPAN__c> mpanLst = new List<SPEN_MPAN__c>();
        Map<Id,Integer> premiseIdEnergisedMPANCount = new Map<Id,Integer>();
        List<SPEN_Premise__c> premRcdList = [select Id, (Select Id from MPAN__r where SPEN_ConnectionStatus__c = 'Energised') from SPEN_Premise__c where id in :premIds];
        
        for(SPEN_Premise__c premRcd: premRcdList)
        {
            mpanLst = premRcd.MPAN__r;
            premiseIdEnergisedMPANCount.put(premRcd.Id, mpanLst.size());
        }
        return premiseIdEnergisedMPANCount;
    }
    public static List<SPEN_MPAN__c> getPremiseForMPAN(Set<Id> premIds)
    {
        List<SPEN_MPAN__c> mpanLst = new List<SPEN_MPAN__c>();
        List<SPEN_Premise__c> premRcdList = [select Id, (Select Id from MPAN__r where SPEN_ConnectionStatus__c = 'Energised') from SPEN_Premise__c where id in :premIds];
        
        for(SPEN_Premise__c premRcd: premRcdList)
        {
            mpanLst = premRcd.MPAN__r;
        }
        return mpanLst;
    }
//CRMD-10729 - S 
     public static Map<Id,Id> getPremiseFromMPAN(Set<Id> mPANIds)
    {
        List<SPEN_MPAN__c> mpanLst = new List<SPEN_MPAN__c>();
        Map<Id,Id> mPANVsPremiseMap = new Map<Id,Id>();
        mpanLst = [select id,SPEN_Premise__c from SPEN_MPAN__c where id IN:mPANIds];
        for(SPEN_MPAN__c mPANrec: mpanLst)
        {
            mPANVsPremiseMap.put(mPANrec.Id, mPANrec.SPEN_Premise__c);
        }
        return mPANVsPremiseMap;
    } //CRMD-10729 - E
    public static Map<Id,SPEN_Premise__c> getcaseRelatedPremiseRecord(Set<Id> premIdset)
    {
        Map<Id,SPEN_Premise__c> premiseMap=new Map<Id,SPEN_Premise__c>();
        if(premIdset != null && !premIdset.isEmpty()){
        List<SPEN_Premise__c> premiseList = [SELECT Id, SPEN_PremiseID__c,SPEN_FlatNumber__c,SPEN_PlotNumber__c,SPEN_Zone__c,SPEN_PostCode__c,SPEN_BuildingNameNumber__c,SPEN_AccountNumberMPAN__c FROM SPEN_Premise__c WHERE Id IN : premIdset WITH SECURITY_ENFORCED];
            for(SPEN_Premise__c premise:premiseList){
                premiseMap.put(premise.Id,premise);
            }
    }
        return premiseMap;
    }
}