/***************************************************************************
* @Author:      Shubhi
* @Date:        30/08/2023
* @UserStory:   CRMD-7688
* @Description: Selector class for SPEN_Employee object
*****************************************************************************/
public class SPEN_EmployeeSelector {
    
    public static List<SPEN_Employee__c> getEmployeeFromEmail(List<String> requestorEmail){
        List<SPEN_Employee__c> emp=new List<SPEN_Employee__c>();
        try{	
            If(!requestorEmail.isEmpty()){
                emp=[SELECT id,SPEN_EmailAddress__c FROM SPEN_Employee__c 
                 WHERE SPEN_EmailAddress__c IN: requestorEmail ];
            }
        }catch(Exception e){
            SEL_LoggingService.log(e);
        }
        return emp ;  
    }
}