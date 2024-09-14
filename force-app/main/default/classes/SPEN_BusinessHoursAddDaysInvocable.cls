/* File Name: SPEN_BusineessHoursAddDaysInvocable 
 * Description: The given code is a global class named SPEN_BusineessHoursAddDaysInvocable get the PlannedEndDate for Job milestone 
 *              based on Lead time & delay.
 * Author: Rajat Kumar Mishra
 * Version: 1.0
 * History:
 * Date            Author                 Comment
 * Aug-31-2023     Rajat Kumar Mishra     Initial version
 *
 */
global class SPEN_BusinessHoursAddDaysInvocable {
    
    global class Request {
        @InvocableVariable(required = true)
        public String businessHourName;
        @InvocableVariable(required = true)
        public DateTime plannedStartDate;
        @InvocableVariable(required = true)
        public Integer leadTime;
        @InvocableVariable(required = true)
        public Integer delayStart;

    }   
    
    @InvocableMethod(label='Calculate Planned End date based on Planned Lead time and Delay' description='Returns the Planned End date')
    global static List<DateTime> addDays(List<Request> requests) {
        List<DateTime> responses = new List<DateTime>();
        if(!requests.isEmpty()) {
            List<BusinessHours> listBusinessHours = [SELECT Id FROM BusinessHours WHERE Name =: requests[0].businessHourName LIMIT 1];           
            DateTime result ;
            Integer addInitialDays = 0;
            if(requests[0].delayStart != null){
                addInitialDays += Integer.valueOf(requests[0].delayStart);
            }                  
            Integer addEndDateDays = addInitialDays+ Integer.valueOf(requests[0].leadTime);
            if(listBusinessHours != null && listBusinessHours.size() > 0){ 
                BusinessHours businessHourObj = listBusinessHours[0];
                DateTime plstartDate = requests[0].plannedStartDate;            
                DateTime endDate = SPEN_BusinessDaysCalculationUtil.addDays((Datetime) plstartDate, addEndDateDays,businessHourObj.Id );               
                result = Date.newInstance(endDate.year(), endDate.month(), endDate.day());
                responses.add(result); 
            }else{
                DateTime plstartDate = requests[0].plannedStartDate;
                result = plstartDate.addDays(addEndDateDays);
                responses.add(result); 
            }                            
        }
        return responses;    
    }

}