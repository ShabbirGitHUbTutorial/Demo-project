public class SPEN_SupplierDetailsSelector 
{
	public static SPEN_SupplierDetails__c getSupplierDetailsRecord(String suppMpidValue)
    {
         List<SPEN_SupplierDetails__c> supplierDetailsRecords = new List<SPEN_SupplierDetails__c>();
        if(String.isNotBlank(suppMpidValue))
        	 supplierDetailsRecords = [Select Name,SPEN_SupplierPhoneNumber__c from SPEN_SupplierDetails__c 
                                                         where SPEN_SupplierMPID__c =:suppMpidValue 
                                                         WITH SECURITY_ENFORCED];
         return supplierDetailsRecords!=null && !supplierDetailsRecords.isEmpty()?supplierDetailsRecords[0]:new SPEN_SupplierDetails__c(); //updated for incident INC3319046
    }
}