/* File Name: SPEN_BusinessHoursDaysBetweenInvocable 
 * Description: The given code is a global class named SPEN_BusinessHoursDaysBetweenInvocable to update the Design Change Lead Time Delay.
 * Author: tanaya.chanda
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Aug-30-2023     Tanaya Chanda      Initial version
 *
 */
global class SPEN_BusinessHoursDaysBetweenInvocable {
    global class Request {
        @InvocableVariable(required = true)
        global String businessHourName;
        @InvocableVariable(required = true)
        global DateTime startDate;
        @InvocableVariable(required = true)
        global DateTime endDate;

    }   
    
    @InvocableMethod(label='Calculate Lead Delay' description='Returns the lead delay based on business hours')
    global static List<Integer> daysBetween(List<Request> requests) {
        /* @calculateLeadDelay
         * requests : List of the input invocable variables passed from the flow.
         */
        List<Integer> responses = new List<Integer>();
        if(!requests.isEmpty()) {
            List<BusinessHours> listBusinessHours = [SELECT Id FROM BusinessHours WHERE Name =: requests[0].businessHourName LIMIT 1];           
            Integer result ;
            if(listBusinessHours != null && listBusinessHours.size() > 0){
                BusinessHours businessHourObj = listBusinessHours[0];
                system.debug('start'+requests[0].startDate);
                system.debug('end'+requests[0].endDate);
                for(Request req: requests){
                    result= SPEN_BusinessDaysCalculationUtil.daysBetween(businessHourObj.Id, requests[0].startDate, requests[0].endDate);       
                	responses.add(result);
                }
                //result= SPEN_BusinessDaysCalculationUtil.daysBetween(businessHourObj.Id, requests[0].startDate, requests[0].endDate);       
                //responses.add(result); 
            }                          
        }
        return responses;    
    }

}