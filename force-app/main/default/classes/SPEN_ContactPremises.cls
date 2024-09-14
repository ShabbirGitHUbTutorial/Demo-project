public class SPEN_ContactPremises {

    public static Boolean checkForExistingConPremRecord(Id conId, Id premId){
        Boolean newConPremAllowed = true;
        List<SPEN_ContactPremise__c> conP = SPEN_ContactPremisesSelector.getCPIsConPresentInfo(conId,premId);
        if(conP.size()> 0){
            newConPremAllowed = false;
        }
        return newConPremAllowed;
       }
    public static Boolean checkForDoublePrimaryContact(Id premId, Boolean isPrimary){
        Boolean primaryContactAllowed = true;
        List<SPEN_ContactPremise__c> conPrem = SPEN_ContactPremisesSelector.getCPPrimaryConInfo(premId,isPrimary);
        if(conPrem.size()>0){
            primaryContactAllowed = false;
        }
        return primaryContactAllowed;
    }
     // 5199 Related change start
    public static Map<Id, String> checkifContactisTaggedWithPremise(Id contactId,Set<String> setOfRoles){
        return SPEN_ContactPremisesSelector.checkForExistingConPremRecord(contactId, setOfRoles);
    }
     // 5199 Related change end
}