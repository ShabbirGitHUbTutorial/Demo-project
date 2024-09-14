/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the Account Queries.
LIBRARY     :   Salesforce Enterprise Library - Case Queries
VERSION     :   1.0

HISTORY     :
Date            Author               Comment
30/05/2023     Sumit Biswas         Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_AccountSelector 
{
    /**************************************************
    @Author: Sumit Biswas
    @Date: 30/05/23
    @purpose: Method to get contact customer details.
    ***************************************************/
    public static List<Account> getPartnerAccount(String accountName)
    {
        List<Account> accountList = new List<Account>();
        
        try{
            if(String.isNotBlank(accountName)){
                accountList = [SELECT Id FROM 
                       Account where 
                       Name =: accountName AND 
                       SPEN_Status__c = 'Active' AND 
                       RecordType.DeveloperName = 'SPEN_Partner' AND
                       SPEN_PartnerType__c = 'Referrals'
                       LIMIT 1];
            }
        }catch(Exception e){
            SEL_LoggingService.log(e);
        }
        
        return accountList;
    }
    /**************************************************
    @Author: Shubhi Vijayvergia
    @Date: 30/08/23
    @purpose: Method to get street contactor accounts.
    ***************************************************/
    public static Account getStreetWorkContractor(String accountName)
    {
        Account acc = new Account();
        
        try{
            if(String.isNotBlank(accountName) ){
                acc = [SELECT Id,name,SPEN_Streetworks_Contractor__c FROM 
                       Account where 
                       Name =: accountName AND 
                       SPEN_Streetworks_Contractor__c=true
                       LIMIT 1];
            }
        }catch(Exception e){
            SEL_LoggingService.log(e);
        }
        
        return acc;
    }
    /**************************************************
    @Author: Shubhi Vijayvergia
    @Date: 30/08/23
    @purpose: Method to get NRSWA contactor accounts.
    ***************************************************/
    public static Account getNRSWAContractor(String accountName)
    {
        Account acc = new Account();
        
        try{
            if(String.isNotBlank(accountName)){
                acc = [SELECT Id,name,SPEN_Streetworks_Contractor__c FROM 
                       Account where 
                       Name =: accountName AND 
                       SPEN_NRSWA_Contractor__c=true
                       LIMIT 1];
            }
        }catch(Exception e){
            SEL_LoggingService.log(e);
        }
        
        return acc;
    }
    
    

}