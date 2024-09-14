public class SPEN_EntitlementSelector 
{
	public static List<Entitlement> getEntitlementRecordsFromAccount(Set<String> setAcctName)
    {
        List<Entitlement> lstEnt = new List<Entitlement>();
        if(!setAcctName.isEmpty())
            lstEnt =   [SELECT id,AccountId,account.name, Name,SlaProcessId 
                            FROM Entitlement
                            WHERE account.name IN: setAcctName];
        return lstEnt;
    }
}