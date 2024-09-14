/* File Name: SPEN_BusinessWorkingDayInvocable 
 * Description: The given code is a global class named SPEN_BusinessWorkingDayInvocable is used to find if providedDate is 
 * business working day based on business hours.
 * Author: Rajat Kumar Mishra
 * Version: 1.0
 * History:
 * Date            Author                 Comment
 * Sep-26-2023     Rajat Kumar Mishra     Initial version
 *
 */

global class SPEN_BusinessWorkingDayInvocable {
    
    global class Request {
        @InvocableVariable(required = true)
        global String businessHourName;
        @InvocableVariable(required = true)
        global DateTime providedDate;

    }   
    //private static List<boolean> boolList = new List<boolean>();
    @InvocableMethod(label='Business Working Day' description='Returns providedDate is business day based on business hours')
    global static List<Boolean> isBusinessDay(List<Request> requests) {
        /* @FindBusinessWorkingDay
         * requests : List of the input invocable variables passed from the flow.
         */
        List<Boolean> responses = new List<Boolean>();
        
        if(!requests.isEmpty()) {
            List<BusinessHours> listBusinessHours = [SELECT Id FROM BusinessHours WHERE Name =: requests[0].businessHourName LIMIT 1];           
            Boolean result ;
            if(listBusinessHours != null && listBusinessHours.size() > 0){
                BusinessHours businessHourObj = listBusinessHours[0];
                for(Request req: requests){
                    result= SPEN_BusinessDaysCalculationUtil.isBusinessDay(businessHourObj.Id, req.providedDate);       
                    responses.add(result); 
                }
                
            }                          
        }
        
      return responses;
    }

}