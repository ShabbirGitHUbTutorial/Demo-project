/* File Name: SPEN_RefreshSAPVendorInvocable
 * Description: This class will be called to sync Vendor Account Details from SAP
 * Author: Anwesha Dey
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * May-20-2024     Anwesha Dey    Initial version
 *
 */
public class SPEN_RefreshSAPVendorInvocable {    
    @AuraEnabled(cacheable=true)
    public static List<Account> getVendorAccount(Id land)
    {
        Integer thresholdInterval= Integer.valueOf(System.Label.SPEN_LnP_VendorAccountSyncInterval);
        Map<Id,Account> vendorToBeSync=new Map<Id,Account>();
        DateTime nextAccountSyncTime=DateTime.now().addMinutes(thresholdInterval*-1);

        List<SPEN_LandAssociation__c> landContacts= [SELECT Id, Name, SPEN_Vendor__c, SPEN_Vendor_Number__c,SPEN_Vendor__r.SPEN_AccountLastSynchronised__c 
                                                     FROM SPEN_LandAssociation__c WHERE SPEN_Active__c = true AND
                                                     (SPEN_Vendor__r.SPEN_AccountLastSynchronised__c<: nextAccountSyncTime OR SPEN_Vendor__r.SPEN_AccountLastSynchronised__c= null ) AND
                                                     SPEN_Land__c =: land AND RecordType.DeveloperName ='SPEN_SAPVendor'];
       
        for(SPEN_LandAssociation__c landCon:landContacts)
        {
            if(!vendorToBeSync.containsKey(landCon.SPEN_Vendor__c)){
                vendorToBeSync.put(landCon.SPEN_Vendor__c,new Account(id=landCon.SPEN_Vendor__c, SPEN_VendorNumber__c=landCon.SPEN_Vendor_Number__c));
            }
        }
        return vendorToBeSync.values();
    }
    
    @AuraEnabled
    public static void syncVendorRequest(List<Account> vendorAccount){
        try{
            List<Account> updateAccountList=new List<Account>();
            for(Account vendor:vendorAccount)
            {
                if(vendor.SPEN_VendorNumber__c != null){
                    HttpRequest reqStatus = new HttpRequest();           
                    reqStatus.setEndpoint(Label.SPEN_LnP_SAPCallout+'/provSalesforceSet?$expand=vendors&$format=json');
                    reqStatus.setMethod('GET');            
                    reqStatus.setHeader('origin', 'RESF');  
                    reqStatus.setHeader('vendor', vendor.SPEN_VendorNumber__c);                
                    Http httpStatus = new Http();
                    HTTPResponse resStatus = httpStatus.send(reqStatus);    
                    if(resStatus.getStatusCode() == 200){                                            	                
                        SPEN_SAPGetVendorResponse vResponse = (SPEN_SAPGetVendorResponse)JSON.deserialize(resStatus.getBody(), SPEN_SAPGetVendorResponse.class);                
                        if(vResponse != null){ 
                            List<SPEN_SAPGetVendorResponse.SPEN_SAPVendorsWrap> vwrapList = vResponse.d.results;
                            if(vwrapList != null && vwrapList.size() > 0){                               
                                for(SPEN_SAPGetVendorResponse.SPEN_SAPVendor vObj : vwrapList[0].vendors.results){                                  	
                                    vendor.Name = vObj.nombre;            
                                    vendor.SPEN_BusinessPartnerNumber__c = vObj.bussinessPartner;
                                    vendor.SPEN_PostalCode__c = vObj.codigoPostal;
                                    vendor.Phone = vObj.telefCom;
                                    vendor.SPEN_VendorEmail__c = vObj.mailCom ;                                                                
                                    vendor.SPEN_Street__c = vObj.calle;
                                    vendor.SPEN_Street2__c = vObj.calle2;
                                    vendor.SPEN_Street3__c = vObj.calle3;
                                    vendor.SPEN_City__c = vObj.ciudad;
                                    vendor.SPEN_State__c = vObj.region;
                                    vendor.SPEN_Country__c = vObj.pais;
                                    vendor.SPEN_VendorEmailPreference__c = vObj.mailPers;
                                    vendor.SPEN_PhonePreference__c = vObj.telefPers;
                                    vendor.SPEN_AccountLastSynchronised__c=System.now();
                                }
                                updateAccountList.add(vendor);
                            } 
                        }                      
                    }
                }            
            }
            update updateAccountList;
        }catch(exception e)
        {
            
        }
        
    }        
}